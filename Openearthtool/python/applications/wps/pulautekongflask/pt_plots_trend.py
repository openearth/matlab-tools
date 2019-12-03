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

# Functions for fitting
def exp_func(x, a, b, c):
    return a+b*np.exp(-(c)*x)
def log_func(x, a, b):
    return a*np.log(x)+b
def sin_func(x, a, b, c, d):
    return a*np.sin(b*(x+c))+d

# Functions for guessing
def guess_sin(x, y):
    # Fit sin to the input time sequence, and return fitting parameters "amp", "omega", "phase", "offset", "freq", "period" and "fitfunc"
    tt = np.array(x)
    yy = np.array(y)
    ff = np.fft.fftfreq(len(tt), (tt[1]-tt[0]))   # assume uniform spacing
    Fyy = abs(np.fft.fft(yy))
    guess_freq = abs(ff[np.argmax(Fyy[1:])+1])   # excluding the zero frequency "peak", which is related to offset
    guess_amp = np.std(yy) * 2.**0.5
    guess_offset = np.mean(yy)
    guess = np.array([guess_amp, 2.*np.pi*guess_freq, 0., guess_offset])
    return guess

# Plot a trend [linear, log, exp, mean averages]
def plotTrend(conf, ttype, times, values, params, units, locations, tempdir):

    # Get size prefences
    xSize, ySize = getPlotSize(conf)

    # Get plot settings
    title, xAxis, yAxis1, yAxis2 = getPlotSettings(conf)
    
    # One time series analysis [not multi]
    location = locations[0]
    time = times[0]
    vals = values[0]
    param = params[0]
    ts = [ datetime_to_float(d) for d in time ]

    # Title definition
    tit = 'Trend analysis [{}] for {}'.format(ttype, location)
    if title:
        tit=title

    # Figure and tooltips definition      
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save" 
    p = figure(width=xSize, height=ySize, x_axis_type="datetime", title=tit, tools=TOOLS, toolbar_location="above")

    # Axis definition
    if xAxis:
        p.xaxis.axis_label = xAxis
    else:
        p.xaxis.axis_label = 'Time'

    if yAxis1:
        p.yaxis.axis_label = yAxis1
    else:
        p.yaxis.axis_label = '''{} ({})'''.format(param, units)
    p.xaxis.formatter = DatetimeTickFormatter(days=['%d/%m'])

    # User preferences
    selGlyph = conf['selectedParams'][0]['glyph']
    selColor = conf['selectedParams'][0]['color']
    if len(selColor) == 6: 
        selColor = selColor.replace('#', '#0') # bug of bokeh? or frontend? 
    selSize = conf['selectedParams'][0]['size']
    selLegend = location
    try:
        if conf['selectedParams'][0]['legendTitle']:
            selLegend = conf['selectedParams'][0]['legendTitle']
    except:
        pass # optional parameter

    # Time / Elapsed time
    x0 = ts[0]
    xn = ts[-1]
    elapsedTime = np.array(ts) - x0

    # Plot [line+symbol]
    x = [float_to_datetime(t) for t in ts]
    source = ColumnDataSource(data=dict(
        x=x,
        y=vals,
        date=[d.strftime('%Y-%m-%d %H:%M:%S') for d in time],
        loc=[location for d in time] # repeat
    ))     
    g1 = Line(x="x", y="y", line_color=selColor)
    p.add_glyph(source, g1)                 
    plotGlyphLeft(p, selGlyph, selColor, selSize, source, selLegend)

    # Plot trend [depending on type]
    g1_r = p.add_glyph(source_or_glyph=source, glyph=g1)

    # Linear fit - y=ax+b
    if ttype == 'linear':
        a,b = np.polyfit(ts, vals, 1)
        y0 = a*x0+b
        yn = a*xn+b
        p.line([float_to_datetime(x0), float_to_datetime(xn)], [y0, yn], line_width=3, line_color='black', legend='y = ax + b [a={}, b={}]'.format(fn(a), fn(b)))   

    # Polynomial [2nd degree] - y=ax2+bx+c
    elif ttype == 'poly2':
        a,b,c = np.polyfit(ts, vals, 2)        
        y = [ a*math.pow(t, 2)+b*t+c for t in ts ]
        p.line(x, y, line_width=3, line_color='black', legend='y = ax2 + bx + c [a={}, b={}, c={}]'.format(fn(a), fn(b), fn(c)))   

    # Polynomial [3rd degree] - y=ax3+bx2+cx+d
    elif ttype == 'poly3':
        a,b,c,d = np.polyfit(ts, vals, 3)
        y = [ a*math.pow(t, 3)+b*math.pow(t, 2)+c*t+d for t in ts ]
        p.line(x, y, line_width=3, line_color='black', legend='y = ax3 + bx2 + cx + d [a={}, b={}, c={}, d={}]'.format(fn(a), fn(b), fn(c), fn(d)))

    # Sinus fit - y=a*sin(b*(x+c))+d
    elif ttype == 'sin':
        ([a,b,c,d], _) = optimize.curve_fit(sin_func,  ts,  vals, maxfev=100000, p0=guess_sin(ts,vals))     
        y = [sin_func(t,a,b,c,d) for t in ts]        
        p.line(x, y, line_width=3, line_color='black', legend='y = a*sin(b*(x+c))+d [a={}, b={}, c={}, d={}]'.format(fn(a), fn(b), fn(c), fn(d)))   
    
    # Logarithmic fit - y=a*log(x)+b
    elif ttype == 'log':
        a,b = np.polyfit(np.log(ts), vals, 1)
        #popt, pcov = optimize.curve_fit(log_func, elapsedTime, vals, p0=(0.5, 99.0))
        p.line(x, log_func(np.array(ts), a, b), line_width=3, line_color='black', legend='y = a*log(x)+b [a={}, b={}]'.format(a, b))

    # Exponential Fit - y=a+b*exp(-cx)
    # https://stackoverflow.com/questions/45337939/finding-initial-guesses-for-exponential-curve-fit
    elif ttype == 'exp':
        ([a,b,c], _) = optimize.curve_fit(exp_func,  ts,  vals, maxfev=100000)
        y = [exp_func(t,a,b,c) for t in ts]
        p.line(x, y, line_width=3, line_color='black', legend='y = a+b*exp(-cx) [a={}, b={}, c={}]'.format(fn(a), fn(b), fn(c)))

    # Moving average Fit
    elif ttype == 'movavg':
        series = pd.Series(vals)
        avgWindow = 10
        if 'averageWindow' in conf:
            avgWindow = int(conf['averageWindow'])
        rolling = series.rolling(window=avgWindow)
        rolling_mean = rolling.mean()
        p.line(x, rolling_mean, line_width=3, line_color='black', legend='Moving average')

    else:
        raise Exception("ERROR: Trend analysis type {} not available".format(ttype))

    # Legend settings
    p.legend.label_text_font_size = '8pt'
    p.legend.location = "top_left"
    p.legend.click_policy="hide"
      
    # Global Hover settings        
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