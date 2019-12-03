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
from pywps.inout.inputs import ComplexInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import sqlfunctions
import json
import os

# Path to file
cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pg_credentials.txt')

class KKT(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [ComplexInput('input_json', 'Complex input title',
		                       [Format('application/json')],
		                       abstract="Complex input abstract.", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'KeukenTafel tool backend output [from Hydrometra]',
		                         supported_formats=[Format('application/json')])]

		super(KKT, self).__init__(
		    self._handler,
		    identifier='kkt',
		    version='1.3.3.7',
		    title='main backend process for the KeukenTafel tool project',
		    abstract='This process makes queries to the HydroMetra database\
		     and sends back a JSON reply wrapped in the xml/wps format',
		    profile='',
		    metadata=[Metadata('KKT'), Metadata('Parcelen/Effecten/Maatregelen')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

	def effectQuery(self, pid, mids):
		# DB connect
		credentials = sqlfunctions.get_credentials(cf)

		# Execute query
		sqlStr = """
		    select
		       p.id,
		       m.mid,
		       m.description,
		       st_area(wkb_geometry)/10000 as area,
		       p.refno3,
		       p.refndrain,
		       p.refpdrain,
		       m.effectno3 as effno3,
		       m.effectndrain as effndrain,
		       m.effectpdrain as effpdrain,
		       m.effectno3 as dno3,
		       m.effectndrain as dndrain,
		       m.effectpdrain as dpdrain
		       from percelen p, measures.measure m
		       join measures.measurementgroup mg on mg.groupid = m.groupid
		       where (p.id = {p} and m.mid in ({m}))
		""".format(p=pid, m=','.join(map(str, mids)))

		try:
			res = sqlfunctions.executesqlfetch(sqlStr, credentials)
		except:
			print 'ERROR: on query = {}'.format(sqlStr)

		# Return result
		return res

	def _handler(self, request, response):
		# Read input
		jsonstr = request.inputs["input_json"][0].data
		print 'INPUT: {}'.format(jsonstr)
		inp = json.loads(jsonstr)

		# For every parcel + list of measures
		res = dict()
		res['effects'] = []
		res['totals'] = []

		for p in inp:
			sqlres = self.effectQuery(p['pid'], p['mids'])
			p['reference'] = { 'no3': 0.0, 'pdrain': 0.0, 'ndrain': 0.0 }
			p['effect'] = { 'no3': 0.0, 'pdrain': 0.0, 'ndrain': 0.0 }
			p['delta'] = { 'no3': 0.0, 'pdrain': 0.0, 'ndrain': 0.0 }

			for tr in sqlres:
				pid, mid, description, area, refno3, refndrain, refpdrain, effno3, effndrain, effpdrain, dno3, dndrain, dpdrain= tr
				tpd = dict()
				tpd['pid'] = pid
				tpd['mid'] = mid
				tpd['description'] = description
				tpd['references'] = {
					'ndrain': refndrain,
					'pdrain': refpdrain,
					'no3': refno3
				}
				tpd['effects'] = {
					'ndrain': effndrain,
					'pdrain': effpdrain,
					'no3': effno3
				}
				tpd['deltas'] = {
					'ndrain': dndrain,
					'pdrain': dpdrain,
					'no3': dno3
				}
				# Append values
				res['effects'].append(tpd)

				# Add up totals
				p['reference']['no3'] = refno3
				p['reference']['pdrain'] = refpdrain
				p['reference']['ndrain'] = refndrain
				p['effect']['no3'] += refno3*(effno3/100)
				p['effect']['pdrain'] += refpdrain*(effpdrain/100)
				p['effect']['ndrain'] += refndrain*(effndrain/100)
				p['delta']['no3'] += refno3*(dno3/100)
				p['delta']['pdrain'] += refpdrain*(dpdrain/100)
				p['delta']['ndrain'] += refndrain*(dndrain/100)

			# Append totals
			p['effect']['no3']=refno3+p['effect']['no3']
			p['effect']['pdrain']=refpdrain+p['effect']['pdrain']
			p['effect']['ndrain']=refndrain+p['effect']['ndrain']
			res['totals'].append(p)

		# Set output
		response.outputs['output_json'].data = json.dumps(res)

		return response
