# -*- coding: utf-8 -*-
"""
Created on Thu Apr 11 08:06:37 2019

@author: wcp_W1903446
"""

from os import makedirs
from os.path import basename, join
import zipfile
import os
import subprocess
import glob
from osgeo import ogr, osr, gdal
import numpy as np

# Write array to grid file
def writeArrayGrid(RasterGrid, RasterName, array, nodataval=-9999):
    SourceRaster = gdal.Open(RasterGrid)
    GeoTrans = SourceRaster.GetGeoTransform()    
    projection = osr.SpatialReference()
    projection.ImportFromWkt(SourceRaster.GetProjectionRef())   
    xsize=SourceRaster.RasterXSize 
    ysize=SourceRaster.RasterYSize  
    driver = gdal.GetDriverByName('GTiff')
    Raster = driver.Create(RasterName , xsize, ysize, 1, gdal.GDT_Float32, ['TILED=YES', 'COMPRESS=LZW'])    
    Raster.SetGeoTransform(GeoTrans)
    Raster.SetProjection(projection.ExportToWkt())  
    band = Raster.GetRasterBand(1)    
    band.WriteArray(array)
    band.SetNoDataValue(nodataval)  
    return RasterName

# Classify array [1,2,3] - upwards
def classifyArray123(arr, interval):
    interval = np.asarray(interval)
    z = np.empty(arr.shape) # init as zeroes
    z[(arr > interval[0])] = 1
    z[(arr > interval[1])] = 2
    z[(arr > interval[2])] = 3
    return z

# Classify array [1,2,3] - downwards
def classifyArray32(arr, interval):
    interval = np.asarray(interval)
    z = np.empty(arr.shape) # init as zeroes
    z[(arr >= interval[1])] = 1
    z[(arr < interval[1])] = 2
    z[(arr < interval[0])] = 3
    return z

# Classify array [1,2,3] - only one threshold
def classifyArrayThr(arr, thr):
    z = np.empty(arr.shape) # init as zeroes        
    z[(arr <= thr)] = 2
    z[(arr > thr)] = 3        
    return z

# Rasterize geometry from PostGIS --- Does not work unfortunately
def pgToRaster(objectid, user, host, passw, db, layer, tmpRast, res=0.5):
    sqlStr = '''select * from {l} where objectid = {o}'''.format(l=layer, o=objectid)
    cmd = '''gdal_rasterize -sql {sql} -burn 1 -a_nodata 0.0 -tr {res} {res} -of GTiff -co COMPRESS=LZW -co TILED=YES PG:\"host={h} dbname={d} user={u} password={p}\" \"{o}\"'''.format(
        res=res, h=host, u=user, p='&Ez3)r5{Gc', d='hobbelkaart', o=tmpRast, sql=sqlStr)
    os.system(cmd)

# Rasterize geometry
def rasterizeGeomMemory(dsRaster, dsShp, res=0.5):
    ds = gdal.Warp('', dsRaster, format='MEM', dstNodata=0, cutlineDSName=dsShp, cropToCutline=True)
    arr = ds.GetRasterBand(1).ReadAsArray()
    return arr

# Rasterize geometry [slow mode]
def rasterizeGeom(rasterin, rasterout, shape):
    cmd = 'gdalwarp -q --config GDAL_CACHEMAX 6000 -dstnodata {nan} -of GTiff -cutline \"{s}\" -crop_to_cutline -overwrite \"{ri}\" \"{ro}\"'.format(s=shape, ri=rasterin, ro=rasterout, nan=np.nan)
    os.system(cmd)
    dsout = gdal.Open(rasterout)
    arr = dsout.GetRasterBand(1).ReadAsArray()
    dsout = None
    return arr

# Generate shapefile [road stukje]
def roadStukjeShp(srs, shpdriver, defn, id_stukje, geom_stukje, geom_stukje_buf, roads_table_idfield, tmpFeaturePath, tmpFeaturePathBuff):
    # Make a feature
    idval = float(id_stukje)
    feat = ogr.Feature(defn)
    feat.SetField(roads_table_idfield, idval)       
    featBuf = ogr.Feature(defn)
    featBuf.SetField(roads_table_idfield, idval)

    # Make a geometry [roads and buffer]
    geom = ogr.CreateGeometryFromWkt(geom_stukje)     
    feat.SetGeometry(geom)
    geomBuf = ogr.CreateGeometryFromWkt(geom_stukje_buf)  
    featBuf.SetGeometry(geomBuf)    

    # Prepare temporary shapefile [roadsfeatBuf]       
    dsTmp = shpdriver.CreateDataSource(tmpFeaturePath)
    layerTmp = dsTmp.CreateLayer('', srs, ogr.wkbPolygon)       
    layerTmp.CreateFeature(feat)
    dsTmp = None
    
    # Prepare temporary shapefile [roads-buffer]        
    dsTmpBuf = shpdriver.CreateDataSource(tmpFeaturePathBuff)
    layerTmpBuf = dsTmpBuf.CreateLayer('', srs, ogr.wkbPolygon)     
    layerTmpBuf.CreateFeature(featBuf)
    dsTmpBuf = None

# Stukje magic
def stukje_magic(tmpFeaturePath, tmpFeaturePathBuff, ahnRast, taludRast, tmpRast, tmpRastBuf, write_shp=False):

    # Cut by feature [get road pixels height]
    arr = rasterizeGeom(ahnRast, tmpRast, tmpFeaturePath)
    roadHeight = np.nanmean(arr)
    if np.isnan(roadHeight): return None, None, None, None # skip irrelevant piece
    if write_shp:
        feat.SetField('roadHeight', float(roadHeight))
    
    # Cut by buffer [get nearby taluds and nearby elevation]
    arrTaludBuff = rasterizeGeom(taludRast, tmpRastBuf, tmpFeaturePathBuff)
    taludInd = np.where(arrTaludBuff > 1) # danger classes = 2,3
    totalInd = np.where(arrTaludBuff >= 1) # all data pixels        
    arrTaludAhn = rasterizeGeom(ahnRast, tmpRastBuf, tmpFeaturePathBuff)
    if len(totalInd[0]) == 0: return None, None, None, None # skip empty pieces

    # If more than 50% pixels are talud
    percTalud = 100.0 * float(len(taludInd[0])) / float(len(totalInd[0])) 
    taludHigh = None
    taludLow = None               
    if len(taludInd[0]):
        taludHigh = float(np.max(arrTaludAhn[taludInd])) - roadHeight
        taludLow = float(np.min(arrTaludAhn[taludInd])) - roadHeight    
        if write_shp:   
            feat.SetField('taludHigh', taludHigh) 
            feat.SetField('taludLow', taludLow)
            feat.SetField('percTalud', float(percTalud))

    return roadHeight, percTalud, taludHigh, taludLow