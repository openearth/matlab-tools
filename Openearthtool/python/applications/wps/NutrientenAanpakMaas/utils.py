# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
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

# $Id: utils.py 14277 2018-04-06 08:43:39Z sala $
# $Date: 2018-04-06 01:43:39 -0700 (Fri, 06 Apr 2018) $
# $Author: sala $
# $Revision: 14277 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/NutrientenAanpakMaas/utils.py $
# $Keywords: $

import ConfigParser
import math
import time
import logging
import os
import tempfile
import sqlfunctions

import simplejson as json
from pyproj import Proj, transform
from owslib.wfs import WebFeatureService
from owslib.wcs import WebCoverageService
from osgeo import gdal

# Read default configuration from file
def readConfig():
    # Default config file (relative path)
    cfile=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')
    cf = ConfigParser.RawConfigParser()  
    cf.read(cfile)
    plots_dir = cf.get('Bokeh', 'plots_dir')
    apache_dir = cf.get('Bokeh', 'apache_dir')   
    return plots_dir, apache_dir

# Parameters check
def check_location(location, epsgin='epsg:3857'):        
    # Valid JSON
    try:
        # Input (coordinates)  
        if isinstance(location, basestring):  
            location_info = json.loads(location)            
            (xin,yin) = location_info['x'], location_info['y']
        else:
            location_info = location
            (xin,yin) = location_info[0], location_info[1]
        
        (lon,lat) = change_coords(xin, yin)
        logging.info('''Input Coordinates {} {} -> {} {}'''.format(xin,yin,lon,lat))  
    except Exception as e: 
        logging.error(e)
        return False, '''<p>Please select a location first with the 'Select on map' button</p>''', -1, -1

    # Parameters check OK 
    return True, '', xin, yin

# Get a unique temporary file
def getTempFile(tempdir):
    dirname = str(time.time()).replace('.','')
    return os.path.join(tempdir, dirname+'.html')

# Change XY coordinates general function
def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:4326'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)

# Get closest point to user click
def queryPostGISClosestPoint(xk, yk, epsg=28992):
    # DB connect
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection.txt')
    credentials = sqlfunctions.get_credentials(cf)
    
    # Look for closes transect ()
    sql = """SELECT *, ST_Distance(ST_PointFromText('POINT({} {})','{}'), geometry) as distance
             FROM location
             ORDER BY distance
             LIMIT 1
            """.format(xk, yk, epsg)     
    res = sqlfunctions.executesqlfetch(sql, credentials)
    
    # If found call info about transect
    if not(len(res)):
        return False
    
    # TRANSECT DB info    
    logging.info('Result = '+ str(res))
    return res 

# Get timeseries for a given ID
def queryPostGISLocIDTseries(locid, param):
    # DB connect
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection.txt')
    credentials = sqlfunctions.get_credentials(cf)
    
    # Parameter selection
    p = 'Ntot'
    if 'P-totaal' in param:
        p = 'Ptot'

    # Look for closes transect ()
    sql = """SELECT datetime, value 
            FROM observation o
            join location l on l.locationid = o.locationid
            join parameter p on p.parameterid = o.parameterid
            where l.locationid = {id} and p.parameter='{p}'
            order by datetime
            """.format(id=locid, p=p)    
    res = sqlfunctions.executesqlfetch(sql, credentials)
    
    # If found call info about transect
    if not(len(res)):
        return False
    
    # TRANSECT DB info    
    #logging.info('Result = '+ str(res))
    return res   

# Get closest point to user click
def queryPostGISClosestPointNitrate(xk, yk, epsg=28992):
    # DB connect
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnectionnitrate.txt')
    credentials = sqlfunctions.get_credentials(cf)
    
    # Look for closes transect ()
    sql = """SELECT *, 
    ST_Distance(ST_PointFromText('POINT({} {})','{}'), st_transform(wgs_geom,28992)) as distance
             FROM fews.locations
             ORDER BY distance
             LIMIT 1""".format(xk, yk, epsg)     
    res = sqlfunctions.executesqlfetch(sql, credentials)

    # If found call info about transect
    if not(len(res)):
        return False
    
    # TRANSECT DB info    
    logging.info('Result = '+ str(res))
    return res 

# Get closest point to user click
def queryPostGISClosestPointKRW(xk, yk, epsg=28992):
    # DB connect
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection.txt')
    credentials = sqlfunctions.get_credentials(cf)
    
    # Look for closes transect ()
    sql = """SELECT *, ST_Distance(ST_PointFromText('POINT({} {})','{}'), geom) as distance                
             FROM krwnutrend.locations
             ORDER BY distance
             LIMIT 1""".format(xk, yk, epsg)     
    logging.info(sql)
    res = sqlfunctions.executesqlfetch(sql, credentials)
    
    # If found call info about transect
    if not(len(res)):
        return False
    
    # TRANSECT DB info    
    logging.info('Result = '+ str(res))
    return res     

# Get timeseries for a given ID
def queryPostGISLocIDTseriesNitrate(locid, param):
    # DB connect
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnectionnitrate.txt')
    credentials = sqlfunctions.get_credentials(cf)
    
    # Get data for l.id = locid with a search radius of 1 / approxmate distance of a longitute * avalue (arbitrary)
    # the data is pretty scarce, so a search of the distance from the point 
    sql = """select datetime, scalarvalue, pg.id, pg.unit
             from fews.locations l
             join fews.timeserieskeys t on t.locationkey = l.locationkey
             join fews.parameterstable p on p.parameterkey = t.parameterkey
             join fews.parametergroups pg on pg.groupkey = p.groupkey
             join fews.timeseriesvaluesandflags ts on ts.serieskey = t.serieskey
             where p.name = '{pid}' and 
             st_within(l.wgs_geom,st_buffer((select wgs_geom from fews.locations where fews.locations.id = '{lid}'),((1/110574.61)*100)))""".format(pid=param, lid=locid)   
    #logging.info(sql)
    res = sqlfunctions.executesqlfetch(sql, credentials)

    # If found call info about transect
    if not(len(res)):
        return False
    
    # TRANSECT DB info    
    logging.info('Result = '+ str(res))
    return res   

# Get timeseries for a given XY location
def queryPostGISLandelijkMeetnetTseriesXY(x,y):
    # DB connect
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection.txt')
    credentials = sqlfunctions.get_credentials(cf)
    
    # Get average tseries for a given XY location in rdnew    
    sql = """with closestpoint as (select id, st_distance(geom,st_setsrid(st_point({x},{y}),28992)) as dist 
             from rivm.lmg_locations
             order by dist
             limit 1
            )
            select xcoordinaat, ycoordinaat, planjaar, filter, avg(no3_n) as no3, avg(nh4_n) as nh4, avg(p_tot) as p_tot,
            'Filterdiepte ('||diepte_bovenkant_filter_tov_mv::text||' - '||diepte_onderkant_filter_tov_mv::text||' m-mv)' as ftext  from rivm.lmg l
            where locid = (select id from closestpoint)
            group by planjaar, filter, xcoordinaat, ycoordinaat, ftext
            order by filter, planjaar""".format(x=x, y=y)   
    #logging.info(sql)
    res = sqlfunctions.executesqlfetch(sql, credentials)

    # If found call info about transect
    if not(len(res)):
        return False
    
    # TRANSECT DB info    
    #logging.info('Result = '+ str(res))
    return res 
