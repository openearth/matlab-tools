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

# $Id: coords.py 13711 2017-09-13 14:52:48Z sala $
# $Date: 2017-09-13 16:52:48 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13711 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/blue2/coords.py $
# $Keywords: $

import os
from pyproj import Proj, transform

# Geo
from shapely.geometry import *
from shapely import wkt
from owslib.wfs import WebFeatureService
from owslib.wcs import WebCoverageService
from pyproj import Proj, transform

# Local
from utils_wcs import *

# Change XY coordinates general function
def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:4326'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)

# Check WCS coverage for the given location
def checkcoverage(url, x, y, epsg_str):
    wcs = WebCoverageService(url, version='1.0.0')
    lstlayer = list(wcs.contents)
    dctlayers = {}
    for l in lstlayer:
        layer = wcs[l]
        if len(layer.boundingboxes) != 0:
            srid = layer.boundingboxes[0]['nativeSrs']
            projbox = Proj(init=srid)
            projpoint = Proj(init=epsg_str)
            x0,y0 = transform(projpoint, projbox, x, y)             
            bbox = layer.boundingboxes[0]['bbox']
            polygon = Polygon([(bbox[0], bbox[1]), (bbox[0], bbox[3]), (bbox[2], bbox[3]),(bbox[0],bbox[3])])
            point0 = Point(x0,y0)
            if point0.within(polygon):
                dctlayers[l] = srid
    return dctlayers  

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