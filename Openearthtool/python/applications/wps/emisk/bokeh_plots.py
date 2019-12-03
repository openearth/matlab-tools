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

# $Id: bokeh_plots.py 14132 2018-01-30 19:06:23Z sala $
# $Date: 2018-01-30 11:06:23 -0800 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14132 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/bokeh_plots.py $
# $Keywords: $

import json
import logging
from datetime import datetime
from colour import Color
import numpy as np

# Plots
from bokeh.plotting import figure, show, save, ColumnDataSource
from bokeh.io import output_file
from bokeh.models import Range1d, HoverTool, Label

# Geology legends
import emisk_geology as eg

# CLASS to generate bokeh plots for eMisk
class bokeh_Plot:
    def __init__(self, datain, propin, outp):
        self.data = datain
        self.properties = propin        
        self.output_html = outp
 
    # Simple Time-Series plot XY
    def plot_Tseries(self):
        # Data preparation
        (time,depth) = zip(*self.data)
        x=[]
        for t in time:  x.append(datetime.strptime(t.split(' ')[0], '%Y-%m-%d'))            
        y=[]
        for d in depth: y.append(float(d))
        locid = self.properties['locationke']
        posx = self.properties['x']
        posy = self.properties['y']
        tit = 'Time series for location with ID = {}'.format(locid)

        # Plot per column
        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
        p = figure(width=650, height=250, x_axis_type="datetime", title=tit, tools=TOOLS)
        p.xaxis.axis_label = 'Time'
        p.yaxis.axis_label = 'Groundwater level (m)'
        p.line(x, y, color="darkblue")
        p.circle(x=x, y=y, size=5, color="darkblue")
        
        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)

    # PlotXY Depth versus SPT values
    def plot_SPT(self):
        # Data preparation        
        x=[]
        y=[]
        (depth, vals) = zip(*self.data)
        for v in vals:  x.append(float(v))        
        for d in depth: y.append(float(d))
        locid = self.properties['locationke']
        posx = self.properties['x']
        posy = self.properties['y']
        tit = 'SPT vs Depth for location with ID = {}'.format(locid)

        # Plot per column
        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
        p = figure(width=400, height=600, title=tit, tools=TOOLS, y_range=Range1d(max(y)+min(y)*0.25, min(y)-min(y)*0.25))
        p.yaxis.axis_label = 'Depth (m-surface)'
        p.xaxis.axis_label = 'SPT value (no. of blows)'
        p.line(x,y, color="darkred")
        p.circle(x,y, size=5, color="darkred")

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)

    # Simple patches XY plot [Borehole]
    def plot_Borehole(self, layernames):   
        # Init
        patchX = []
        patchY = []
        colors = []
        tops = []
        bottoms = []
        
        # Prepare plot
        TOOLS="pan,wheel_zoom,box_zoom,reset,hover,save"
        locid = self.properties['locationke']
        posx = self.properties['x']
        posy = self.properties['y']        
        tit = 'Borehole depth plot [x,y] = [{},{}] meters'.format(int(posx),int(posy))
        p = figure(plot_width=450, plot_height=500, title=tit, tools=TOOLS)
        p.toolbar.logo = None 
        p.grid.grid_line_color = None
        p.xaxis.visible = False
        p.x_range = Range1d(0, 50)
        p.yaxis.axis_label = "Depth (meters-MSL)"        

        # Tip
        citation = Label(x=20, y=-40, x_units='screen', y_units='screen',
                 text='TIP: Hover cursor on layers to get extra info', render_mode='css',
                 border_line_color='black', border_line_alpha=1.0, text_font_size="10pt", text_font_style='bold',
                 background_fill_color='yellow', background_fill_alpha=1.0)
        p.add_layout(citation)    

        # Plot patches
        n = len(self.data)       
        i=0
        px = [5, 5, 25, 25]
        names = []
        while (i<n-1):         
            # Define patch            
            py = [self.data[i], self.data[i+1], self.data[i+1], self.data[i]]
            layername = layernames[i]
            colorlayer = eg.colorscheme[layername]
            p.patch(px,py, color=colorlayer)

            # For hover
            colors.append(colorlayer)
            patchX.append(px)
            patchY.append(py)
            tops.append(self.data[i])
            bottoms.append(self.data[i+1])  
            names.append(eg.titlescheme[layernames[i]])          
            i+=1

        # Last level [no bottom, -1000m]
        py = [self.data[-1], self.data[-1]-1000, self.data[-1]-1000, self.data[-1]]
        p.patch(px,py, color=eg.colorscheme[layernames[-1]])
        colors.append(eg.colorscheme[layernames[-1]])
        patchX.append(px)
        patchY.append(py)
        tops.append(self.data[-1])
        bottoms.append(self.data[-1]-1000) 
        names.append(eg.titlescheme[layernames[-1]])

        # - Source data dict
        source = ColumnDataSource(data=dict(
            x=patchX,
            y=patchY,
            color=colors,
            names=names,         
            tops=tops,
            bottoms=bottoms
        ))
        p.patches('x', 'y', source=source, fill_color='color', fill_alpha=0.7, line_color="black", line_width=0.5)
        p.y_range = Range1d(min(self.data)-100, max(self.data))

        # - Mouse hover
        hover = p.select_one(HoverTool)
        hover.point_policy = "follow_mouse"
        hover.tooltips = """
        <div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Layer:</span>
                <span style="font-size: 12px; color: #777777;">@names</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Top (m):</span>
                <span style="font-size: 12px; color: #777777;">@tops</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Bottom (m):</span>
                <span style="font-size: 12px; color: #777777;">@bottoms</span>
            </div>            
        </div>
        """

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p) 

    # Plot borehole of Lithology vs depth
    def plot_Lithology_Borehole(self):
        # Init
        patchX = []
        patchY = []
        colors = []
        tops = []
        bottoms = []
        names = []
        
        # Prepare plot
        TOOLS="pan,wheel_zoom,box_zoom,reset,hover,save"
        locid = self.properties['locationke']
        posx = self.properties['x']
        posy = self.properties['y']        
        tit = 'Location_id={}, [x,y] = [{},{}] meters'.format(locid,posx,posy)
        p = figure(plot_width=500, plot_height=500, title=tit, tools=TOOLS)
        p.toolbar.logo = None 
        p.grid.grid_line_color = None
        p.xaxis.visible = False
        p.x_range = Range1d(0, 50)
        p.yaxis.axis_label = "Depth (meters-MSL)"        
        
        # Tip
        citation = Label(x=20, y=-40, x_units='screen', y_units='screen',
                 text='TIP: Hover cursor on layers to get extra info', render_mode='css',
                 border_line_color='black', border_line_alpha=1.0, text_font_size="10pt", text_font_style='bold',
                 background_fill_color='yellow', background_fill_alpha=1.0)
        p.add_layout(citation)        
        
        # Plot patches
        i=0
        for d in self.data:
            lockey, locname, desc, top, bot, period, color_name, color_st = d  # decode, see query  
            top*=-1.0
            bot*=-1.0
            # Define patch
            px = [5, 5, 30, 30]
            py = [top, bot, bot, top]
            c = eg.colorLookupTable_Lithology[color_name]
            p.patch(px,py, color=c)

            # For hover
            colors.append(c)
            patchX.append(px)
            patchY.append(py)
            names.append(desc)
            tops.append(top)
            bottoms.append(bot)            
            i+=1

        # - Source data dict
        source = ColumnDataSource(data=dict(
            x=patchX,
            y=patchY,
            color=colors,
            names=names,         
            tops=tops,
            bottoms=bottoms
        ))
        p.patches('x', 'y', source=source, fill_color='color', fill_alpha=0.7, line_color="black", line_width=0.5)

        # - Mouse hover
        hover = p.select_one(HoverTool)
        hover.point_policy = "follow_mouse"
        hover.tooltips = """
        <div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Layer:</span>
                <span style="font-size: 12px; color: #777777;">@names</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Top (m):</span>
                <span style="font-size: 12px; color: #777777;">@tops</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Bottom (m):</span>
                <span style="font-size: 12px; color: #777777;">@bottoms</span>
            </div>            
        </div>
        """

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)           

    # Simple patches XY plot [Borehole]
    def plot_Transect(self, distances):   
        # Reshape matrix
        layers = zip(*self.data)

        # Prepare plot
        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
        p = figure(width=650, height=450, title='Transect Plot', tools=TOOLS)        
        p.yaxis.axis_label = "Depth (meters-MSL)"
        p.xaxis.axis_label = 'Distance (m)'

        # Data preparation
        miny = 99999
        maxy = -99999 
        for layer in eg.orderedtitles:
            i=0   
            y=np.asarray(self.data[layer])        
            x=np.linspace(0.0, distances[layer], num=len(y)) ## Number of points x resolution            
            if min(y) < miny:   miny = min(y)
            if max(y) > maxy:   maxy = max(y)
            p.line(x,y, color=eg.colorscheme[layer], legend=eg.titlescheme[layer], line_width=4)
            i+=1            
  
        # Plot margins
        distY = (maxy - miny)        
        p.y_range = Range1d(miny-(maxy-miny)*0.1, maxy+(maxy-miny)*0.75)

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)