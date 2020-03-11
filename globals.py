#!/usr/bin/python3
## created as per the advice in https://stackoverflow.com/questions/29803007/in-python-access-variable-defined-in-main-from-another-module
import json
from os import path
my_cwd = path.dirname(path.realpath(__file__))
config = json.loads(open("%s/config.json" % (my_cwd)).read())
config['db']['db'] = "%s/%s" % ( my_cwd, config['db']['db'])
