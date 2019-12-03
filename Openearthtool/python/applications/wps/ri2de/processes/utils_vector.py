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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/utils_vector.py $
# $Keywords: $

import json
import os
import fiona
import math
import geojson
from osgeo import ogr
from sqlalchemy import create_engine
from pyproj import Proj, transform
from rasterstats import zonal_stats
from shapely.geometry import *

from utils_lines import *

# Change XY coordinates general function
def change_coords(px, py, epsgin='epsg:4326', epsgout='epsg:3857'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)

# Explode coordinates
def explode_coords(coords):
    """Explode a GeoJSON geometry's coordinates object and yield coordinate tuples.
    As long as the input is conforming, the type of the geometry doesn't matter."""
    for e in coords:
        if isinstance(e, (float, int)):
            yield coords
            break
        else:
            for f in explode_coords(e):
                yield f

# Get bounds of a feature collection geojson [south, weast, north, east]
def get_area_bounds_fc(cf, geojson_str):
	geo = geojson.loads(geojson_str)
	minxs = []
	maxxs = []
	minys = []
	maxys = []	
	for f in geo['features']:
		x, y = zip(*list(explode_coords(f['geometry']['coordinates'])))
		minxs.append(min(x))
		maxxs.append(max(x))
		minys.append(min(y))
		maxys.append(max(y))

	minx, miny, maxx, maxy = min(minxs), min(minys), max(maxxs), max(maxys)
	area = abs(maxx-minx * maxy-miny)*111139 # degrees to meters approx

	return minx, miny, maxx, maxy, area

# Get bounds of beature
def get_area_bounds(cf, geojson_str):
	f = geojson.loads(geojson_str)
	lon, lat = zip(*list(explode_coords(f['geometry']['coordinates'])))
	px0, py0, px1, py1 = min(lon), min(lat), max(lon), max(lat)
	minx, miny = change_coords(px0, py0, epsgin='epsg:4326', epsgout='epsg:3857')
	maxx, maxy = change_coords(px1, py1, epsgin='epsg:4326', epsgout='epsg:3857')
	area = ((maxx-minx)*(maxy-miny))/1000000.0 # km2
	area_limit = cf.get('Settings', 'area_limit')
	# Check limit
	if area > float(area_limit):
		raise ValueError('The selected area exceeds the maximum capacity for calculations')

	return area

# Transform a GeoJSON feature collection to a MULTIPOLYGON WKT
def geojson_to_wkt(geojson_str):
	f = geojson.loads(geojson_str)
	g = ogr.CreateGeometryFromJson(geojson.dumps(f['geometry']))
	p = (g.ExportToWkt().replace('POLYGON','') + ',')	
	return 'MULTIPOLYGON ({})'.format(p[:-1])

# Get roads given an area of interest
def get_roads(cf, roadsId, lines=False):
	# Check if existing selection exists [caching]
	if lines:
		outfname = os.path.join(cf.get('Settings', 'tmpdir'), roadsId.rstrip()+'_lines.geojson')
	else:
		outfname = os.path.join(cf.get('Settings', 'tmpdir'), roadsId.rstrip() + '.geojson')

	print('Loading: {}'.format(outfname))
	# Calculate temp roads only if necessary
	if not(os.path.exists(outfname)):
		raise ValueError('The roads layer selected does not exist')

	return outfname

# Get envelope for only the roads [GeoJSON]
def get_roads_envelope_geojson(geojson_file):
  # Read geojson
  with open(geojson_file, 'r') as myfile:
    geojson_str = myfile.read().replace('\n', '')    
    geom = ogr.CreateGeometryFromJson(geojson_str)
    xmin, xmax, ymin, ymax = geom.GetEnvelope()
  return xmin, ymin, xmax, ymax # s,w,n,e

# Get WKT string from bounds
def get_wkt_from_bounds(s, w, n, e):
	wkt_str = 'POLYGON (( {y0} {x0}, {y0} {x1}, {y1} {x1}, {y1} {x0}, {y0} {x0} ))'.format(x0=w, x1=e, y0=s, y1=n)
	return wkt_str

# Get envelope for only the roads [shapefile]
def get_roads_envelope_shp(shp_file):
	# Read shapefile
	driver = ogr.GetDriverByName("ESRI Shapefile")
	dataSource = driver.Open(shp_file, 0)
	layer = dataSource.GetLayer()

	# Get full envelope
	x=[]
	y=[]
	for feature in layer:
		geom = feature.GetGeometryRef()
		xmin, xmax, ymax, ymin = geom.GetEnvelope()
		x.append(xmin)
		x.append(xmax)
		y.append(ymin)
		y.append(ymax)
	layer.ResetReading()

	return min(x), min(y), max(x), max(y) # s,w,n,e

