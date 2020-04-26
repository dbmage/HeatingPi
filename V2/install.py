#!/usr/bin/python3
import os
import pwd
import getpass
from sys import exit
from distutils.dir_util import copy_tree

newlocation = '/usr/local/bin/HeatingPi/V2'
curuser = getpass.getuser()
if not os.path.isdir(newlocation):
    try:
        os.mkdir(newlocation)
    except OSError:
        print("Creation of the directory %s failed." % (newlocation))
        print("Please create the directory and ensure the current user %s owns it" % (curuser))
        exit(1)
try:
    copy_tree(os.path.dirname(os.path.realpath(__file__)), newlocation)
    print("Installed to %s!" % (newlocation))
except Exception as e:
    print("Failed to move project to %s." % (newlocation))
    print("Please check the permissions of the folder")
    print("Error: %s" % (e))
    exit(1)
