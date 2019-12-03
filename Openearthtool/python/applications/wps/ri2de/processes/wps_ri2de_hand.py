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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_slope.py $
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

class WpsRi2deHand(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [LiteralInput('roads_identifier', 'Identifier of the road selection given by the wps_ri2de_roads function', data_type='string'),
				  ComplexInput('layers_setup', 'HAND layer to perform the calculation',
		                       [Format('application/json')],
		                       abstract="Complex input abstract", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Ri2DE calculation with the HAND layer [0,1,2]',
		                         supported_formats=[Format('application/json')])]

		super(WpsRi2deHand, self).__init__(
		    self._handler,
		    identifier='ri2de_calc_hand',
		    version='1.0',
		    title='backend process for the RI2DE tool project, assigns classes to the road layer based on the HAND values',
		    abstract='It classifies the HAND layer into several classes [0,1,2]\
		     and sends back a JSON reply wrapped in the xml/wps format with the wmslayer to show',
		    profile='',
		    metadata=[Metadata('WpsRi2deHand'), Metadata('Ri2DE/hand')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

	## MAIN
	def _handler(self, request, response):

		try:
			# Read input
			layers_jsonstr, layer_info, roadsId = read_input(request)
            
            # call function that reads the config, calls the actual function and returns
            # the config dictionary and wmslayer as result
            cf,wmslayer = parsefunction(layers_jsonstr, layer_info, roadsId)

			# Set output
			response.outputs['output_json'].data = write_output(cf, wmslayer)
		
		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)	

		return response
    
    def parsefunction(layers_jsonstr, layer_info, roadsId):
        	# Read configuration
			cf = read_config()

			# Get roads GeoJSON and exact bounds
			geoFname = get_roads(cf, roadsId)
			s,w,n,e = get_roads_envelope_geojson(geoFname)
						
			# Data extraction [HAND Height Above Nearest Drainage] / wcs						
			handfname = os.path.join(self.workdir, 'hand.tif')			
			cut_wcs(s,w,n,e, layer_info['layername'], layer_info['owsurl'], handfname)			

			# create temporary file			
			handclassfname = os.path.join(self.workdir, 'hand_{}.tif'.format(int(1000000*time.time())))			

			# Classify slope			
			classfname = classify_raster(handfname, self.workdir, layer_info['classes'], '123')

			# Apply mask		
			apply_road_mask(cf, classfname, geoFname, self.workdir)

			# Upload to GeoServer to TEMP workspace
			layername = os.path.basename(slopefname).replace('.tif', '')
			wmslayer = geoserver_upload_gtif(cf, layername, classfname)
         return cf,wmslayer
            



