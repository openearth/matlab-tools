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

# General
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

# Functions for formatting
def fn(f):
    if f < 0.01:
        return '%.2E'%Decimal(f)
    else:
        return "{0:.2f}".format(f)
        
# Plot a glyph / Left axis
def plotGlyphLeft(p, selGlyph, selColor, selSize, source, legend_str):
    if selGlyph == 'triangle':
        p.triangle('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str)
    elif selGlyph == 'cross':
        p.cross('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str)
    elif selGlyph == 'asterisk':
        p.asterisk('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str)
    elif selGlyph == 'square':
        p.square('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str)
    elif selGlyph == 'diamond':
        p.diamond('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str)
    else:
        p.circle('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str)

# Plot a glyph / Right axis
def plotGlyphRight(p, selGlyph, selColor, selSize, source, legend_str):
    if selGlyph == 'triangle':
        p.triangle('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str, y_range_name="right")
    elif selGlyph == 'cross':
        p.cross('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str, y_range_name="right")
    elif selGlyph == 'asterisk':
        p.asterisk('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str, y_range_name="right")
    elif selGlyph == 'square':
        p.square('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str, y_range_name="right")
    elif selGlyph == 'diamond':
        p.diamond('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str, y_range_name="right")
    else:
        p.circle('x', 'y', size=selSize, color=selColor, source=source, legend=legend_str, y_range_name="right")
