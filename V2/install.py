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
while passwd == '':
    print("Please choose the admin password")
    a = getpass.getpass("Password: ")
    b = getpass.getpass("Confirm: ")
    if a == b:
        passwd = b64encode(passwd.encode())

config = open("%s/config/config.json" % (my_cwd)).read()
config = config.replace('CHANGEME', passwd.decode('utf-8'))
myfh = open("%s/config/config.json" % (my_cwd), 'w')
myfh.write(config)
myfh.close()
print("Password set")
config = json.loads(config)
for thing in config['logspecs']:
    lfile = "%s%s" % (config['logdir'], config['logspecs'][thing]['filename'])
    lfh = open(lfile, 'w')
    lfh.write('')
    lfh.close()
    os.chown(lfile, fowner, fgroup)
    os.chmod(lfile, 0o750)

if not os.path.isdir(newlocation):
    try:
        os.mkdir(newlocation)
    except OSError:
        print("Creation of the directory %s failed." % (newlocation))
        print("Please create the directory and ensure the current user %s owns it" % (curuser))
        exit(1)
try:
    print("Installing....")
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
    print("Installed, testing installation....")
    try:
        for i in range(5):
            requests.get('http://127.0.0.1/api/test')
    except:
        print("Install failed, backend not running!")
        sys.exit(1)
    print("Installed to %s!" % (newlocation))
except Exception as e:
    print("Failed to move project to %s." % (newlocation))
    print("Please check the permissions of the folder")
    print("Error: %s" % (e))
    exit(1)
