# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#       Gerrit Hendriksen
#	gerrit.hendriksen@deltares.nl
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

# $Id: info_nhiflux.py 13706 2017-09-13 09:29:46Z sala $
# $Date: 2017-09-13 11:29:46 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13706 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/GWvsTime.py $
# $Keywords: $

"""
http://localhost/cgi-bin/pywps.cgi?service=wps&request=GetCapabilities&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?service=wps&request=DescribeProcess&Identifier=gwvstime&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=gwvstime&datainputs=[location=(5.88251988130295,51.4379275403273)]
"""


# core
import os
import operator
import math
import tempfile
import logging
import configparser
import time

# modules
import datetime
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
from .gmdb_utils import *
from .gmdb_sql import *
from .bokeh_plots import *

logger = logggin.getLogger('PYWPS')
"""
This is a redesigned WPS for the emisk application
"""
today_str = datetime.now().strftime("%Y-%m-%d")


class gwvstime(Process):
    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [LiteralInput(identifier="location",
                                            title="Selecteer een locatie en klik op execute",
                                            abstract="input=mapselection",
                                            # type=type(""),
                                            uoms=["Point"],
                                            default="Selecteer een locatie op de kaart"),
                  LiteralInput(identifier="sdate",
                                             title="Selecteer begingdatum (YYYY-MM-DD)",
                                             # type=bytes,
                                             default="1993-01-01"),
                  LiteralInput(identifier="edate",
                                             title="Selecteer begingdatum (YYYY-MM-DD)",
                                             # type=bytes,
                                             default=today_str)]

        outputs = [ComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"),Format("application/json")])]
        super(gwvstime,self).__init__(
                            self._handler,
                            identifier="gwvstime",
                            title="Grondwateronttrekking tijdreeksen",
                            version="1.3.3.7",
                            store_supported="true",
                            status_supported="true",
                            abstract="""Maak een tijdreeks van grondwater onttrekkingen. Het dichtsbijzijnde punt wordt geselecteerd. Indien meerdere filters aanwezig, dan worden twee plots in 1 grafiek gemaakt.""",
                            grass_location=False,
                            inputs=inputs,
                            outputs=outputs)

    def _handler(self,request,response):
        # Outputs prepare
        outdata = io.StringIO()
        values = {}

        # Read config
        PLOTS_DIR, APACHE_DIR = readConfig()

        # Inputs check
        # location = self.location.getValue()
        location = request.inputs['location'][0].data
        logger.info('''INPUT [gwvstime]: location={}'''.format(str(location)))
        startdate = request.inputs['startdate'][0].data
        # startdate = self.sdate.getValue()
        # enddate = self.edate.getValue()
        enddate = request.inputs['edate'][0].data
        logger.info('''INPUT [gwvstime]: start datum={}'''.format(startdate))
        logger.info('''INPUT [gwvstime]: eind datum={}'''.format(enddate))

        # Error messaging
        okparams, msg, x, y = check_location(location)
        if not(okparams):
            logger.info(msg)
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            # self.json.setValue(outdata)
            response.outputs['json'].data = outdata
            return

        # Check if well nearby via WFS
        properties = {}
        (xk, yk) = change_coords(x, y, epsgin='epsg:3857', epsgout='epsg:28992')

        # Query Database by location
        res, properties = sql_gwlevels_vs_time(
            xk, yk, startdate, enddate, properties)
        if res != None and res != []:
            # Generate plot GW vs time
            tmpfile = TempFile(PLOTS_DIR)
            logger.info('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^')
            logger.info(res)
            logger.info('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^')
            bokeh = bokeh_Plot(None, None, colorTable=None)
            bokeh.plot_Tseries(
                res, properties['x'], properties['y'], properties['id'], tmpfile)
            values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
        else:
            values['error_html'] = "<p>Er zijn geen gegevens beschikbaar voor de geselecteerde locatie</p>"

        # Send back result JSON
        json_str = json.dumps(values)
        logger.info('''OUTPUT [gwvstime]: {}'''.format(json_str))
        # outdata.write(json_str)
        # self.json.setValue(outdata)
        response.outputs['json'].data = json_str
        return response
