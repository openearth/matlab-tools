# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Gerrit Hendriksen, Joan Sala
#
#       gerrit.hendriksen@deltares.nl, joan.salacalero@deltares.nl
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

# $Id: transect_regis.py 13812 2017-10-10 18:50:44Z sala $
# $Date: 2017-10-10 20:50:44 +0200 (Tue, 10 Oct 2017) $
# $Author: sala $
# $Revision: 13812 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/transect_regis.py $
# $Keywords: $

# core
import os
import math
import tempfile
import logging
import time
import configparser

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

# relative
from .regis import regiswps
from .coords import *
from .bokeh_plots import bokeh_Plot

# Geo
from shapely import wkt
logger = logging.getLogger('PYWPS')

# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')


class transect_regis(Process):
    # Fill in from configuration
    PLOTS_DIR = ''
    APACHE_DIR = ''

    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [LiteralInput(identifier="transect_regis",
                                            title="Please draw a transect [double-click to finish] and click Execute",
                                            abstract="input=mapselection",
                                            # type=type(""),
                                            uoms=["linestring"],
                                            default="Select a location on the map")]

        outputs = [ComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"),Format("application/json")])]
        super(transect_regis,self).__init__(
                            self._handler,
                            identifier="transect_regis",
                            title="Toon ondergrond volgens REGIS [transect]",
                            version="1.3.3.7",
                            store_supported="true",
                            status_supported="true",
                            abstract="""Deze functie maakt het mogelijk om op een willekeurige plaats in Nederland de laag opbouw te visualiseren waarmee REGIS is geschematiseerd.""",
                            grass_location=False,
                            inputs=inputs,
                            outputs=outputs)

    # Read configuration from file

    def readConfig(self):
        cf = configparser.RawConfigParser()
        cf.read(CONFIG_FILE)
        self.PLOTS_DIR = cf.get('Bokeh', 'plots_dir')
        self.APACHE_DIR = cf.get('Bokeh', 'apache_dir')

    def _handler(self,request,response):
        # Read configuration file
        self.readConfig()

        # Output prepare
        json_output = io.StringIO()
        values = {}

        # Inputs check
        # linestr_str = self.transect.getValue()
        linestr_str = request.inputs["transect_regis"][0].data
        logger.info(
            '''INPUT [transect_regis]: location={}'''.format(str(linestr_str)))
        lwkt = wkt.loads(linestr_str)

        if len(lwkt.coords) < 2:
            msg = 'Type must be LineString and has to have at least two points'
            logger.info(msg)
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Get values for selected xy in fixed epsg
        epsgout = 'epsg:28992'
        epsgin = 'epsg:3857'

        # Data resolution (geotop=100m, regis/regis=250) ==> overwrite input polyline with sliced one
        resolution = math.sqrt(2.0*250.0*250.0)
        nsamplesmax = 30

        # Loop over values
        xo, yo = change_coords(
            lwkt.coords[0][0], lwkt.coords[0][1], epsgin=epsgin, epsgout=epsgout)
        xk, yk = change_coords(
            lwkt.coords[1][0], lwkt.coords[1][1], epsgin=epsgin, epsgout=epsgout)
        data_error = False
        errmsg = ''
        values['regis'] = []
        coords = linesampling(xo, yo, xk, yk, resolution)
        if len(coords) > nsamplesmax:
            data_error = True
            errmsg = "<p>Het door u geselecteerde transect overschrijdt de maximale lengte [{}km], probeer het opnieuw</p>".format(
                int(round(nsamplesmax*resolution)/1000))
        else:
            try:
                for x, y in coords:
                    regis = regiswps(x, y)
                    minv = regis[0][1]
                    maxv = regis[-1][2]

                    # regis runs from NAP, not maaiveld
                    maaiveldverschil = regis[0][1]
                    dt = {}
                    # euclidean distance
                    dt['dist'] = math.sqrt((x-xo)*(x-xo) + (y-yo)*(y-yo))
                    dt['min'] = float(maxv)  # - maaiveldverschil
                    dt['max'] = float(minv)  # - maaiveldverschil
                    dt['layers'] = []
                    dt['point'] = [round(x, 1), round(y, 1)]

                    for layer in regis:
                        fromv = float(layer[1])  # - maaiveldverschil
                        tov = float(layer[2])  # - maaiveldverschil
                        typev = layer[0]
                        dt['layers'].append(
                            {
                                "top": fromv, "bottom": tov, "type": typev
                            })

                    # to serialize results, avoiding NaN
                    #if math.isnan(dt['top']):       dt['top'] = None
                    #if math.isnan(dt['bottom']):    dt['bottom'] = None

                    # add to list
                    values['regis'].append(dt)
            except Exception as e:
                data_error = True
                errmsg = "<p>Er zijn geen gegevens beschikbaar voor de geselecteerde locatie</p>"
                logger.warning(e)
                pass

        # Output and graph
        if data_error:
            values['error_html'] = errmsg
        else:
            # Output and graph (temporary files, outside of wps instance tempdir, otherwise they get deleted)
            values['title_plot'] = """REGIS (xo={}m, yo={}m, xn={}m, yn={}m)""".format(
                int(xo), int(yo), int(xk), int(yk))
            dirname = str(time.time()).replace('.', '')
            temp_html = os.path.join(self.PLOTS_DIR, dirname+'.html')
            plot = bokeh_Plot(values, temp_html, colorTable='REGIS')
            plot.generate_plot(single=False)
            values['url_plot'] = self.APACHE_DIR + dirname + '.html'
            values['title'] = 'regis - REGIS Transect'
            values['plot_xsize'] = 850
            values['plot_ysize'] = 600

        # Output finalize
        json_str = json.dumps(values, use_decimal=True)
        #logger.info('''OUTPUT [transect_regis]: {}'''.format(json_str))
        # json_output.write(json_str)
        # self.json.setValue(json_output)
        response.outputs['json'].data = json_str
        return response
