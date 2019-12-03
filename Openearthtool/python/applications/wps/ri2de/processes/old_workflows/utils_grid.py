# -*- coding: utf-8 -*-
"""
Created on Thu Sep 20 15:29:56 2018

@author: gaytan_sa
"""


from scipy.interpolate import griddata
import numpy as np 
from shapely.geometry import LineString, Point
from osgeo import gdal,gdalconst
from osgeo import osr
from shutil import copyfile

def getdis(xgrid, ygrid,  x, y):
    
    #xgrid, ygrid = np.mgrid[0:1:100j, 0:1:200j]
    #x = xgrid.reshape(xgrid.size,1)
    #y = ygrid.reshape(ygrid.size,1)
    #x = np.random.rand(1000, 1)
    #y = np.random.rand(1000, 1)
#    x = x.reshape(x.shape[0],1)
#    y = y.reshape(y.shape[0],1)
    x = x.reshape(x.size,1)
    y = y.reshape(y.size,1)
    x = x[np.logical_not(np.isnan(x))]
    y = y[np.logical_not(np.isnan(y))]
    
    #x,y = getdens(x,y,30)
    x = x.reshape(x.shape[0],1)
    y = y.reshape(y.shape[0],1)

    points = np.concatenate((x, y), axis=1)
    values = np.arange(points.shape[0])
    
    # Find index of the nearest point
    inear = griddata(points, values, (xgrid, ygrid), method='nearest')

    
    # Nearest point to the grid
    xi = np.asarray(points[inear,0])
    yi = np.asarray(points[inear,1])
    
    # Compute the distance 
    d = dist(xgrid, ygrid, xi, yi)
    #d.reshape(xgrid.shape)
    return d

def getclass(zgrid,interval):
    interval = np.asarray (interval)
    #([.1,.2,.3,.4,.5,.6,.7,.8,.9]) 
    z = np.empty(zgrid.shape)
    #z = zgrid
#    z[:] = -9999
    #plt.pcolor(xgrid, ygrid, zgrid, cmap='RdBu')
    for j in range(interval.size):
        k = j
        if (j==0):
            i = (zgrid<=interval[j])
            z[i] = k;
        elif (j==interval.size-1):
             i = (zgrid>interval[j])
             z[i] = k;
        else:
             i = (zgrid > interval[j-1]) & (zgrid <= interval[j])
             z[i] = k;
        #plt.pcolor(xgrid, ygrid, z, cmap='RdBu')
    return z
    
# Distance function
def dist(x,y,xi,yi):
    return np.sqrt(np.power((x-xi), 2) + np.power((y-yi), 2))

def getgrid(x, y):
    #Distance in meeters
    dxy = 30 
    x = np.asarray(x)
    y = np.asarray(y)
    x = x.reshape(x.shape[0],1)
    y = y.reshape(y.shape[0],1)
    
    xmin = round(x.min(),0)
    xmax = round(x.max(),0)
    ymin = round(y.min(),0)
    ymax = round(y.max(),0)
    
    y = np.arange(ymin,ymax,dxy)
    x = np.arange(xmin,xmax,dxy)
    xgrid, ygrid = np.meshgrid(x, y)
    
    return xgrid, ygrid
def getmask(rasterFile):
    
    xgrid,ygrid,mask = getRaster(rasterFile)
    a = np.empty(mask.shape)
    a[:] = np.nan
    a[mask==1] = 1
    mask = a
    
def getRaster(rasterFile):  
    #Get Mask Band
    raster = gdal.Open(rasterFile)
    band = raster.GetRasterBand(1)
    zgrid = band.ReadAsArray()
    
    # Create a grid
    xsize=raster.RasterXSize 
    ysize=raster.RasterYSize 
    dx = raster.GetGeoTransform(1)[1]
    dy = raster.GetGeoTransform(1)[5]
    xmin = raster.GetGeoTransform(1)[0]
    xmax = xmin+dx*xsize
    ymax = raster.GetGeoTransform(1)[3]
    ymin = ymax+dy*ysize  
    y = np.arange(ymax,ymin,dy)
    x = np.arange(xmin,xmax,dx)
    xgrid, ygrid = np.meshgrid(x, y)
    
    return xgrid, ygrid, zgrid

def getdens(x,y,distance):
    x = x.reshape(x.shape[0],1)
    y = y.reshape(y.shape[0],1)
    points = np.concatenate((x, y), axis=1)
    line = LineString(points)
    
    count = distance;
    newline = []
    
    startpoint = [line.xy[0][0], line.xy[1][0]]
    endpoint = [line.xy[0][-1], line.xy[1][-1]]
    newline.append(startpoint)
    
    while count < line.length:
          point = line.interpolate(count)
          newline.append([point.x , point.y])
          count = count+distance
          newline.append(endpoint)
          #print count

    newline = np.asarray(newline)
    x = newline[:,0]
    y = newline[:,1]
    return x,y

