import os
import sys
import json
import requests
import RPi.GPIO as GPIO
from base64 import b64encode, b64decode
from datetime import datetime, timedelta, date
from workalendar import europe
UnitedKingdom = europe.UnitedKingdom
#sys.path.append(my_cwd)
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
        atq.removeJob(jobid)
        log.info("Removed job %s from queue %s because it is to close to the last human request" % (jobid, queue))

def clearQueues():
    for function in config['queues']:
        for queue in config['queues'][function]:
            atq.clearJobs(config['queues'][function][queue])
            log.info("Cleared jobs from queue %s" % (queue))

def pinSetup():
    # Set Pin numbering mode
    try:
        GPIO.setmode(getattr(GPIO, config['pinmode']))
    except:
        log.error("Incorrect pinmode %s" % (config['pinmode']))
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
        log.info("Initialised pin %s with mode %s and state %s" % (pin, mode, defset))
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
            jobid = atq.addJob(timer, queue, command)
            log.info("Added job %s to queue %s" % (jobid, queue))

def resetPins():
    # Midnight failsafe - sets all pins to default setting and clears queues
    for pin in pins['active']:
        if pins['mode'][pin] is 'NONE':
            continue
        mode = getattr(GPIO, pins['mode'][pin])
        pintype = pins['type'][pin]
        defset = getattr(GPIO, pins['types'][pins['type'][pin]][pins['defaultsetting'][pin]])
        GPIO.output(pins['active'][pin], GPIO.defset)
        log.info("Set pin %s to state %s" % (pin, defset))
    clearQueues()

def on(function):
    pin = config['pins']['function'][function]
    state = getattr(GPIO, pins['types'][pins['type'][function]]['on'])
    GPIO.output(pin, GPIO.state)
    log.info("Set pin %s to state %s" % (pin, state))
    if function not in config['queues']:
        return
    checkTime(config['queues'][function]['off'])
    return

def off(function):
    pin = config['pins']['function'][function]
    state = getattr(GPIO, pins['types'][pins['type'][function]]['off'])
    GPIO.output(pin, GPIO.state)
    log.info("Set pin %s to state %s" % (pin, state))
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
    log.info("Added job %s to queue %s with command %s" % (offjobid, queue, command))
    if function not in config['queues']:
        return
    onqueue = config['queues'][function]['on']
    offqueue = config['queues'][function]['off']
    for queue in [ onqueue, offqueue ]:
        queuejobs = atq.getJobsList(queue)
        for jobid in queuejobs:
            job = queuejobs[jobid]
            jobdt = datetime.strptime("%s %s/%s/%s" % (job['time'], job['date'], job['month'], job['year']), '%X %d/%b/%Y')
            if jobdt > offtime:
                continue
            atq.removeJob(jobid)
            log.info("Removed job %s from queue %s" % (jobid, queue))
    return

def getPinState(pin):
    state = GPIO.input(pin)
   return state
