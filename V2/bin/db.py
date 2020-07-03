import os
import sys
import json
import sqlite3
from bin import functions as hpfuncs

def connect():
    database = config['db']['db']
    if os.path.exists(database) and not os.path.isfile(database):
        log.error("Database provided is invalid: %s" % (database))
        return "Database provided is invalid"
    try:
        config['db']['connection'] = sqlite3.connect(database)
        config['db']['cursor'] = config['db']['connection'].cursor()
    except sqlite3.Error as e:
        log.error("Error connecting to DB: %s" % (e))
        return e
    return True

def disconnect():
    config['db']['connection'].close()
    config['db']['connection'] = None
    config['db']['cursor'] = None
    return True

def executeQuery(query):
    connect()
    cursor = config['db']['cursor']
    query = query.replace(';', '')
    try:
        cursor.execute(query)
        if any(sqlfunction.upper() in query for sqlfunction in [ 'create', 'update', 'insert', 'delete']):
            config['db']['connection'].commit()
    except sqlite3.Error as e:
        log.error("Error executing query (%s): %s" % (query, e))
        if any(sqlfunction.upper() in query for sqlfunction in [ 'create', 'update', 'insert', 'delete']):
            config['db']['connection'].rollback()
        disconnect()
        return False
    if 'insert' in query or 'update' in query:
        disconnect()
        return True
    output = []
    for row in cursor:
        output.append(row)
    disconnect()
    return output

def createTable(table):
    if table not in config['db']['tables']:
        log.warning("%s is not a valid table")
        return False
    columns = ""
    for column in config['db']['tables'][table]:
        columns += "%s," % (' '.join(column))
    query = "Create table %s(%s)" % (table, columns[:-1])
    log.warning("Creating table %s" % (table))
    return executeQuery(query)

def tableCheck(table):
    connect()
    cursor = config['db']['cursor']
    query = "SELECT name FROM sqlite_master WHERE type='table' AND name='%s'" % (table)
    cursor.execute(query)
    output = cursor.fetchall()
    if len(output) > 0:
        output = list(output[0])
    disconnect()
    return output

def describeTable(table):
    query = "DESCRIBE %s" % (table)
    output = executeQuery(query)
    if output == False:
        return False
    return output

def selectData(table, datafilter=None):
    query = "SELECT * FROM %s" % (table)
    if datafilter:
        query += " WHERE %s" % (datafilter)
    output = executeQuery(query)
    if output == False:
        return False
    return output

def updateData(table, column, updatedata, datafilter):
    query = "UPDATE %s SET %s = %s WHERE %s" % (table, column, updatedata, datafilter)
    output = executeQuery(query)
    if output == False:
        return False
    return output

def insertData(table, data):
    if not isinstance(data, list):
        log.error("Incorrect datatype (%s) for insert: %s" % (type(data), data))
        return False
    tabledes = describeTable(table)
    headers = []
    if tabledes == False:
        raise ValueError("%s is not a valid table")
        return False
    for row in tabledes:
        header.append(row[0])
    if len(data) != len(headers):
        log.error("Not enough values for insert - provided %s need %s" % (len(data), len(headers)))
        return False
    query = "INSERT INTO %s(%s) VALUES (%s)" % (table, ','.join(headers), ','.join(data))
    output = executeQuery(query)
    if output == False:
        return False
    return True

def removeData(table, datafilter):
    query = "DELETE FROM %s WHERE %s" % (table, datafilter)
    output = executeQuery(query)
    if output == False:
        return False
    return output
