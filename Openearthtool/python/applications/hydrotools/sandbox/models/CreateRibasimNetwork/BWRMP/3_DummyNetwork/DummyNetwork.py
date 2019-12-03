# -*- coding: utf-8 -*-
"""
Created on Fri Jul 11 16:44:00 2014

@author: tollena
"""

import pcraster as pcr
import os
import numpy as np
import shutil
import copy
import string

try:
    from osgeo import ogr
except ImportError:
    import ogr

import osr
    
basin = "SUMBAWA"

TYPE = ["Flow - Channel","Diversion"]
minarea = 5000000
LD = [0.3,0.1,0.1,0.1,0.3]
Length = 0.02
DummyLine = 0.001
PWS_SHP = "PWS.shp"
DIV_SHP = "Diversions.shp"
IRR_SHP = "Irrigation.shp"
WADI_SHP = "11_WATERDISTRICT_" + basin + ".shp"
NETWNEW_SHP = "Network_dummy.shp"

SHPDriver = ogr.GetDriverByName("ESRI Shapefile")

# create the spatial reference, WGS84
srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)

if os.path.exists(NETWNEW_SHP):
    SHPDriver.DeleteDataSource(NETWNEW_SHP)
if os.path.exists(PWS_SHP):
    SHPDriver.DeleteDataSource(PWS_SHP)
if os.path.exists(DIV_SHP):
    SHPDriver.DeleteDataSource(DIV_SHP)
if os.path.exists(IRR_SHP):
    SHPDriver.DeleteDataSource(IRR_SHP)

WADI_ATT = os.path.splitext(os.path.basename(WADI_SHP))[0]
WADI_IN = ogr.Open(WADI_SHP)
WADI_LYR = WADI_IN.GetLayerByName(WADI_ATT)
WADI_LYR.ResetReading()

#Create New Network Layer
NETWNEW_out = SHPDriver.CreateDataSource(NETWNEW_SHP)
NETWNEW_ATT = os.path.splitext(os.path.basename(NETWNEW_SHP))[0]
NETWNEW_LYR  = NETWNEW_out.CreateLayer(NETWNEW_ATT, srs, geom_type=ogr.wkbLineString)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
NETWNEW_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("ID_FROM", ogr.OFTString)
fieldDef.SetWidth(12)
NETWNEW_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("ID_TO", ogr.OFTString)
fieldDef.SetWidth(12)
NETWNEW_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("NAME_FROM", ogr.OFTString)
fieldDef.SetWidth(25)
NETWNEW_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("NAME_TO", ogr.OFTString)
fieldDef.SetWidth(25)
NETWNEW_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("TYPE", ogr.OFTString)
fieldDef.SetWidth(12)
NETWNEW_LYR.CreateField(fieldDef)

#Create PWS layer
PWS_out = SHPDriver.CreateDataSource(PWS_SHP)
PWS_ATT = os.path.splitext(os.path.basename(PWS_SHP))[0]
PWS_LYR  = PWS_out.CreateLayer(PWS_ATT, srs, geom_type=ogr.wkbPoint)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
PWS_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("NAME", ogr.OFTString)
fieldDef.SetWidth(12)
PWS_LYR.CreateField(fieldDef)

#Create Irrigation layer
IRR_out = SHPDriver.CreateDataSource(IRR_SHP)
IRR_ATT = os.path.splitext(os.path.basename(IRR_SHP))[0]
IRR_LYR  = IRR_out.CreateLayer(IRR_ATT, srs, geom_type=ogr.wkbPoint)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
IRR_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("NAME", ogr.OFTString)
fieldDef.SetWidth(12)
IRR_LYR.CreateField(fieldDef)

#Create DIV layer
DIV_out = SHPDriver.CreateDataSource(DIV_SHP)
DIV_ATT = os.path.splitext(os.path.basename(DIV_SHP))[0]
DIV_LYR  = DIV_out.CreateLayer(DIV_ATT, srs, geom_type=ogr.wkbPoint)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
DIV_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("NAME", ogr.OFTString)
fieldDef.SetWidth(12)
DIV_LYR.CreateField(fieldDef)

def addline(Layer, X1, X2, Y1, Y2, ID, ID_FROM, ID_TO, NAME_FROM, NAME_TO, Type):
    line = ogr.Geometry(ogr.wkbLineString)
    line.AddPoint(X1,Y1)
    line.AddPoint(X2,Y2)
    feature = ogr.Feature(Layer.GetLayerDefn())
    feature.SetGeometry(line)
    feature.SetField("ID", str(ID))
    feature.SetField("ID_FROM", str(ID_FROM))
    feature.SetField("ID_TO", str(ID_TO))
    feature.SetField("NAME_FROM", str(NAME_FROM))
    feature.SetField("NAME_TO", str(NAME_TO))
    feature.SetField("TYPE", Type)
    Layer.CreateFeature(feature)     
    return Layer, X1, X2, Y1, Y2, ID, ID_FROM, ID_TO, Type, line, feature

