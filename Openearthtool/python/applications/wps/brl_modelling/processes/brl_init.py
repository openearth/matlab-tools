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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/brl_modelling/processes/brl_init.py $
# $Keywords: $

# PyWPS
from pywps import Process, Format, FORMATS
from pywps.inout.inputs import ComplexInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import os
import json

# local
from processes.brl_utils import read_config

class WpsBRLInit(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = []

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'BRL global configuration and settings',
		                         supported_formats=[Format('application/json')])]

		super(WpsBRLInit, self).__init__(
		    self._handler,
		    identifier='brl_init',
		    version='1.0',
		    title='main configuration process for the BaseRiverBed project',
		    abstract='This process replies back with the backend configuration',
		    profile='',
		    metadata=[Metadata('WpsBRLInit'), Metadata('BRL/configuration')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)


	def _handler(self, request, response):

		try:		
			# Read configuration
			layersFname = read_config()

			# Get area bounds [south, west, north, east]
			if not os.path.exists(layersFname):
				raise ValueError('The configuration file was not found')
			
			# Set output
			with open(layersFname, 'r') as fn:
				data = json.load(fn)
				response.outputs['output_json'].data = json.dumps(data, indent=4, sort_keys=True)

		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)

		return response
