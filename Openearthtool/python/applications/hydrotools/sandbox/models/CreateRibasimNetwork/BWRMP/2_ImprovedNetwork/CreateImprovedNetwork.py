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


NETWOLD_SHP = "Sbk_Chan_l.shp"
NETWOLD_NU_SHP = "sbk_channel&lat_notused_l.shp"
VIF_SHP = "sbk_boundary_inflow_n.shp"
CON_SHP = "sbk_sbk-3b-node_confluence_n.shp"
TER_SHP = "sbk_boundary_terminal_n.shp"
ROR_SHP = "sbk_sbk-3b-node_runoffriver_n.shp"
SWR_SHP = "sbk_sbk-3b-node_reservoir_n.shp"
DIV_SHP = "sbk_sbk-3b-node_weir_n.shp"
NETWNEW_SHP = "Network_improved.shp"
PWS_SHP = "PWS.shp"
#DIV_SHP = "Diversions.shp"
IRR_SHP = "sbk_sbk-3b-node_irrigation_n.shp"
WADI_SHP = "11_WATERDISTRICT_SUMBAWA.shp"
CATCH_ATT = 'DAS'
PFX_CATCH = "DAS_"
TYPE = ["Flow - Channel","Diversion"]
DummyLine = 0.001
LD = [0.3,0.1,0.1,0.1,0.3] 
minarea = 3000000
Length = 0.02

    
SHPDriver = ogr.GetDriverByName("ESRI Shapefile")

# create the spatial reference, WGS84
srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)

if os.path.exists(NETWNEW_SHP):
    SHPDriver.DeleteDataSource(NETWNEW_SHP)
if os.path.exists(PWS_SHP):
    SHPDriver.DeleteDataSource(PWS_SHP)
#if os.path.exists(DIV_SHP):
    
# Read waterdistrict layer
WADI_ID = []
WADI_RUR = []
WADI_URB = []
WADI_IRR = []
WADI_ATT = os.path.splitext(os.path.basename(WADI_SHP))[0]
WADI_IN = ogr.Open(WADI_SHP)
WADI_LYR = WADI_IN.GetLayerByName(WADI_ATT)
WADI_LYR.ResetReading()
WADI_DEF = WADI_LYR.GetLayerDefn()
CATCH_NAMES = [] 
for feat in WADI_LYR:
    WADI_ID.append(int("%i" % feat.GetFieldAsInteger('ID')))
    CATCH_NAMES.append("%s" % feat.GetFieldAsString(CATCH_ATT))
    DMURB14 = float(("%f" % feat.GetFieldAsDouble('DMURB14')))
    DMURB35 = float(("%f" % feat.GetFieldAsDouble('DMURB35')))
    ADDURB = ("%s" % feat.GetFieldAsString('ADDURB'))
    if ADDURB == 'yes':
        WADI_URB.append('yes')
    elif DMURB14 > 0 or DMURB35 > 0:
        WADI_URB.append('yes')
    else: WADI_URB.append('no')
    DMRUR14 = float(("%f" % feat.GetFieldAsDouble('DMRUR14')))
    DMRUR35 = float(("%f" % feat.GetFieldAsDouble('DMRUR35')))
    ADDRUR = ("%s" % feat.GetFieldAsString('ADDRUR'))
    if ADDRUR == 'yes':
        WADI_RUR.append('yes')
    elif DMRUR14 > 0 or DMRUR35 > 0:
        WADI_RUR.append('yes')
    else: WADI_RUR.append('no')
    ASTIRR14 = float(("%f" % feat.GetFieldAsDouble('ASTIRR14')))
    ASTIRR35 = float(("%f" % feat.GetFieldAsDouble('ASTIRR35')))
    ADDIRR = ("%s" % feat.GetFieldAsString('ADDRUR'))
    if ADDIRR == 'yes':
        WADI_IRR.append('yes')
    elif ASTIRR14 > 0 or ASTIRR35 > 0:
        WADI_IRR.append('yes')
    else: WADI_IRR.append('no')
Node_count = int(WADI_ID[len(WADI_ID)-1])
WADI_LYR.ResetReading()