def Xoffleft(DummyLine, Xorg, Xstart, Xend, Ystart, Yend):
        FeatLen = np.power(np.power(Xend-Xstart,2) + np.power(Yend-Ystart,2),0.5)
        SF = DummyLine/FeatLen                            
        DX = np.abs(Yend-Ystart)*SF
        XNEW = Xorg+DX
        if not Yend-Ystart == 0:
            if (Xend-Xstart)/(Yend-Ystart) > 0:
                XNEW = Xorg-DX
        return XNEW
        
def Xoffright(DummyLine, Xorg, Xstart, Xend, Ystart, Yend):
        FeatLen = np.power(np.power(Xend-Xstart,2) + np.power(Yend-Ystart,2),0.5)
        SF = DummyLine/FeatLen                            
        DX = np.abs(Yend-Ystart)*SF
        XNEW = Xorg-DX
        if not Yend-Ystart == 0:
            if (Xend-Xstart)/(Yend-Ystart) > 0:
                XNEW = Xorg+DX
        return XNEW
        
def Yoffleft(DummyLine, Yorg, Xstart, Xend, Ystart, Yend):
        FeatLen = np.power(np.power(Xend-Xstart,2) + np.power(Yend-Ystart,2),0.5)
        SF = DummyLine/FeatLen                         
        DY = np.abs(Xend-Xstart)*SF
        YNEW = Yorg+DY
        return YNEW

def Yoffright(DummyLine, Yorg, Xstart, Xend, Ystart, Yend):
        FeatLen = np.power(np.power(Xend-Xstart,2) + np.power(Yend-Ystart,2),0.5)
        SF = DummyLine/FeatLen                         
        DY = np.abs(Xend-Xstart)*SF
        YNEW = Yorg-DY
        return YNEW

Network_sum = open("CreateImprovedNetwork_summary.txt", 'r')
for line in Network_sum:
    splitline = string.split(line, ":")
    if splitline[0] == 'StartLine':
        LINE_count = int(splitline[1])
    if splitline[0] == 'StartNode':
        Node_count = int(splitline[1]) 


