## Author: Joe Ash - DBMage - https://github.com/dbmage
## LazyLogger credit: Andreas Bontozoglou - urban-1 - https://github.com/urban-1
## Ideas and testing: Dave Ash - daveash  - https://github.com/daveash
import at
import os
import sys
import json
import requests
import traceback
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
atq = at.at()
atq.sudo = True
hpfunc.atq = atq

## Initialise necessary things
hpfuncs.pinSetup()
for table in config['db']['tables']:
    output = db.tableCheck(table)
    log.warning("Checking table %s: %s" % (table, output))
    if len(output) < 1 or output == False:
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

def retCreated(data=None):
    return retHTTP(201, data=data)

def retError(data=None):
    return retHTTP(500, data=data)

def retInvalid(data=None):
    return retHTTP(400, data=data)

def retUnAuth(data=None):
    return retHTTP(401, data=data)

def retDisabled(data=None):
    return retHTTP(503, data=data)

## Routes
@route('/test')
def test():
    return retOK(data='API Running')

@route('/pinon/<pin>')
def pinOn(pin):
    hpfuncs.on(pin)
    data = {
        "pin" : pin,
        "state" : hpfuncs.getPinState(pin)
    }
    return retOK(data=data)

@route('/pinoff/<pin>')
def pinOff(pin):
    hpfuncs.off(pin)
    data = {
        "pin" : pin,
        "state" : hpfuncs.getPinState(pin)
    }
    return retOK(data=data)

@route('/resetpins')
def resetPins():
    hpfuncs.resetPins()
    return retOK()

@post('/auth')
def authenticateUser():
    try:
        user,password = json.loads(request.json)
    except:
        log.error("Unabled to get username and password from auth req: %s" % (request.json))
        return retInvalid()
    usercheck = db.selectData('users', datafilter="UNAME == %s" % (user))
    if len(usercheck) != 1:
        log.error("User %s is invalid" % (user))
        return retUnAuth()
    if password != b64decode(usercheck[0][2]).decode('utf-8'):
        log.error("Incorrect password for %s" % (user))
        return retUnAuth()
    return retOK()

@route('/getUsers')
def getUsers():
    data = db.selectData('users', datafilter="type != 'disabled'")
    if data == False:
        return json.dumps([])
    return json.dumps(list(data))

@route('/checkUserName/<username>')
def checkUsername(username):
    users = db.selectData('users', datafilter="type != 'disabled'")
    for user in users:
        if username == user[1]:
            return retInvalid( data=json.dumps( { 'error' : "Username %s is already taken" % (username) } ) )
    return retOk()

@post('/createuser')
def createUser():
    try:
        if hpfuncs.addUser(json.loads(request.json)):
            return retCreated()
    except Exception as e:
        log.error(e)
        log.error(traceback.print_exc())
        return retError(data="Create user failed: %s" % (e))

@post('/setup')
def setup():
    data = json.loads(request.forms.json) # this doesn't work
    print(data)
    if hpfuncs.setUse(data['use'], data['setting']):
        return retOK()
    return retError(data='Setting use failed')

## Run WSGI
application = default_app()
