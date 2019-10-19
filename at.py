import os
import sys
import subprocess

def getJobsList(queue):
    out = subprocess.Popen(['wc', '-l', 'my_text_file.txt'],
           stdout=subprocess.PIPE,
           stderr=subprocess.STDOUT)
    output,errors = out.communicate()
    if errors:
        return errors
    return output

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
