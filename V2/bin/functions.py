import os
import sys
import json
import requests
import RPi.GPIO as GPIO
from time import sleep
from base64 import b64encode, b64decode
from datetime import datetime, timedelta, date
from workalendar import europe
UnitedKingdom = europe.UnitedKingdom
#sys.path.append(my_cwd)
from bin import db
from bin import at as atq

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
        name = pin
        pin = int(pins['mapping'][name])
        mode = getattr(GPIO, pins['mode'][name])
        pintype = pins['type'][name]
        defset = getattr(GPIO, pins['types'][pins['type'][name]][pins['defaultsetting'][name]])
        log.info("Initialised pin %s (%s) with mode %s and state %s" % (pin, name, mode, defset))
        GPIO.setup(pin, mode, initial=defset)

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
    pins = config['pins']
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
    pins = config['pins']
    pin = pins['mapping'][function]
    type = pins['type'][function]
    state = getattr(GPIO, pins['types'][type]['on'])
    GPIO.output(pin, state)
    log.info("Set pin %s to state %s" % (pin, state))
    if type == 'momentary':
        sleep(0.5)
        off(function)
        return
    if function not in config['queues']:
        return
    checkTime(config['queues'][function]['off'])
    return

def off(function):
    pins = config['pins']
    pin = pins['mapping'][function]
    type = pins['type'][function]
    state = getattr(GPIO, pins['types'][type]['off'])
    GPIO.output(pin, state)
    log.info("Set pin %s to state %s" % (pin, state))
    if function not in config['queues']:
        return
    checkTime(config['queues'][function]['on'])
    return

def timed(function, duration):
    pins = config['pins']
    pin = pins['mapping'][function]
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
    if isinstance(pin, int):
        return GPIO.input(pin)
    try:
        return GPIO.input(int(pin))
    except:
        pass
    pins = config['pins']
    pin = pins['mapping'][pin]
    return GPIO.input(pin)

def addUser(userdata):
    dbdata = "'%s', '%s', '%s', '%s'" % ( userdata['name'], userdata['uname'], b64encode(userdata['password'].encode()), userdata['type'] )
    return db.insertData('users', dbdata)
