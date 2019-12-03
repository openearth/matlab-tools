# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
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

# $Id: meetlocaties_plot.py 14277 2018-04-06 08:43:39Z sala $
# $Date: 2018-04-06 01:43:39 -0700 (Fri, 06 Apr 2018) $
# $Author: sala $
# $Revision: 14277 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/NutrientenAanpakMaas/meetlocaties_plot.py $
# $Keywords: $

import json
import logging
from datetime import datetime
import numpy as np

# Plots
from bokeh.plotting import figure, show, save, ColumnDataSource
from bokeh.layouts import row, column
from bokeh.io import output_file
from bokeh.models import Range1d, HoverTool

# CLASS to generate bokeh plots for NutrientenAanpakMaas
class bokeh_Plot:
    def __init__(self, datain, xin, yin, locin, outp, locname_in, title_in):
        self.data = datain
        self.x = xin
        self.y = yin
        self.locid = locin
        self.output_html = outp
        self.locname = locname_in
        self.title = title_in
 
    def plot_TseriesMNLSO(self,parameter,unit):
        # Data preparation
        (t,v) = zip(*self.data)

        # Plot per column
        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
        p = figure(width=800, height=540, x_axis_type="datetime", title=self.title, tools=TOOLS)
        p.xaxis.axis_label = 'Datum'
        p.yaxis.axis_label = ' '.join([parameter,'waarden in',unit])
        p.line(t,v, color="red")
        p.circle(x=t, y=v, size=5, color="red")
        p.y_range = Range1d(0, max(v)*1.5)

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p) 
 
    # Simple Time-Series plot XY
    def plot_Tseries(self):
        # Data preparation
        (t,v,i,unit) = zip(*self.data)

        # Plot per column
        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
        p = figure(width=800, height=540, x_axis_type="datetime", title=' '.join(['Observaties in een straal van ca. 100 meter rond',self.title]), tools=TOOLS)
        p.xaxis.axis_label = 'Datum'
        p.yaxis.axis_label = ' '.join([i[0],'in',unit[0]])
        #p.line(t,v, color="red")
        p.circle(x=t, y=v, size=5, color="red")
        p.y_range = Range1d(0, max(v)*1.5)
        logging.info(t)

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)

    # Simple Time-Series plot XY
    def plot_3Tseries_Mean(self): # default no3
        # Data be like: [x, y, planjaar, filter, avg(no3_n) as no3, avg(nh4_n) as nh4, avg(p_tot) as p_tot]
        figures = []
        pos_jaar = 2
        pos_filter = 3
        pos_filttext = 7        
        colors = ['#3288bd', '#fee08b', '#fc8d59', '#d53e4f']
        ytitles = [ 'mg/l NO3-N', 'mg/l NH4_N', 'mg/l P']
        for col in [4,5,6]:
            # Plot per column            
            TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
            p = figure(width=750, height=240, x_axis_type="datetime", title=self.title, tools=TOOLS)
            p.xaxis.axis_label = 'Planjaar'
            p.yaxis.axis_label = ytitles[col-4]       
            
            # Data preparation 
            actual_filt=self.data[0][pos_filter]
            filttext = self.data[0][pos_filttext]

            t = []
            v = []
            i = 0
            for row in self.data:
            	i = i + 1
                filt = row[pos_filter]
                if filt != actual_filt:
                    p.line(t,v, color=colors[actual_filt-1])
                    p.circle(x=t, y=v, size=5, color=colors[actual_filt-1], legend='{}'.format(self.data[0][pos_filttext]))
                    # Advance
                    actual_filt = filt
                    v = []
                    t = []             
                else:
                    t.append(datetime(row[pos_jaar], 1, 1, 0, 0))
                    v.append(row[col])            
            
            # Last filter
            p.line(t,v, color=colors[actual_filt-1])
            p.circle(x=t, y=v, size=5, color=colors[actual_filt-1], legend='{}'.format(self.data[-1][pos_filttext])) 
            # Append figure
            figures.append(p)

        # Vertical layout
        p = column(figures[0], figures[1], figures[2])

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)        