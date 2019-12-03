# -*- coding: utf-8 -*-
"""
Created on Tue Sep 11 15:53:29 2018

@authors: gaytan_sa, aboufira
"""

import shapefile
import sys
from scipy.interpolate import interpolate
from scipy.interpolate import griddata
import numpy as np
from utils import change_coords as cc
import geopandas
from osgeo import ogr
from osgeo import gdal
from osgeo import ogr

def getlayer(shpfile, layername):
    shape = shapefile.Reader(shpfile)

    # first feature of the shapefile
    feature = shape.shapeRecords()[0]
    first = feature.shape.__geo_interface__
    feature.record
    feature.record[2]

    if feature.record[2] == layername:
        print(layername)

    print(first)  # (GeoJSON format)

    records = shape.shapeRecords()

    x = []
    y = []
    points = [];
    for i in range(len(records)):
        feature = shape.shapeRecords()[i]
        xyl = feature.shape.points
        xy = np.asarray(xyl)
        for j in range(len(xy)):
            x.append(xy[j][0])
            y.append(xy[j][1])
            points.append(xy[j])
    x = np.asarray(x)
    y = np.asarray(y)
    points = np.asarray(points)
    return x, y, points

def getlayer2(shpfile, layername):
    
    inDriver = ogr.GetDriverByName("ESRI Shapefile")
    inDataSource = inDriver.Open(shpfile, 0)
    inLayer = inDataSource.GetLayer()
        
    #Filter layer
    inLayer.SetAttributeFilter("fclass IN {}".format(tuple(layername)))
    print inLayer.GetFeatureCount()
    for i in range(0,inLayer.GetFeatureCount()):
       f = inLayer.GetFeature(i)
       g = f.GetGeometryRef()
       val =np.asarray(g.GetPoints())
       if i==0:
          values  = val
       elif i>0:
          values =  np.concatenate((values, val))
          
    y = values[:,1]
    x = values[:,0]
    return x, y


#def getdataosm(extent,infratype):
 #   import overpass

    #TODO implement extent and a list of infrastrutures necessary (i.e. main road = {high way, motorway, etc})

 #   overpass_query = """
 #   way[highway={highwaytag}]({bbox});
 ##   out;
 #   """.format(highwaytag=infratype,bbox=extent)
 #   api = overpass.API()
 #   data = api.get(overpass_query, verbosity='geom')
 #   gdf = geopandas.GeoDataFrame.from_features(data['features'])

 #   gdf = gdf.loc[gdf['geometry'].notnull()]
 #   return gdf


#extent = (2128766, 4840344,2317723,5243489) # input for cc
#osmextent = (cc(extent[0],extent[1],'epsg:3857', 'epsg:4326'),cc(extent[2],extent[3],'epsg:3857', 'epsg:4326'))
#print(osmextent)
#data = getdataosm(','.join([str(osmextent[0][1]),str(osmextent[0][0]),str(osmextent[1][1]),str(osmextent[1][0])]),'primary')
#data.to_file(driver='GeoJSON', filename = 'from_osm.geojson',encoding = 'utf-8')