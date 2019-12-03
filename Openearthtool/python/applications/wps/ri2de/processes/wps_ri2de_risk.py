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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_calc.py $
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


class WpsRi2deRisk(Process):

    def __init__(self):
        # Input [in json format ]
        inputs = [
            LiteralInput('roads_identifier', 'Identifier of the road selection given by the wps_ri2de_roads function',
                         data_type='string'),
            LiteralInput('buffer_dist', 'Distance taken by the calculation',
                         data_type='string'),
            LiteralInput('segment_length', 'Road network will be divided in this segment length',
                         data_type='string'),
            ComplexInput('layers_setup', 'risk raster layer to perform the calculation with',
                         [Format('application/json')],
                         abstract="Complex input abstract", )]

        # Output [in json format]
        outputs = [ComplexOutput('output_json',
                                 'Ri2DE risk assessment per segment size, vector layer',
                                 supported_formats=[Format('application/json')])]

        super(WpsRi2deRisk, self).__init__(
            self._handler,
            identifier='ri2de_calc_risk',
            version='1.0',
            title='final calculation step for the Ri2DE tool. Translation of final calculation to segments of a given size.',
            abstract='This process performs the main calculation and averaging\
		     and sends back a JSON reply wrapped in the xml/wps format with the geojson content to display',
            profile='',
            metadata=[Metadata('WpsRi2deCalc'), Metadata('Ri2DE/calculation')],
            inputs=inputs,
            outputs=outputs,
            store_supported=False,
            status_supported=False
        )

    def _handler(self, request, response):

        try:
            # Read configuration
            cf = read_config()

            # Read input
            layers_jsonstr, layer_info, roadsId = read_input(request)
            buffer_dist, segment_length = read_input_segments(request)

            # Get roads GeoJSON and exact bounds
            roads_fname = get_roads(cf, roadsId, lines=True)

            # Get roads splitted
            roads_split, roads_split_buff = get_roads_splitted(roads_fname, float(segment_length)/111139.0, float(buffer_dist)/111139.0) # meters to degrees

            # Get source raster [cached]
            source_fname = os.path.join(cf.get('Settings', 'tmpdir_data'), layer_info['layername'].split(':')[1]+'.tif')

            # Risk [calculation]            
            result = risk_calc(roads_split, roads_split_buff, source_fname)

            # Set output
            response.outputs['output_json'].data = json.dumps(result)

        except Exception as e:
            res = {'errMsg': 'ERROR: {}'.format(e)}
            response.outputs['output_json'].data = json.dumps(res)

        return response
