# -*- coding: utf-8 -*-
"""
Created on Mon Oct 15 22:42:33 2018

@author: micha
"""

import gdal
from gdalconst import GA_ReadOnly
#dstSRS='EPSG:4328'
def TransformEPSG(RasterFile,dstSRS):
    SourceRaster = gdal.Open(RasterFile)
       
    TargetRaster='New_crs_raster.tif'
    gdal.Warp(TargetRaster,SourceRaster)
    
    return TargetRaster

def get_raster_extend(raster_name,dstSRS):
    
    #1. Open the grid
    data = gdal.Open(raster_name, GA_ReadOnly)
    
    
    new_crs_grid=TransformEPSG(raster_name,dstSRS)
    
    new_crs_data=gdal.Open(new_crs_grid)
    
    geoTransform =new_crs_data.GetGeoTransform()
    
    #2. Get the extend 

    minx = geoTransform[0]
    maxy = geoTransform[3]
    maxx = minx + geoTransform[1] * data.RasterXSize
    miny = maxy + geoTransform[5] * data.RasterYSize
    print [minx, miny, maxx, maxy]
    return minx, miny, maxx, maxy


