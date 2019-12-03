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
# http://localhost:5000/wps?request=Execute&service=WPS&identifier=ra2ce_select_hazard&version=1.0.0&datainputs=json_matrix={"values":[[1,1,3,1,1],[1,1,4,1,1],[1,1,5,1,1],[1,1,2,1,1],[1,1,1,1,5]]};layer_name=bosbermbranden
# https://ri2de.openearth.eu/wps?request=Execute&service=WPS&identifier=ra2ce_select_hazard&version=1.0.0&datainputs=layer_name=bosbermbranden

# other
from pywps import Process, Format
from pywps.inout.inputs import LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata
import json
import logging

# local
from processes.ra2ceutils import readConfig, select_from_db, calccosts

class WpsRa2ceSelectHazard(Process):

    def __init__(self):
		# Input [in json format]
        inputs = [LiteralInput('json_matrix', 'matrix with priorities', data_type='string'),
                  LiteralInput('layer_name', 'selected hazard layer', data_type='string')]

		# Output [in json format]
        outputs = [ComplexOutput('output_json',
		                         'Ra2ce calculation of costs',
		                         supported_formats=[Format('application/json')])]

        super(WpsRa2ceSelectHazard, self).__init__(
		    self._handler,
		    identifier='ra2ce_select_hazard',
		    version='1.0',
		    title='backend process for the RA2CE POC, gets user input to select a hazard layer to calculate the cost',
		    abstract='It uses PostgreSQL to identify the right uid for the layer selected by the user\
		     which is used to get the right layer from the Postgres database',
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

            # Read input
            json_matrix = request.inputs["json_matrix"][0].data
            layer_name = request.inputs["layer_name"][0].data
            logging.info('INPUT [layer_name] = {}'.format(layer_name))
            operator_layer, societal_layer = select_from_db(cf, layer_name)

            res = calccosts(cf, layer_name, json_matrix)

    		# Set output
            response.outputs['output_json'].data = res

    		# Set output
            logging.info("res = {}".format(operator_layer))

        except Exception as e:
            res = { 'errMsg' : 'ERROR: {}'.format(e) }
            logging.info('''WPS [WpsSelectHazard]: ERROR = {}'''.format(e))
            response.outputs['output_json'].data = json.dumps(res)

        return response


