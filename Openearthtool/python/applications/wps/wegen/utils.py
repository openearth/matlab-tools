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
# $Date: 2018-01-30 08:21:10 +0100 (Tue, 30 Jan 2018) $
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
from pyproj import Proj, transform
from owslib.wfs import WebFeatureService
from owslib.wcs import WebCoverageService
from osgeo import gdal

## Utils WCS [from fast]
import utils_wcs

# Read default configuration from file
def readConfig():
    # Default config file (relative path)
    cfile=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')
    cf = ConfigParser.RawConfigParser()  
    cf.read(cfile)
    plots_dir = cf.get('Bokeh', 'plots_dir')
    apache_dir = cf.get('Bokeh', 'apache_dir')
    geoserver_url = cf.get('GeoServer', 'url')
    #geoserver_anim_url = cf.get('GeoServer', 'anim_url')
    #geoserver_anim_lay = cf.get('GeoServer', 'anim_lay')
    return plots_dir, apache_dir , geoserver_url #, geoserver_anim_url, geoserver_anim_lay

# Get a unique temporary file
def tempfile(tempdir, typen='plot', extension='.html'):
    fname = typen + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)

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

# Get Raster transect intersect [default 100m]
def getDatafromWCS(geoserver_url, layername,  xst, yst, xend, yend, crs=28992, all_box=False):
	linestr = 'LINESTRING ({} {}, {} {})'.format(xst, yst, xend, yend)
	l = utils_wcs.LS(linestr, crs, geoserver_url, layername)
	l.line()
	return l.intersect(all_box=all_box) # coords+data
