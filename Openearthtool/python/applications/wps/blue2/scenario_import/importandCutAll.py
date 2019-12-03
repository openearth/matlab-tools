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

from netcdfReader import *
from shpReader import *
from Rasterizer import *

import json
import sys

## MAIN ##
if __name__ == "__main__":

	# Read configuration into dictionary
	with open(sys.argv[1]) as handle:
		conf = json.loads(handle.read())

	# Output dir create if necessary
	if not os.path.exists(conf['outputDir']):
		os.mkdir(conf['outputDir'])
	if not os.path.exists(conf['tmpDir']):
		os.mkdir(conf['tmpDir'])

	# Read shapefiles
	shapes = {}	
	for s,sp in conf['shapefiles'].iteritems():
		rs = Rasterizer(conf['tmpDir'], conf['modelMask'], sp['file'], sp['field'])
		shapes[s] = rs.rasterizeAll()

	# Find netcdf files recursively
	ncfiles = []
	for root, directories, filenames in os.walk(conf['inputDir']):
		for f in filenames:
			if f.endswith('.nc'):
				ncfiles.append(os.path.join(root, f))

	# For every netcdf file
	i=0.0
	percent=0.0

	for f in ncfiles:
		try:
			pathArr = os.path.normpath(f).split(os.sep)
			dataname = os.path.basename(f).replace('.nc', '')
			scenarioname = pathArr[-2]
			modelname = pathArr[-3]
			nc = ncFile(f)
			print '--------------------------------------------------'
			print '{}% - File: {}'.format(percent, f)
			print '{}% - Variables: {}'.format(percent, nc.variables)
			print '{}% - Timesteps: {}'.format(percent, len(nc.timesteps))		
				
		except Exception, e: 
			print 'ERROR: ' + str(e)
			print 'ERROR: Invalid netcdf {}'.format(f)
		
		# For every variable in the netCDF		
		for v in nc.variables:			
			# For every geometry in every shapefile
			for idShp, dictList in shapes.iteritems():
				# Naming convention
				pgtable = '{}_{}_{}_{}_{}'.format(idShp, modelname, scenarioname, dataname, v)
				if conf['outputDB']['schema'] == 'mmf':
					pgtable = pgtable = '{}_mmf_{}'.format(idShp, v)
				outshp = os.path.join(conf['outputDir'], pgtable+'.shp')

				if os.path.exists(outshp):
					print '{}% - Skipping table: {}'.format(percent, pgtable)
				else:
					print '{}% - Filling table: {}'.format(percent, pgtable)				
					# Function that extracts value for every timestep/geometry 
					gdf = nc.maskNetdfwithGeometries(v, dictList, conf["crs"])		
					# Write shapefile
					gdf.to_file(driver='ESRI Shapefile', filename=outshp)

		# Update progress
		i+=1.0
		percent = 100.0*round(float(i)/float(len(ncfiles)), 3)

		
	#nc = ncFile()
	#nc.parseFile(fname)