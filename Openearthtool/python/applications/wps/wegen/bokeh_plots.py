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
from bokeh.models import Range1d, HoverTool, Label
from bokeh.palettes import gray
from bokeh.models import LinearColorMapper, ColorBar, BasicTicker

# CLASS to generate bokeh plots for eMisk
class bokeh_Plot:
    def __init__(self, datainx, datainy, propin, outp):
        self.datax = datainx
        self.datay = datainy
        self.properties = propin        
        self.output_html = outp
 
    # Simple patches XY plot [Borehole]
    def plot_Transect(self):   
        # order data by key/year
        odatay = collections.OrderedDict(sorted(self.datay.items()))
        keys_ord = odatay.keys()

        # Prepare plot
        TOOLS = "pan,wheel_zoom,box_zoom,save"
        p = figure(width=950, height=500, tools=TOOLS)        
        p.yaxis.axis_label = "Hoogte (m-NAP)"
        p.xaxis.axis_label = 'Afstand (m)'

        # Data preparation
        miny = 99999        
        maxy = -99999
        minx = 99999
        maxx = -99999  
        pal = gray(len(odatay.keys())+1)[0:-1] # avoid white [first two colors out]        
        pal.reverse() # white to black        
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

        # Fake legend
        p.square([-9999], [-9999], color='#FFFF00', legend='geselecteerd transect')
        p.square([-9999], [-9999], color='#FF00FF', legend='beschikbare data')

        # Plot margins
        distY = (maxy - miny)        
        p.y_range = Range1d(miny-(maxy-miny)*0.05, maxy+(maxy-miny)*0.25)
        p.x_range = Range1d(minx-(maxx-minx)*0.05, maxx+(maxx-minx)*0.15)
        color_bar = ColorBar(color_mapper=color_mapper, label_standoff=10, border_line_color=None, location=(0,0), ticker=BasicTicker(desired_num_ticks=i-1))
        p.add_layout(color_bar, 'left')

        # - Output HTML
        output_file(self.output_html, title="generated with bokeh_plot.py")
        save(p)