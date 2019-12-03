# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares on behalf of RI2DE/RA2CE project
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

"""EEPR = Erosion of Embankments due to Proximity of Rivers
   This is the main script
"""

import os
import ri2de_configuration
from utils import change_coords as cc
from utils_grid import *
from utils_shp  import *
from getosm import *
from create_road_map import *
from create_water_map import *
#from create_soil_map import *
from create_landcover_map import *
from create_slope_map import *
from shutil import copyfile
from create_vulnerability_map import *

"""For this threat the main input parameter is extent and the infrastructure type
   used to filter the OSM data"""
   
   
#extent = (2128766, 4840344,2317723,5243489) # input for cc
#wgsextent = (cc(extent[0],extent[1],'epsg:3857', 'epsg:4326'),cc(extent[2],extent[3],'epsg:3857', 'epsg:4326'))
#
#bbx = (cc(extent[0],extent[1],'epsg:3857', 'epsg:4326'),cc(extent[2],extent[3],'epsg:3857', 'epsg:32634'))
#
#"""with this extent layers from soildata and dem should be clipped """
#"""read the config"""
#dictconf = ri2de_configuration.erosionembankmentsproximityconfig()


wrkfolder = "D:\tools\RI2DE\processes"
land_Shapefile = "Land_Cover.shp"
roadfile  = "roads.shp"
waterfile = "water.shp"
gridfile  = "grid.tif"
masktif   = "mask.tif"
soiltif   = "soil.tif"
landtif   = "land.tif"
filter_value = ['trunk','primary']
demfile = "TOTALCLIP.tif"
slopetif = "slope.tif"
filter_area  = (1892743.319, 4632654.133, 1947567.929, 4673772.591)
land_Shapefile = "Land_Cover.shp"

# ---- step 1, getting road network within boundingbox and producing grind ans mask

masktif = create_road_map(roadfile,gridfile,filter_value,filter_area,bufferDist=300,cellsize=30)

# TODO, get data from OSM directly including a filter on primary roads, motorways and highways
# TODO convert to local crs
# ---- step 2 create buffer and mask
# TODO, create a mask from the filtered OSM data with a buffer that is passed as parameter

# ---- step 3 get water data from OSM
watertif = create_water_map(waterfile,gridfile,['river'],filter_area,interval= [30,100,300])

# TODO retrieve water data (filter on rivers)
# TODO apply proximity code
# Convert proximity to hazardvalues
# TODO convert to local crs

# ---- step 4, getting soildata
# getting soildata from ISRIC (at least from any other kind of webmapservice)
# TODO ask thomas what to do with the percentages derive fromo the soil layers.
create_soil_map(wrkfolder,gridfile)

# ---- step 5, get GLOBCOVER data
# TODO download from deltares data portal
# TODO, reclass globcover data to grass = -2, urban/rock = 0, rest = -1
landtif = create_landcover_map(land_Shapefile,gridfile)
    
# ---- step 6, slope embankment
demtif = create_slope_map(demfile,slopetif, gridfile,interval= [5,10,20])

# ---- step 7, calculation
# TODO make the calculation
create_vulnerability_map("water.tif","soil.tif","Land_Cover_Map.tif","slope.tif",gridfile, masktif,"vulmapT1.tif")


# gdalcalc.py ((waterras + soilras + luseras + slopeembankmentras) / 8 ) * 100
# 

