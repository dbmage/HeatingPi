## Author: Joe Ash - DBMage - https://github.com/dbmage
## LazyLogger credit: Andreas Bontozoglou - urban-1 - https://github.com/urban-1
## Ideas and testing: Dave Ash - daveash  - https://github.com/daveash
import os
import sys
import json
import requests
import functions
import logging as log
import RPi.GPIO as GPIO
from lazylog import Logger
from base64 import b64encode, b64decode
from bottle import run, post, error, route, install, request, response, template, HTTPResponse, default_app

## Needed for deifnitive path
my_cwd = os.path.dirname(os.path.realpath(__file__))

## custom imports
sys.path.append("%s/bin" % (my_cwd))
import db
import at as atq

## Set global vars
config = json.loads(open("%s/config/config.json" % (my_cwd)).read())
config['db']['db'] = "%s/bin/%s" % ( my_cwd, config['db']['db'])
__builtins__.my_cwd = my_cwd
__builtins__.config = config

## Setup logging
config['logspecs']['level'] = getattr(log, config['logspecs']['level'], 'INFO')
Logger.init(config['logdir'], termSpecs={"level" : 0}, fileSpecs=[config['logspecs']])
## Pass logger to other modules instead ofsetting up in each one
db.log = log
functions.log = log
atq.log = log

## Initialise necessary things
db.connect(config['db']['db'])
functions.pinSetup()

## WSGI functions
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

## Routes
@route('/test')
def FUNCTION():
    return retOK('Running')

@route('/pinon/<pin>')
def FUNCTION(pin):
    functions.on(pin)
    data = {
        "pin" : pin,
        "state" : functions.getPinState(pin)
    }
    return retOK(data)

@route('/pinoff/<pin>')
def FUNCTION(pin):
    functions.off(pin)
    data = {
        "pin" : pin,
        "state" : functions.getPinState(pin)
    }
    return retOK(data)

@route('/resetpins')
def FUNCTION():
    functions.resetPins()
    return retOK()

## Run WSGI
application = default_app()