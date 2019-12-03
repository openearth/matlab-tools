# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_slope.py $
# $Keywords: $
# http://localhost:5000/wps?request=Execute&service=WPS&identifier=ra2ce_calc_ratio&version=1.0.0&datainputs=layer_name=plasvorming;json_matrix={"values":[[1,1,3,1,1],[1,1,4,1,1],[1,1,5,1,1],[1,1,2,1,1],[1,1,1,1,5]]}
# PyWPS

# https://ri2de.openearth.eu/wps?service=wps&version=1.0.0&request=DescribeProcess&Identifier=ra2ce_calc_ratio

from pywps import Process, Format
from pywps.inout.inputs import LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import logging

# local
from processes.ra2ceutils import readConfig, calccosts

class WpsRa2ceRatio(Process):

    def __init__(self):
        # Input [in json format ]
        inputs = [LiteralInput('layer_name', 'name of layer in db', data_type='string'),
				  LiteralInput('json_matrix', 'matrix with priorities', data_type='string')]

        # Output [in json format]
        outputs = [ComplexOutput('output_json',
		                         'Ra2ce calculation of costs',
		                         supported_formats=[Format('application/json')])]

        super(WpsRa2ceRatio, self).__init__(
		    self._handler,
		    identifier='ra2ce_calc_ratio',
		    version='1.0',
		    title='backend process for the RA2CE POC, calculates the ratio between Annual Repair costs and Societial Costs',
		    abstract='It uses PostgreSQL to calculate the ratio\
		     using 2 columns of a table and answer via a JSON reply, wrapped in the xml/wps format with the wmslayer to show',
		    profile='',
		    metadata=[Metadata('WpsRa2ceRatio'), Metadata('Ra2CE/ratio')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

    ## MAIN
    def _handler(self, request, response):
        logging.info("""request = {}""".format(request))
        try:
            # Read configuration
            cf = readConfig()

            # Read input
            json_matrix = request.inputs["json_matrix"][0].data
            layer_name = request.inputs["layer_name"][0].data.strip()

            res = calccosts(cf, layer_name, json_matrix)

    		# Set output
            response.outputs['output_json'].data = res

        except Exception as e:
            res = { 'errMsg' : 'ERROR: {}'.format(e) }
            logging.info('''WPS [WpsRa2ceRatio]: ERROR = {}'''.format(e))
            response.outputs['output_json'].data = res

        return response

