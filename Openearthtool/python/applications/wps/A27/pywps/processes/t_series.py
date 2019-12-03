#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for <projectdata>
#       Lilia Angelova
#       Lilia.Angelova@deltares.nl
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

from pywps.app import Process
from pywps import Format, FORMATS
from pywps.inout.outputs import LiteralOutput
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata
import logging
import simplejson as json
from bokeh.plotting import figure, show, output_file, save
import time
import os
from processes.t_series_plot_lines import *


class HeadSeries(Process):
    def __init__(self):
        inputs = []
        outputs = [ComplexOutput('output_json', 'HTML plot',
                    supported_formats=[Format('application/json')])]

        super(HeadSeries, self).__init__(
            self._handler,
            identifier='t_series',
            version='1.0',
            title='Timeseries plot of ground water levels',
            abstract='The process provides an overview of the ground water levels in the selected well.',
            profile='',
            metadata=[Metadata('Head Series')],
            inputs=inputs,
            outputs=outputs,
            store_supported=False,
            status_supported=False
        )

    def _handler(self, request, response):
        
        values = {}
        location = 5723323
        try:
            plot = heads_plot(location)
            logging.info(plot)
            tempdir = os.path.join(os.path.curdir, 'data\{}.html').format(location)
            logging.info(os.path.curdir)
            output_file(tempdir)
            save(plot)

            # Send back result JSON     
            values['url_plot'] = tempdir
            values['title'] = 'Ground water levels'
            json_str = json.dumps(values)
            #logging.info('''OUTPUT [plot]: {}'''.format(json_str))
            response.outputs['output_json'].data = json_str
            return response

        except Exception as e:
            res = { 'errMsg' : 'ERROR: {}'.format(e) }
            response.outputs['output_json'].data = json.dumps(res)
        # except:
        #     values['url_plot'] = os.path.join(os.path.curdir, 'data\dummy_plot.html')
        #     json_str = json.dumps(values)
        #     response.outputs['output_json'].data = json_str
        #     return response


