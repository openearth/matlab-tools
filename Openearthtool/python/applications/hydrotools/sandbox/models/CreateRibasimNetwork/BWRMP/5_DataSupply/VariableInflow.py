# -*- co*ding: utf-8 -*-
"""
Created on Sat Jul 19 10:53:45 2014

@author: tollena
"""

import struct
import os
import string

try:
    from osgeo import ogr
except ImportError:
    import ogr

RibasimDir = "c:/Ribasim7/Sumbawa.Rbn/work/"
basin = "SUMBAWA"

BIN = RibasimDir + "VARINFL.BIN"
WADI_SHP = "11_WATERDISTRICT_" + basin + ".shp"
VifNodes = open("VifNodes.txt",'r')
line = VifNodes.readline()
print line
VIF_include = string.split(line, ',')

HeaderSize = 64
BlockSize = 1420

#parameter structure
PVirCatch = ['f',136,4]
PID=['H',0,2]
PCatchLab = ['I',8,4]
PActInflow = ['I',120,4]

WADI_ATT = os.path.splitext(os.path.basename(WADI_SHP))[0]
WADI_IN = ogr.Open(WADI_SHP)
WADI_LYR = WADI_IN.GetLayerByName(WADI_ATT)
WADI_LYR.ResetReading()

ITEM_IDS = []
AREA = []

for idx, feat in enumerate(WADI_LYR):
    ITEM_IDS.append(feat.GetFieldAsString(0))
    AREA.append(feat.GetFieldAsDouble(1)/1000000) 
WADI_IN.Destroy()
Summary = open("VifNodes.txt", "w+")
#Calculate inflow nodes
FileLen = int(os.path.getsize(BIN))
NmbrItems = (FileLen - HeaderSize)/BlockSize

with open(BIN, mode='rb') as f:
    DATA = f.read()
f = open(BIN, 'r+b')   
#
for item in range(HeaderSize,FileLen,BlockSize):
    if str(struct.unpack(PID[0], DATA[item:item+2])[0]) in ITEM_IDS:
        ITEM_idx = ITEM_IDS.index(str(struct.unpack(PID[0], DATA[item:item+2])[0]))
        WD = str(struct.unpack(PID[0], DATA[item:item+2])[0])
        f.seek(item + PCatchLab[1])
        f.write(struct.pack(PCatchLab[0],int(WD)))
        f.seek(item + PActInflow[1])     
        f.write(struct.pack(PActInflow[0],int(WD)))
        f.seek(item + PVirCatch[1])  
        f.write(struct.pack(PVirCatch[0],AREA[ITEM_idx]))     

f.close()
