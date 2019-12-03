# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Ioanna Micha
#       ioanna.micha@deltares.nl
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_custom.py $
# $Keywords: $


# PyWPS
from pywps import Process, Format, FORMATS
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

#other

import json


# local
from processes.utils import *
from processes.utils_csw import *
from processes.utils_geoserver import *
from processes.utils_raster import *
from processes.utils_vector import *

class WpsGetRecordsUrl(Process):


	def __init__(self):
		 #Input [in json format ]
		inputs = [
				  LiteralInput('roads_identifier',
							   'Identifier of the road selection given by the wps_ri2de_roads function',
							   data_type='string'),
				  ComplexInput('csw_url',
							   'Catalogue service ows url',
							   [Format('application/json')],
		                       abstract="Complex input abstract", ),
				  ComplexInput('keywords', 'keywords',
		                       [Format('application/json')],
		                       abstract="Complex input abstract", )
		]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Records owsurls',
		                         supported_formats=[Format('application/json')])]

		super(WpsGetRecordsUrl, self).__init__(
			self._handler,
			identifier='getrecords_url',
		    version='1.0',
		    title='getrecords operation and extraction of owsurls',
		    abstract='It uses the owslib in order to implement the getrecords operation of the csw 2.0.2 ',
			profile='',
			metadata=[Metadata('WpsGetRecordsUrl'), Metadata('Ri2DE/GetRecordsUrl')],
			inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

	## MAIN
	def _handler(self, request, response):
		try:
			#1 Read configuration
			cf = read_config()

			#2 read data from request
		
			cswUrl_jsonstr = request.inputs["csw_url"][0].data
			roadsId = request.inputs["roads_identifier"][0].data.strip()
			keywords_jsonstr = request.inputs["keywords"][0].data
		

			# Get roads GeoJSON and exact bounds
			geoFname = get_roads(cf, roadsId)
			s,w,n,e = get_roads_envelope_geojson(geoFname)
			bbox = [s,w,n,e]
	
			# Get keywords
			keywords = json_loads_byteified(keywords_jsonstr)
			filter_object = createFilterList(keywords["keywords"],bbox)
	
			# Search records
			cswUrl = json_loads_byteified(cswUrl_jsonstr)
			records = get_csw_records(cswUrl["csw"], filter_object)

			# Set output
			response.outputs['output_json'].data = json.dumps(records)

		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)	
		
	
		return response




