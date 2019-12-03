# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerrit Hendriksen
#
#       gerrit.hendriksen@deltares.nl
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

# $Id: info_nhiflux.py 13706 2017-09-13 09:29:46Z sala $
# $Date: 2017-09-13 11:29:46 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13706 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/bokeh_plots.py $
# $Keywords: $

import os
import logging
import psycopg2
import configparser


def readConfigdb():
    # Default config file (relative path)
    cfile = os.path.join(os.path.dirname(
        os.path.realpath(__file__)), 'gmdb_connection.txt')
    cf = configparser.RawConfigParser()
    cf.read(cfile)
    credentials = {}
    credentials['dbname'] = cf.get('PostgreSQL', 'dbname')
    credentials['user'] = cf.get('PostgreSQL', 'user')
    credentials['password'] = cf.get('PostgreSQL', 'password')
    credentials['host'] = cf.get('PostgreSQL', 'host')
    return credentials


def executesqlfetch(strSql, credentials):
    conn = psycopg2.connect(
        "dbname={dbname} host={host} user={user} password={password}".format(**credentials))
    cur = conn.cursor()
    try:
        cur.execute(strSql)
        p = cur.fetchall()
        return p
    except Exception as e:
        logging.info(e.message)
    finally:
        cur.close()
        conn.close()


def gettimeseries(x, y, credentials):
    strSql = """select id, ST_distance(st_setsrid(st_makepoint(api_well.point_geom[1]::double precision, api_well.point_geom[2]::double precision), 28992)
             ,st_setsrid(st_makepoint({x},{y}),28992)) as distance
             from api_well 
             order by distance
             limit 1""".format(x=x, y=y)
    id = executesqlfetch(strSql, credentials)[0][0]
    logging.info(' '.join(['well_id', str(id)]))
    return id


def getdata(id, begin_date, end_date, credentials):
    strSql = """
        select dt_measured::text,
        (volume - lag(volume) over (order by dt_measured)) / (extract(epoch from dt_measured - lag(dt_measured) over (order by dt_measured))/ 86400) as volume,"number"
        from api_well w
        join api_filter f on f.well_id = w.id
        join api_measurement m on filter_id = f.id
        where w.id = {id} and dt_measured between '{sd}'::date and '{ed}'::date
        order by "number",dt_measured""".format(id=id, sd=begin_date, ed=end_date)
    data = executesqlfetch(strSql, credentials)
    if data is None:
        logging.info('No data found for the given location')
    else:
        logging.info(' '.join(['number of observations', str(len(data))]))
    return data


def sql_gwlevels_vs_time(x, y, begin_date, end_date, properties):
    credentials = readConfigdb()
    properties['x'] = x
    properties['y'] = y
    id = gettimeseries(x, y, credentials)
    properties['id'] = id
    res = getdata(id, begin_date, end_date, credentials)
    if not(res is None):
        logging.info('Returned {} values'.format(len(res)))
    return res, properties

# def sql_gwlevels_vs_time(locid, parameterkey=10):
#	# Prepare query
#	sqlstr='''
#		SELECT timeseriesvaluesandflags.datetime, timeseriesvaluesandflags.scalarvalue
#		FROM location INNER JOIN timeseries ON location.locationkey = timeseries.locationkey INNER JOIN timeseriesvaluesandflags ON timeseries.serieskey = timeseriesvaluesandflags.serieskey
#		WHERE (timeseries.parameterkey = {}) AND (location.locationkey = {})
#		ORDER BY location.locationkey, timeseriesvaluesandflags.datetime
#	'''.format(parameterkey, locid)
#	logging.info(sqlstr)
#
#	# Execute
#	res=executeQuery(sqlstr)
#	logging.info('Returned {} values'.format(len(res)))
#	return res
