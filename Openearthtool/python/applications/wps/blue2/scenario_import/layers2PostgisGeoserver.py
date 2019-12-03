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
# $Keywords: $

import os
import sys
import json
from geoalchemy2 import Geometry, WKTElement
from sqlalchemy import *
import geopandas as gpd
import pandas as pd

## MAIN ##
if __name__ == "__main__":

	# Read configuration into dictionary
	with open(sys.argv[1]) as handle:
		conf = json.loads(handle.read())

	# Read shapefiles [they have the same structure]
	for s,sp in conf['shapefiles'].iteritems():
		divTable = s
		idField = sp['field']		
		otherFields = sp['otherfields']

	# Creating SQLAlchemy's engine to use
	engine = create_engine('postgresql://{u}:{p}@{h}:5432/{d}'.format(
				u=conf['outputDB']['user'], d=conf['outputDB']['db'], p=conf['outputDB']['pass'], h=conf['outputDB']['host']
			)
	)

	# Find shp files recursively
	os.chdir(conf['outputDir'])
	shpfiles = []
	for root, directories, filenames in os.walk('.'):
		for f in filenames:
			if f.endswith('.shp'):
				
				# Read shapefile without geometry
				gdf = gpd.read_file(f)
				gdf.drop('geometry', 1, inplace=True)

				# Get columns
				cols = list(gdf)
				cols.pop(0) 									# without index
				gdf[cols] = gdf[cols].apply(pd.to_numeric)		# tseries to number
				 
				# Write PostGIS table / overwrite
				t = os.path.basename(f).replace('.shp', '')
				s = conf['outputDB']['schema']
				print '--------------------------------------------------'
				print 'File: {}'.format(f)			
				print 'Table: {}.{}'.format(s, t) 								
				gdf.to_sql(t, engine, if_exists='replace', index=False, schema=s)