# Read variable inflow layer
VIF_ATT = os.path.splitext(os.path.basename(VIF_SHP))[0]
VIF_IN = ogr.Open(VIF_SHP)
VIF_LYR = VIF_IN.GetLayerByName(VIF_ATT)
VIF_LYR.ResetReading()
VIF_DEF = VIF_LYR.GetLayerDefn()
VIF_IDS = []
for feat in VIF_LYR:
    VIF_IDS.append("%s" % feat.GetFieldAsString(0))
VIF_IN.Destroy()

# Read Runoff River layer
ROR_COORD = []
ROR_NAME = []
if os.path.exists(ROR_SHP):
    ROR_ATT = os.path.splitext(os.path.basename(ROR_SHP))[0]
    ROR_IN = ogr.Open(ROR_SHP)
    ROR_LYR = ROR_IN.GetLayerByName(ROR_ATT)
    ROR_LYR.ResetReading()
    ROR_DEF = ROR_LYR.GetLayerDefn()

    for feat in ROR_LYR:
        feat_geometry = feat.geometry()
        ROR_COORD.append([feat_geometry.GetX(),feat_geometry.GetY()])
        ROR_NAME.append(feat.GetFieldAsString('NAME      '))
    ROR_IN.Destroy()

# Read Reservoir layer
SWR_ATT = os.path.splitext(os.path.basename(SWR_SHP))[0]
SWR_IN = ogr.Open(SWR_SHP)
SWR_LYR = SWR_IN.GetLayerByName(SWR_ATT)
SWR_LYR.ResetReading()
SWR_DEF = SWR_LYR.GetLayerDefn()
SWR_COORD = []
SWR_NAME = []
for feat in SWR_LYR:
    feat_geometry = feat.geometry()
    SWR_COORD.append([feat_geometry.GetX(),feat_geometry.GetY()])
    SWR_NAME.append(feat.GetFieldAsString('NAME      '))
SWR_IN.Destroy()

# Read Diversion layer
DIV_ATT = os.path.splitext(os.path.basename(DIV_SHP))[0]
DIV_IN = ogr.Open(DIV_SHP)
DIV_LYR = DIV_IN.GetLayerByName(DIV_ATT)
DIV_LYR.ResetReading()
DIV_DEF = DIV_LYR.GetLayerDefn()
DIV_COORD = []
DIV_NAME = []
for feat in DIV_LYR:
    feat_geometry = feat.geometry()
    DIV_COORD.append([feat_geometry.GetX(),feat_geometry.GetY()]) 
    DIV_NAME.append(feat.GetFieldAsString('NAME      '))
DIV_IN.Destroy()

# Read irrigation layer
IRR_COORD = []
IRR_NAME = []
if os.path.exists(IRR_SHP):
    IRR_ATT = os.path.splitext(os.path.basename(IRR_SHP))[0]
    IRR_IN = ogr.Open(IRR_SHP)
    IRR_LYR = IRR_IN.GetLayerByName(IRR_ATT)
    IRR_LYR.ResetReading()
    IRR_DEF = IRR_LYR.GetLayerDefn()

    for feat in IRR_LYR:
        feat_geometry = feat.geometry()
        IRR_COORD.append([feat_geometry.GetX(),feat_geometry.GetY()]) 
        IRR_NAME.append(feat.GetFieldAsString('NAME      '))
    IRR_IN.Destroy()


# Read confluence layer
CON_ATT = os.path.splitext(os.path.basename(CON_SHP))[0]
CON_IN = ogr.Open(CON_SHP)
CON_LYR = CON_IN.GetLayerByName(CON_ATT)
CON_LYR.ResetReading()
CON_DEF = CON_LYR.GetLayerDefn()
CON_IDS = []  
for feat in CON_LYR:
    CON_IDS.append("%s" % feat.GetFieldAsString(0))   
CON_IN.Destroy()
    
# Read terminal layer
TER_ATT = os.path.splitext(os.path.basename(TER_SHP))[0]
TER_IN = ogr.Open(TER_SHP)
TER_LYR = TER_IN.GetLayerByName(TER_ATT)
TER_LYR.ResetReading()
TER_DEF = TER_LYR.GetLayerDefn()
TER_IDS = []  
for feat in TER_LYR:
    TER_IDS.append("%s" % feat.GetFieldAsString(0))   
