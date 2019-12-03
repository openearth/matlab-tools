# -*- coding: utf-8 -*-
"""
Created on Tue Sep 25 09:33:47 2018

@author: micha
"""


from osgeo import gdal,gdalconst
import numpy as np
import os
from osgeo import osr
from utils_wcs import *
from utils_getdata import *
from utils_grid import *

#path with the folder that the soil raster are stored

#function that open the raster and transform it to array
def GetSourceRaster(soil_name,folder):
    
    for raster in os.listdir(folder):
                
        if raster.startswith(soil_name):
            raster_file="{}\{}".format(folder,raster)
            return raster_file
    return
    
      
    
    
def RasterToArray(raster):
    
    #open dataset
    ds=gdal.Open(raster)
    #print type(ds)
    #Get Raster Band
    band=ds.GetRasterBand(1)
    #store the cell values in an Array
    array = band.ReadAsArray()
    return(array)
    
#function that calculates the mean value of a list of arrays 
def mean_val(list_array):
    #create a 3d array with all the list of arrays
    ar=np.mean( np.array(list_array), axis=0 )
    return ar
 
#function that create the mean array of each group of soil raster
#arguments folder tha are stored and first letter of the file
def  mean_array_soil(soil_name,folder):
    #list to store the arrays   
    list_arr = []
    #search in the folder for the files
    for raster in os.listdir(folder):
        
        if raster.startswith(soil_name):
            raster_file="{}\{}".format(folder,raster)
            
            array=RasterToArray(raster_file)
            
            
            #list that contains all the arrays of the soil
            list_arr.append(array)
    #call the function that calculates mean values        
    mean_array_soil=mean_val(list_arr)
    return mean_array_soil 

#def TransformEPSG(RasterFile,Name):
#    SourceRaster = gdal.Open(RasterFile)
#       
#    TargetRaster=Name+'.tif'
#    gdal.Warp(TargetRaster,SourceRaster,dstSRS='EPSG:32631')
    
#    return TargetRaster

def GetInfoFromSourceRaster(RasterFile):
    
    SourceRaster = gdal.Open(RasterFile)
    GeoTrans = SourceRaster.GetGeoTransform()
    
    projection = osr.SpatialReference()
    projection.ImportFromWkt(SourceRaster.GetProjectionRef())  
    xsize=SourceRaster.RasterXSize 
    ysize=SourceRaster.RasterYSize 
    return GeoTrans, projection,xsize,ysize    
    
def ArrayToGtiff(Name, Array,
                  xsize, ysize, GeoTrans, projection):
    DataType = gdal.GDT_Byte
    RasterName=Name+'.tif'
    driver=gdal.GetDriverByName('GTiff')
    Raster = driver.Create( RasterName, xsize, ysize, 1, DataType )
    
    Raster.SetGeoTransform(GeoTrans)
    Raster.SetProjection( projection.ExportToWkt() )
    # Write the array
    Raster.GetRasterBand(1).WriteArray( Array )
    Raster.GetRasterBand(1).SetNoDataValue(0)
    return RasterName




def create_soil_map(wrkfolder,grid_file):
    
    xst,yst,xend,yend=get_raster_extend(grid_file, "EPSG:4326")
    
    folder=getdata_soil(xst, yst, xend, yend, wrkfolder, crs=4326)
    
#Calculate the mean array for each given soil

    clay_array=mean_array_soil("CLYPPT_M",folder)
    silt_array=mean_array_soil("SLTPPT_M",folder)
    sand_array=mean_array_soil("SNDPPT_M",folder)

#create an array with only the max values        
    truth = np.maximum(np.maximum(clay_array, silt_array), sand_array)

#create an array with 1 for sand, 2 for silt, 3 clay
    true = np.where(truth == clay_array, 3, truth)
    true = np.where(truth == silt_array, 2, true)
    true = np.where(truth == sand_array, 1, true)
    true = np.where(truth == 255,0,true)

#write the raster
#1st: trasform the original to EPSG:32631
    #SourceRaster=TransformEPSG("CLYPPT_M_sl1_250m.tif")
    SourceRaster=GetSourceRaster("CLYPPT_M",folder)
    GeoTrans,projection,xsize,ysize=GetInfoFromSourceRaster(SourceRaster)
    
    RasterName=ArrayToGtiff("Soil_Map1",true,xsize,ysize,GeoTrans,projection)
    Soil_Map_tif=TransformEPSG(RasterName,"Soil_Map2")
    
        
    reprojectRaster("Soil_Map2.tif",grid_file,"Soil_Map.tif")
    return 
    
  

    
   






