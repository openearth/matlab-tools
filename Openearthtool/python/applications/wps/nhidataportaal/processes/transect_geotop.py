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

# $Id: transect_geotop.py 13812 2017-10-10 18:50:44Z sala $
# $Date: 2017-10-10 20:50:44 +0200 (Tue, 10 Oct 2017) $
# $Author: sala $
# $Revision: 13812 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/transect_geotop.py $
# $Keywords: $

# core
import os
import math
import tempfile
import logging
import time
import configparser
import numpy as np

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
from os.path import dirname, realpath, join


# relative
from .GeoTop import GeoTopOnOpendap
from .coords import *
from .bokeh_plots import bokeh_Plot
from .ahn2 import *

# Geo
from shapely import wkt

# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')

dir_path = dirname(realpath(__file__))
geotop_fn = join(dir_path, "../data", "geotop.nc")


class transect_geotop(Process):
    # Fill in from configuration
    PLOTS_DIR = ''
    APACHE_DIR = ''

    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [LiteralInput(identifier="transect_geotop",
                                            title="Please draw a transect [double-click to finish] and click Execute",
                                            abstract="input=mapselection",
                                            # type=type(""),
                                            uoms=["linestring"],
                                            default="Select a location on the map")]

        outputs = [ComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"),Format("application/json")])]
        super(transect_geotop,self).__init__(
                            self._handler,
                            identifier="transect_geotop",
                            title="Toon ondergrond volgens GeoTop [transect]",
                            version="1.3.3.7",
                            store_supported="true",
                            status_supported="true",
                            abstract="""Deze functie maakt het mogelijk om op een willkeurige lokatie in Nederland de opbouw van de ondergrond volgens GEOTOP
                                        in een overzichtelijk diagram weer te geven.""",
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
        linestr_str = request.inputs["transect_geotop"][0].data
        logging.info(
            '''INPUT [transect_geotop]: location={}'''.format(str(linestr_str)))
        lwkt = wkt.loads(linestr_str)

        if len(lwkt.coords) < 2:
            msg = 'Type must be LineString and has to have at least two points'
            logging.info(msg)
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Get values for selected xy in fixed epsg
        epsgout = 'epsg:28992'
        epsgin = 'epsg:3857'

        # Data resolution (geotop=100m, nhi/regis=250) ==> overwrite input polyline with sliced one
        resolution = math.sqrt(2.0*100.0*100.0)
        nsamplesmax = 110

        # Loop over values
        xo, yo = change_coords(
            lwkt.coords[0][0], lwkt.coords[0][1], epsgin=epsgin, epsgout=epsgout)
        xk, yk = change_coords(
            lwkt.coords[1][0], lwkt.coords[1][1], epsgin=epsgin, epsgout=epsgout)
        data_error = False
        errmsg = ''
        values['geotop'] = []
        coords = linesampling(xo, yo, xk, yk, resolution)
        if len(coords) > nsamplesmax:
            data_error = True
            errmsg = "<p>Het door u geselecteerde transect overschrijdt de maximale lengte [{}km], probeer het opnieuw</p>".format(
                int(round(nsamplesmax*resolution)/1000))
        else:
            for x, y in coords:
                # GeoTOP (x,y)
                try:
                    offset = float(AHN_DAP(x, y))
                    dist = math.sqrt((x-xo)*(x-xo) + (y-yo) *
                                     (y-yo))  # euclidean distance
                    geotop = GeoTopOnOpendap('http://www.dinodata.nl/opendap/GeoTOP/geotop.nc').get_all_layers(x, y)
                    # geotop = GeoTopOnOpendap(
                    #     geotop_fn).get_all_layers(x, y)
                    minv = geotop[0][2]
                    maxv = geotop[-1][3]
                    dt = {}
                    dt['dist'] = dist
                    dt['ahn2'] = offset
                    dt['point'] = [round(x, 1), round(y, 1)]
                    dt['min'] = -float(maxv)
                    dt['max'] = -float(minv)
                    dt['layers'] = []
                    for layer in geotop:
                        fromv = -float(layer[2])
                        tov = -float(layer[3])
                        typev = layer[1]
                        namev = layer[0]
                        dt['layers'].append(
                            {
                                "top": fromv, "bottom": tov,
                                "type": typev, "name": namev
                            }
                        )

                    # AHN height
                    dt['ahn'] = float(AHN_DAP(x, y))

                    # add to list
                    values['geotop'].append(dt)
                except Exception as e:
                    data_error = True
                    errmsg = "<p>Er zijn geen gegevens beschikbaar voor de geselecteerde locatie</p>"
                    logging.info(e)
                    pass

        # Output and graph
        if data_error:
            values['error_html'] = errmsg
        else:
            # Output and graph (temporary files, outside of wps instance tempdir, otherwise they get deleted)
            values['title_plot'] = """GeoTop (xo={}m, yo={}m, xn={}m, yn={}m)""".format(
                int(xo), int(yo), int(xk), int(yk))
            dirname = str(time.time()).replace('.', '')
            temp_html = os.path.join(self.PLOTS_DIR, dirname+'.html')
            plot = bokeh_Plot(values, temp_html, colorTable='GEOTOP')
            plot.generate_plot(single=False, zlimit=-50)
            values['url_plot'] = self.APACHE_DIR + dirname + '.html'
            values['title'] = 'NHI - GeoTop Transect'
            values['plot_xsize'] = 850
            values['plot_ysize'] = 600

        # Output finalize
        json_str = json.dumps(values, use_decimal=True)
        #logging.info('''OUTPUT [transect_geotop]: {}'''.format(json_str))
        # json_output.write(json_str)
        # self.json.setValue(json_output)
        response.outputs['json'].data = json_str
        return response