TER_IN.Destroy()

# Read network layer and create improved version
NETWOLD_ATT = os.path.splitext(os.path.basename(NETWOLD_SHP))[0]
NETWOLD_IN = ogr.Open(NETWOLD_SHP)
NETWOLD_LYR = NETWOLD_IN.GetLayerByName(NETWOLD_ATT)
NETWOLD_LYR.ResetReading()
NETWOLD_SREF = NETWOLD_LYR.GetSpatialRef()
NETWOLD_DEF = NETWOLD_LYR.GetLayerDefn()

# Read non used network
if os.path.exists(NETWOLD_NU_SHP):
    NETWOLD_NU_ATT = os.path.splitext(os.path.basename(NETWOLD_NU_SHP))[0]
    NETWOLD_NU_IN = ogr.Open(NETWOLD_NU_SHP)
    NETWOLD_NU_LYR = NETWOLD_NU_IN.GetLayerByName(NETWOLD_NU_ATT)
    NETWOLD_NU_LYR.ResetReading()

#Create New Network Layer
NETWNEW_out = SHPDriver.CreateDataSource(NETWNEW_SHP)
NETWNEW_ATT = os.path.splitext(os.path.basename(NETWNEW_SHP))[0]
NETWNEW_LYR  = NETWNEW_out.CreateLayer(NETWNEW_ATT, NETWOLD_SREF)

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

LINE_count = 1
#WatDist_sum = open("CreateWaterdistricts_summary.txt", 'r')
#for line in WatDist_sum:
#    splitline = string.split(line, ":")
#    if splitline[0] == 'DistMax':
#        WD_ID = int(splitline[1]) + 1 
#WatDist_sum.close()
    
SBK_IDS = []
SBK_RENUM = []
SBK_IDS.append(["-999","-999"])
SBK_RENUM.append(["-999","-999"])

if os.path.exists(NETWOLD_NU_SHP):
    for idx, i in enumerate(range(NETWOLD_NU_LYR.GetFeatureCount())):
        old_feature = NETWOLD_NU_LYR.GetFeature(i)
        old_geometry = old_feature.geometry()
        ID_FROM = old_feature.GetFieldAsString(5)
        ID_TO = old_feature.GetFieldAsString(6)
        if str(ID_FROM) in np.array(SBK_IDS)[:,0]:
            ID_START = np.array(SBK_IDS)[np.where(np.array(SBK_IDS)[:,0]==str(ID_FROM)),1].tolist()[0][0]
        else:
            ID_START = Node_count
            SBK_IDS.append([str(ID_FROM),str(Node_count)])
            Node_count += 1
        if str(ID_TO) in np.array(SBK_IDS)[:,0]:
            ID_END = np.array(SBK_IDS)[np.where(np.array(SBK_IDS)[:,0]==str(ID_TO)),1].tolist()[0][0]
        else:
            ID_END = Node_count
            SBK_IDS.append([str(ID_TO),ID_END])
            Node_count += 1
        X1 = old_geometry.GetX(0)
        X6 = old_geometry.GetX(1)
        Y1 = old_geometry.GetY(0)
        Y6 = old_geometry.GetY(1)
        if [X1,Y1] in ROR_COORD:
            PFSTART = "ROR"
            NAMESTART = ROR_NAME[ROR_COORD.index([X1,Y1])]
        elif [X1,Y1] in SWR_COORD:
            PFSTART = "SWR"
            NAMESTART = SWR_NAME[SWR_COORD.index([X1,Y1])]
        elif [X1,Y1] in DIV_COORD:
            PFSTART = "DIV"
            NAMESTART = DIV_NAME[DIV_COORD.index([X1,Y1])]
        elif [X1,Y1] in IRR_COORD:
            PFSTART = "IRR"
            NAMESTART = IRR_NAME[IRR_COORD.index([X1,Y1])]
        else: 
            PFSTART = ""
            NAMESTART = ""
        if [X6,Y6] in ROR_COORD:
            PFEND = "ROR"
            NAMEEND = ROR_NAME[ROR_COORD.index([X6,Y6])]
        elif [X6,Y6] in SWR_COORD:
            PFEND = "SWR"
            NAMEEND = SWR_NAME[SWR_COORD.index([X6,Y6])]
        elif [X6,Y6] in DIV_COORD:
            PFEND = "DIV"
            NAMEEND = DIV_NAME[DIV_COORD.index([X6,Y6])]
        elif [X6,Y6] in IRR_COORD:
            PFEND = "IRR"
            NAMEEND = IRR_NAME[IRR_COORD.index([X6,Y6])]
        else: 
            PFEND = ""
            NAMEEND = ""
        if [X1,Y1] in DIV_COORD and [X6,Y6] in IRR_COORD:
            Line = addline(NETWNEW_LYR, X1, X6, Y1, Y6,  str(LINE_count), PFSTART+str(ID_START), PFEND+str(ID_END),NAMESTART,NAMEEND, TYPE[1])
        else: Line = addline(NETWNEW_LYR, X1, X6, Y1, Y6,  str(LINE_count), PFSTART+str(ID_START), PFEND+str(ID_END),NAMESTART,NAMEEND, TYPE[0])
        LINE_count += 1

