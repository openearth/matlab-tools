# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
#       Gerrit Hendriksen, after Joan Sala
#       gerrit.hendriksen@deltares.nl
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/brl_modelling/processes/brl_watercourses.py $
# $Keywords: $

"""
describe http://localhost:5000/wps?request=DescribeProcess&service=WPS&identifier=brl_watercourses&version=1.0.0
execute http://localhost:5000/wps?request=Execute&service=WPS&identifier=brl_watercourses&version=1.0.0&DataInputs=geojson_area={"id":"88c50716c0288377dcec68e5e0f010c4","type":"Feature","properties":{},"geometry":{"coordinates":[[[6.1289, 52.2557],[6.1561, 52.2407],[6.1634, 52.2511],[6.1368, 52.2650],[6.1289, 52.2557],[6.1289, 52.2557]]],"type":"Polygon"}}
execute on server https://basisrivierbodemligging.openearth.nl/wps?request=Execute&service=WPS&identifier=brl_watercourses&version=1.0.0&DataInputs=geojson_area={"id":"88c50716c0288377dcec68e5e0f010c4","type":"Feature","properties":{},"geometry":{"coordinates":[[[6.1289, 52.2557],[6.1561, 52.2407],[6.1634, 52.2511],[6.1368, 52.2650],[6.1289, 52.2557],[6.1289, 52.2557]]],"type":"Polygon"}}
"""
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
from processes.brl_utils import *
from processes.brl_utils_vector import *

class WpsBRLWatercourse(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [ComplexInput('geojson_area', 'Area of interest', 
                         [Format('application/json')], abstract="Complex input abstract", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'BRL extraction of watercourses (only primary RWS waterways) for a certain area',
		                         supported_formats=[Format('application/json')])]

		super(WpsBRLWatercourse, self).__init__(
		    self._handler,
		    identifier='brl_watercourses',
		    version='1.0',
		    title='backend process for the BRL tool to extract watercourses',
		    abstract='It uses the power of PostGIS to extract line objects within the given boundary and also returns an extent later used in the modelling part',
		    profile='',
		    metadata=[Metadata('WpsBRLWatercoarse'), Metadata('BRL/water')],
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

			# Query roads
			watersId = 'waters_{}'.format(int(1000000*time.time()))
			waterLines,waterPoly = get_waters_geojson(cf, area_jsonstr)
			
			# Write roads - to read later in calculations
			tmpdir = cf.get('wps', 'tmp')
			geofileL = open(os.path.join(tmpdir, watersId+'_lines.geojson'), 'w')
			geofileL.write(waterLines)
			extentP = open(os.path.join(tmpdir, watersId+'_extent_rd.geojson'), 'w')
			extentP.write(waterPoly)

			# Set output
			res = dict()
			res['watersCollection'] = json.loads(waterLines)			
			res['watersIdentifier'] = watersId
			response.outputs['output_json'].data = json.dumps(res)
		
		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e)}
			response.outputs['output_json'].data = json.dumps(res)	

		return response
