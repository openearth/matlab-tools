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

# Make timeseries plot: Can have up to 2 parameters/units (automatically get put on different axes), up to 10 locations
def plotTseries(conf, times, values, flags, params, units, locations, tempdir):
    
    # Get size prefences
    xSize, ySize = getPlotSize(conf)

    # Get plot settings
    title, xAxis, yAxis1, yAxis2 = getPlotSettings(conf)

    # Check that there are exactly two params and unit combinations
    params_units = [ m+ " (" + n + ")" for m,n in zip(params, units) ] # combine params and units

    if len(set(params_units))>2 or len(locations)>10:
        raise Exception("ERROR: " + str(len(set(params_units))) + " param/unit combos and " + str(len(set(locations))) + " locations were provided. Must have 2 or fewer unique parameter/unit combos and 10 or fewer locations for a timeseries plot.")
        return
    else:
        # Initialize figure
        TOOLS = "reset,pan,wheel_zoom,box_zoom,save"

        diffPars = [ a for a in set(params) ]
        if title:
            tit = title
        else:
            if len(diffPars) == 1:
                tit = 'Time series of parameter: ' + diffPars[0]
            else:
                tit = 'Time series of parameters: ' + diffPars[0] + ' and ' + diffPars[1]

        # Figure and tooltips definition
        p = figure(width=xSize, height=ySize, x_axis_type="datetime", title=tit, tools=TOOLS, toolbar_location="above")
        
        # Axis definition
        if xAxis:
            p.xaxis.axis_label = xAxis
        else:
            p.xaxis.axis_label = 'Time'

        if yAxis1:
            p.yaxis.axis_label = yAxis1
        else:
            p.yaxis.axis_label = params_units[0]

        p.xaxis.formatter = DatetimeTickFormatter(days=['%d/%m'])

        # If more than one parameter (or set of units) is specified, make a new axis
        if len(set(params_units)) == 2:
            param_unit2 = next(iter(set(params_units) - set([params_units[0]])))

            # Figure out what the right axis limits should be (this doesn't happen automatically for some reason)
            low = 1000000000 # dummy starting limits
            high = -1000000000
            for index, i in enumerate(params_units):
                if i == param_unit2:
                    low = min(low,min(values[index]))
                    high = max(high,max(values[index]))

            yrange = high-low # Used to add some padding to the right axis y-range

            # Set up right axis
            if yAxis2: param_unit2 = yAxis2
            p.extra_y_ranges = {"right": DataRange1d(start=low-yrange*0.1, end=high+yrange*0.25)}
            p.add_layout(LinearAxis(y_range_name="right", axis_label=param_unit2), 'right')

        # Loop through data
        renderers_list = []
        yrange_min =  100000000
        yrange_max = -100000000
        for index, l in enumerate(locations):
            # Get data
            param = params[index]
            x = times[index]
            y = values[index]
            yrange_max = max(yrange_max, max(y))
            yrange_min = min(yrange_min, min(y))

            # Flagged data [only when flag >0 it is unreliable)
            xff, yff, flagstr = [], [], []
            nff = 0
            for ff in flags[index]:
                if ff == 0:
                    flagstr.append('OK (reliable data)')
                else:
                    xff.append(x[nff])
                    yff.append(y[nff])
                    flagstr.append('WARNING (unreliable data)')
                nff += 1

            # Source for tooltips
            source = ColumnDataSource(data=dict(
                x = x,
                y = y,
                par = [param]*len(x),
                date = [d.strftime('%Y-%m-%d %H:%M:%S') for d in x],
                loc = [l]*len(x),
                rel = flagstr
            ))
            sourceFlags = ColumnDataSource(data=dict(
                x = xff,
                y = yff
            ))

            # Plot the data
            y_range_axis = 'left'
            if len(set(params)) == 1:
                # If there is only one type of param in the set, only one y-axis and legend shows location names only.
                legend_str = locations[index]
            elif param == params[0]:
                # If there are two params in the set, and you're plotting the first param, put it on the left axis and legend shows location name + param.
                legend_str = locations[index]+ " (" + param + ")"
            else:
                # If there are two params in the set, and you're plotting the second param, put it on the right axis and legend shows location name + param.
                legend_str = locations[index]+ " (" + param + ")"
                y_range_axis = "right"

            # Defaults
            selGlyph = 'circle'
            selColor = '#0a99db' # deltares blue [default]
            selSize = 4
            selLegend = legend_str
            
            # User preferences
            try:
                for c in conf['selectedParams']:
                    if c['locationId'] == l:
                        selGlyph = c['glyph']
                        selColor = c['color']
                        if len(selColor) == 6: 
                            selColor = selColor.replace('#', '#0') # bug of bokeh? or frontend?
                        selSize = c['size']                        
                        try:
                            if c['legendTitle']:
                                selLegend = c['legendTitle'] # optional parameter
                        except:
                            pass
            except:
                pass

            # Plot [Line + Glyph[circle, square, triangle]]
            if y_range_axis == 'left':
                g1 = Line(x="x", y="y", line_color=selColor)
                p.add_glyph(source, g1)
                plotGlyphLeft(p, selGlyph, selColor, selSize, source, selLegend)

                # Flagged data
                if len(xff) > 0: 
                    plotGlyphLeft(p, selGlyph, 'gray', selSize*2, sourceFlags, 'Unreliable data')

                # Hover glyphs
                g1_r = p.add_glyph(source_or_glyph=source, glyph=g1)
                renderers_list.append(g1_r)
            else:
                g1 = Line(x="x", y="y", line_color=selColor)
                p.add_glyph(source, g1, y_range_name="right")
                plotGlyphRight(p, selGlyph, selColor, selSize, source, selLegend)

                # Flagged data
                if len(xff) > 0: 
                    plotGlyphRight(p, selGlyph, 'gray', selSize * 2, sourceFlags, 'Unreliable data')

                # Hover glyphs
                g1_r = p.add_glyph(source_or_glyph=source, glyph=g1, y_range_name="right")
                renderers_list.append(g1_r)

        # Y-axis space for legend
        diffR= yrange_max - yrange_min
        p.y_range = DataRange1d(start=yrange_min - 0.1*diffR, end=yrange_max + 0.3*diffR)

        # Legend settings
        p.legend.label_text_font_size = '8pt'
        p.legend.location = "top_left"
        p.legend.click_policy="hide"

        # Global Hover settings
        hover = HoverTool(formatters={'DateTime': 'datetime'}, renderers=renderers_list)
        hover.tooltips = [
            ("date", "@date"),
            ("value", "@y")
        ]
        hover.mode = 'vline'

        p.tools.append(hover)
        p.toolbar.logo = None

        # Output HTML
        output_html = getTempFile(tempdir)
        output_file(output_html, title="generated with bokeh_plot.py") # TODO change title to something useful
        save(p)
        return output_html
