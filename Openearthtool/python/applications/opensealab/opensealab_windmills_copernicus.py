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
from Copernicus_Marine_Client.Copernicus_Marine_download import CMEMSDownload

# Other imports
from datetime import date
import os

# TIME FILTER: the week before the workshop
t0 = date(2013, 06, 01)
t1 = date(2014, 06, 01)
t0_str = "2013-06-01 23:00:00"
t1_str = "2014-06-01 23:00:00"

# GEO FILTER: the region of interest
bbox = (7.55, 56.99, 12.09, 58.05)

# Z FILTER: the selected depths
depth0 = 0.0
depth1 = 100.0

# Output directory
output_dir = './windmills_downloaded_data/cmems'

# SALINITY - Data download - Copernicus Marine
user = 'adminweb'
passw = 'adminweb'
motuserver = 'http://data.ncof.co.uk/motu-web/Motu'
service = 'NORTHWESTSHELF_ANALYSIS_FORECAST_PHYS_004_001_b'
dataset = 'MetO-NWS-PHYS-hi-SAL'
variable = 'vosaline'
output_netcdf = 'salinity_cmems.nc'
## Perform download
cmems = CMEMSDownload(bbox, t0, t1, depth0, depth1, variable, output_dir, output_netcdf, user, passw, motuserver, service, dataset)
cmems.download()

# PPRD - Data download - Copernicus Marine
user = 'adminweb'
passw = 'adminweb'
motuserver = 'http://data.ncof.co.uk/motu-web/Motu'
service = 'NORTHWESTSHELF_REANALYSIS_BIO_004_011'
dataset = 'MetO-NWS-REAN-BIO-daily-PPRD'
variable = 'netPP'
output_netcdf = 'netPP_cmems.nc'
## Perform download
cmems = CMEMSDownload(bbox, t0, t1, depth0, depth1, variable, output_dir, output_netcdf, user, passw, motuserver, service, dataset)
cmems.download()
