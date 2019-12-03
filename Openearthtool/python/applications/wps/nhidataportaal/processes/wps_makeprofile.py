# -*- coding: utf-8 -*-
"""
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for LHM functions
#
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

"""

# core
import os
import tempfile
import logging
import configparser
import time

# modules
import types
import simplejson as json
import io
from pywps import Format
from pywps.app import Process
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import LiteralOutput,ComplexOutput
from pywps.app.Common import Metadata
from pywps.inout.formats import FORMATS

# Self libraries
from .makeprofile import *
from .coords import *
from shapely.wkt import loads

#from meetlocaties_plot import *
logger = logging.getLogger('PYWPS')
"""
This is a redesigned WPS LHM Data Portal
"""

# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')


class wps_makeprofile(Process):
    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [LiteralInput(identifier="location",
                                            title="Selecteer een locatie en druk op execute",
                                            abstract="input=mapselection",
                                            # type=type(""),
                                            uoms=["Point"],
                                            default="Select a location on the map")]

        outputs = [ComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"),Format("application/json")])]
        super(wps_makeprofile,self).__init__(
                            self._handler,
                            identifier="wps_makeprofile",
                            title="Toon dwarsprofiel op gegeven locatie",
                            version="1.3.3.7",
                            store_supported="true",
                            status_supported="true",
                            abstract="""Deze functie maakt het mogelijk op een willekeurig punt (mits gegevens aanwezig) profielinformatie van HyDAMO op te halen en te tonen""",
                            grass_location=False,
                            inputs=inputs,
                            outputs=outputs)

    # Read configuration from file

    def readConfig(self):
        cf = configparser.RawConfigParser()
        cf.read(CONFIG_FILE)
        self.PLOTS_DIR = cf.get('Bokeh', 'plots_dir')
        self.APACHE_DIR = cf.get('Bokeh', 'apache_dir')

    # Execute wps service to get tseries
    def _handler(self,request,response):
        # Outputs prepare
        outdata = io.StringIO()
        values = {}

        # Read config
        self.readConfig()
        dirname = str(time.time()).replace('.', '')
        temp_html = os.path.join(self.PLOTS_DIR, dirname+'.html')

        # Inputs check
        # location = self.location.getValue()
        location = json.loads(request.inputs["location"][0].data)
        logger.info(
            '''INPUT [Plot Profile]: location={}'''.format(str(location)))

        # Coodinates conversion
        # location_info = json.loads(self.location.getValue())
        location_info = json.loads(request.inputs["location"][0].data)
        logger.info(type(location_info))
        logger.info(location_info)
        (xin, yin) = location_info["x"], location_info["y"]

        # Make profile
        wktenvelope = makeprofile(xin, yin, temp_html)
        g = loads(wktenvelope)
        center = g.centroid

        # Generate plot
        #bokeh = bokeh_Plot(res, xk, yk, None, temp_html, None, None)
        # bokeh.plot_3Tseries_Mean()

        # Send back result JSON
        values['url_plot'] = self.APACHE_DIR + os.path.basename(temp_html)
        values['zoomx'] = center.x
        values['zoomy'] = center.y
        values['plot_xsize'] = 700
        values['plot_ysize'] = 400
        values['margin'] = 1500
        values['title'] = 'HyDAMO Dwarsprofiel'
        values['wktenvelope'] = wktenvelope

        json_str = json.dumps(values)
        logger.info('''OUTPUT [krw_tseries]: {}'''.format(json_str))
        # outdata.write(json_str)
        # self.json.setValue(outdata)
        response.outputs['json'].data = json_str
        return response
