# -*- coding: utf-8 -*-
"""
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for LHM functions
#
#       gerrit.hendriksen@deltares.nl
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

"""
import os
import math
import time
from .sqlfunctions import *
import numpy as np
import tempfile
from bokeh.plotting import figure, show, save, ColumnDataSource
from bokeh.layouts import row, column
from bokeh.io import output_file
from bokeh.models import Range1d, HoverTool

# read credential file and populate dictionary with credentials
credentials = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'pgconnection_nhi.txt')


def makeprofile(x, y, outhtml):
    # get profile data
    a = getdatafromclosestprofile(x, y)
    (x, y, z, p, wktenvelope) = list(zip(*a))

    # calculate distances between points
    lstdist = calculatedistancebetweenpoints(x, y)

    # Plot per column
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p = figure(width=600, height=350, title='{}'.format(p[0]), tools=TOOLS)
    p.xaxis.axis_label = 'afstand (m tov beginpunt)'
    p.yaxis.axis_label = 'hoogte (m-NAP)'
    p.line(lstdist, z, color="red",)

    # - Output HTML
    output_file(outhtml, title="Powered by OpenEarth")
    save(p)

    return wktenvelope[0]

# used to be working on profiellijnen, but since profielcode for a profile is not unique anymore ...


def getdatafromclosestprofile(xi, yi):
    strSql = """
        select st_x(geometriepunt),st_y(geometriepunt), st_z(geometriepunt),profielcode, ST_AsText(ST_Buffer(ST_Transform(geometriepunt, 3857), 100))
        from dwarsprofiel where profielcode =
            (SELECT profielcode FROM dwarsprofiel
            ORDER BY geometriepunt <#> st_transform(st_setsrid(st_point({x},{y}), 3857), 28992)
            LIMIT 1)
        order by codevolgnummer""".format(x=xi, y=yi)

    logging.info(strSql)
    cf = get_credentials(credentials)
    a = executesqlfetch(strSql, cf)
    logging.info(a[0][3])
    return a


def calculatedistancebetweenpoints(x, y):
    lstdist = []
    p1 = (x[0], y[0])
    for p in range(len(x)):
        dist = math.hypot(x[p]-p1[0], y[p]-p1[1])
        lstdist.append(dist)
    return lstdist
