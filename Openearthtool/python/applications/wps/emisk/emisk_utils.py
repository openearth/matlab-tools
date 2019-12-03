# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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

# $Id: emisk_utils.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-29 23:21:10 -0800 (Mon, 29 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/emisk_utils.py $
# $Keywords: $

import ConfigParser
import math
import time
import logging
import StringIO
import os
import tempfile
import simplejson as json
import numpy as np
from PIL import Image
from pyproj import Proj, transform
from owslib.wfs import WebFeatureService
from owslib.wcs import WebCoverageService
from osgeo import gdal

## Utils WCS [from fast]
from emisk_utils_wcs import *

# Read default configuration from file
def readConfig():
	# Default config file (relative path)
	cfile=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'emisk_config.txt')
	cf = ConfigParser.RawConfigParser()  
	cf.read(cfile)
	plots_dir = cf.get('Bokeh', 'plots_dir')
	apache_dir = cf.get('Bokeh', 'apache_dir')
	sqlserver_url = cf.get('SqlServer', 'host') # default is 'local'
	sqlserver_user = cf.get('SqlServer', 'user') # default is 'sa'
	sqlserver_pass = cf.get('SqlServer', 'pass') # default is ''
	sqlserver_db = cf.get('SqlServer', 'db')
	geoserver_url = cf.get('GeoServer', 'url')
	return plots_dir, apache_dir, geoserver_url, sqlserver_db, sqlserver_url, sqlserver_user, sqlserver_pass

# Get a unique temporary file
def emiskTempFile(tempdir, typen='plot', extension='.html'):
    fname = typen + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)

def inside_kuwait_latlon(lon, lat):
  # Kuwait Bounding Box
  '''POLYGON((46.5326 30.138, 48.4497 30.138, 48.4497 28.5001, 46.5326 28.5001, 46.5326 30.138))'''
  return (lat < 30.14 and lat > 28.50 and lon < 48.45 and lon > 46.53)

# Change XY coordinates general function
def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:4326'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)

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
    
    # Check inside Europe
    if not inside_kuwait_latlon(lon, lat):
        return False, '''<p>Please select a location inside the Kuwait borders</p>''', -1, -1

    # Parameters check OK 
    return True, '', xin, yin 

# Get closest feature via WFS [radius]
def closestFeatureWFS(geoserver_url, layername, xk, yk, dist=50000, allfeatures=False):
	wfs = WebFeatureService(url=geoserver_url+'?service=wfs', version='2.0.0', timeout=30)
	response = wfs.getfeature(typename=layername, bbox=(xk-dist, yk-dist, xk+dist, yk+dist), propertyname='*', outputFormat='application/json')
	data = json.loads(response.read()) 
	logging.info('WFS found {} features in layer {}'.format(data['totalFeatures'], layername))
	
	# All features or just the closest one
	if allfeatures:
		return data['features'], len(data['features'])
	else:
		# Get closest point by euclidean distance
		properties = None
		mindist = 9999999
		for feature in data['features']:
			(xsel,ysel) = feature['geometry']['coordinates']
			dist = math.sqrt((xk-xsel)*(xk-xsel) + (yk-ysel)*(yk-ysel))		
			if dist < mindist:
				mindist = dist
				properties = feature['properties']
		logging.info('Found point {} at distance={} meters'.format(properties, mindist))			
	return properties, mindist

# Get Raster transect intersect [default 100m]
def getDatafromWCS(geoserver_url, layername,  xst, yst, xend, yend, crs=32638, all_box=False):
	linestr = 'LINESTRING ({} {}, {} {})'.format(xst, yst, xend, yend)
	l = LS(linestr, crs, geoserver_url, layername)
	l.line()
	return l.intersect(all_box=all_box) # coords+data
