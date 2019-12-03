# -*- coding: utf-8 -*-
"""
Created on Thu Oct  4 11:39:26 2018

@author: gaytan_sa
"""
from shutil import copyfile
import numpy as np
from utils import change_coords as cc
from utils_grid import *
from utils_shp  import *
from getosm import *

#shapefileIn = "water.shp"
#gridFile = "grid.tif"
#watertif = "water.tif"
#interval = np.asarray([30, 100, 300])
#shapefileFilter = "water_filter.shp"
#filter_class = ['river']

def create_water_map(shapefileIn,gridFile,filter_class,filter_area,interval):
    
    shapefileFilter = shapefileIn[0:-4] + '_filter.shp'
    watertif        = shapefileIn[0:-4] + '.tif'
    createFilteredShapefile(filter_class,filter_area,shapefileIn,shapefileFilter)
    copyfile(gridFile, watertif) 
    interval = np.asarray(interval)
    for i in range(0,interval.size):
          distance = interval[interval.size-1-i]
          strdis = str(distance)
          bufferfile = shapefileFilter[0:-4] + strdis +'.shp'            
          createBuffer(shapefileFilter, bufferfile, distance)      
          os.system('gdal_rasterize -burn ' + str(i+1) +' -l ' + bufferfile[0:-4] + ' ' + bufferfile + ' ' + watertif)
    return watertif  
          
          