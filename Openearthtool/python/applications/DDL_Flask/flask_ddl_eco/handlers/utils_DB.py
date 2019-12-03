import psycopg2
import psycopg2.extras
import logging
import os

from utils_CONFIG import *

def connect():
    config = config2dict(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'dbconfig.txt'))    
    dbconfig = config['db']
    conn = psycopg2.connect("dbname={} host={} user={} password={}".format(dbconfig['dbname'], dbconfig['host'], dbconfig['user'], dbconfig['pwd']))
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    return conn, cur

def executesqlfetch(strSql):
    conn, cur = connect()
    try:
        cur.execute(strSql)
        p = cur.fetchall()
        return p
    except Exception, e:
        logging.warn(e.message.__str__())
    finally:
        cur.close()
        conn.close()
