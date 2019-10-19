import os
import sys
import subprocess

def runOsCmd(command):
    if not isinstance(command, list):
        return False
    try:
        out = subprocess.Popen(command,
               stdout=subprocess.PIPE,
               stderr=subprocess.STDOUT)
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

# def addJob(jobtime, queue, command):
#     status = runOsCmd(['at', jobtime, "-q%s" % (queue), "-c %s" % (command)])
#     if not status:
#         return False
#     return True

def addJobFromFile(jobtime, queue, file):
    status = runOsCmd(['at', jobtime, "-q%s" % (queue), '<',  file])
    if not status:
        return False
    return True

def removeJob(jobid):
    status = runOsCmd(['atrm', jobid])
    if not status:
        return False
    return True

def clearJobs(queue):
    jobs = getJobsList(queue)
    for job in jobs:
        removeJob(job)
