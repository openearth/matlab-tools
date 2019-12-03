# -*- coding: utf-8 -*-
"""
Created on Tue Aug 12 16:07:41 2014

@author: tollena
"""

import math
from subprocess import call
import copy
import pcraster as pcr
import sys
try:
    from osgeo import ogr
except ImportError:
    import ogr
try:
    from osgeo import gdal
    from osgeo.gdalconst import *
except ImportError:
    import gdal
    from gdalconst import *
import os
import osr
import numpy as np

srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)
Driver = ogr.GetDriverByName("ESRI Shapefile")

def get_extent(ds):
    ''' Return list of corner coordinates from a dataset'''
    gt = ds.GetGeoTransform()
    # 'top left x', 'w-e pixel resolution', '0', 'top left y', '0', 'n-s pixel resolution (negative value)'
    nx, ny = ds.RasterXSize, ds.RasterYSize
    xmin = np.float64(gt[0])
    ymin = np.float64(gt[3]) +np.float64(ny) * np.float64(gt[5])
    xmax = np.float64(gt[0]) + np.float64(nx) * np.float64(gt[1])
    ymax = np.float64(gt[3])
    return (xmin, ymin, xmax, ymax)
    
def round_extent(extent, snap):
    '''Increases the extent until all sides lie on a coordinate divide able by 'snap'.'''
    xmin, ymin, xmax, ymax = extent
    snap = float(snap) # prevent integer division issues
    xmin = round(math.floor(xmin / snap) * snap,5)
    ymin = round(math.floor(ymin / snap) * snap,5)
    xmax = round(math.ceil(xmax / snap) * snap,5)
    ymax = round(math.ceil(ymax / snap) * snap,5)
    return (xmin, ymin, xmax, ymax)

def DeleteShapes(shapes):
    shapelist = list(shapes)
    for shape in shapelist:
        if os.path.exists(shape):
            Driver.DeleteDataSource(shape) 
            print "shapefile deleted: " + shape

def MergeShapes(shapesin, Layer):
    for SHP in shapesin:
        if os.path.exists(SHP):
            ATT = os.path.splitext(os.path.basename(SHP))[0]
            DATA = ogr.Open(SHP)
            LYR = DATA.GetLayerByName(ATT)
            LYR.ResetReading()
            for idx, i in enumerate(range(LYR.GetFeatureCount())):
                oldfeature = LYR.GetFeature(i)
                geometry = oldfeature.geometry()
                feature = ogr.Feature(Layer.GetLayerDefn())
                feature.SetGeometry(geometry)
                feature.SetField("ID",oldfeature.GetFieldAsString(0))
                Layer.CreateFeature(feature)
            DATA.Destroy()

