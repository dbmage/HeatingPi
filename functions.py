import os
import sys
import json
import requests
import RPi.GPIO as GPIO
from base64 import b64encode, b6decode
from datetime import datetime, timedelta, date
from workalendar.europe import UnitedKingdom
sys.path.append(my_cwd)
import db
import at as atq

def getPassword(password):
    return b64decode(password).decode('utf-8')

def checkTime(queue):
    timecheck = datetime.now() + timedelta(hours=1)
    queuejobs = atq.getJobsList(queue)
    for jobid in queuejobs:
        job = queuejobs[jobid]
        jobdt = datetime.strptime("%s %s/%s/%s" % (job['time'], job['date'], job['month'], job['year']), '%X %d/%b/%Y')
        if jobdt >= timecheck:
            continue
        # log message - removed job X because it is to close to the last human request
        atq.removeJob(jobid)

def clearQueues():
    for function in config['queues']:
        for queue in config['queues'][function]:
            atq.clearJobs(config['queues'][function][queue])
            # Log message - Cleared jobs from queue X

def setup():
    # Set Pin numbering mode
    try:
        GPIO.setmode(getattr(GPIO, config['pinmode']))
    except:
        print("Incorrect pinmode %s" % (config['pinmode']))
        return False
    # Stop warnings about pins being configured already
    GPIO.setwarnings(False)
    pins = config['pins']
    for pin in pins['active']:
        if pins['mode'][pin] is 'NONE':
            continue
        mode = getattr(GPIO, pins['mode'][pin])
        pintype = pins['type'][pin]
        defset = getattr(GPIO, pins['types'][pins['type'][pin]][pins['defaultsetting'][pin]])
        # Log message - initialised pin X with mode Y and state Z
        GPIO.setup(channel, GPIO.mode, initial=GPIO.defset)

def setTimers():
    clearQueues()
    bankholidays = []
    if config['bankholidays']:
        for x in UnitedKingdom().holidays():
            # Extract datetime objects from holidays
            bankholidays.append(x[0])
    for function in config['sets']:
        table = config['sets'][function]
        headers = []
        if datetime.now() in bankholidays:
            set = config['bankholidays']
        dow = datetime.now().strftime("%A")
        for x in db.describeTable(table)[2:]:
            headers.append(x[0])
        timers = db.selectData(table, "DAY = %s" % (dow))[0][2:]
        for timer in range(0, len(timers)):
            if len(timers[timer]) < 4:
                continue
            state = 'on'
            if 'off' in headers[timer].lower():
                state= 'off'
            queue = config['queues'][function][state]
            command = config['commands'][state]
            atq.addJob(timer, queue, command)

def resetPins():
    # Midnight failsafe - sets all pins to default setting and clears queues
    for pin in pins['active']:
        if pins['mode'][pin] is 'NONE':
            continue
        mode = getattr(GPIO, pins['mode'][pin])
        pintype = pins['type'][pin]
        defset = getattr(GPIO, pins['types'][pins['type'][pin]][pins['defaultsetting'][pin]])
        GPIO.output(pins['active'][pin], GPIO.defset)
        # Log message - set pin X to state Y
    clearQueues()

def on(function):
    pin = config['pins']['function'][function]
    state = getattr(GPIO, pins['types'][pins['type'][function]]['on'])
    GPIO.output(pin, GPIO.state)
    if function not in config['queues']:
        return
    checkTime(config['queues'][function]['off'])
    return

def off(function):
    pin = config['pins']['function'][function]
    state = getattr(GPIO, pins['types'][pins['type'][function]]['off'])
    GPIO.output(pin, GPIO.state)
    if function not in config['queues']:
        return
    checkTime(config['queues'][function]['on'])
    return

def timed(function, duration):
    pin = config['pins']['function'][function]
    state = getattr(GPIO, pins['types'][pins['type'][function]]['on'])
    command = "%s/%s" % (config['commands']['off'], function)
    if 0 < duration < 25:
        duration = duration * 60
    now = datetime.now()
    offtime = now - timedelta(seconds=now.second) - timedelta(microseconds=now.microsecond) + timedelta(minutes=duration)
    offjobid = atq.addJob(offtime, queue, command)
    if function not in config['queues']:
        return
    onqueue = config['queues'][function]['on']
    offqueue = config['queues'][function]['off']
    queuejobs = atq.getJobsList(onqueue)
    for jobid in queuejobs:
        job = queuejobs[jobid]
        jobdt = datetime.strptime("%s %s/%s/%s" % (job['time'], job['date'], job['month'], job['year']), '%X %d/%b/%Y')
        if jobdt > offtime:
            continue
        atq.removeJob(jobid)
    queuejobs = atq.getJobsList(offqueue)
    for jobid in queuejobs:
        job = queuejobs[jobid]
        jobdt = datetime.strptime("%s %s/%s/%s" % (job['time'], job['date'], job['month'], job['year']), '%X %d/%b/%Y')
        if jobdt > offtime:
            atq.removeJob(offjobid)
        if jobdt < offtime:
            atq.removeJob(jobid)
    return
