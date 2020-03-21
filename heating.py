
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
from bottle import run, post, error, route, install, request, response, template, HTTPResponse

## Set global vars
my_cwd = os.path.dirname(os.path.realpath(__file__))
config = json.loads(open("%s/config.json" % (my_cwd)).read())
config['db']['db'] = "%s/%s" % ( my_cwd, config['db']['db'])
__builtins__.my_cwd = my_cwd
__builtins__.config = config

## Setup logging
config['logspecs']['level'] = getattr(log, config['logspecs']['level'], 'INFO')
logger = Logger(config['logdir'], termSpecs=None, fileSpecs=config['logspecs'])
## Error log
elog = logger.addFileLogger({'filename': "%s/heatingpi-error.log" % (config['logdir']), 'level' : logging.DEBUG})
db.log = elog
functions.log = elog
atq.log = elog

db.connect(config['db']['db'])
print(config)
