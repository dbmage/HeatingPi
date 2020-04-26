#!/usr/bin/python3
import os
import pwd
import getpass
from sys import exit
from grp import getgrnam
from pwd import getpwnam
from distutils.dir_util import copy_tree

newlocation = '/usr/local/bin/HeatingPi/'
curuser = getpass.getuser()
if not os.path.isdir(newlocation):
    try:
        os.mkdir(newlocation)
    except OSError:
        print("Creation of the directory %s failed." % (newlocation))
        print("Please create the directory and ensure the current user %s owns it" % (curuser))
        exit(1)
try:
    copy_tree("%s" % (os.path.dirname(os.path.realpath(__file__))), newlocation)
    for file in [ 'install.sh', 'install.py', 'install.log', 'Package.list']:
        os.remove("%s%s" % (newlocation, file))
    fowner = getpwnam('heatingpi').pw_uid
    fgroup = getgrnam('www-data').gr_gid
    for root, dirs, files in os.walk(newlocation):
        for thing in dirs:
            os.chown(os.path.join(root, thing), fowner, fgroup)
            os.chmod(os.path.join(root, thing), 0o750)
        for thing in files:
            os.chown(os.path.join(root, thing), fowner, fgroup)
            os.chmod(os.path.join(root, thing), 0o750)
    print("Installed to %s!" % (newlocation))
except Exception as e:
    print("Failed to move project to %s." % (newlocation))
    print("Please check the permissions of the folder")
    print("Error: %s" % (e))
    exit(1)
