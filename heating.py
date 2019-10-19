#!/usr/bin/python3

from bottle import route, run
import sys
import os
import requests
import RPi.GPIO as GPIO
import json

sys.path.append('/usr/sbin/heating/')
config = json.loads(open('/usr/sbin/heating/config.json').read())
print(config)