def GetInfoFromSourceRaster(RasterFile):
    
    SourceRaster = gdal.Open(RasterFile)
    GeoTrans = SourceRaster.GetGeoTransform()
    
    projection = osr.SpatialReference()
    projection.ImportFromWkt(SourceRaster.GetProjectionRef())  
    xsize=SourceRaster.RasterXSize 
    ysize=SourceRaster.RasterYSize 
    return GeoTrans, projection,xsize,ysize    
def RasterToclass(rasterFile,interval):
    
    #open dataset
    raster = gdal.Open(rasterFile, gdal.GA_Update)
    
    #Get Raster Band
    band = raster.GetRasterBand(1)
    
    #store the cell values in an Array
    array = band.ReadAsArray()
    
    # classified array
    array = getclass(array,interval)
    band.WriteArray(array)
    
def changeEPSG(RasterFile,dstSRS):
    #dstSRS='EPSG:32631';
    RasterFile = RasterFile
    SourceRaster = gdal.Open(RasterFile)
    gdal.Warp(RasterFile,SourceRaster,dstSRS)
    return RasterFile

def raster2rastergrid(rasterfile,rasterfilenew,gridfile):
    
    xi,yi,zi = getRaster(gridfile)
    x, y, z =  getRaster(rasterfile)
    x = x[1:,:]
    y = y[1:,:]

    x = x.reshape(x.size,1)
    y = y.reshape(y.size,1)
    z = z.reshape(z.size,1)
    x = x.reshape(x.shape[0],1)
    y = y.reshape(y.shape[0],1)
    z = z.reshape(z.shape[0],1)
    
    points = np.concatenate((x, y), axis=1)
  
    
    # Find index of the nearest point
    zi = griddata(points, z, (xi, yi), method='linear')
    
    # copy file grid
    copyfile(gridfile, rasterfilenew)
    
    #open dataset
    raster = gdal.Open(rasterfile, gdal.GA_Update)
    
    #Get Raster Band
    band = raster.GetRasterBand(1)
    
    #store the cell values in an Array
    array = band.ReadAsArray()
    
    # New array
    array = zi[:,:,0]
    band.WriteArray(array)
    return rasterfilenew




def TransformEPSG(RasterFile,TargetRaster,SRS):
    SourceRaster = gdal.Open(RasterFile)
       
 
    gdal.Warp(TargetRaster,SourceRaster,dstSRS=SRS)
    
    return TargetRaster


def get_raster_extend(raster,dstSRS):
    #1. Open the grid
    data = gdal.Open(raster)
    
    TargetRaster="TargetRaster.tif"
    
    new_crs_grid=TransformEPSG(raster,TargetRaster,dstSRS)
    
    new_crs_data=gdal.Open(new_crs_grid)
    #print type(new_crs_data)
    geoTransform =new_crs_data.GetGeoTransform()
    #print geoTransform
    #2. Get the extend 

    minx = geoTransform[0]
    maxy = geoTransform[3]
    maxx = minx + geoTransform[1] * data.RasterXSize
    miny = maxy + geoTransform[5] * data.RasterYSize
    #print [minx, miny, maxx, maxy]
    return minx, miny, maxx, maxy   

def reprojectRaster(src_filename,match_filename,dst_filename):
    
    src = gdal.Open(src_filename, gdalconst.GA_ReadOnly)
    src_proj = src.GetProjection()
    src_geotrans = src.GetGeoTransform()


    match_ds = gdal.Open(match_filename, gdalconst.GA_ReadOnly)
    match_proj = match_ds.GetProjection()
    match_geotrans = match_ds.GetGeoTransform()
    
    wide = match_ds.RasterXSize
    high = match_ds.RasterYSize


    
    dst = gdal.GetDriverByName('GTiff').Create(dst_filename, wide, high, 1, gdalconst.GDT_Byte)
    dst.SetGeoTransform( match_geotrans )
    dst.SetProjection( match_proj)
    dst.GetRasterBand(1).SetNoDataValue(0)
    

    # Do the work
    gdal.ReprojectImage(src, dst, src_proj, match_proj, gdalconst.GRA_Bilinear)

    del dst 
    return (gdal.Open(dst_filename,gdalconst.GA_ReadOnly))

def WriteArrayToGrid(RasterGrid, RasterName, array):
    
    SourceRaster = gdal.Open(RasterGrid)
    GeoTrans = SourceRaster.GetGeoTransform()
    
    projection = osr.SpatialReference()
    projection.ImportFromWkt(SourceRaster.GetProjectionRef())  
    xsize=SourceRaster.RasterXSize 
    ysize=SourceRaster.RasterYSize 
    
    DataType = gdal.GDT_Float32
    
    driver = gdal.GetDriverByName('GTiff')
    Raster = driver.Create(RasterName , xsize, ysize, 1, DataType )
    
    Raster.SetGeoTransform(GeoTrans)
    Raster.SetProjection( projection.ExportToWkt() )
    band = Raster.GetRasterBand(1)
    
    band.WriteArray( array )
    band.SetNoDataValue(-9999)
    
    return RasterName