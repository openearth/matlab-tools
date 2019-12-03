# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/brl_modelling/processes/brl_utils_vector.py $
# $Keywords: $

import json
import os
from sqlalchemy import create_engine
import geojson
from osgeo import ogr

# Get roads given an area of interest
def get_waters(cf, watersId, lines=False):
	# Check if existing selection exists [caching]
	if lines:
		outfname = os.path.join(cf.get('Settings', 'tmpdir'), watersId.rstrip()+'_lines.geojson')
	else:
		outfname = os.path.join(cf.get('Settings', 'tmpdir'), watersId.rstrip() + '.geojson')

	print('Loading: {}'.format(outfname))
	# Calculate temp roads only if necessary
	if not(os.path.exists(outfname)):
		raise ValueError('The waters layer selected does not exist')

	return outfname

def geojson_to_wkt(geojson_str):
	f = geojson.loads(geojson_str)
	g = ogr.CreateGeometryFromJson(geojson.dumps(f['geometry']))
	return g.ExportToWkt()

# Get roads as GeoJSON
def get_waters_geojson(cf, geojson_str):
	# DB connections
	engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
	+':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
	+'/'+cf.get('PostGIS', 'db'), strategy='threadlocal')
	
#	# Get WKT string [postgis handles better]
#	area = get_area_bounds(cf, geojson_str)
	wkt_str = geojson_to_wkt(geojson_str)
	
#	buffsizedeg = float(buffsize)/111139.0
	
	# PostGIS query [extract watercourses from the table and extract polygon (the actual input, converted to RD to be used as mask for further processing within brl_utils_imod)]
	sqlStr = """SELECT ST_AsGeoJSON(ST_Transform(ST_GeomFromText('{wkt}',4326),28992)) as polygon, 
                ST_AsGeoJSON(
        	      ST_Intersection(
    			    ST_GeomFromText('{wkt}',4326), 
    			      ST_Union(st_transform(geom,4326)))) as lines 
                FROM vaarwegvakken WHERE ST_Intersects(st_transform(geom,4326), ST_GeomFromText('{wkt}',4326))""".format(wkt=wkt_str)
    
	# Get data and close connection [one row]
	resB = engine.execute(sqlStr)
	for r in resB:
		dataPoly = r.polygon
		dataLines = r.lines
	resB.close()

	return dataLines,dataPoly

# Create a GeoJSON feature from an OGR feature
def create_feature(g):
	feat = {
		'type': 'Feature',
		'properties': {},
		'geometry': json.loads(g.ExportToJson())
	}
	return feat

def roundCoords(px, py, resolution=250):
	return round(px/resolution)*resolution, round(py/resolution)*resolution

#input is bbox dictionary of coordinates
# centre point will be calculated and with the centrepoint new extent for modelling will be created
# and rounded to modelcellsize
def createmodelextent(bbox_rd,extent):
    x0,y0 = bbox_rd[0][0],bbox_rd[0][1]
    x1,y1 = bbox_rd[3][0],bbox_rd[3][1]
    xm,ym = (x0+(x1-x0)/2),(y0+(y1-y0)/2)
    xe0,ye0 = xm-extent,ym-extent
    xe1,ye1 = xm+extent,ym+extent
    lstext = [roundCoords(xe0,ye0,250),roundCoords(xe1,ye1,250)]
    return lstext
