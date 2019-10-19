import os
import sys
import subprocess

def getJobsList(queue):
    out = subprocess.Popen(['atq', "-q%s" % (queue)],
           stdout=subprocess.PIPE,
           stderr=subprocess.STDOUT)
    output,errors = out.communicate()
    if errors:
        return errors
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

def addJob(jobtime,queue, command):
    return True

def addJobFromFile(jobtime, queue, file):
    return True

def removeJob(queue, jobid):
    return True

def clearJobs(queue):
    jobs = getJobsList(queue)
    for job in jobs:
        removeJob(queue, job['id'])
