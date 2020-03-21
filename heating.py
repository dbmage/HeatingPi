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
## Access log
alog = logger.addFileLogger({'filename': "%s/heatingpi-access.log" % (config['logdir']), 'level' : logging.INFO})
db.log = elog
functions.log = elog
atq.log = elog
## Logging rquests
def log_to_logger(fn):
    '''
    Wrap a Bottle request so that a log line is emitted after it's handled.
    (This decorator can be extended to take the desired logger as a param.)
    '''
    @wraps(fn)
    def apiRequest(*args, **kwargs):
        actual_response = fn(*args, **kwargs)
        # modify this to log exactly what you need:
        alog.access('%s %s %s' % (request.method, request.path, response.status))
        return actual_response
    return apiRequest

install(log_to_logger)

db.connect(config['db']['db'])
print(config)
