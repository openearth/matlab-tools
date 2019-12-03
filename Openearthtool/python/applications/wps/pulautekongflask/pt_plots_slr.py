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

# Plot Sea Level Rise analysis
def plotSLRAnalysis(conf, times, values, params, units, locations, tempdir):

    # Get size prefences
    xSize, ySize = getPlotSize(conf)

    # Get plot settings
    title, xAxis, yAxis1, yAxis2 = getPlotSettings(conf)

    # One time series analysis [not multi]
    location = locations[0]
    time = times[0]
    vals = values[0]
    param = params[0]

    # Data analysis
    tt_data = {'date': time, 'value': vals}
    df = pd.DataFrame(tt_data, columns = ['date', 'value'])
    df.index = df['date']
    period_mean = df.groupby(pd.Grouper(freq=conf['averagingPeriod']))['value'].mean()

    # Title definition
    tit = 'Sea Level Rise analysis for {}'.format(location)
    if title:
        tit = title        

    # Figure and tooltips definition
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p = figure(width=xSize, height=ySize, x_axis_type="datetime", title=tit, tools=TOOLS, toolbar_location="above")
    p.xaxis.formatter = DatetimeTickFormatter(days=['%d/%m'])

    # Axis definition
    if xAxis:
        p.xaxis.axis_label = xAxis
    else:
        p.xaxis.axis_label = 'Time in {}'.format(conf['averagingPeriod'])

    if yAxis1:
        p.yaxis.axis_label = yAxis1
    else:
        p.yaxis.axis_label = param
     
    p.title.text_font_size = '8pt'

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

    # Plot [line+symbol]
    source = ColumnDataSource(data=dict(
        x=[d.to_pydatetime() for d in period_mean.index],
        y=list(period_mean),
        date=[d.strftime('%Y-%m-%d %H:%M:%S') for d in period_mean.index],
        loc=[location for d in period_mean.index]
    ))
    g1 = Line(x="x", y="y", line_color=selColor)
    p.add_glyph(source, g1)
    plotGlyphLeft(p, selGlyph, selColor, selSize, source, selLegend)

    # Legend settings
    p.legend.label_text_font_size = '8pt'
    p.legend.location = "top_left"
    p.legend.click_policy="hide"

    # Global Hover settings
    g1_r = p.add_glyph(source_or_glyph=source, glyph=g1)
    hover = HoverTool(formatters={'DateTime': 'datetime'}, renderers=[g1_r])
    hover.tooltips = [
        ("date", "@date"),
        ("value", "@y")
    ]
    hover.mode = 'vline'

    p.tools.append(hover)
    p.toolbar.logo = None

    # Output HTML
    output_html = getTempFile(tempdir)
    output_file(output_html, title="generated with make_plots.py")
    save(p)
    return output_html
