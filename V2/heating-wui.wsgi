## Author: Joe Ash - DBMage - https://github.com/dbmage
## LazyLogger credit: Andreas Bontozoglou - urban-1 - https://github.com/urban-1
## Ideas and testing: Dave Ash - daveash  - https://github.com/daveash
import os
import sys
import json
import time
import requests
import traceback
import logging as log
import RPi.GPIO as GPIO
from lazylog import Logger
from base64 import b64encode, b64decode
from bottle import run, post, error, route, install, request, response, template, HTTPResponse, default_app, redirect, auth_basic

## Needed for deifnitive path
my_cwd = os.path.dirname(os.path.realpath(__file__))
sys.path.append("%s" % (my_cwd))
config = json.loads(open("%s/config/config.json" % (my_cwd)).read())
from bin import general
apiurl = 'http://localhost:5000'
## Setup logging
## console logger does not accept NOTSET so set to 60 to stop console logging
Logger.init(config['logdir'], termSpecs={"level" : 60}, fileSpecs=[config['logspecs']['wui']])

def apiCall(endpoint, data=None):
    try:
        url = "%s%s" % ( apiurl, endpoint )
        if endpoint == '/test':
                return requests.get(url, timeout=2)
        if data == None:
            return requests.get( url )
        return requests.post(url, json=json.dumps(data))
    except:
        log.error(traceback.print_exc())
        return HTTPResponse(body=json.dumps(traceback.print_exc()), status=500)

def getUsers():
    data = apiCall('/getUsers').text
    config['users'] = json.loads(data)
    if config['users'] == False:
        log.error("Error response from the API")
        return False
    return True

def init():
    try:
        req = apiCall('/test')
        if req.status_code != 200:
            log.error("API issue: %s" % (req.text))
            sys.exit()
    except:
        log.error("No response from the API")
        return False
    if getUsers() == False:
        return False
    log.warning("User count: %s" % (len(config['users'])))
    return True

def checkLogin(user, password):
    log.error(user)
    log.error(password)
    # if getUsers() == False:
    #     log.error(1)
    #     return HTTPResponse(status=500)
    # if len(config['users']) < 1:
    #     log.error(2)
    #     return True
    # resp = apiCall('/auth', data=json.dumps( [ user, password ] ) )
    # log.error(3)
    # if resp.status_code != 200:
    #     log.error(4)
    #     return False
    # log.error(5)
    return True

def firstRun(update=None):
    if config['installstep'] == 0:
        return template('firstrun', content='create_account_form')
    if config['installstep'] == 1:
        return template('firstrun', content='setup', pins=config['pins']['freepins'], error=update)

def register_user(userdata):
    for thing in ['names', 'username', 'password', 'type' ]:
        if thing not in userdata:
            log.error("Missing %s" % (thing))
            log.error(userdata)
            return False
    general.configSave(my_cwd, config)
    return apiCall('/createuser', data=userdata)

def addPins(pins):
    for pin in pins:
        pinno, pinuse = row
        if pinno not in config['pins']['freepins']:
            continue
        config['pins']['mapping'][pinuse] = pinno
        if 'heating' in pinuse or 'water' in pinuse:
            config['pins']['mode'][pinuse] = 'OUT'
            config['pins']['type'][pinuse] = 'binary'
        else:
            config['pins']['mode'][pinuse] = 'NONE'
            config['pins']['type'][pinuse] = 'NONE'
        config['pins']['defaultsetting'][pinuse] = 'off'
        config['pins']['freepins'].remove(pinno)
        config['pins']['active'].push(pinuse)
    return True

def setup(data):
    req = apiCall('/setup', data=data)
    if req.status_code != 200:
        return firstRun('Error saving settings, please check the log for details')
    addPins(data['pins'])
    config['install'] = True
    config['installstep'] = -1
    redirect('/')

## Routes
@route('/')
@auth_basic(checkLogin)
def root():
    if len(config['users']) == 0 or config['installstep'] != -1:
        config['install'] = False
        return firstRun()
    return template('main', content=None)

@route('/test')
def test():
    return HTTPResponse(status=200, body=json.dumps('WUI running'))

@post('/createuser')
def createUser():
    config['users'] = json.loads(apiCall('/getUsers').text)
    if config['install'] == True or len(config['users']) > 0:
        return HTTPResponse(body=None, status=404)
    data = {}
    data['names'] = request.forms.fname
    data['username'] = request.forms.username
    data['password'] = request.forms.password.lower()
    data['type'] = request.forms.type
    resp = register_user(data)
    if resp == False:
        return template('main', content="Bad form data")
    if resp.status_code != 201:
        return template('main', content="Creating user failed")
    config['installstep'] += 1
    general.configSave(my_cwd, config)
    redirect('/')

@post('/setup')
def setup():
    data = {
        'use' : request.forms.use,
        'setting' : 'off',
        'pins' : json.loads(request.forms.pindata)
    }
    return setup(data)


## Run WSGI
start = False
while not start:
    start = init()
    if start:
        break
    time.sleep(60)
log.info("Successfully connected to API, starting WUI")
application = default_app()
