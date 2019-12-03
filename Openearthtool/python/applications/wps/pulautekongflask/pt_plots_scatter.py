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

# Make scatterplot: this function can read exactly two datasets, which can have 1 or two locations and one or two parameters
# Currently all inputs are lists
def plotScatter(conf, times, values, params, units, locations, tempdir, correlation=False):

    # Get size prefences
    xSize, ySize = getPlotSize(conf)

    # Get plot settings
    title, xAxis, yAxis1, yAxis2 = getPlotSettings(conf)

    # xaxis is always first parameter in list
    # Check that there are exactly two param-location combinations
    params_units_locations = [m+ " (" + n + ") - " + o for m,n,o in zip(params,units,locations)] # combine params and units

    if len(locations)!=2 or len(params)!=2:
        raise Exception("ERROR: " + str(len(set(params_units_locations))) + " location/parameter combinations were provided. Must provide 2 locations/parameters combos for a scatterplot. Note: the two parameters and/or locations can be the same, but there must be two datasets.")
        return
    else:
        # Define figure title (format depends on # unique locations/parameters)
        if len(set(locations)) == 2 and len(set(params)) == 2:
            tit = "Scatterplot of " + params [0] + " at " + locations[0] + " vs. " + params[1] + " at " + locations[1]
        elif len(set(locations)) == 1 and len(set(params)) == 2:
            tit = "Scatterplot of " + params [0] + " vs. " + params[1] + " at " + locations[0]
        elif len(set(locations)) == 2 and len(set(params)) == 1:
            tit = "Scatterplot of " + params [0] + " at " + locations[0] + " vs. " + locations[1]
        else: # This option dosn't really make sense - it means you're plotting the same parameter at the same location...
            tit = "Scatterplot of " + params [0] + " at " + locations[0]
        if not title: 
            title=tit

        # Initialize figure
        TOOLS = "reset,pan,wheel_zoom,box_zoom,save"
        p = figure(width=xSize, height=ySize, tools=TOOLS, title=title, toolbar_location="above")
        
        # Axis definition
        if yAxis2:
            p.xaxis.axis_label = yAxis2
        else:
            p.xaxis.axis_label = locations[0] + " - " + params[0] + " (" + units[0] + ")"

        if yAxis1:
            p.yaxis.axis_label = yAxis1
        else:
            p.yaxis.axis_label = locations[1] + " - " + params[1] + " (" + units[1] + ")"
     
        p.title.text_font_size = '8pt'

        # Get data
        tx = []
        for t in times[0]: tx.append(t)
        x=[]
        for v in values[0]: x.append(float(v))
        ty = []
        for t in times[1]: ty.append(t)
        y=[]
        for v in values[1]: y.append(float(v))

        # Get rid of missing data (nan)
        x2 = np.asarray(x)
        inds_good = ~np.isnan(x2)
        x = x2[inds_good]
        tx2 = np.asarray(tx)
        tx = tx2[inds_good]
        y2 = np.asarray(y)
        inds_good = ~np.isnan(y2)
        y = y2[inds_good]
        ty2 = np.asarray(ty)
        ty = ty2[inds_good]

        # Find overlapping points in time
        inds_x,inds_y = intersection_indices(tx, ty)
        x = x[inds_x]
        tx = tx[inds_x]
        y = y[inds_y]
        ty = ty[inds_y]

        # Find line of best fit
        par = np.polyfit(x, y, 1, full=True)
        slope=par[0][0]
        intercept=par[0][1]
        xl = [min(x), max(x)]
        yl = [slope*xx + intercept  for xx in xl]

        # Get R-squared
        variance = np.var(y)
        residuals = np.var([(slope*xx + intercept - yy)  for xx,yy in zip(x,y)])
        Rsqr = np.round(1-residuals/variance, decimals=2)
        leg_text = 'Rsqr = {}, variance={}'.format(Rsqr, round(variance,2))

        if correlation:
            corr = signal.correlate(x, y, mode='same')
            p.line(x, corr, color='darkblue', line_width=3, legend=leg_text)
        else:
            # Source for tooltips
            source = ColumnDataSource(data=dict(x=x, y=y))
            selColor1 = conf['selectedParams'][0]['color']
            selColor2 = conf['selectedParams'][1]['color']
            if len(selColor1) == 6: selColor1 = selColor1.replace('#', '#0') # bug of bokeh? or frontend?
            if len(selColor2) == 6: selColor2 = selColor2.replace('#', '#0') # bug of bokeh? or frontend?

            # Plot the data
            p.circle('x', 'y', size=10, color=selColor1, fill_alpha=0.2, source=source, legend=leg_text) # deltares blue [default]

            # Plot the line of best fit and error bounds
            p.line(xl, yl, color=selColor2, line_width=3, legend=leg_text)

        # Hover toolbar settings
        #hover = HoverTool(tooltips=[("value", "@y")])
        #p.tools.append(hover)
        p.toolbar.logo = None

        # Output HTML
        output_html = getTempFile(tempdir)
        output_file(output_html, title="generated with pt_plots.py")
        save(p)
        return output_html

