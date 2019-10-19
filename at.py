import os
import sys
import subprocess

def runOsCmd(command,cmdin=None):
    if not isinstance(command, list):
        return False
    try:
        out = subprocess.Popen(command,
               stdin=subprocess.PIPE,
               stdout=subprocess.PIPE,
               stderr=subprocess.STDOUT)
        if cmdin != None:
            out.stdin.write(cmdin.encode())
        output,errors = out.communicate()
        if errors:
            return errors
        return output
    except:
        return False

def getJobsList(queue):
    output = runOsCmd(['atq', "-q%s" % (queue)])
    jobs = {}
    jobqueue = output.decode('utf-8').split('\n')
    for job in jobqueue:
        if len(job) < 1:
            continue
        job = job.replace('\t', ' ')
        jobid, jobday, jobmonth, jobdate, jobtime, jobyear, jobqueue, jobuser = job.split(' ')
        jobs[jobid] = {
            'time' : jobtime,
            'day' : jobday,
            'date' : jobdate,
            'month' : jobmonth,
            'year' : jobyear,
            'queue' : jobqueue,
            'user' : jobuser
        }
    return jobs

def addJob(jobtime, queue, command):
    status = runOsCmd(['at', jobtime, "-q%s" % (queue)], stdin=command)
    if not status:
        return False
    return status.decode('utf-8').split('\n')[1].split(' ')[1]

def addJobFromFile(jobtime, queue, file):
    filecontents = open(file).read()
    status = runOsCmd(['at', jobtime, "-q%s" % (queue)], cmdin=filecontents)
    if not status:
        return False
    return status.decode('utf-8').split('\n')[1].split(' ')[1]

def removeJob(jobid):
    status = runOsCmd(['atrm', jobid])
    if not status:
        return False
    return True

def clearJobs(queue):
    jobs = getJobsList(queue)
    for job in jobs:
        removeJob(job)
