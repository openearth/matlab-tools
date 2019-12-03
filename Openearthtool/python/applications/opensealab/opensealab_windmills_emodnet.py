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
from EMODNET_Client import EMODNET_WCS_query
from EMODNET_Client import EMODNET_WFS_query
import os

# Other imports
from datetime import date

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
output_dir = './windmills_downloaded_data/emodnet'

# BATHYMETRY - Data download - EMODnet
outtif  = os.path.join(output_dir, 'bathymetry_emodnet.tif')
url_wcs = 'http://ows.emodnet-bathymetry.eu/wcs?'
layer_wcs = 'emodnet:mean_atlas_land'
ident = 'emodnet:mean'
emodwcs = EMODNET_WCS_query.EMODNET_WCS_query(bbox, outtif, url_wcs, layer_wcs, ident)
width, height = emodwcs.getDataWCS()
print 'WCS query finished'
print 'Image created with resolution = {} x {}'.format(width, height)

outtif  = os.path.join(output_dir, 'bathymetry_emodnet_color.tif')
url_wcs = 'http://ows.emodnet-bathymetry.eu/wcs?'
layer_wcs = 'emodnet:mean_atlas_land'
ident = 'emodnet:mean'
emodwcs = EMODNET_WCS_query.EMODNET_WCS_query(bbox, outtif, url_wcs, layer_wcs, ident)
width, height = emodwcs.getDataWCS()
print 'WCS query finished'
print 'Image created with resolution = {} x {}'.format(width, height)
'''
# BIOLOGY - Emodnet
url_wfs = 'http://geo.vliz.be/geoserver/wfs/ows?'
layer_wfs = 'Dataportal:eurobis'
outshp = os.path.join(output_dir, 'biology_emodnet.csv')
format = 'csv'
propertyname='Dataportal:scientificname'
literal='Amphiura filiformis'

# Do work
emodwfs = EMODNET_WFS_query.EMODNET_WFS_query(bbox, outshp, url_wfs, layer_wfs, format, propertyname, literal)
df = emodwfs.getDataWFS()
print 'WFS query finished'


# Habitats - Emodnet
url_wfs = 'http://77.246.172.208/geoserver/emodnet/wfs'
layer_wfs = 'emodnet:natura2000'
outshp = os.path.join(output_dir, 'natura2000_emodnet.zip')
format = 'shape-zip'
propertyname=''
literal=''

# Do work
emodwfs = EMODNET_WFS_query.EMODNET_WFS_query(bbox, outshp, url_wfs, layer_wfs, format, propertyname, literal)
df = emodwfs.getDataWFS()
print 'WFS query finished'
'''