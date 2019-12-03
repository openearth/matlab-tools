# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Lilia Angelova,Gerrit Hendriksen, Joan Sala
#
#       Lilia.Angelova@deltares.nl,gerrit.hendriksen@deltares.nl, joan.salacalero@deltares.nl
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

# core
import os
import operator
import math
import tempfile
import logging
import configparser
import time

# modules
import types
import simplejson as json
import io
from .bokeh_plots_edit import bokeh_Plot
from bokeh.layouts import row, gridplot
# from bokeh.io import output_file,save
import bokeh.io as b_io
from pywps import Format
from pywps.app import Process
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import LiteralOutput,ComplexOutput
from pywps.app.Common import Metadata
from pywps.inout.formats import FORMATS
from os.path import dirname, realpath, join

# relative
from .GeoTop import GeoTopOnOpendap
from .regis import regiswps
from .opendap_nhi import nhi_invoer
from .ahn2 import *
from .coords import *
from .water_atlas_utils import*
logger = logging.getLogger('PYWPS')
# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')

dir_path = dirname(realpath(__file__))
geotop_fn = join(dir_path, "../data", "geotop.nc")


class water_atlas(Process):
    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [LiteralInput(identifier="location",
                                            title="Prik op een lokatie naar voorkeur.",
                                            abstract="input=mapselection",
                                            # type=type(""),
                                            uoms=["Point"],
                                            default="Select a location on the map")]

        outputs = [ComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy.",
                                          abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"),Format("application/json")])]
        super(water_atlas,self).__init__(
                            self._handler,
                            identifier="water_atlas",
                            title="Toon laagopbouw volgens REGIS,LHM3.3 and GeoTop [dichtstbijzijnde punt].",
                            version="1.3.3.7",
                            store_supported="true",
                            status_supported="true",
                            abstract="""Deze functie biedt en overzicht van de ondergrond van de geselecteerde locatie volgens REGIS,LHM3.3 and GeoTop.""",
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
        values_nhi = {}
        values_regis = {}
        values_geotop = {}
        values_wells = {}

        # Main loop (for every point of the line)
        values_nhi['nhi'] = []
        values_regis['regis'] = []
        values_geotop['geotop'] = []
        values_wells['well'] = []
        npoints = 0

        # Input (coordinates)
        # location_info = json.loads(self.location.getValue())
        location_info = json.loads(request.inputs["location"][0].data)
        (xin, yin) = location_info['x'], location_info['y']

        # convert coordinates
        epsgin = 'epsg:3857'
        (x_rd, y_rd) = change_coords(xin, yin, epsgin=epsgin, epsgout='epsg:28992')
        logger.info("Changed cords:{},{}".format(x_rd, y_rd))
        screen_data = getscreensdb(x_rd, y_rd)

        # we need to get data from REGIS, GeoTop and NHI for the same location which is the closest well
        well_loc = screen_data[0][0]
        (x, y) = well_loc[6:-1].split(' ')
        (x, y) = getCoords250(int(x), int(y))
        logger.info("getCoords250() output:{},{}".format(x, y))

        # AHN
        try:
            hoogte = ahn(x, y)
            regis = regiswps(x, y)
            ahn2z = AHN_DAP(x, y)
            values_nhi['maaiveldhoogte'] = float(hoogte)

        except:
            hoogte = 0.0
            values_nhi['maaiveldhoogte'] = hoogte

        # x0,y0
        if npoints == 0:
            xo = x
            yo = y

        dt = {}
        ranges = [hoogte]
        fluxes = []
        dt['layers'] = []
        dt['dist'] = math.sqrt((x-xo)*(x-xo) + (y-yo) *
                               (y-yo))  # euclidean distance
        dt['point'] = [round(x, 1), round(y, 1)]

        # regis values
        dt_regis = {}
        minv = regis[0][1]
        maxv = regis[-1][2]
        maaiveldverschil = regis[0][1]
        dt_regis['min'] = float(maxv)  # - maaiveldverschil
        dt_regis['max'] = float(minv)  # - maaiveldverschil
        dt_regis['layers'] = []
        dt_regis['point'] = [round(x, 1), round(y, 1)]
        dt_regis['dist'] = math.sqrt(
            (x-xo)*(x-xo) + (y-yo)*(y-yo))  # euclidean distance

        for layer in regis:
            fromv = float(layer[1])  # - maaiveldverschil
            tov = float(layer[2])  # - maaiveldverschil
            typev = layer[0]
            dt_regis['layers'].append(
                {
                    "top": fromv, "bottom": tov, "type": typev
                })

        # geotop values
        try:
            dist = math.sqrt((x-xo)*(x-xo) + (y-yo) *
                             (y-yo))  # euclidean distance
            geotop = GeoTopOnOpendap(
                geotop_fn).get_all_layers(x, y)
            dt_geotop = {}
            dt_geotop['dist'] = dist
            dt_geotop['point'] = [round(x, 1), round(y, 1)]
            dt_geotop['layers'] = []
            minv = geotop[0][2]
            maxv = geotop[-1][3]
            dt_geotop['min'] = -float(maxv)
            dt_geotop['max'] = -float(minv)
            for layer in geotop:
                fromv = -float(layer[2])
                tov = -float(layer[3])
                typev = layer[1]
                namev = layer[0]
                dt_geotop['layers'].append(
                    {
                        "top": fromv, "bottom": tov,
                        "type": typev, "name": namev
                    })

        except:
            pass

        # NHI
        nhi = nhi_invoer(x, y)
        prev = float(hoogte)
        nhi_sort = sorted(list(nhi.items()), key=operator.itemgetter(0))
        # logger.info(nhi_sort)
        for item in nhi_sort:
            key, value = item
            value = [float(x) if x is not None else None for x in value]
            flf, ghg, glg, top, base = value

            if not base or not top:
                continue

            if base is not None:
                ranges.append(base)
            if top is not None:
                ranges.append(top)
            if flf is not None:
                fluxes.append(flf)

            # NaN control
            if math.isnan(prev):
                prev = None
            if math.isnan(top):
                top = None
            if math.isnan(base):
                base = None

            layer_fer = {"top": prev, "bottom": top,
                         "type": "aquifer", "GLG": glg, "GHG": ghg}
            layer_tar = {"flux": flf, "top": top,
                         "bottom": base, "type": "aquitard"}
            dt['layers'].append(layer_fer)
            dt['layers'].append(layer_tar)

            prev = base

        try:
            # Correction for maaiveld
            maaiveldhoogte = float(max(ranges))
            dt['max'] = float(max(ranges))
            dt['min'] = float(min(ranges))
            dt['maxFlux'] = float(max(fluxes))
            dt['minFlux'] = float(max(fluxes))
        except:
            pass

        # well data
        dt_wells = {}
        dt_wells['dist'] = dist
        dt_wells['point'] = [round(x, 1), round(y, 1)]
        dt_wells['layers'] = screen_data[1::]
        # logger.info(dt_wells)

        # add to list
        values_regis['regis'].append(dt_regis)
        try:
            values_geotop['geotop'].append(dt_geotop)
        except:
            pass
        values_nhi['nhi'].append(dt)
        values_wells['well'].append(dt_wells)
        npoints += 1

        # Plot title
        values_nhi['title_plot'] = """LHM3.3 (z={} m-NAP)""".format(
            int(maaiveldhoogte))
        values_regis['title_plot'] = """REGIS (z={} m-NAP)""".format(
            int(maaiveldverschil))
        values_geotop['title_plot'] = """GeoTop (z={} m-NAP)""".format(
            round(ahn2z, 2))
        values_wells['title_plot'] = """Well (z={} m-NAP)""".format(
            round(screen_data[0][1]))

        logger.info(values_geotop)
        logger.info(values_nhi)
        logger.info(values_regis)
        logger.info(values_wells)

        # get the bottom of the last screen in the well
        list_data = values_wells["well"][0]["layers"]
        lowest_screen = min(list_data, key=lambda x: x["bottom"])
        lowest_bottom = lowest_screen["bottom"]
        highest_screen = max(list_data, key=lambda x: x["top"])
        highest_top = highest_screen["top"]
        # filter all other values to the lowest screen in the

        # filter regis
        regis_d = values_regis["regis"][0]['layers']
        regis_d[:] = [d for d in regis_d if d.get('top') >= lowest_bottom]
        # update with the filtered data
        values_regis["regis"][0]['layers'] = regis_d

        # filter nhi
        nhi_d = values_nhi["nhi"][0]['layers']
        nhi_d[:] = [d for d in nhi_d if d.get('top') >= lowest_bottom]
        # update with the filtered data
        values_nhi["nhi"][0]['layers'] = nhi_d

        # filter geotop
        try:
            geotop_d = values_geotop["geotop"][0]['layers']
            geotop_d[:] = [d for d in geotop_d if d.get(
                'top') >= lowest_bottom]
            # update with the filtered data
            values_geotop["geotop"][0]['layers'] = geotop_d
        except:
            pass

        # Output and graph (temporary files, outside of wps instance tempdir, otherwise they get deleted)
        dirname = str(time.time()).replace('.', '')
        temp_html = os.path.join(self.PLOTS_DIR, dirname+'.html')

        # same x and y axis ranges
        y_min = lowest_bottom
        y_max = highest_top

        # NHI
        plot_nhi = bokeh_Plot(values_nhi, y_min, y_max, colorTable='NHI')
        p1 = plot_nhi.generate_plot()
        # REGIS
        plot_regis = bokeh_Plot(values_regis, y_min, y_max, colorTable='REGIS')
        p2 = plot_regis.generate_plot()

        # GeoTop
        plot_geotop = bokeh_Plot(values_geotop, y_min,
                                 y_max, colorTable='GEOTOP')
        p3 = plot_geotop.generate_plot()

        # well data
        plot_well = bokeh_Plot(values_wells, y_min, y_max, colorTable='WELL')
        p4 = plot_well.generate_plot()

        # #combine all plots in one layout
        # combined = row(p1,p2,p3,p4)
        combined = gridplot([[p1, p2, p3, p4]])
        b_io.output_file(os.path.join(self.PLOTS_DIR, dirname + '.html'))
        b_io.save(combined)

        values['url_plot'] = self.APACHE_DIR + dirname + '.html'
        values['title'] = 'Subsurface data plot for x= {}, y= {}'.format(
            int(xo), int(yo))
        values['plot_xsize'] = 1000
        values['plot_ysize'] = 700

        # Output finalize
        json_str = json.dumps(values)
        # json_output.write(json_str)
        # self.json.setValue(json_output)
        response.outputs['json'].data = json_str
        return response
