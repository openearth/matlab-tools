# -*- coding: utf-8 -*-
"""
Created on Thu Oct  4 20:32:40 2018

@author: gaytan_sa
"""
import os
from shutil import copyfile
import numpy as np
from utils_grid import *
#demfile = "p:/11202750-ri2de/Datasets/Elevation/Albania/015_DTM_10m/TOTALCLIP.tif"
#slopefile = "slope.tif"
#demfile = "p:/1208166-ecostress/FAST/SRTM/data/srtm_01_18/srtm_01_18.tif"
#os.system('gdaldem slope ' + demfile + ' ' + slopefile + ' -of GTiff -b 1 -s 1')
#os.system('gdaldem slope TOTALCLIP.tif slope.tif -of GTiff -b 1 -s 1')
#demfileIn = "dem.tif"
#gridFile = "grid.tif"
#slopefileOut = "slope.tif"

# Function that compute the slop given a dem file
def create_slope_map(demfileIn,slopefileOut, gridFile,interval):
    interval = np.asarray(interval)
    slopefileIn = slopefileOut[0:-4] + '_inter.tif'
    os.system('gdaldem slope ' + demfileIn + ' ' + slopefileIn + ' -of GTiff -b 1 -s 1')
    reprojectRaster(slopefileIn,gridFile,slopefileOut)
    RasterToclass(slopefileOut,interval)
    return slopefileOut  
    

#    copyfile(gridFile, slopefileOut) 
#    interval = np.asarray(interval)
#    slopefileIn = slopefileOut[0:-4] + '_inter.tif'
#    os.system('gdaldem slope ' + demfileIn + ' ' + slopefileIn + ' -of GTiff -b 1 -s 1')
#    RasterToclass(slopefileIn,interval)
#    slopefileOut = raster2rastergrid(slopefileIn,slopefileOut,gridFile)
#    return slopefileOut  
