# -*- coding: utf-8 -*-
"""
Created on Thu Oct  4 11:39:26 2018

@author: gaytan_sa
"""
from shutil import copyfile
import numpy as np
from shutil import copyfile
import numpy as np
from utils import change_coords as cc
from utils_grid import *
from utils_shp  import *
from getosm import *
from osgeo import gdal

#roadfile = "roads.shp"
#gridFile = "grid.tif"
#roadfilefilter = "road_filter.shp"
#filter_value = ['trunk', 'primary']
#bufferDist=300;
#cellsize=30
#filter_area = '1892743.319 4673772.591, 1947567.929 4678517.028, 1949017.618 4632522.343, 1887471.722 4632654.133'

def create_road_map(roadfile,gridFile,filter_value,filter_area,bufferDist,cellsize):
    
    roadfilecliped = roadfile[0:-4] + '_clip.shp'
    roadfilefilter = roadfile[0:-4] + '_filter.shp'
    roadfilebuffer = roadfile[0:-4] + '_buffer.shp'
    maskfile       = 'mask.tif'
    #maskfile       = roadfile[0:-4] + '_mask.tif'
    createClipedShapefile(filter_area,roadfile,roadfilecliped)
    createFilteredShapefile(filter_value,filter_area,roadfilecliped,roadfilefilter)
    createBuffer(roadfilefilter, roadfilebuffer, bufferDist)
    creategrid(roadfilebuffer,gridFile,cellsize)
    gdal.Warp(gridFile,gridFile,dstSRS='EPSG:32631')
    createmask(roadfilebuffer,maskfile, gridFile)
    return maskfile