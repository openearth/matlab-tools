# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares on behalf of RI2DE H2020 project
#       Sandra Gaytan Aguilar
#       Gerrit Hendriksen
#       sandra.gaytan@deltares.nl
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

import os
from utils import *
from utils_wcs import *

#complete list of datasources from ISRIC can be found at http://data.isric.org/geonetwork/
#url = url to wcs (for ISRIC soilgrids250 layers http://data.isric.org/geoserver/sg250m/ows?
#layer = layer of the wcs (layer 1 silt content is SLTPPT_M_sl1_250m)
#rbbox = xmin,ymin,xmax,ymax
#name = variable name of the downloaded gtiff

def getDatafromWCS(geoserver_url, layername,  xst, yst, xend, yend, crs=4326, all_box=False):
	linestr = 'LINESTRING ({} {}, {} {})'.format(xst, yst, xend, yend)
	l = LS(linestr, crs, geoserver_url, layername)
	l.line()
	return l.getraster(all_box=all_box)

GEOSERVER_URL = 'http://data.isric.org/geoserver/ows?'
layer = 'sg250m:SLTPPT_M_sl1_250m'
x0 = 19.833
y0 = 41.607
xk = 20.996
yk = 42.494
d=getDatafromWCS(GEOSERVER_URL, layer, x0, y0, xk, yk)
