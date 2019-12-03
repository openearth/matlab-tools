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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_roads.py $
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

class WpsRi2deRoads(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [LiteralInput('buffer_dist', 'Road buffer size in meter', data_type='string'),
				  ComplexInput('geojson_area', 'Area of interest', [Format('application/json')], abstract="Complex input abstract", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Ri2DE extraction of roads for a certain area',
		                         supported_formats=[Format('application/json')])]

		super(WpsRi2deRoads, self).__init__(
		    self._handler,
		    identifier='ri2de_calc_roads',
		    version='1.0',
		    title='backend process for the RI2DE extraction of roads',
		    abstract='It uses the power of PostGIS',
		    profile='',
		    metadata=[Metadata('WpsRi2deRoads'), Metadata('Ri2DE/roads')],
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
			area_jsonstr = request.inputs["geojson_area"][0].data
			buffer_dist = request.inputs["buffer_dist"][0].data

			# Query roads
			roadsId = 'roads_{}'.format(int(1000000*time.time()))
			roadsBuff, roadsLines = get_roads_geojson(cf, area_jsonstr, buffer_dist)
			
			# Write roads - to read later in calculations
			geofile = open(os.path.join(cf.get('Settings', 'tmpdir'), roadsId+'.geojson'), 'w')
			geofile.write(roadsBuff)
			geofileL = open(os.path.join(cf.get('Settings', 'tmpdir'), roadsId+'_lines.geojson'), 'w')
			geofileL.write(roadsLines)

			# Set output
			res = dict()
			res['roadsCollection'] = json.loads(roadsLines)			
			res['roadsIdentifier'] = roadsId
			response.outputs['output_json'].data = json.dumps(res)
		
		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)	

		return response
