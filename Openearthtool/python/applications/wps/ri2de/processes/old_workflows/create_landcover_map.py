# -*- coding: utf-8 -*-
"""
Created on Wed Oct 10 12:01:00 2018

@author: micha
"""

from osgeo import ogr
from osgeo import gdal
from osgeo import osr
import numpy as np

def Add_Integer_Field(in_shp,Old_Field_Name="code_06",New_Field_Name="icode"):
    #1 open the shapefile in writing mode 
    driver = ogr.GetDriverByName('ESRI Shapefile')
    dataSource = driver.Open(in_shp, 1)
    layer = dataSource.GetLayer()
    
    #2 create a new field
    field=ogr.FieldDefn(New_Field_Name, ogr.OFTInteger)
    layer.CreateField(field)

    #3 set integer of the code_06 to the new field
    feature=layer.GetNextFeature()
    while feature:
        code=feature.GetField(Old_Field_Name)
        feature.SetField(New_Field_Name,int(code))
        layer.SetFeature(feature)
        feature = layer.GetNextFeature()
    dataSource.Destroy()
    return in_shp
def Rast_Polyg_with_Template_Grid(polygon_shp, template_raster, out_raster, field="icode"):
    
           
    src_ds = gdal.Open(template_raster)
    srcband = src_ds.GetRasterBand(1)
    

    # Open the data source and read in the extent
    source_ds = ogr.Open(polygon_shp)
    source_layer = source_ds.GetLayer()

    target_ds = gdal.GetDriverByName('GTiff').Create(out_raster, src_ds.RasterXSize, src_ds.RasterYSize, 1, gdal.GDT_Int32)
    target_ds.SetGeoTransform(src_ds.GetGeoTransform())
    target_ds.SetProjection(src_ds.GetProjection())
    band = target_ds.GetRasterBand(1)
    band.SetNoDataValue(-9999)

    # Rasterize
    gdal.RasterizeLayer(target_ds, [1], source_layer, options=["ATTRIBUTE={}".format(field)])
    return out_raster
def RasterToArray(raster):
  
    
    ds=gdal.Open(raster)
    band=ds.GetRasterBand(1)
    array = band.ReadAsArray()
    return(array)
    
def GetInfoFromRaster(RasterFile):
    
    SourceRaster = gdal.Open(RasterFile)
    GeoTrans = SourceRaster.GetGeoTransform()
    
    projection = osr.SpatialReference()
    projection.ImportFromWkt(SourceRaster.GetProjectionRef())  
    xsize=SourceRaster.RasterXSize 
    ysize=SourceRaster.RasterYSize 
    return GeoTrans, projection,xsize,ysize 

def WriteArrayToRaster(RasterName, Array,
                  xsize, ysize, GeoTrans, projection):
    DataType = gdal.GDT_Int32
    
    driver=gdal.GetDriverByName('GTiff')
    Raster = driver.Create(RasterName , xsize, ysize, 1, DataType )
    
    Raster.SetGeoTransform(GeoTrans)
    Raster.SetProjection( projection.ExportToWkt() )
    band = Raster.GetRasterBand(1)
    
    band.WriteArray( Array )
    band.SetNoDataValue(-9999)
    
    return RasterName

def create_landcover_map(Polygon_Shapefile,Grid_file):
    
    
    #1. Define the inputs paths
    Out_Raster1="Land_Cover_Map_with_Codes.tif"
    Out_Raster="Land_Cover_Map.tif"
    #2. Add a new field with integer values of code_06 field
    Add_Integer_Field(Polygon_Shapefile)
    
    #3. Rasterize the shapefile on a raster based on the template grid raster
    Out_Raster1=Rast_Polyg_with_Template_Grid(Polygon_Shapefile,Grid_file,Out_Raster1)
    
    #4. Insert the values of the raster in an array
    array=RasterToArray(Out_Raster1)
    
    
    Urban=[111,112,121,123,124,142,332]
    Grass=[141,211,212,221,222,223,231,242,243,311,312,313,321,322,323,324,333]
    Other=[131,132,331,411,421,422,511,512,521,522,523]
    
    #5. Create an array with 0 for urban, 1 for other, 2 for grass
    true=np.where(np.isin(array,Urban),0,array)
    true=np.where(np.isin(true,Other),1,true)
    true=np.where(np.isin(true,Grass),2,true)
    
    #6. Take the info from the raster with the code in order to write it in a new raster
    
    GeoTrans,projection,xsize,ysize=GetInfoFromRaster(Out_Raster1)
    
    #7. Write array into   Raster 
    Out_Raster=WriteArrayToRaster(Out_Raster,true,xsize,ysize,GeoTrans,projection)


