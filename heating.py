#!/usr/bin/python3
import os
import sys
import json
import requests
import RPi.GPIO as GPIO
from base64 import b64encode, b64decode
from bottle import route, run
my_cwd = os.path.dirname(os.path.realpath(__file__))
import db
import at as atq
from functions import *

config = json.loads(open("%s/config.json" % (my_cwd)).read())
config['db']['db'] = "%s/%s" % ( my_cwd, config['db']['db'])
db.connect(config['db']['db'])
print(config)
