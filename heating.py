#!/usr/bin/python3
import os
import sys
import json
import requests
import RPi.GPIO as GPIO
from base64 import b64encode, b64decode
from bottle import route, run
global my_cwd = os.path.dirname(os.path.realpath(__file__))
sys.path.append(my_cwd)
import db
import at as atq
from functions import *

global config = json.loads(open("%s/config.json" % (my_cwd)).read())
print(config)
