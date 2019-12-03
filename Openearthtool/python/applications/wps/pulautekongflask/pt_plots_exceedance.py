# -*- coding: utf-8 -*-
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#       Nena Vandebroek
#       nena.vandebroek@deltares.nl
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
import configparser

# modules
import math
import time
import statistics
import numpy as np
from scipy import optimize
from scipy import signal
import pandas as pd
from datetime import datetime
from decimal import Decimal

# Plots
from bokeh.plotting import figure, save
from bokeh.io import output_file
from bokeh.models import DatetimeTickFormatter, LinearAxis, DataRange1d, ColumnDataSource
from bokeh.palettes import Category10, Spectral6
from bokeh.transform import factor_cmap
from bokeh.models import HoverTool
from bokeh.models.glyphs import Line
from bokeh.layouts import column

# project specific functions
from pt_utils import *
from pt_utils_plots import *
from exceedence_utils import *

# Exceedence figure [3 plots combined]
def exceedanceFig(conf, potThreshold, location, param, xsize, ysize, time, vals, pot, pop, pot_exc_prob, pot_exc_value, pop_exc_prob, pop_exc_value, tempdir):

    # Defaults
    selGlyph = 'circle'
    selColor = '#0a99db' # deltares blue [default]
    selSize = 4
    selLegend = location
           
    # User preferences
    try:
        selGlyph = conf['selectedParams'][0]['glyph']
        selColor = conf['selectedParams'][0]['color']
        if len(selColor) == 6: 
            selColor = selColor.replace('#', '#0') # bug of bokeh? or frontend?
        selSize = conf['selectedParams'][0]['size']
        selLegend = conf['selectedParams'][0]['legendTitle'] # optional parameter
    except:
        pass

    source = ColumnDataSource(data=dict(
        x=time,
        y=vals,
        date=[d.strftime('%Y-%m-%d %H:%M:%S') for d in time],
        loc=[location for d in time]
    ))

    # ----------------
    # Figure - 1
    # ----------------
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p1 = figure(y_range=(min(vals), max(vals)*1.5), width=xsize, height=ysize, x_axis_type="datetime", title='Exceedence analysis for {}'.format(location), tools=TOOLS, toolbar_location="above")
    p1.xaxis.axis_label = 'Time'
    p1.yaxis.axis_label = param
    p1.xaxis.formatter = DatetimeTickFormatter(days=['%d/%m'])
    p1.toolbar.logo = None

    g1 = Line(x="x", y="y", line_color=selColor)
    p1.add_glyph(source, g1)
    plotGlyphLeft(p1, selGlyph, selColor, selSize, source, location)
    p1.line([time[0], time[-1]], [potThreshold, potThreshold], color='gray', line_width=4, line_dash="10 5", legend='Threshold')
    tidX = [ time[idx] for idx in pot.indices ]
    vidX = [ vals[idx] for idx in pot.indices ]
    p1.circle(tidX, vidX, color='black', legend='Peak over threshold [pot]', size=10, fill_color="white", fill_alpha=1.0)

    # ----------------
    # Figure - 2
    # ----------------
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p2 = figure(width=xsize, height=ysize, x_axis_type="log", title='Exceedence analysis for {}'.format(location), tools=TOOLS, toolbar_location="above")
    p2.xaxis.axis_label = 'Return period [years]'
    p2.yaxis.axis_label = 'Probability'
    p2.line(pot_exc_prob, pot_exc_value, color='gray', line_width=2, line_dash="6 6", legend='pot_exc_value')
    p2.line(pop_exc_prob, pop_exc_value, color='black', line_width=2, legend='pop_exc_value')

    # Legend settings
    p2.legend.label_text_font_size = '8pt'
    p2.legend.location = "top_left"
    p2.legend.click_policy="hide"
    p2.toolbar.logo = None

    # Global Hover settings
    g1_r = p1.add_glyph(source_or_glyph=source, glyph=g1)
    hover = HoverTool(formatters={'DateTime': 'datetime'}, renderers=[g1_r])
    hover.tooltips = [
        ("date", "@date"),
        ("value", "@y")
    ]
    hover.mode = 'vline'
    p1.tools.append(hover)

    # Output HTML
    output_html = getTempFile(tempdir)
    output_file(output_html, title="generated with make_plots.py")
    save(column(p1, p2))
    return output_html

# Plot Sea Level Rise analysis
def plotExceedance(conf, times, values, params, units, locations, tempdir):

    # Get size prefences
    xSize, ySize = getPlotSize(conf)

    # Get plot settings
    title, xAxis, yAxis1, yAxis2 = getPlotSettings(conf)
    
    # One time series analysis [not multi]
    location = locations[0]
    time = np.array([np.datetime64(t) for t in times[0]])
    vals = np.array(values[0])
    param = params[0]

    # Actual analysis using input above
    potThreshold = 2.7
    popInterval = 30
    if 'potThreshold' in conf:
        potThreshold = float(conf['potThreshold'])
    if 'popInterval' in conf:
        popInterval = int(conf['popInterval'])

    pot = PeakOverThreshold(vals, potThreshold)
    pop = PeakOverPeriod(time, vals, popInterval)    
    duration = time[-1]-time[0]

    duration = duration.astype('timedelta64[m]').astype('float')/60/24/365
    pot_exc_prob = duration/(np.arange(1,pot.peaks.shape[0]+1,1))
    pot_exc_value = np.flip(np.sort(pot.peaks))
    pop_exc_prob = duration/(np.arange(1,pop.peaks.shape[0]+1,1))
    pop_exc_value = np.flip(np.sort(pop.peaks))

    # Plotting [3 figures in one]
    out_html = exceedanceFig(conf, potThreshold, location, param, xSize, ySize, time.tolist(), vals.tolist(),
        pot, pop, pot_exc_prob, pot_exc_value, pop_exc_prob, pop_exc_value, tempdir)

    return out_html