for idx, feat in enumerate(WADI_LYR):
    VIF_ID = feat.GetFieldAsString(0)
    InHydro = feat.GetFieldAsString(2)
    Area = feat.GetFieldAsDouble(1)
    if InHydro == 'no':        
        if Area >= minarea:
            geom = feat.geometry()
            centroid = geom.Centroid()
            XCentroid = centroid.GetX()
            YCentroid = centroid.GetY()                            
         
            # determine original start/end coordinates       
            X1 = XCentroid
            X6 = XCentroid
            Y1 = YCentroid - 0.5 * Length
            Y6 = YCentroid + 0.5 * Length
            # determine "split line" coordinates
            DX = X6-X1
            X2 = XCentroid
            X3 = XCentroid
            X4 = XCentroid
            X5 = XCentroid
            DY = Y6-Y1
            Y2 = Y1 + DY * LD[0]
            Y3 = Y2 + DY * LD[1]
            Y4 = Y3 + DY * LD[2]
            Y5 = Y4 + DY * LD[3]
            # determine "offset" coordinates
            X7 = Xoffleft(DummyLine, X2, X1, X6, Y1, Y6)
            X8 = Xoffleft(DummyLine, X4, X1, X6, Y1, Y6)
            Y7 = Yoffleft(DummyLine, Y2, X1, X6, Y1, Y6)
            Y8 = Yoffleft(DummyLine, Y4, X1, X6, Y1, Y6)
            
            X9 = Xoffright(DummyLine, X2, X1, X6, Y1, Y6)
            X10 = Xoffright(DummyLine, X4, X1, X6, Y1, Y6)
            Y9 = Yoffright(DummyLine, Y2, X1, X6, Y1, Y6)
            Y10 = Yoffright(DummyLine, Y4, X1, X6, Y1, Y6)
            
                #add first part (optional inclusion of variable inflow)
            Line = addline(NETWNEW_LYR, X1, X2, Y1, Y2, str(LINE_count), VIF_ID, Node_count,"VIF_"+VIF_ID,"",TYPE[0])
            LINE_count += 1       
            
            # add first triangle PWS
            Line = addline(NETWNEW_LYR, X2, X7, Y2, Y7, str(LINE_count), Node_count, "PWS" + str(Node_count+1),"","PWS_RR_"+str(Node_count+1)+ "_WD_" +str(VIF_ID), TYPE[1])
            DIV_PWS = copy.deepcopy(Node_count)
            LINE_count += 1
            Line = addline(NETWNEW_LYR, X2, X9, Y2, Y9, str(LINE_count), Node_count, "PWS" + str(Node_count+2),"","PWS_UR_"+str(Node_count+2)+ "_WD_" +str(VIF_ID), TYPE[1])
            LINE_count += 1       
            Line = addline(NETWNEW_LYR, X2, X3, Y2, Y3, str(LINE_count), Node_count, Node_count+3,"","", TYPE[0])
            LINE_count += 1    
            Node_count += 1
            Line = addline(NETWNEW_LYR, X7, X3, Y7, Y3, str(LINE_count), "PWS" + str(Node_count), Node_count+2,"PWS_RR_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
            PWS_rural = copy.deepcopy(Node_count)
            LINE_count += 1
            Node_count += 1
            Line = addline(NETWNEW_LYR, X9, X3, Y9, Y3, str(LINE_count), "PWS" + str(Node_count), Node_count+1,"PWS_UR_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
            PWS_urban = copy.deepcopy(Node_count)
            LINE_count += 1
            Node_count += 1   
            
            # add line between PWS
            Line = addline(NETWNEW_LYR, X3, X4, Y3, Y4, str(LINE_count), Node_count, Node_count+1,"","", TYPE[0])
            LINE_count += 1
            Node_count += 1 
            # add second triangle Irrigation
            Line = addline(NETWNEW_LYR, X4, X8, Y4, Y8, str(LINE_count), Node_count, "IRR" + str(Node_count+1),"","IRR_ST_"+str(Node_count+1)+ "_WD_" +str(VIF_ID), TYPE[1])
            DIV_IRR = copy.deepcopy(Node_count)
            LINE_count += 1
            Line = addline(NETWNEW_LYR, X4, X10, Y4, Y10, str(LINE_count), Node_count, "IRR" + str(Node_count+2),"","IRR_TC_"+str(Node_count+2)+ "_WD_" +str(VIF_ID), TYPE[1])
            LINE_count += 1       
            Line = addline(NETWNEW_LYR, X4, X5, Y4, Y5, str(LINE_count), Node_count, Node_count+3,"","", TYPE[0])
            LINE_count += 1    
            Node_count += 1
            Line = addline(NETWNEW_LYR, X8, X5, Y8, Y5, str(LINE_count), "IRR" + str(Node_count), Node_count+2,"IRR_ST_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
            IRR_rural = copy.deepcopy(Node_count)
            LINE_count += 1
            Node_count += 1
            Line = addline(NETWNEW_LYR, X10, X5, Y10, Y5, str(LINE_count), "IRR" + str(Node_count), Node_count+1,"IRR_TC_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
            IRR_technic = copy.deepcopy(Node_count)
            LINE_count += 1
            Node_count += 1  
            #add line between PWS and end
            Line = addline(NETWNEW_LYR, X5, X6, Y5, Y6, str(LINE_count), Node_count, Node_count+1,"","",TYPE[0])
            LINE_count += 1
            Node_count += 2
              
            #add PWS nodes    
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(X7,Y7)
            feature = ogr.Feature(PWS_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            feature.SetField("ID", str(PWS_rural))
            feature.SetField("NAME", "PWS_RR_" + str(PWS_rural))
            PWS_LYR.CreateFeature(feature)     
            
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(X9,Y9)
            feature = ogr.Feature(PWS_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            feature.SetField("ID", str(PWS_urban))
            feature.SetField("NAME", "PWS_URB_" + str(PWS_urban))
            PWS_LYR.CreateFeature(feature)
        
            #add DIV nodes    
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(X2,Y2)
            feature = ogr.Feature(DIV_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            feature.SetField("ID", str(DIV_PWS))
            feature.SetField("NAME", "DIV_RR_" + str(DIV_PWS))
            DIV_LYR.CreateFeature(feature)     
            
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(X4,Y4)
            feature = ogr.Feature(DIV_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            feature.SetField("ID", str(DIV_PWS))
            feature.SetField("NAME", "DIV_URB_" + str(DIV_PWS))
            DIV_LYR.CreateFeature(feature)
            
            #add IRRIGATION nodes    
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(X8,Y8)
            feature = ogr.Feature(IRR_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            feature.SetField("ID", str(PWS_rural))
            feature.SetField("NAME", "IRR_ST" + str(IRR_rural))
            IRR_LYR.CreateFeature(feature)     
            
            point = ogr.Geometry(ogr.wkbPoint)
            point.AddPoint(X10,Y10)
            feature = ogr.Feature(PWS_LYR.GetLayerDefn())
            feature.SetGeometry(point)
            feature.SetField("ID", str(PWS_urban))
            feature.SetField("NAME", "IRR_TC_" + str(IRR_technic))
            IRR_LYR.CreateFeature(feature)
       
WADI_IN.Destroy()
NETWNEW_out.Destroy()
PWS_out.Destroy()
DIV_out.Destroy()
IRR_out.Destroy()