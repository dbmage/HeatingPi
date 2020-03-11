#!/usr/bin/python3
import os
import db
import sys
import json
import requests
import at as atq
import RPi.GPIO as GPIO
from functions import *
from base64 import b64encode, b64decode
from bottle import route, run
my_cwd = os.path.dirname(os.path.realpath(__file__))
config = json.loads(open("%s/config.json" % (my_cwd)).read())
config['db']['db'] = "%s/%s" % ( my_cwd, config['db']['db'])
__builtins__.my_cwd = my_cwd
__builtins__.config = config
db.connect(config['db']['db'])
print(config)
