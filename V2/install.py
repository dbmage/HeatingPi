#!/usr/bin/python3
import os
import pwd
import json
import getpass
import requests
from sys import exit
from grp import getgrnam
from pwd import getpwnam
from base64 import b64encode
from distutils.dir_util import copy_tree

my_cwd = os.path.dirname(os.path.realpath(__file__))
newlocation = '/usr/local/bin/HeatingPi/'
curuser = getpass.getuser()
fowner = getpwnam('heatingpi').pw_uid
fgroup = getgrnam('www-data').gr_gid
passwd = ''
def print_progress(message, type=None):
    colours = {
        'ok' : '\x1b[1;32m',
        'warn' : '\x1b[1;33m',
        'failed' : '\x1b[1;31m'
    }
    if type == 'start':
        print("\033[1;35;40m%-40s\x1b[0m" % (message), end='')
        return
    if type == 'end' and message.lower() in colours:
        print("[%s%s\x1b[0m]" % (colours[message.lower()], message.center(6)))
        return
    if type.lower() in colours:
        print("%s%-40s\x1b[0m" % (colours[type.lower()], message))
        return
    print(message)

while passwd == '':
    print_progress("Please choose the admin password", type='warn')
    a = getpass.getpass("Password: ")
    b = getpass.getpass("Confirm: ")
    if a == b:
        passwd = b64encode(passwd.encode())

print_progress("Password", type='start')
try:
    config = open("%s/config/config.json" % (my_cwd)).read()
    config = config.replace('CHANGEME', passwd.decode('utf-8'))
    myfh = open("%s/config/config.json" % (my_cwd), 'w')
    myfh.write(config)
    myfh.close()
except:
    print_progress("Failed", type='end')
    print("Unableto set password, check permissions of %s" % (newlocation))
    sys.exit(1)
print_progress("OK", type='end')
print_progress("Logfiles", type='start')
config = json.loads(config)
try:
    for thing in config['logspecs']:
        lfile = "%s%s" % (config['logdir'], config['logspecs'][thing]['filename'])
        lfh = open(lfile, 'w')
        lfh.write('')
        lfh.close()
        os.chown(lfile, fowner, fgroup)
        os.chmod(lfile, 0o750)
except:
    print_progress("Failed", type='end')
    print("Error creating %s%s", (config['logdir'], config['logspecs'][thing]['filename']))
    sys.exit(1)
print_progress("OK", type='end')
print_progress("Install", type='start')
if not os.path.isdir(newlocation):
    try:
        os.mkdir(newlocation)
    except OSError:
        print_progress("Failed", type='end')
        print("Creation of the directory %s failed." % (newlocation))
        print("Please create the directory and ensure the current user %s owns it" % (curuser))
        exit(1)
try:
    copy_tree("%s" % (my_cwd), newlocation)
    for file in [ 'install.sh', 'install.py', 'install.log', 'Package.list']:
        os.remove("%s%s" % (newlocation, file))
    for root, dirs, files in os.walk(newlocation):
        for thing in dirs:
            os.chown(os.path.join(root, thing), fowner, fgroup)
            os.chmod(os.path.join(root, thing), 0o750)
        for thing in files:
            os.chown(os.path.join(root, thing), fowner, fgroup)
            os.chmod(os.path.join(root, thing), 0o750)
except Exception as e:
    print_progress("Failed", type='end')
    print("Failed to move project to %s." % (newlocation))
    print("Please check the permissions of the folder")
    print("Error: %s" % (e))
    exit(1)
print_progress("OK", type='end')
print_progress("Testing installation", type='start')
try:
    for i in range(5):
        requests.get('http://127.0.0.1/api/test', timeout=2)
except:
    print_progress("Failed", type='end')
    print("Install failed, backend not running!")
    sys.exit(1)
print_progress("OK", type='end')
print("Installed to %s!" % (newlocation))
