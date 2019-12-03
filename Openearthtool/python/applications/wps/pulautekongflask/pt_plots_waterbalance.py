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

# Plot waterbalance: this function plots the pre-defined water balance and requires no inputs
def plotWaterBalance(conf, data, plots_dir):

    # TO DO: 
    # Import data for the following parameters, within the range of "times" (all for locationId = wb_entirepolder):
    #   Q.wb.structure, Q.wb.pump, Q.wb.rainfall_tot, Q.wb.evap, Q.wb.seepage, Q.wb.storage, Q.wb.residual.
    # Give a warning if data is not available for complete specified period (especially since our test period is only 1 week)
    # The data will be flow rates (m3/s) at daily timesteps. We want to calculate the average over the range of "times" and plot these averages in the graph.

    # Get size prefences
    xSize, ySize = getPlotSize(conf)

    # Get plot settings
    title, xAxis, yAxis1, yAxis2 = getPlotSettings(conf)

    # Inflow from structures
    inflow_structures = data['Q.wb.structure'] # replace with import + averaging

    # Outflow at pump
    outflow_pump = data['Q.wb.pump'] # replace with import + averaging
    
    # Rainfall
    rainfall = data['Q.wb.rainfall_tot'] # replace with import + averaging

    # Evaporation
    evap = data['Q.wb.evap'] # replace with import + averaging

    # Seepage
    seepage = data['Q.wb.seepage'] # replace with import + averaging

    # Storage
    storage = data['Q.wb.storage'] # replace with import + averaging

    # Residual
    residual = data['Q.wb.residual'] # replace with import + averaging

    # MAKE PLOT
    wb_components = ['Inflow at Structures','Outflow at Pump', 'Rainfall', 'Evaporation', 'Seepage', 'Storage', 'Residual']
    wb_values = [inflow_structures, outflow_pump, rainfall, evap, seepage, storage, residual]
    wb_colors = ['#880000' if i < 0 else '#0a99db' for i in wb_values] # Make it red if negative, blue if positive?
    tit = "Water balance analysis"
    if title: tit = title
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"

    plot_data = dict(wb_components = wb_components, wb_values = wb_values)
    source = ColumnDataSource(data = plot_data)
    p = figure(x_range=wb_components, width=xSize, height=ySize, tools=TOOLS, title=tit, toolbar_location="above")
    #p.vbar(x='wb_components', top='wb_values', width=0.9, source=source, line_color='white', fill_color = factor_cmap('wb_components', palette=Spectral6, factors=wb_components))
    p.vbar(x='wb_components', top='wb_values', width=0.9, source=source, line_color='white', fill_color = factor_cmap('wb_components', palette=wb_colors, factors=wb_components))

    # Axis definition
    if xAxis:
        p.xaxis.axis_label = xAxis
    else:
        p.xaxis.axis_label = "Component of water balance"

    if yAxis1:
        p.yaxis.axis_label = yAxis1
    else:
        p.yaxis.axis_label = "Average rate of change (m3/s)"
     
    p.title.text_font_size = '8pt'    
    p.xaxis.axis_line_color = "black"
    p.add_tools(HoverTool(tooltips=[("Component", "@wb_components"), ("Value", "@wb_values")]))

    # Output HTML
    output_html = getTempFile(plots_dir)
    output_file(output_html, title="generated with make_plots.py")
    save(p)

    # Output CSV
    csv_path = getTempFile(plots_dir, typen='export', extension='.csv')
    fcsv = open(csv_path, 'a')
    fcsv.write("component;value\n")

    for k,v in zip(wb_components, wb_values):
        fcsv.write('{};{}\n'.format(k,v))

    return output_html, csv_path
