# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
#       Frederique de Groen
#       frederique.degroen@deltares.nl
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

# http://localhost:5000/wps?request=Execute&service=WPS&identifier=ra2ce_provide_hazard_list&version=1.0.0
# https://ri2de.openearth.eu/wps?request=Execute&service=WPS&identifier=ra2ce_provide_hazard_list&version=1.0.0


# other
from pywps import Process, Format
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata # to do
import json
import logging
from sqlalchemy import create_engine

# local
from processes.ra2ceutils import readConfig

class WpsRa2ceProvideHazardList(Process):

    def __init__(self):
		# Input [in json format] - no inputs
        inputs = [] # no inputs

		# Output [in json format]
        outputs = [ComplexOutput('output_json',
		                         'Ra2ce operator cost layer from selected hazard',
		                         supported_formats=[Format('application/json')])]

        super(WpsRa2ceProvideHazardList, self).__init__(
		    self._handler,
		    identifier='ra2ce_provide_hazard_list',
		    version='1.0',
		    title='backend process for the RA2CE POC, gives the front-end the list of hazards',
		    abstract='It loads a list from a PostgreSQL database to provide to the front-end',
		    profile='',
#		    metadata=[Metadata('WpsRa2ceSelectHazard'), Metadata('RA2CE/select_hazard')], # TO DO
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
            )

    ## MAIN
    def _handler(self, request, response):
        try:
            # Read configuration
            cf = readConfig()

            # connect to database
            engine = create_engine('postgresql+psycopg2://'+cf.get('PostGis', 'user')
			    +':'+cf.get('PostGis', 'pass')+'@'+cf.get('PostGis', 'host')+':'+str(cf.get('PostGis', 'port'))
			    +'/'+cf.get('PostGis', 'db'), strategy='threadlocal')

        	#first set everything to 0 and create a new view
            strSql = """select name, layer_name from ra2ce.layernames;"""
            ressql = engine.execute(strSql)

            # get the name of the layer/table in postgresql
            list_names, list_layers = [], []
            for row in ressql:
                list_layers.append(row['layer_name'])
                list_names.append(row['name'])

    		# Set output
            res = [{"layer_name": l, "name": n} for l, n in zip(list_layers, list_names)]
            response.outputs['output_json'].data = json.dumps(res)
            logging.info("res = {}".format(list_layers))

        except Exception as e:
            res = { 'errMsg' : 'ERROR: {}'.format(e) }
            logging.info('''WPS [WpsRa2ceProvideHazardList]: ERROR = {}'''.format(e))
            response.outputs['output_json'].data = json.dumps(res)

        return response

