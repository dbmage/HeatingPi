#!/usr/bin/python3
import os
import db
import sys
import json
import requests
import at as atq
import logging as log
import RPi.GPIO as GPIO
from functions import *
from lazylog import Logger
from base64 import b64encode, b64decode
from bottle import route, run
## Set global vars
my_cwd = os.path.dirname(os.path.realpath(__file__))
config = json.loads(open("%s/config.json" % (my_cwd)).read())
config['db']['db'] = "%s/%s" % ( my_cwd, config['db']['db'])
__builtins__.my_cwd = my_cwd
__builtins__.config = config
## Setup logging
config['logspecs']['level'] = getattr(log, config['logspecs']['level'], 'INFO')
Logger.init(config['logdir'], termSpecs=None, fileSpecs=config['logspecs'])

db.connect(config['db']['db'])
## TODO Need to lookup how I did this in STRIP
#functions.log =
print(config)
