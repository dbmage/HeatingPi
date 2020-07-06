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
from bottle import run, post, error, route, install, request, response, template, HTTPResponse, default_app, redirect

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

def init():
    try:
        req = apiCall('/test')
        if req.status_code != 200:
            log.error("API issue: %s" % (req.text))
            sys.exit()
    except:
        log.error("No response from the API")
        return False
    data = apiCall('/getUsers').text
    log.info(data)
    config['users'] = json.loads(data)
    if config['users'] == False:
        log.error("Error response from the API")
        return False
    log.warning("User count: %s" % (len(config['users'])))
    return True

def firstRun():
    if config['installstep'] == 0:
        return template('firstrun', content='create_account_form')
    if config['installstep'] == 1:
        return template('firstrun', content=template('setup', pins=config['pins']['freepins']))

def register_user(userdata):
    for thing in ['names', 'username', 'password', 'type' ]:
        if thing not in userdata:
            log.error("Missing %s" % (thing))
            log.error(userdata)
            return False
    config['install'] = True
    general.configSave(my_cwd, config)
    data = apiCall('/getUsers').text
    config['users'] = json.loads(data)
    return apiCall('/createuser', data=userdata)

## Routes
@route('/')
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
    if config['install'] == True:
        return HTTPResponse(body=None, status=404)
    data = {}
    data['names'] = request.forms.fname
    data['username'] = request.forms.username
    data['password'] = request.forms.password.lower()
    data['type'] = request.forms.type
    resp = register_user(data)
    if resp == False:
        return template('main', content="Bad form data")
    if resp.status_code != 200:
        return template('main', content="Creating user failed")
    config['installstep'] += 1
    redirect('/')

## Run WSGI
start = False
while not start:
    start = init()
    if start:
        break
    time.sleep(60)
log.info("Successfully connected to API, starting WUI")
application = default_app()