for idx, i in enumerate(range(NETWOLD_LYR.GetFeatureCount())):
    old_feature = NETWOLD_LYR.GetFeature(i)
    NETW_ID = old_feature.GetFieldAsString(0)
    NETW_ID = int(NETW_ID[0:NETW_ID.find('_')])
    ID_FROM = old_feature.GetFieldAsString(5)
    ID_TO = old_feature.GetFieldAsString(6)
    VIF_ID = old_feature.GetFieldAsString(0)[0:len(old_feature.GetFieldAsString(0))-2]      
    old_geometry = old_feature.geometry()        
    if ID_FROM in VIF_IDS:
        VIFup = True
    else:
        VIFup = False
        if str(ID_FROM) in np.array(SBK_IDS)[:,0]:
            ID_START = np.array(SBK_IDS)[np.where(np.array(SBK_IDS)[:,0]==str(ID_FROM)),1].tolist()[0][0]
        else:
            ID_START = Node_count
            SBK_IDS.append([str(ID_FROM),str(Node_count)])
            Node_count += 1
    if str(ID_TO) in np.array(SBK_IDS)[:,0]:
        ID_END = np.array(SBK_IDS)[np.where(np.array(SBK_IDS)[:,0]==str(ID_TO)),1].tolist()[0][0]
    else:
        ID_END = Node_count
        SBK_IDS.append([str(ID_TO),ID_END])
        Node_count += 1
    # determine original start/end coordinates       
    X1 = old_geometry.GetX(0)
    X6 = old_geometry.GetX(1)
    Y1 = old_geometry.GetY(0)
    Y6 = old_geometry.GetY(1)
    if [X1,Y1] in ROR_COORD:
        PFSTART = "ROR"
        NAMESTART = ROR_NAME[ROR_COORD.index([X1,Y1])]
    elif [X1,Y1] in SWR_COORD:
        PFSTART = "SWR"
        NAMESTART = SWR_NAME[SWR_COORD.index([X1,Y1])]
    elif [X1,Y1] in DIV_COORD:
        PFSTART = "DIV"
        NAMESTART = DIV_NAME[DIV_COORD.index([X1,Y1])]
    elif [X1,Y1] in IRR_COORD:
        PFSTART = "IRR"
        NAMESTART = IRR_NAME[IRR_COORD.index([X1,Y1])]
    else: 
        PFSTART = ""
        NAMESTART = ""
    if [X6,Y6] in ROR_COORD:
        PFEND = "ROR"
        NAMEEND = ROR_NAME[ROR_COORD.index([X6,Y6])]
    elif [X6,Y6] in SWR_COORD:
        PFEND = "SWR"
        NAMEEND = SWR_NAME[SWR_COORD.index([X6,Y6])]
    elif [X6,Y6] in DIV_COORD:
        PFEND = "DIV"
        NAMEEND = DIV_NAME[DIV_COORD.index([X6,Y6])]
    elif [X6,Y6] in IRR_COORD:
        PFEND = "IRR"
        NAMEEND = IRR_NAME[IRR_COORD.index([X6,Y6])]
    else: 
        PFEND = ""
        NAMEEND = ""
    
    # determine "split line" coordinates
    DX = X6-X1
    X2 = X1 + DX * LD[0]
    X3 = X2 + DX * LD[1]
    X4 = X3 + DX * LD[2]
    X5 = X4 + DX * LD[3]
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
    if VIFup == True:
        if WADI_RUR[WADI_ID.index(NETW_ID)] == 'yes' or WADI_URB[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X1, X2, Y1, Y2, str(LINE_count), VIF_ID, Node_count+1,PFX_CATCH+CATCH_NAMES[WADI_ID.index(int(VIF_ID))],"", TYPE[0])
            LINE_count += 1
            Node_count += 1
        elif WADI_IRR[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X1, X4, Y1, Y4, str(LINE_count), VIF_ID, Node_count+1,PFX_CATCH+CATCH_NAMES[WADI_ID.index(int(VIF_ID))],"", TYPE[0])
            LINE_count += 1
            Node_count += 1
        else:
            Line = addline(NETWNEW_LYR, X1, X6, Y1, Y6, str(LINE_count), VIF_ID, PFEND+str(ID_END),PFX_CATCH+CATCH_NAMES[WADI_ID.index(int(VIF_ID))],NAMEEND, TYPE[0])
            LINE_count += 1
            Node_count += 1
    else:
        X11 = X1 + DX * LD[0]/2
        X12 = Xoffright(DummyLine, X11, X1, X6, Y1, Y6)
        Y11 = Y1 + DY * LD[0]/2
        Y12 = Yoffright(DummyLine, Y11, X1, X6, Y1, Y6)
        
        Line = addline(NETWNEW_LYR, X1, X11, Y1, Y11, str(LINE_count), PFSTART+str(ID_START), Node_count+1,NAMESTART,"", TYPE[0])
        LINE_count += 1
        Line = addline(NETWNEW_LYR, X12, X11, Y12, Y11, str(LINE_count), VIF_ID, Node_count+1,PFX_CATCH+CATCH_NAMES[WADI_ID.index(int(VIF_ID))],"", TYPE[0])
        LINE_count += 1
        Node_count += 1
        if WADI_RUR[WADI_ID.index(NETW_ID)] == 'yes' or WADI_URB[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X11, X2, Y11, Y2, str(LINE_count), Node_count, Node_count+1,"","", TYPE[0])
            LINE_count += 1
            Node_count += 1
        elif WADI_IRR[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X11, X4, Y11, Y4, str(LINE_count), Node_count, Node_count+1,"","", TYPE[0])
            LINE_count += 1
            Node_count += 1
        else: 
            Line = addline(NETWNEW_LYR, X11, X6, Y11, Y6, str(LINE_count), Node_count, PFEND+str(ID_END),"",NAMEEND, TYPE[0])
            LINE_count += 1
            Node_count += 1
    
    # add first triangle PWS
    if WADI_RUR[WADI_ID.index(NETW_ID)] == 'yes' or WADI_URB[WADI_ID.index(NETW_ID)] == 'yes':
        if WADI_RUR[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X2, X7, Y2, Y7, str(LINE_count), Node_count, "PWS" + str(Node_count+1),"","PWS_RR_"+str(Node_count+1)+ "_WD_" +str(VIF_ID), TYPE[1])
            DIV_PWS = copy.deepcopy(Node_count)
            LINE_count += 1
        if WADI_URB[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X2, X9, Y2, Y9, str(LINE_count), Node_count, "PWS" + str(Node_count+2),"","PWS_UR_"+str(Node_count+2)+ "_WD_" +str(VIF_ID), TYPE[1])
            LINE_count += 1       
        if WADI_RUR[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X7, X3, Y7, Y3, str(LINE_count), "PWS" + str(Node_count+1), Node_count+3,"PWS_RR_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
            PWS_rural = copy.deepcopy(Node_count)
            LINE_count += 1
        if WADI_URB[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X9, X3, Y9, Y3, str(LINE_count), "PWS" + str(Node_count+2), Node_count+3,"PWS_UR_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
            PWS_urban = copy.deepcopy(Node_count)
            LINE_count += 1
        Line = addline(NETWNEW_LYR, X2, X3, Y2, Y3, str(LINE_count), Node_count, Node_count+3,"","", TYPE[0])
        LINE_count += 1    
        Node_count += 3
    
        
    if WADI_IRR[WADI_ID.index(NETW_ID)] == 'no':
        if WADI_RUR[WADI_ID.index(NETW_ID)] == 'yes' or WADI_URB[WADI_ID.index(NETW_ID)] == 'yes':
            Line = addline(NETWNEW_LYR, X3, X6, Y3, Y6, str(LINE_count), Node_count, PFEND+str(ID_END),"",NAMEEND, TYPE[0])
            LINE_count += 1
            Node_count += 1 
    elif WADI_IRR[WADI_ID.index(NETW_ID)] == 'yes':
        if WADI_RUR[WADI_ID.index(NETW_ID)] == 'yes' or WADI_URB[WADI_ID.index(NETW_ID)] == 'yes':
            # add line between PWS
            Line = addline(NETWNEW_LYR, X3, X4, Y3, Y4, str(LINE_count), Node_count, Node_count+1,"","", TYPE[0])
            LINE_count += 1
            Node_count += 1 
            # add second triangle Irrigation
            Line = addline(NETWNEW_LYR, X4, X8, Y4, Y8, str(LINE_count), Node_count, "IRR" + str(Node_count+1),"","IRR_ST_"+str(Node_count+1)+ "_WD_" +str(VIF_ID), TYPE[1])
            DIV_IRR = copy.deepcopy(Node_count)
            LINE_count += 1    
            Line = addline(NETWNEW_LYR, X8, X5, Y8, Y5, str(LINE_count), "IRR" + str(Node_count+1), Node_count+2,"IRR_ST_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
            IRR_rural = copy.deepcopy(Node_count)
            LINE_count += 1
            Line = addline(NETWNEW_LYR, X4, X5, Y4, Y5, str(LINE_count), Node_count, Node_count+2,"","", TYPE[0])
            LINE_count += 1
            Node_count += 2
            #add line between PWS and end
            Line = addline(NETWNEW_LYR, X5, X6, Y5, Y6, str(LINE_count), Node_count, PFEND+str(ID_END),"",NAMEEND,TYPE[0])
            LINE_count += 1
            Node_count += 1
    

for idx, feat in enumerate(WADI_LYR):
    VIF_ID = int(feat.GetFieldAsInteger('ID'))
    ID_END = Node_count
    Node_count += 1
    InHydro = feat.GetFieldAsString('HYDRO')
    Area = feat.GetFieldAsDouble('AREA_M2')
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
            if WADI_RUR[WADI_ID.index(VIF_ID)] == 'yes' or WADI_URB[WADI_ID.index(VIF_ID)] == 'yes':
                Line = addline(NETWNEW_LYR, X1, X2, Y1, Y2, str(LINE_count), VIF_ID, Node_count+1,"","", TYPE[0])
                LINE_count += 1
                Node_count += 1
            elif WADI_IRR[WADI_ID.index(VIF_ID)] == 'yes':
                Line = addline(NETWNEW_LYR, X1, X4, Y1, Y4, str(LINE_count), VIF_ID, Node_count+1,"","", TYPE[0])
                LINE_count += 1
                Node_count += 1
            else: 
                if [X1,Y1] in DIV_COORD:
                    Line = addline(NETWNEW_LYR, X1, X6, Y1, Y6, str(LINE_count), VIF_ID, PFEND+str(ID_END),PFX_CATCH+CATCH_NAMES[WADI_ID.index(int(VIF_ID))],NAMEEND, TYPE[1])
                else: Line = addline(NETWNEW_LYR, X1, X6, Y1, Y6, str(LINE_count), VIF_ID, PFEND+str(ID_END),PFX_CATCH+CATCH_NAMES[WADI_ID.index(int(VIF_ID))],NAMEEND, TYPE[0]) 
                LINE_count += 1
                Node_count += 1
            # add first triangle PWS
            if WADI_RUR[WADI_ID.index(VIF_ID)] == 'yes' or WADI_URB[WADI_ID.index(VIF_ID)] == 'yes':
                if WADI_RUR[WADI_ID.index(VIF_ID)] == 'yes':
                    Line = addline(NETWNEW_LYR, X2, X7, Y2, Y7, str(LINE_count), Node_count, "PWS" + str(Node_count+1),"","PWS_RR_"+str(Node_count+1)+ "_WD_" +str(VIF_ID), TYPE[1])
                    DIV_PWS = copy.deepcopy(Node_count)
                    LINE_count += 1
                if WADI_URB[WADI_ID.index(VIF_ID)] == 'yes':
                    Line = addline(NETWNEW_LYR, X2, X9, Y2, Y9, str(LINE_count), Node_count, "PWS" + str(Node_count+2),"","PWS_UR_"+str(Node_count+2)+ "_WD_" +str(VIF_ID), TYPE[1])
                    LINE_count += 1       
                if WADI_RUR[WADI_ID.index(VIF_ID)] == 'yes':
                    Line = addline(NETWNEW_LYR, X7, X3, Y7, Y3, str(LINE_count), "PWS" + str(Node_count+1), Node_count+3,"PWS_RR_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
                    PWS_rural = copy.deepcopy(Node_count)
                    LINE_count += 1
                if WADI_URB[WADI_ID.index(VIF_ID)] == 'yes':
                    Line = addline(NETWNEW_LYR, X9, X3, Y9, Y3, str(LINE_count), "PWS" + str(Node_count+2), Node_count+3,"PWS_UR_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
                    PWS_urban = copy.deepcopy(Node_count)
                    LINE_count += 1
                Line = addline(NETWNEW_LYR, X2, X3, Y2, Y3, str(LINE_count), Node_count, Node_count+3,"","", TYPE[0])
                LINE_count += 1    
                Node_count += 3
            
                
            if WADI_IRR[WADI_ID.index(VIF_ID)] == 'no':
                if WADI_RUR[WADI_ID.index(VIF_ID)] == 'yes' or WADI_URB[WADI_ID.index(VIF_ID)] == 'yes':
                    Line = addline(NETWNEW_LYR, X3, X6, Y3, Y6, str(LINE_count), Node_count, Node_count+1,"","", TYPE[0])
                    LINE_count += 1
                    Node_count += 1 
            elif WADI_IRR[WADI_ID.index(VIF_ID)] == 'yes':
                if WADI_RUR[WADI_ID.index(VIF_ID)] == 'yes' or WADI_URB[WADI_ID.index(VIF_ID)] == 'yes':
                    # add line between PWS
                    Line = addline(NETWNEW_LYR, X3, X4, Y3, Y4, str(LINE_count), Node_count, Node_count+1,"","", TYPE[0])
                    LINE_count += 1
                    Node_count += 1 
                    # add second triangle Irrigation
                    Line = addline(NETWNEW_LYR, X4, X8, Y4, Y8, str(LINE_count), Node_count, "IRR" + str(Node_count+1),"","IRR_ST_"+str(Node_count+1)+ "_WD_" +str(VIF_ID), TYPE[1])
                    DIV_IRR = copy.deepcopy(Node_count)
                    LINE_count += 1    
                    Line = addline(NETWNEW_LYR, X8, X5, Y8, Y5, str(LINE_count), "IRR" + str(Node_count+1), Node_count+2,"IRR_ST_"+str(Node_count)+ "_WD_" +str(VIF_ID),"", TYPE[0])
                    IRR_rural = copy.deepcopy(Node_count)
                    LINE_count += 1
                    Line = addline(NETWNEW_LYR, X4, X5, Y4, Y5, str(LINE_count), Node_count, Node_count+2,"","", TYPE[0])
                    LINE_count += 1
                    Node_count += 2
                    #add line between PWS and end
                    Line = addline(NETWNEW_LYR, X5, X6, Y5, Y6, str(LINE_count), Node_count, ID_END,"","",TYPE[0])
                    LINE_count += 1
                    Node_count += 1
                  
    
Summary = open("CreateImprovedNetwork_summary.txt", "w+")
Summary.write("StartNode: "+ str(Node_count)+"\n")
Summary.write("StartLine: "+ str(LINE_count)+"\n")

Summary.close()

       
NETWNEW_out.Destroy()
PWS_out.Destroy()
#DIV_out.Destroy()
NETWOLD_IN.Destroy()
WADI_IN.Destroy()