# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#
#       Gerrit Hendriksen
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

# $Id: info_nhiflux.py 13706 2017-09-13 09:29:46Z sala $
# $Date: 2017-09-13 11:29:46 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13706 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/emisk_utils.py $
# $Keywords: $

import configparser
import math
import time
import logging
import io
import os
import tempfile
import simplejson as json
import numpy as np
from pyproj import Proj, transform

# Read default configuration from file


def readConfig():
    # Default config file (relative path)
    cfile = os.path.join(os.path.dirname(
        os.path.realpath(__file__)), 'NHIconfig.txt')
    cf = configparser.RawConfigParser()
    cf.read(cfile)
    plots_dir = cf.get('Bokeh', 'plots_dir')
    apache_dir = cf.get('Bokeh', 'apache_dir')
    return plots_dir, apache_dir

# Get a unique temporary file


def TempFile(tempdir):
    dirname = str(time.time()).replace('.', '')
    return os.path.join(tempdir, dirname+'.html')


def inside_nl_latlon(lon, lat):
    return (lat < 53.599 and lat > 50.662 and lon < 7.569 and lon > 3.195)

# Change XY coordinates general function


def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:4326'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)

# Parameters check


def check_location(location, epsgin='epsg:3857'):
    # Valid JSON
    try:
        # Input (coordinates)
        if isinstance(location, str):
            location_info = json.loads(location)
            (xin, yin) = location_info['x'], location_info['y']
        else:
            location_info = location
            (xin, yin) = location_info[0], location_info[1]

        (lon, lat) = change_coords(xin, yin)
        logging.info(
            '''Input Coordinates {} {} -> {} {}'''.format(xin, yin, lon, lat))
    except Exception as e:
        logging.error(e)
        return False, '''<p>Selecteer een locatie op de kaart 'Select on map' button</p>''', -1, -1

    # Check inside Europe
    if not inside_nl_latlon(lon, lat):
        return False, '''<p>Selecteer een locatie binnen Nederland</p>''', -1, -1

    # Parameters check OK
    return True, '', xin, yin
