#!/usr/bin/python3
import os
import pwd
import sys
import getpass
import subprocess

newlocation = '/usr/local/bin/HeatingPi'
curuser = getpass.getuser()
if ! os.path.isdir(newlocation):
    try:
        os.mkdir(newlocation)
    except OSError:
        print("Creation of the directory %s failed." % (newlocation))
        print("Please create the directory and ensure the current user %s owns it" % (curuser))
        sys.exit(1)
    if pwd.getpwuid(os.stat(newlocation).st_uid)[0] != curuser:
        print("%s exists, but is not owned by you (%s), please ensure you own %s" % (newlocation, curuser, newlocation))
        sys.exit(1)
filecopy = subprocess.Popen(['cp', '*', newlocation],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT)
output,errors = filecopy.communicate()
if errors:
    print("Failed to move project to %s." % (newlocation))
    print("Please check the permissions of the folder")
