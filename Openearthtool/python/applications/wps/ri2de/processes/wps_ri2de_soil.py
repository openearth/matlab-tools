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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_soil.py $
# $Keywords: $

# PyWPS
from pywps import Process, Format, FORMATS
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import json
import geojson
import os
import time

# local
from processes.utils import *
from processes.utils_raster import *
from processes.utils_vector import *
from processes.utils_geoserver import *

class WpsRi2deSoil(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [LiteralInput('roads_identifier', 'Identifier of the road selection given by the wps_ri2de_roads function', data_type='string'),
				  ComplexInput('layers_setup', 'culverts layer to perform the calculation with',
		                       [Format('application/json')],
		                       abstract="Complex input abstract", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Ri2DE calculation of a soil layer [1,2,3]',
		                         supported_formats=[Format('application/json')])]

		super(WpsRi2deSoil, self).__init__(
		    self._handler,
		    identifier='ri2de_calc_soil',
		    version='1.0',
		    title='backend process for the RI2DE tool project, calculates soil and classifies into classes',
		    abstract='It uses gdal tools to calculate soil\
		     and sends back a JSON reply wrapped in the xml/wps format with the wmslayer to show',
		    profile='',
		    metadata=[Metadata('WpsRi2deSoil'), Metadata('Ri2DE/soil')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

	## MAIN
	def _handler(self, request, response):

		try:
			# Read configuration
			cf = read_config()

			# Read input
			layers_jsonstr, layer_info, roadsId = read_input(request)

			# Get roads GeoJSON and exact bounds
			geoFname = get_roads(cf, roadsId)
			s,w,n,e = get_roads_envelope_geojson(geoFname)
						
			# Data extraction [Soil map] / wcs			
			soilLayers = ["CLYPPT", "SLTPPT", "SNDPPT"]
			for sl in soilLayers:
				for lev in range(1,8):
					layerName = 'ISRIC:{}_M_sl{}_250m'.format(sl, lev)
					soilFname = os.path.join(self.workdir, '{}_L{}.tif'.format(sl, lev))
					print(layer_info['owsurl'])
					print(layerName)
					cut_wcs(s,w,n,e, layerName, layer_info['owsurl'], soilFname)
			
			# Soil map calculation
			soilfname = os.path.join(self.workdir, 'soil_{}.tif'.format(int(1000000*time.time())))
			combine_soil_layers(self.workdir, soilfname)

			# Apply mask		
			apply_road_mask(cf, soilfname, geoFname, self.workdir)

			# Upload to GeoServer to TEMP workspace			
			layername = os.path.basename(soilfname).replace('.tif', '')
			wmslayer = geoserver_upload_gtif(cf, layername, soilfname)

			# Set output
			response.outputs['output_json'].data = write_output(cf, wmslayer)
		
		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)

		return response
