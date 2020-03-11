import os
import sys
import json
import sqlite3
#import pymysql as mysql
import functions
# user = config['db']['user']
# password = getPassword(config['db']['pass'])
# host = config['db']['host']
# database = config['db']['db']

def connect(database):
    if os.path.exists(database) and not os.path.isfile(database):
        return "Database provided is invalid"
    try:
        config['db']['connection'] = sqlite3.connect(database)
        config['db']['cursor'] = config['db']['connection'].cursor()
    except sqlite3.Error as e:
        return e
    return True

def executeQuery(query):
    cursor = config['db']['cursor']
    query = query.replace(';', '')
    try:
        cursor.execute(query)
        if any(sqlfunction.upper() in query for sqlfunction in [ 'update', 'insert', 'delete']):
            config['db']['connection'].commit()
    except mysql.Error as e:
        # log message - Error executing query (query): e[1]
        if any(sqlfunction.upper() in query for sqlfunction in [ 'update', 'insert', 'delete']):
            config['db']['connection'].rollback()
        return e
    if 'insert' in query or 'update' in query:
        return True
    output = []
    for row in cursor:
        output.append(row)
    return output

def describeTable(table):
    query = "DESCRIBE %s" % (table)
    output = executeQuery(query)
    if not output:
        return False
    return output

def selectData(table, datafilter=None):
    query = "SELECT * FROM %s" % (table)
    if datafilter:
        query += " WHERE %s" % (datafilter)
    output = executeQuery(query)
    if not output:
        return False
    return output

def updateData(table, column, updatedata, datafilter):
    query = "UPDATE %s SET %s = %s WHERE %s" % (table, column, updatedata, datafilter)
    output = executeQuery(query)
    if not output:
        return False
    return output

def insertData(table, data):
    if not isinstance(list, data):
        #log message - Incorrect datatype for insert: data
        return False
    tabledes = describeTable(table)
    headers = []
    for row in tabledes:
        header.append(row[0])
    if len(data) != len(headers):
        #log message - Not enough values for insert - provided x need y
        return False
    query = "INSERT INTO %s(%s) VALUES (%s)" % (table, ','.join(headers), ','.join(data))
    output = executeQuery(query)
    if not output:
        return False
    return True

def removeData(table, datafilter):
    query = "DELETE FROM %s WHERE %s" % (table, datafilter)
    output = executeQuery(query)
    if not output:
        return False
    return output
