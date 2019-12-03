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

# $Id$
# $Date$
# $Author$
# $Revision$
# $Keywords: $

import json
import logging
import pandas as pd
from bokeh.plotting import figure, save, output_file, ColumnDataSource
from bokeh.models import HoverTool
import numpy as np

# CLASS to generate bokeh plots for GeoTop data
class bokeh_Plot:
    def __init__(self, outp):
        self.output_html = outp        

    def generate_plot(self, transect_id, ds, change_rate, change_rate_unc, outliers, flag_sandy, country, intercept, time, b_unc):

        # - Plot (patches)
        TOOLS="pan,wheel_zoom,box_zoom,reset,save,hover"
        p = figure(plot_width=600, plot_height=350, title='Shoreline profile in {} with Sandy={}'.format(country, flag_sandy), tools=TOOLS)
        p.toolbar.logo = None 
        p.grid.grid_line_color = None

        # Dates                
        year1 = np.array([1984+round(float(i)) for i in time[1:-1].split(',')])
        t = np.array([float(i) for i in time[1:-1].split(',')])
        d = np.array([ float(i) for i in ds[1:-1].split(',')])

        # get regression line
        yy= change_rate*t + intercept
        yup= (change_rate)*t + (intercept+ b_unc)
        ydown= (change_rate)*t + (intercept- b_unc)

        source = ColumnDataSource(data=dict(
            x=year1,
            y=d,
            c=[country for y in year1],
            t=[transect_id for y in year1] # repeat
        ))

        # plot lines        
        p.line(x=year1, y= yy, line_color= 'black', legend='Rate of change = {} +/- {} m/year'.format(("%.3f" % change_rate), ("%.3f" % change_rate_unc)))
        p.line(x=year1, y= yup, line_color= 'black',line_dash= 'dotted')
        p.line(x=year1, y= ydown, line_color= 'black',line_dash= 'dotted')
        p.circle(x='x', y='y', alpha= 0.5, size= 8, source=source)

        # - Axis definition
        p.xaxis.axis_label = "Year"
        p.yaxis.axis_label = "Distance w.r.t landward boundary [m]"
        p.title.text_font_size = "11pt"
        p.title.text_font_style = "normal"
        p.title.align= 'center'
        p.xaxis.axis_label_text_font_size = "10pt"
        p.xaxis.axis_label_text_font_style= 'normal'
        p.yaxis.axis_label_text_font_size = "10pt"
        p.yaxis.axis_label_text_font_style= 'normal'

        # - Mouse hover
        hover = p.select_one(HoverTool)
        hover.point_policy = "follow_mouse"
        hover.tooltips = """
        <div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Country:</span>
                <span style="font-size: 12px; color: #777777;">@c</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Time (x):</span>
                <span style="font-size: 12px; color: #777777;">@x</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Value (y)</span>
                <span style="font-size: 12px; color: #777777;">@y</span>
            </div>
        </div>
        """

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)