# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala Calero
#
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

# $Id: bokeh_plots.py 14834 2018-11-21 15:46:52Z sala $
# $Date: 2018-11-21 16:46:52 +0100 (Wed, 21 Nov 2018) $
# $Author: sala $
# $Revision: 14834 $
# $Keywords: $

import json
import logging
import numpy as np
import time
from datetime import datetime
from bokeh.plotting import figure, ColumnDataSource
from bokeh.models import HoverTool
from bokeh.models import Range1d

# CLASS to generate bokeh plots for GeoTop data


class bokeh_Plot:
    def __init__(self, inp, y_min, y_max, colorTable='GEOTOP'):
        self.jdata = inp
        self.y_min = y_min
        self.y_max = y_max
        # self.output_html = outp
        self.colorscheme = ['blue', 'darkviolet', 'green', 'darkorange',
                            'magenta', 'gold', 'limegreen', 'pink', 'cyan', 'purple']

        # REGIS color table
        self.colorLookupTable_REGIS = {
            'Holoceen complex': "#958d82",
            'Boxtel Schimmert klei': "#9E8F52",
            'Boxtel zand': "#ffffb4",
            'Boxtel klei': "#9E8F52",
            'Boxtel Liempde klei': "#9E8F52",
            'Kreftenheye Wychen klei': "#9E8F52",
            'Kreftenheye zand': "#ffffb4",
            'Kreftenheye klei': "#9E8F52",
            'Beegden Rosmalen klei': "#9E8F52",
            'Beegden zand': "#ffffb4",
            'Beegden klei': "#9E8F52",
            'Woudenberg zand': "#ffffb4",
            'Woudenberg veen': "#8461bd",
            'Eem zand': "#ffffb4",
            'Eem klei': "#9E8F52",
            'Kreftenheye Zutphen klei': "#9E8F52",
            'Kreftenheye Twello klei': "#9E8F52",
            'Drente zand': "#ffffb4",
            'Drente Uitdam klei': "#9E8F52",
            'Drente Gieten klei': "#9E8F52",
            'Gestuwde afzettingen complex': "#b2b2b2",
            'Drachten zand': "#ffffb4",
            'Urk zand': "#ffffb4",
            'Urk klei': "#9E8F52",
            'Peelo zand': "#ffffb4",
            'Peelo klei': "#9E8F52",
            'Sterksel zand': "#ffffb4",
            'Sterksel klei': "#9E8F52",
            'Appelscha zand': "#ffffb4",
            'Stramproy zand': "#ffffb4",
            'Stramproy klei': "#9E8F52",
            'Peize-Waalre zand': "#ffffb4",
            'Waalre klei': "#9E8F52",
            'Peize klei': "#9E8F52",
            'Peize complex': "#ebbd00",
            'Maassluis zand': "#ffffb4",
            'Maassluis complex': "#73bac3",
            'Maasluis klei': "#9E8F52",
            'Kiezelooliet zand': "#ffffb4",
            'Kiezelooliet klei': "#9E8F52",
            'Oosterhout zand': "#ffffb4",
            'Oosterhout complex': "#577a00",
            'Oosterhout klei': "#9E8F52",
            'Breda zand': "#ffffb4",
            'Breda klei': "#9E8F52",
            'Ville bruinkool': "#996600",
            'Rupel Boom klei': "#9E8F52",
            'Rupel zand': "#ffffb4",
            'Rupel klei': "#9E8F52",
            'Tongeren Goudsberg klei': "#9E8F52",
            'Tongeren zand': "#ffffb4",
            'Dongen Asse klei': "#9E8F52",
            'Dongen zand': "#ffffb4",
            'Dongen klei': "#9E8F52",
            'Dongen Ieper klei': "#9E8F52",
            'Landen complex': "#c4abb0",
            'Heyenrath complex': "#8f1f41",
            'Houthem kalksteen': "#eb00d7",
            'Maastricht kalksteen': "#eba43e",
            'Gulpen kalksteen': "#eb523e",
            'Vaals complex': "#018527",
            'Aken complex': "#018566"
        }

        # NHI color table
        self.colorLookupTable_NHI = {
            "aquifer": "#43a2ca",
            "aquitard": "#fed98e"
        }

        # GEOTOP color table
        self.colorLookupTable_GEOTOP = {
            'antropogeen': "#958d82",
            'organisch materiaal (veen)': "#975b53",
            'klei': "#158115",
            'klei zandig, leem, kleiig fijn zand': "#c2cf5c",
            'zand fijn': "#d8ce91",
            'zand matig grof': "#d9bb75",
            'zand grof': "#caa145",
            'grind': "#646368",
            'schelpen': "#4885be",
        }
        # NHI color table
        self.colorLookupTable_WELL = {
            "screen": "#a1dab4",
        }

        # Color tables/data choose
        if (colorTable == 'GEOTOP'):
            self.colorLookupTable = self.colorLookupTable_GEOTOP
            self.data = self.jdata['geotop']
        if (colorTable == 'NHI'):
            self.colorLookupTable = self.colorLookupTable_NHI
            self.data = self.jdata['nhi']
        if (colorTable == 'REGIS'):
            self.colorLookupTable = self.colorLookupTable_REGIS
            self.data = self.jdata['regis']
        if (colorTable == 'WELL'):
            self.colorLookupTable = self.colorLookupTable_WELL
            self.data = self.jdata['well']

    def generate_plot(self, single=True, zlimit=None):
        # - Read data
        i = 0
        N = len(self.data)

        types = []
        colors = []
        patchX = []
        patchY = []
        distances = []
        ps = []
        nd = 50

        for elem in self.data:
            # - Distances of the polyline points
            d = float(elem['dist'])
            if i < N-1:
                nd = float(self.data[i+1]['dist'])
            distances.append(d)

            # - Treat every layer [plot per distance]
            l = 0
            offset = 0
            for lay in elem['layers']:
                # Check if offset needs to be substracted
                if 'ahn2' in elem:
                    offset = elem['ahn2']
                # get top/bottom/color
                topf = float(lay['top']) + offset
                botf = float(lay['bottom']) + offset
                try:
                    cols = self.colorLookupTable[lay['type']]
                except:
                    cols = '#666666'
                # Geotop has limit
                if zlimit != None:
                    if botf < zlimit:
                        botf = zlimit
                # append patch
                types.append(' #{}: {}'.format(l, lay['type']))
                colors.append(cols)
                patchX.append([d, d, nd, nd])
                patchY.append([botf, topf, topf, botf])
                ps.append("""({}, {})""".format(
                    elem['point'][0], elem['point'][1]))
                # layer counter
                l += 1
            i += 1  # next point

        # - Source data dict
        source = ColumnDataSource(data=dict(
            x=patchX,
            y=patchY,
            color=colors,
            types=types,
            ps=ps,
        ))

        # - Plot (patches)
        TOOLS = "pan,wheel_zoom,box_zoom,reset,hover,save"
        if single:
            w = 230
            h = 600
        else:
            w = 800
            h = 550
        p = figure(plot_width=w, plot_height=h,
                   title=self.jdata['title_plot'], tools=TOOLS)
        p.toolbar.logo = None
        p.grid.grid_line_color = None
        p.patches('x', 'y', source=source, fill_color='color',
                  fill_alpha=0.7, line_color="white", line_width=0.7)

        # - Axis definition
        p.xaxis.visible = False
        p.yaxis.axis_label = "Depth (m-NAP)"
        # bottom, top = -37,100
        bottom = self.y_min
        top = self.y_max
        p.y_range = Range1d(bottom, top)

        # - Mouse hover
        hover = p.select_one(HoverTool)
        hover.point_policy = "follow_mouse"
        hover.tooltips = """
        <div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Layer:</span>
                <span style="font-size: 12px; color: #777777;">@types</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Depth (m):</span>
                <span style="font-size: 12px; color: #777777;">$y</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Location (x,y):</span>
                <span style="font-size: 12px; color: #777777;">@ps</span>
            </div>
        </div>
        """

        # - Output HTML
        # output_file(self.output_html, title="generated with bokeh_plot.py")
        # save(p)
        return p
