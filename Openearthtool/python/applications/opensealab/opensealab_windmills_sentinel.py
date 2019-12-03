# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
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
# OpenEarthTools is an online collaboration to share andmanage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.
# $Keywords: $

# Modules import
from Sentinel_Client.SentinelSearch import *

import os

# Other imports
from datetime import date

# TIME FILTER:
t0 = date(2017, 01, 01)
t1 = date(2017, 11, 15)
t0_str = "2017-01-01 23:00:00"
t1_str = "2017-11-15 23:00:00"

# GEO FILTER: the region of interest
bbox = (2.91, 54.89, 4.17, 55.35)

# Data download - Sentinels
download_full = True  # download preview or get image
mission = 'Sentinel-2'
clouds = (0, 20)
outfname = './windmills_downloaded_data/sentinel/search_sentinel.json'
output_dir = './windmills_downloaded_data/sentinel'
lessCloudsWithinDates(download_full, outfname, mission, clouds, bbox, t0, t1, output_dir)
