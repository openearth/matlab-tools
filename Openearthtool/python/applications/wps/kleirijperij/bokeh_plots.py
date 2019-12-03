# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala
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

# $Id: bokeh_plots.py 14128 2018-01-30 07:30:36Z sala $
# $Date: 2018-01-30 08:30:36 +0100 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14128 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/bokeh_plots.py $
# $Keywords: $

import json
import logging
from datetime import datetime
import numpy as np
import collections

# Plots
from bokeh.plotting import figure, show, save, ColumnDataSource
from bokeh.io import output_file
from bokeh.layouts import row
from bokeh.models import Range1d, HoverTool, Label
from bokeh.palettes import viridis #gray
from bokeh.models import LinearColorMapper, ColorBar, BasicTicker, Legend

# CLASS to generate bokeh plots for eMisk
class bokeh_Plot:
    def __init__(self, datainx, datainy, propin, paramName, loc_id, outp):
        self.datax = datainx
        self.datay = datainy
        self.properties = propin
        self.output_html = outp
        self.parameter_name = paramName
        self.locid = loc_id
 
    # Simple patches XY plot [Borehole]
    def plot_Transect(self):
        # order data by key/year
        odatay = collections.OrderedDict(sorted(self.datay.items()))
        keys_ord = odatay.keys()
        logging.info(self.datax)

        # Prepare plot
        TOOLS = "pan,wheel_zoom,box_zoom,save"
        p = figure(width=950, height=500, tools=TOOLS)        
        p.yaxis.axis_label = "Hoogte (m-NAP)"
        p.xaxis.axis_label = "Afstand (m)"

        # Data preparation
        miny = 99999
        maxy = -99999
        minx = 99999
        maxx = -99999  
        pal = viridis(len(odatay.keys()))
        # pal = gray(len(odatay.keys())+1)[0:-1] # avoid white [first two colors out]  # do not use black but use the color palette viridis
        # pal.reverse() # white to black        
        color_mapper = LinearColorMapper(palette=pal, low=keys_ord[0], high=keys_ord[-1])

        i=0
        for k, v in odatay.iteritems():         
            y=np.asarray(v)
            x=np.asarray(self.datax[k])        
            miny = min(miny, min(y))
            maxy = max(maxy, max(y))
            minx = min(minx, min(x))
            maxx = max(maxx, max(x))
            p.line(x,y, color=pal[i], line_width=2)
            i+=1 

        # Legend especially for the transect in Kleirijperij location Delfzijl
        d1 = p.square([-9999], [-9999], color=pal[0])
        d2 = p.square([-9999], [-9999], color=pal[1])
        d3 = p.square([-9999], [-9999], color=pal[2])
        d4 = p.square([-9999], [-9999], color=pal[3])
        d5 = p.square([-9999], [-9999], color=pal[4])
        d6 = p.square([-9999], [-9999], color=pal[5])
        legend = Legend(items=[
            ('09-04-2018', [d1]),
            ('23-04-2018', [d2]),
            ('31-05-2018', [d3]),
            ('02-08-2018', [d4]),
            ('06-09-2018', [d5]),
            ('15-10-2018', [d6])
            ], location=(0, 250))

        # Plot margins
        distY = (maxy - miny)        
        p.y_range = Range1d(miny-(maxy-miny)*0.05, maxy+(maxy-miny)*0.25)
        p.x_range = Range1d(minx-(maxx-minx)*0.05, maxx+(maxx-minx)*0.15)
        # color_bar = ColorBar(color_mapper=color_mapper, label_standoff=10, border_line_color=None, location=(0,0), ticker=BasicTicker(desired_num_ticks=i-1))
        p.add_layout(legend, "left")   # for this project a color bar is not necessary, the legend is used

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)

            # Simple Time-Series plot XY
    def plot_IndexPropertiesAtDepth(self):
        # Data preparation
        (v,d,locatie_nummer) = zip(*self.properties)
        vMixed = []
        dMixed = []
        vSingle = []
        dSingle = []

        for n, i in enumerate(locatie_nummer):
            if i == 0:
                vMixed.append(v[n])                
                dMixed.append(d[n])
            elif i > 0:
                vSingle.append(v[n])
                dSingle.append(d[n])

        logging.info("Mixed measurements: {} {} || Single measurements: {} {}".format(vMixed, dMixed, vSingle, dSingle))            

        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"

        if not(vSingle):
            # There are only mixed measurements
            p1 = figure(width=800, height=540, title=' '.join(['Meetwaardes mengmonsters ||',self.parameter_name,'|| vak',self.locid]), tools=TOOLS, y_range=dMixed)
            p1.xaxis.axis_label = self.parameter_name
            p1.yaxis.axis_label = 'Diepte'
            p1.hbar(y=dMixed, height=0.5, left=0, right=vMixed, color="dodgerblue")
            p = p1
        elif not(vMixed):
            # There are only single measurements
            uniqueLocations = set(locatie_nummer)
            listLocations = list(uniqueLocations)
            listLocations = [str(item) for item in listLocations]  

            p2 = figure(width=800, height=540, title=' '.join(['Meetwaardes enkele monsters ||',self.parameter_name,'|| vak',self.locid]), tools=TOOLS, y_range=listLocations)
            p2.xaxis.axis_label = self.parameter_name
            p2.yaxis.axis_label = 'Diepte'
            p2.hbar(y=dSingle[0:3], height=0.5, left=0, right=vSingle[0:3], color="burlywood")
            p2.hbar(y=dSingle[3:6], height=0.5, left=0, right=vSingle[3:6], color="sandybrown")           
            p2.hbar(y=dSingle[6:9], height=0.5, left=0, right=vSingle[6:9], color="chocolate")  
            p = p2
        else:
            # There are 2 types of measurements: mixed and single
            p1 = figure(width=800, height=540, title=' '.join(['Meetwaardes mengmonsters ||',self.parameter_name,'|| vak',self.locid]), tools=TOOLS, y_range=dMixed)
            p1.xaxis.axis_label = self.parameter_name
            p1.yaxis.axis_label = 'Diepte'
            p1.hbar(y=dMixed, height=0.5, left=0, right=vMixed, color="dodgerblue")

            p2 = figure(width=800, height=540, title=' '.join(['Meetwaardes enkele monsters ||',self.parameter_name,'|| vak',self.locid]), tools=TOOLS, y_range=dSingle)
            p2.xaxis.axis_label = self.parameter_name
            p2.yaxis.axis_label = 'Diepte'
            p2.hbar(y=dSingle, height=0.5, left=0, right=vSingle, color="burlywood")

            p = row(p1,p2)

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)