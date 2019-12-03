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

# $Id: info_geotop.py 13812 2017-10-10 18:50:44Z sala $
# $Date: 2017-10-10 20:50:44 +0200 (Tue, 10 Oct 2017) $
# $Author: sala $
# $Revision: 13812 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/info_geotop.py $
# $Keywords: $

# core
import os
from os.path import dirname, realpath, join
import math
import tempfile
import logging
import time
import configparser
import netCDF4

# modules
import types
import simplejson as json
import io
# from pywps.Process import WPSProcess
from pywps import Format
from pywps.app import Process
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import LiteralOutput, ComplexOutput
from pywps.app.Common import Metadata
from pywps.inout.formats import FORMATS


# relative
from .GeoTop import GeoTopOnOpendap
from .coords import *
from .bokeh_plots import bokeh_Plot
from .ahn2 import *

logger = logging.getLogger('PYWPS')
# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')

dir_path = dirname(realpath(__file__))

# url = join(dir_path, "../data", "geotop.nc")
url =  os.path.join(r"D:\NHI_upgrade\data", "geotop.nc")


class info_geotop(Process):
    # Fill in from configuration
    PLOTS_DIR = ''
    APACHE_DIR = ''

    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [LiteralInput(identifier="location",
                               title="Prik op een lokatie naar voorkeur.",
                               abstract="input=mapselection",
                               # type=type(""),
                               uoms=["Point"],
                               default="Select a location on the map")]

        outputs = [ComplexOutput(identifier="json",
                                 title="Returns list of values for specified xy",
                                 abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"), Format("application/json")])]
        super(info_geotop, self).__init__(
            self._handler,
            identifier="info_geotop",
            title="Toon ondergrond volgens GeoTop [punt]",
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

    def _handler(self, request, response):
        # Read configuration file
        self.readConfig()

        # Output prepare
        json_output = io.StringIO()
        values = {}

        # Main loop (for every point of the line)
        values['geotop'] = []
        npoints = 0

        # Input (coordinates)
        # epsg = self.epsg.getValue()
        epsg = 3857
        epsgin = 'epsg:'+str(epsg)
        location_info = json.loads(request.inputs["location"][0].data)
        # location_info = json.loads(self.location.getValue())
        (xin, yin) = location_info['x'], location_info['y']

        # convert coordinates
        logger.info(
            '''Input Coordinates {} {} in epsg={}'''.format(xin, yin, epsgin))
        (x, y) = change_coords(xin, yin, epsgin=epsgin, epsgout='epsg:28992')

        (x, y) = getCoords250(x, y)
        logger.info(
            '''INPUT [info_geotop]: coordinates_250_rdnew={},{}'''.format(x, y))

        # x0,y0
        if npoints == 0:
            xo = x
            yo = y

        # geotop (x,y)
        data_error = False

        # GeoTOP (x,y)
        try:
            # Height [AHN2]
            ahn2z = AHN_DAP(x, y)
            logger.info('AHN [z] = {} meters'.format(ahn2z))
            # Geotop stack
            dist = math.sqrt((x-xo)*(x-xo) + (y-yo) *
                             (y-yo))  # euclidean distance
            geotop = GeoTopOnOpendap("http://www.dinodata.nl/opendap/GeoTOP/geotop.nc").get_all_layers(x, y)
            # netCDF4.Dataset("http://www.dinodata.nl/opendap/GeoTOP/geotop.nc")
            minv = geotop[0][2]
            maxv = geotop[-1][3]
            dt = {}
            dt['dist'] = dist
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
                    })

            # add to list
            values['geotop'].append(dt)
            npoints += 1
        except Exception as e:
            data_error = True
            logger.warning(e)

        if data_error:
            values['error_html'] = "<p>Er zijn geen gegevens beschikbaar voor de geselecteerde locatie</p>"
        else:
            # ahn_val= round(ahn2z,2)
            # Output and graph (temporary files, outside of wps instance tempdir, otherwise they get deleted)
            values['title_plot'] = """geotop (x={} m, y={} m, z={} m)""".format(
                int(xo), int(yo), ahn2z)
            dirname = str(time.time()).replace('.', '')
            temp_html = os.path.join(self.PLOTS_DIR, dirname+'.html')
            plot = bokeh_Plot(values, temp_html, colorTable='GEOTOP')
            plot.generate_plot()
            values['url_plot'] = self.APACHE_DIR + dirname + '.html'
            values['title'] = 'GeoTop plot'
            values['plot_xsize'] = 450
            values['plot_ysize'] = 650

        # Output finalize
        json_str = json.dumps(values, use_decimal=True)
        logger.info('''OUTPUT [info_geotop]: {}'''.format(json_str))
        # json_output.write(json_str)
        # self.json.setValue(json_output)
        response.outputs['json'].data = json_str
        return response