def Reach2Nodes(SHP,EPSG,toll):
    if not EPSG == None:
        srs.ImportFromEPSG(int(EPSG))
    SHP_ATT = os.path.splitext(os.path.basename(SHP))[0]
    END_SHP = SHP_ATT + "_end.shp"
    START_SHP = SHP_ATT + "_start.shp"
    CONN_SHP = SHP_ATT + "_connection.shp"
    
    DeleteShapes([END_SHP,START_SHP,CONN_SHP])
    
    fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
    fieldDef.SetWidth(12)
    
    END_out = Driver.CreateDataSource(END_SHP)
    END_ATT = os.path.splitext(os.path.basename(END_SHP))[0]
    if not EPSG == None:
        END_LYR  = END_out.CreateLayer(END_ATT, srs, geom_type=ogr.wkbPoint)
    else: END_LYR  = END_out.CreateLayer(END_ATT, geom_type=ogr.wkbPoint)
    END_LYR.CreateField(fieldDef)
    
    START_out = Driver.CreateDataSource(START_SHP)
    START_ATT = os.path.splitext(os.path.basename(START_SHP))[0]
    if not EPSG == None:
        START_LYR  = START_out.CreateLayer(START_ATT, srs, geom_type=ogr.wkbPoint)
    else: START_LYR  = START_out.CreateLayer(START_ATT, geom_type=ogr.wkbPoint)
    START_LYR.CreateField(fieldDef)
    
    CONN_out = Driver.CreateDataSource(CONN_SHP)
    CONN_ATT = os.path.splitext(os.path.basename(CONN_SHP))[0]
    if not EPSG == None:
        CONN_LYR  = CONN_out.CreateLayer(CONN_ATT, srs, geom_type=ogr.wkbPoint)
    else: CONN_LYR  = CONN_out.CreateLayer(CONN_ATT, geom_type=ogr.wkbPoint)
    CONN_LYR.CreateField(fieldDef)
    
    StartCoord = []
    EndCoord = []
    
    ATT = os.path.splitext(os.path.basename(SHP))[0]
    DATA = ogr.Open(SHP)
    LYR = DATA.GetLayerByName(ATT)
    LYR.ResetReading()
    for i in range(LYR.GetFeatureCount()):
        feature = LYR.GetFeature(i)
        geometry = feature.geometry()
        StartCoord.append([geometry.GetX(0),geometry.GetY(0)])
        points = geometry.GetPointCount()
        EndCoord.append([geometry.GetX(points-1),geometry.GetY(points-1)])
        
    DATA.Destroy()
        
    Connections = [[np.nan,np.nan],[np.nan,np.nan]]
    
    for i in range(len(StartCoord)):
        if not True in np.all(np.isclose(StartCoord[i],EndCoord,rtol=0,atol=toll),axis=1):
            #point is startpoint
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(StartCoord[i][0],StartCoord[i][1])
            feature = ogr.Feature(START_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            START_LYR.CreateFeature(feature)
        else:
            #point is a connection
            if not True in np.all(np.isclose(StartCoord[i],Connections,rtol=0,atol=toll),axis=1):
                Connections.append(StartCoord[i])
                point = ogr.Geometry(ogr.wkbPoint)
                point.AddPoint(StartCoord[i][0],StartCoord[i][1])
                feature = ogr.Feature(CONN_LYR.GetLayerDefn())
                feature.SetGeometry(point)
                CONN_LYR.CreateFeature(feature)
        if not True in np.all(np.isclose(EndCoord[i],StartCoord,rtol=0,atol=toll),axis=1):
            #point is end
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(EndCoord[i][0],EndCoord[i][1])
            feature = ogr.Feature(END_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            END_LYR.CreateFeature(feature)
        else:
            #point is a connection
            if not True in np.all(np.isclose(EndCoord[i],Connections,rtol=0,atol=toll),axis=1):
                Connections.append(EndCoord[i])
                point = ogr.Geometry(ogr.wkbPoint)
                point.AddPoint(EndCoord[i][0],EndCoord[i][1])
                feature = ogr.Feature(CONN_LYR.GetLayerDefn())
                feature.SetGeometry(point)
                CONN_LYR.CreateFeature(feature)
    
    END_out.Destroy()
    START_out.Destroy()
    CONN_out.Destroy()
    return START_SHP, END_SHP, CONN_SHP    

def ReachOrder(SHP,EPSG,toll):
    if not EPSG == None:
        srs.ImportFromEPSG(int(EPSG))
    SHP_ATT = os.path.splitext(os.path.basename(SHP))[0]
    ORDER_SHP = SHP_ATT + "_order1.shp"
    FileOrder = []
    FileOrder.append(ORDER_SHP)
    
    if os.path.exists(ORDER_SHP):
        Driver.DeleteDataSource(ORDER_SHP)
    
    IDField = ogr.FieldDefn("ID", ogr.OFTString)
    IDField.SetWidth(12)
    
    OrderField = ogr.FieldDefn("ORDER", ogr.OFTString)
    OrderField.SetWidth(12)
     
    StartCoord = []
    EndCoord = []
    
    ATT = os.path.splitext(os.path.basename(SHP))[0]
    DATA = ogr.Open(SHP)
    LYR = DATA.GetLayerByName(ATT)
    LYR.ResetReading()
    for i in range(LYR.GetFeatureCount()):
        feature = LYR.GetFeature(i)
        geometry = feature.geometry()
        StartCoord.append([geometry.GetX(0),geometry.GetY(0)])
        points = geometry.GetPointCount()
        EndCoord.append([geometry.GetX(points-1),geometry.GetY(points-1)])  
    EndCoord_np = np.array(EndCoord)
    reaches = copy.deepcopy(i)+1
    ReachIDs = range(reaches)
    ReachOrders = np.array([None] * len(ReachIDs))
    
    order = 1
    ordercoord = copy.deepcopy(EndCoord)
    tempcoord = []
    endpoints = 0   
    for i in ReachIDs:
        ReachStart = StartCoord[i]
        ReachEnd = EndCoord[i] 
        if not True in np.all(np.isclose(ReachStart,ordercoord,rtol=0,atol=toll), axis=1):
            ReachOrders[i] = order
            tempcoord.append(ReachEnd)
        if not True in np.all(np.isclose(ReachEnd,StartCoord,rtol=0,atol=toll),axis=1):
           endpoints += 1         
    ordercoord = copy.deepcopy(tempcoord)
    order += 1
    iterations = 0
    
    while None in list(ReachOrders) and iterations <= 100:
        iterations += 1
        OrderMove = False
        for i in ReachIDs:
            if ReachOrders[i] == None:
                ReachStart = StartCoord[i]
                ReachEnd = EndCoord[i]
                OrderSelect = ReachOrders[np.all(np.isclose(ReachStart,EndCoord_np,rtol=0,atol=toll), axis=1)]
                if not None in list(OrderSelect):
                    if all(x == list(OrderSelect)[0] for x in list(OrderSelect)) == True:
                        OrderMove = True
                        ReachOrders[i] = order
                    else:
                        ReachOrders[i] = int(np.max(OrderSelect))
        if OrderMove:
            order += 1
    
    if None in list(ReachOrders):
        print "Conversion of river to orders failed. Try to use a smaller tollerance"
        #sys.exit(1)
    
    LYR.ResetReading()
    
    for i in range(1,max(ReachOrders)+1):
        order = i
        ORDER_SHP = SHP_ATT + "_order" + str(order)+".shp"
        FileOrder.append(ORDER_SHP)
        if os.path.exists(ORDER_SHP):
            Driver.DeleteDataSource(ORDER_SHP)
        ORDER_out = Driver.CreateDataSource(ORDER_SHP)
        ORDER_ATT = os.path.splitext(os.path.basename(ORDER_SHP))[0]
        if not EPSG == None:
            ORDER_LYR  = ORDER_out.CreateLayer(ORDER_ATT, srs, geom_type=ogr.wkbLineString)
        else: ORDER_LYR  = ORDER_out.CreateLayer(ORDER_ATT, geom_type=ogr.wkbLineString)
        ORDER_LYR.CreateField(IDField)
        ORDER_LYR.CreateField(OrderField)
        for j in range(LYR.GetFeatureCount()):
            if ReachOrders[j] == order:
                orgfeature = LYR.GetFeature(j)
                geometry = orgfeature.geometry()
                feature = ogr.Feature(ORDER_LYR.GetLayerDefn())
                feature.SetGeometry(geometry)
                feature.SetField("ID",str(j))
                feature.SetField("ORDER",str(order))
                ORDER_LYR.CreateFeature(feature)
        ORDER_out.Destroy()
    
    DATA.Destroy()   
    return FileOrder

def Burn2Tif(shapes,attribute,TIFF):
    for shape in shapes:
        shape_att = os.path.splitext(os.path.basename(shape))[0]
        os.system("gdal_rasterize -a " + str(attribute) + " -l " + shape_att + " " + shape + " " + TIFF)

def ReverseMap(MAP):
    MAX = int(np.max(pcr.pcr2numpy(MAP,np.NAN)))
    REV_MAP = pcr.ordinal(pcr.ifthen(pcr.scalar(MAP) == pcr.scalar(-9999), pcr.scalar(0)))
    for i in range(MAX+1):
        if i > 0:
            print i        
            REV_MAP = pcr.cover(pcr.ifthen(pcr.ordinal(MAP) == pcr.ordinal(i), pcr.ordinal(pcr.scalar(MAX+1)-pcr.scalar(i))),REV_MAP)
    REV_MAP = pcr.cover(REV_MAP, pcr.ordinal(MAP))
    return REV_MAP
    
def DeleteList(itemlist):
    for item in itemlist:
        os.remove(item)
 
def Tiff2Point(TIFF):
    DS = gdal.Open(TIFF,GA_ReadOnly)
    if DS is None:
        print 'Could not open ' + fn
        sys.exit(1)
    
    cols = DS.RasterXSize
    rows = DS.RasterYSize
    geotransform = DS.GetGeoTransform()
    originX = geotransform[0]
    originY = geotransform[3]
    pixelWidth = geotransform[1]
    pixelHeight = geotransform[5]  
    
    band = DS.GetRasterBand(1)
    NoData = band.GetNoDataValue()
    
    ATT =  os.path.splitext(os.path.basename(TIFF))[0] 
    SHP = ATT + ".shp"
    
    if os.path.exists(SHP):
        Driver.DeleteDataSource(SHP) 
    
    SHP_out = Driver.CreateDataSource(SHP)
    SHP_LYR  = SHP_out.CreateLayer(ATT, geom_type=ogr.wkbPoint)
    
    fieldDef = ogr.FieldDefn("ID", ogr.OFTInteger)
    fieldDef.SetWidth(12)
    SHP_LYR.CreateField(fieldDef)
    
    fieldDef = ogr.FieldDefn("X", ogr.OFTReal)
    fieldDef.SetWidth(20)
    fieldDef.SetPrecision(5)
    SHP_LYR.CreateField(fieldDef)
    
    fieldDef = ogr.FieldDefn("Y", ogr.OFTReal)
    fieldDef.SetWidth(20)
    fieldDef.SetPrecision(5)
    SHP_LYR.CreateField(fieldDef)
    
    for x in range(cols):
        for y in range(rows):
            value = band.ReadAsArray(x, y, 1, 1)
            if not value == NoData:
                xCoord = originX + (0.5 + x)*pixelWidth
                yCoord = originY + (y+0.5)*pixelHeight
                point = ogr.Geometry(ogr.wkbPoint)
                point.AddPoint(xCoord,yCoord)
                feat_out = ogr.Feature(SHP_LYR.GetLayerDefn())
                feat_out.SetGeometry(point)
                feat_out.SetField("ID", str(int(value[0][0])))
                feat_out.SetField("X", xCoord)
                feat_out.SetField("Y", yCoord)
                SHP_LYR.CreateFeature(feat_out)           
    
    SHP_out.Destroy()
    DS = None

def GridDef(TIFF,XML):
    DS = gdal.Open(TIFF,GA_ReadOnly)
    if DS is None:
        print 'Could not open ' + fn
        sys.exit(1)
    
    cols = DS.RasterXSize
    rows = DS.RasterYSize
    geotransform = DS.GetGeoTransform()
    originX = geotransform[0]
    originY = geotransform[3]
    pixelWidth = geotransform[1]
    pixelHeight = geotransform[5]
    DS = None
    Grid_xml = open(XML, 'w+')
    Grid_xml.write('<regular locationId="GRID_NAME">\n')
    Grid_xml.write('\t<rows>'+str(rows)+'</rows>\n')
    Grid_xml.write('\t<columns>'+str(cols)+'</columns>\n')
    Grid_xml.write('\t<geoDatum>GEODATUM</geoDatum>\n')
    Grid_xml.write('\t<firstCellCenter>\n')
    Grid_xml.write('\t\t<x>'+str(originX + 0.5*pixelWidth)+'</x>\n')
    Grid_xml.write('\t\t<y>'+str(originY + 0.5*pixelHeight)+'</y>\n')
    Grid_xml.write('\t</firstCellCenter>\n')
    Grid_xml.write('\t<xCellSize>'+str(pixelWidth)+'</xCellSize>\n')
    Grid_xml.write('\t<yCellSize>'+str(pixelWidth)+'</yCellSize>\n')
    Grid_xml.write('</regular>\n')