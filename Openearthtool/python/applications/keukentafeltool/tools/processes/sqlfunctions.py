# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for Keukentafeltool
#
#   Gerrit Hendriksen <Gerrit.Hendriksen@deltares.nl>
#   Joan Sala Calero <joan.salacalero@deltares.nl>
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

import types
import datetime
import psycopg2
import logging

def flushCopyBuffer(bufferFile, atable, credentials, cols, asep):
    conn = psycopg2.connect("dbname={dbname} host={host} user={user} password={password}".format(**credentials))
    cur = conn.cursor()
    bufferFile.seek(0)   # Little detail where lures the deamon...
    cur.copy_from(bufferFile, atable, sep=asep, columns=cols)
    cur.connection.commit()
    bufferFile.close()


# next function evaluates type of value of first record and returns the PostgreSQL type
def getpgtype(aval):
    if isinstance(aval, types.StringType):
        return 'text'
    elif isinstance(aval, types.UnicodeType):
        return 'text'
    elif isinstance(aval, types.IntType):
        return 'integer'
    elif isinstance(aval, types.FloatType):
        return 'double precision'
    elif isinstance(aval, datetime.datetime):
        return 'text'
    elif isinstance(aval, datetime.time):
        return 'text'
    else:
        return 'text'


def perform_sql(sql, credentials):
    conn = psycopg2.connect("dbname={dbname} host={host} user={user} password={password}".format(**credentials))
    cur = conn.cursor()
    try:
        cur.execute(sql)
        conn.commit()
        logging.debug("query type, # rows affected) -- " + cur.statusmessage)
        return True
    except Exception, e:
        logging.warn(e.message.__str__())
        if e.message.__str__().index('already exists') > 0:
            return True
        else:
            return False
    finally:
        cur.close()
        conn.close()

# function to read textfile with keys and values. The keys have to be uname, pwd, host and dbname for
# respectively username, password, hostname of the server and a database name. For the databasename None is the
# default value. The credential file can be used for every database on a particular server (with respect to the rights assigned)
# if dbase is not specified as parameter to the function the dbase specified in the credenital file will be used


def get_credentials(credentialfile, dbase=None):
    fdbp = open(credentialfile, 'rb')
    credentials = {}
    if dbase != None:
        credentials['dbname'] = dbase
    for i in fdbp:
        item = i.split('=')
        if str.strip(item[0]) == 'dbname':
            if dbase == None:
                credentials['dbname'] = str.strip(item[1])
        if str.strip(item[0]) == 'uname':
            credentials['user'] = str.strip(item[1])
        if str.strip(item[0]) == 'pwd':
            credentials['password'] = str.strip(item[1])
        if str.strip(item[0]) == 'host':
            credentials['host'] = str.strip(item[1])
    logging.info('credentials set for database ', credentials['dbname'], 'on host', credentials['host'])
    logging.info('for user', credentials['user'])
    return credentials


def executesqlfetch(strSql, credentials):
    conn = psycopg2.connect("dbname={dbname} host={host} user={user} password={password}".format(**credentials))
    cur = conn.cursor()
    try:
        cur.execute(strSql)
        p = cur.fetchall()
        return p
    except Exception, e:
        logging.warn(e.message)
    finally:
        cur.close()
        conn.close()
