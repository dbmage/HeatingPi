## Author: Joe Ash - DBMage - https://github.com/dbmage
## LazyLogger credit: Andreas Bontozoglou - urban-1 - https://github.com/urban-1
## Ideas and testing: Dave Ash - daveash  - https://github.com/daveash
import os
import sys
import json
import requests
import logging as log
import RPi.GPIO as GPIO
from lazylog import Logger
from base64 import b64encode, b64decode
from bottle import run, post, error, route, install, request, response, HTTPResponse, default_app

## Needed for deifnitive path
my_cwd = os.path.dirname(os.path.realpath(__file__))

## custom imports
sys.path.append("%s" % (my_cwd))
from bin import db
from bin import at as atq
## Was unaware of python dist functions module. Renamed to avoid clash
from bin import functions as hpfuncs

## Set global vars
config = json.loads(open("%s/config/config.json" % (my_cwd)).read())
config['db']['db'] = "%s/bin/%s" % ( my_cwd, config['db']['db'])
__builtins__['my_cwd'] = my_cwd
__builtins__['config'] = config

## Setup logging
config['logspecs']['api']['level'] = getattr(log, config['logspecs']['api']['level'], 'INFO')
## console logger does not accept NOTSET so set to 60 to stop console logging
Logger.init(config['logdir'], termSpecs={"level" : 60}, fileSpecs=[config['logspecs']['api']])
## Pass logger to other modules instead ofsetting up in each one
db.log = log
hpfuncs.log = log
atq.log = log

## Initialise necessary things
hpfuncs.pinSetup()
for table in config['db']['tables']:
    output = db.tableCheck(table)
    log.warning("Checking table %s: %s" % (table, output))
    if len(output) < 1:
        log.warning("Table %s not found, creating" % (table))
        db.createTable(table)
    if len(output) > 1:
        log.critical("More than one table was found matching %s!" % (table))
        sys.exit(1)

## WSGI hpfuncs
def retHTTP(retcode,data=None):
    if not isinstance(retcode, int):
        retcode = int(retcode)
    if not data:
        return HTTPResponse(status=retcode)
    try:
        jsondata = json.dumps(data)
        return HTTPResponse(status=retcode, body=jsondata)
    except:
        pass
    return HTTPResponse(status=retcode, body=data)

def retOK(data=None):
    return retHTTP(200, data=data)

def retError(data=None):
    return retHTTP(500, data=data)

def retInvalid(data=None):
    return retHTTP(400, data=data)

def retDisabled(data=None):
    return retHTTP(503, data=data)

## Routes
@route('/test')
def FUNCTION():
    return retOK(data='Running')

@route('/pinon/<pin>')
def FUNCTION(pin):
    hpfuncs.on(pin)
    data = {
        "pin" : pin,
        "state" : hpfuncs.getPinState(pin)
    }
    return retOK(data=data)

@route('/pinoff/<pin>')
def FUNCTION(pin):
    hpfuncs.off(pin)
    data = {
        "pin" : pin,
        "state" : hpfuncs.getPinState(pin)
    }
    return retOK(data=data)

@route('/resetpins')
def FUNCTION():
    hpfuncs.resetPins()
    return retOK()

@route('/getUsers')
def FUNCTION():
    return json.dumps(db.selectData('users', datafilter="type != 'disabled'"))

@post('createuser')
def FUNCTION():
    try:
        if hpfuncs.addUser(json.loads(request.json['payload'])):
            return retOK()
        return retError(data='Create user failed')
    except:
        return retError(data='Create user failed')
## Run WSGI
application = default_app()
