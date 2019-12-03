# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
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

from pywps import Process, LiteralInput, LiteralOutput, ComplexOutput, ComplexInput, Format
from pywps.app.Common import Metadata
from pywps.inout.formats import FORMATS
from processes.make_plots import make_plots
import json

class MakePlots(Process):
    def __init__(self):
        inputs = [ComplexInput('json_input','Input locations, parameters, start/end dates, and analysis type in JSON format',supported_formats=[Format('application/json')])]
        outputs = [ComplexOutput('json_output','Output HTML script and div in JSON format',supported_formats=[Format('application/json')])]

        super(MakePlots, self).__init__(
            self._handler,
            identifier='wps_make_plots',
            version='1.0',
            title='Analyze and plot Pulau Tekong data',
            abstract='Analyze and plot one or more location-parameter combinations.',
            profile='',
            metadata=[Metadata('Make Plots'), Metadata('Analyze and plot Pulau Tekong data')],
            inputs=inputs,
            outputs=outputs,
            store_supported=False,
            status_supported=False
        )

    def _handler(self, request, response):
        result = make_plots(request.inputs)
        response.outputs['output'].data = json.dumps(result)
        return response
