#!/usr/bin/python3
import os
import db
import sys
import json
import globals
import requests
import at as atq
import RPi.GPIO as GPIO
from functions import *
from base64 import b64encode, b64decode
from bottle import route, run

config['db']['db'] = "%s/%s" % ( my_cwd, config['db']['db'])
db.connect(config['db']['db'])
print(config)
