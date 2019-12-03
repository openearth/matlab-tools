# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
#       Gerrit Hendriksen
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_calc.py $
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
from processes.utils import *

class WpsRi2deSusceptibilities(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = []

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Ri2DE global configuration and settings',
		                         supported_formats=[Format('application/json')])]

		super(WpsRi2deSusceptibilities, self).__init__(
		    self._handler,
		    identifier='ri2de_susceptibilities',
		    version='1.0',
		    title='Susceptibilities configuration process for the RI2DE tool project',
		    abstract='This process replies with list of susceptibilities',
		    profile='',
		    metadata=[Metadata('WpsRi2deSusceptibilities'), Metadata('Ri2DE/configsusceptibilities')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)


	def _handler(self, request, response):

		try:		
			# Read configuration
			susceptibilitiesFname = read_susceptibilities()
         
			# Get area bounds [south, west, north, east]
			if not os.path.exists(susceptibilitiesFname):
				raise ValueError('The configuration file was not found')
			
			# Set output
			with open(susceptibilitiesFname, 'r') as fn:
				data = json.load(fn)
				response.outputs['output_json'].data = json.dumps(data, indent=4, sort_keys=True)

		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)

		return response
