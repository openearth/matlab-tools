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
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/blue2/bokeh_plots.py $
# $Keywords: $

import json
import logging
from datetime import datetime
import numpy as np

# Plots
from bokeh.plotting import figure, show, save, ColumnDataSource
from bokeh.io import output_file
from bokeh.models import Range1d, HoverTool, Label
 
# Simple Time-Series plot XY
def plot_Tseries(x, y, varname, units, output_html):
    # Data preparation
    tit = 'Time series for the selected location'

    # Plot per column
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p = figure(width=650, height=375, x_axis_type="datetime", title=tit, tools=TOOLS)
    p.xaxis.axis_label = 'Time'
    p.yaxis.axis_label = varname + ' ' + units
    p.line(x, y, color="darkblue")
    p.circle(x=x, y=y, size=5, color="darkblue")
    
    # - Output HTML
    output_file(self.output_html, title="generated with bokeh_plot.py")
    save(p)

# Simple Time-Series plot XY
def plot_Tseries_Multi(iden, data, time, varname, output_html, highlight, output_type):
    # Data preparation
    tit = '{} [model results]'.format(iden)
    yaxis_tit = varname
    if 'threshold' in output_type:
        tit = '{} [threshold indexation]'.format(iden)
        yaxis_tit = '{} / threshold'.format(varname)

    # Plot per column
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p = figure(width=750, height=375, x_axis_type="datetime", title=tit, tools=TOOLS)
    p.xaxis.axis_label = 'Time'
    p.yaxis.axis_label = yaxis_tit 

    # Background elements
    i=0
    xs=[]
    ys=[]
    for k,y in data.iteritems():
        if k==highlight:            
            sely=y # save
        ys.append(y)
        xs.append(time)
        
    # Draw thresholds if needed
    if 'thresholds' in output_type:
        p.line([time[0], time[-1]], [0.0, 0.0], color='#1A9641', legend='Excellent', line_width=3, line_alpha=1.0)  
        p.line([time[0], time[-1]], [0.5, 0.5], color='#A6D96A', legend='Good', line_width=3, line_alpha=1.0)   
        p.line([time[0], time[-1]], [0.8, 0.8], color='#FFFFBF', legend='Moderate', line_width=3, line_alpha=1.0) 
        p.line([time[0], time[-1]], [1.0, 1.0], color='#FDAE61', legend='Poor', line_width=3, line_alpha=1.0)
        p.line([time[0], time[-1]], [1.2, 1.2], color='#D7191C', legend='Bad', line_width=3, line_alpha=1.0)

    # Other timeseries
    p.multi_line(xs=xs, ys=ys, color="grey")    

    # Draw selected on top
    p.line(time, sely, color="blue")
    p.circle(x=time, y=sely, size=5, color="blue")

    # - Output HTML
    output_file(output_html, title="generated with bokeh_plot.py")
    save(p)