# Get roads as GeoJSON
def get_roads_geojson(cf, geojson_str, buffsize):
	# DB connections
	engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
	+':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
	+'/'+cf.get('PostGIS', 'db'), strategy='threadlocal')

	# Get WKT string [postgis handles better]
	area = get_area_bounds(cf, geojson_str)
	wkt_str = geojson_to_wkt(geojson_str)
	buffsizedeg = float(buffsize)/111139.0

	# PostGIS query [buffer and union]
	bufferQ = '''ST_AsGeoJSON(ST_Intersection(ST_GeomFromText(\'{g}\', {s}), ST_Union(ST_Buffer(wkb_geometry, {b})))) as buffer'''.format(b=buffsizedeg, g=wkt_str, s=4326)
	linesQ = '''ST_AsGeoJSON(ST_Intersection(ST_GeomFromText(\'{g}\', {s}), ST_Union(wkb_geometry))) as lines'''.format(g=wkt_str, s=4326)
	sqlStr = '''SELECT {buffer_query}, {lines_query} FROM {t} WHERE ST_Intersects(wkb_geometry, ST_GeomFromText(\'{g}\', {s}))'''.format(
            	g=wkt_str, s=4326, t='osm_roads_joan', buffer_query=bufferQ, lines_query=linesQ)

	# Get data and close connection [one row]
	resB = engine.execute(sqlStr)
	for r in resB:
		dataBuffered = r.buffer
		dataLines = r.lines
	resB.close()

	return dataBuffered, dataLines


# Coverage functions [for now]
def in_europe(s, w, n, e):
	europe = [-24.7003125, 35.96066995, 47.63671875, 71.87554134]
	return ((n > europe[0]) and (n < europe[2]) # North check
		and (s > europe[0]) and (s < europe[2]) # South check
		and (e > europe[1]) and (e < europe[3]) # East check
		and (w > europe[1]) and (w < europe[3])) # West check

# Culverts/OSM functions
def get_culverts(cf, tableName, wkt_str, workdir, distance):

	# OSM culverts in europe are points, otherwise lines
	shpfName = os.path.join(workdir, 'culverts_{}.shp'.format(distance))
	distance_deg = float(distance)/111120.0 # meters to degrees

	# PostGIS query [buffer and union]
	sql = '''SELECT ST_Union(ST_Buffer(wkb_geometry, {b})) FROM {t} WHERE ST_Within(wkb_geometry, ST_GeomFromText(\'{g}\', {s}))'''.format(
	b=distance_deg, g=wkt_str, t=tableName, s=4326)
		
	# PostGIS connection 
	pg = 'host={h} dbname={d} user={u} password={p}'.format(
	  h=cf.get('PostGIS', 'host'),
	  u=cf.get('PostGIS', 'user'),
	  p=cf.get('PostGIS', 'pass'),
	  d=cf.get('PostGIS', 'db'))	

	# Extraction and concat		
	cmd = '''ogr2ogr -f "ESRI Shapefile" {shp} PG:"{p}" -sql "{s}"'''.format(
		s=sql, p=pg, shp=shpfName)
	os.system(cmd)  
	
	return shpfName

# Get risks per segment on a Roads/GeoJSON + Risk/GeoTiff
def risk_calc(fc_lines, fc_poly, sourceFname):

	# Calculate zonal stats
	print('Calculating zonal stats ...')
	res = zonal_stats(fc_poly, sourceFname, stats="min max mean")
	print('Done')

	i=0
	for g in fc_lines['features']:

		# Default coloring		
		if res[i]['mean'] >= 2.0:
			res[i]['color'] = '#FF0000' # red
		elif res[i]['mean'] >= 1.0:
			res[i]['color'] = '#fff565' # yellow
		else:
			res[i]['color'] = '#00FF00' # green

		# Save results
		g['properties'] = res[i]		

		i+=1

	return fc_lines

# GeoJSON split road multilinestring into a feature collection of linestrings [segments]
def get_roads_splitted(geojson_roads, segment_length, buffer_size):

	# Collection of splitted lines
	print('Splitting roads ...')
	fc = {'type': 'FeatureCollection', 'features': []}
	fcb = {'type': 'FeatureCollection', 'features': []}
	# Parse existing roads selection [single Multilinestring]
	with fiona.open(geojson_roads) as gj:
		for feature in gj:
			geom = feature['geometry']
			shapely_geom = shape(geom)
			# For every LineString
			for line in shapely_geom:
				segs = split_line_multiple(ogr.CreateGeometryFromWkb(line.wkb), length=segment_length)
				for s in segs:
					fc['features'].append(create_feature(s))
					fcb['features'].append(create_feature(s.Buffer(buffer_size)))
	return fc, fcb

# Create a GeoJSON feature from an OGR feature
def create_feature(g):
	feat = {
		'type': 'Feature',
		'properties': {},
		'geometry': json.loads(g.ExportToJson())
	}
	return feat
