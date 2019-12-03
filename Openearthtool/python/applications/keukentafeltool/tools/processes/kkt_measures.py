# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for Keukentafeltool
#
#   Gerrit Hendriksen <Gerrit.Hendriksen@deltares.nl>
#   Joan Sala Calero <joan.salacalero@deltares.nl>
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

# PyWPS
from pywps import Process, Format, FORMATS
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import sqlfunctions
import json
import os

# Path to file
cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pg_credentials.txt')

class KKT_measures(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = []

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Keukentafeltool available measure list',
		                         supported_formats=[Format('application/json')])]

		super(KKT_measures, self).__init__(
		    self._handler,
		    identifier='kkt_measures',
		    version='1.3.3.7',
		    title='list of available measures and measure groups',
		    abstract='This process makes queries to the HydroMetra database\
		     and sends back a JSON reply wrapped in the xml/wps format',
		    profile='',
		    metadata=[Metadata('KKT_measures'), Metadata('Parcelen/Effecten/Maatregelen')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

	def measuresQuery(self):
		# DB connect		
		credentials = sqlfunctions.get_credentials(cf)
		
		# Execute query
		sqlStr = """select m.mid, m.description, m.hyperlink, mg.groupid, mg.description  
		            from measures.measure m
                    join measures.measurementgroup mg on mg.groupid = m.groupid"""		
		try:
			res = sqlfunctions.executesqlfetch(sqlStr, credentials)
		except:
			print 'ERROR: on query = {}'.format(sqlStr)

		# Return result
		return res

	def _handler(self, request, response):
		# Get Measures
		res = []
		for mr in self.measuresQuery():			
			mid, mid_desc,hlink,gid, gid_desc = mr
			tpd = dict()
			tpd['mid'] = mid
			tpd['midText'] = mid_desc
			tpd['hlink'] = hlink
			tpd['gid'] = gid			
			tpd['gidText'] = gid_desc			
			res.append(tpd)

		# Set output
		response.outputs['output_json'].data = json.dumps(res)

		return response
