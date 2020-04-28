## Author: Joe Ash - DBMage - https://github.com/dbmage
## LazyLogger credit: Andreas Bontozoglou - urban-1 - https://github.com/urban-1
## Ideas and testing: Dave Ash - daveash  - https://github.com/daveash
import os
import sys
import json
import time
import requests
import logging as log
import RPi.GPIO as GPIO
from lazylog import Logger
from base64 import b64encode, b64decode
from bottle import run, post, error, route, install, request, response, template, HTTPResponse, default_app

## Needed for deifnitive path
my_cwd = os.path.dirname(os.path.realpath(__file__))
config = json.loads(open("%s/config/config.json" % (my_cwd)).read())
## Setup logging
## console logger does not accept NOTSET so set to 60 to stop console logging
Logger.init(config['logdir'], termSpecs={"level" : 60}, fileSpecs=[config['logspecs']['wui']])

def init():
    try:
        req = requests.get('http://localhost:5000/test', timeout=2)
        if req.status_code != 200:
            log.error("API issue: %s" % (req.text))
            sys.exit()
    except:
        log.error("No response from the API")
        return False
    data = requests.get('http://localhost:5000/getUsers').text
    log.info(data)
    config['users'] = json.loads(data)
    if config['users'] == False:
        log.error("Error response from the API")
        return False
    log.warning("User count: %s" % (len(config['users'])))
    return True

def firstRun(stage=None):
    if stage == None:
        return template('firstrun', content='create_account_form')
## Routes
@route('/')
def FUNCTION():
    if len(config['users']) == 0:
        return firstRun()
    return template('main', content=None)

@route('/install')
def FUNCTION():
    if config['install'] == True:
        return HTTPResponse(404)
    return template('firstrun', content=template(step2))
## Run WSGI
start = False
while not start:
    start = init()
    if start:
        break
    time.sleep(60)
application = default_app()
