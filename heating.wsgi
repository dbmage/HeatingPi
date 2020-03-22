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
from bottle import run, post, error, route, install, request, response, template, HTTPResponse, default_app

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
## Initialise necessary things
db.connect(config['db']['db'])
pinSetup()

def retHTTP(retcode,data=None):
    if not isinstance(retcode, int):
        retcode = int(retcode)
    if not data:
        return HTTPResponse(retcode)
    try:
        jsondata = json.dumps(data)
        return HTTPResponse(retcode, body=jsondata)
    except:
        pass
    return HTTPResponse(retcode, body=data)

def retOK(data=None):
    return retHTTP(200, data)

def retError(data=None):
    return retHTTP(500, data)

def retInvalid(data=None):
    return retHTTP(400, data)

def retDisabled(data=None):
    return retHTTP(503, data)

@route('/test')
def FUNCTION():
    return retOK('Running')

@route('/pinon/<pin>')
def FUNCTION(pin):
    on(pin)
    data = {
        "pin" : pin,
        "state" : getPinState(pin)
    }
    return retOK(data)

@route('/pinoff/<pin>')
def FUNCTION(pin):
    off(pin)
    data = {
        "pin" : pin,
        "state" : getPinState(pin)
    }
    return retOK(data)

@route('/resetpins')
def FUNCTION():
    resetPins()
    return retOK()

application = default_app()
