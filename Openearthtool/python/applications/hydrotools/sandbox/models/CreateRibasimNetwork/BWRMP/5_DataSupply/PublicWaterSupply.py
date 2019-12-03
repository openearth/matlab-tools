# -*- co*ding: utf-8 -*-
"""
Created on Sat Jul 19 10:53:45 2014

@author: tollena
"""

import struct
import os

try:
    from osgeo import ogr
except ImportError:
    import ogr

RibasimDir = "c:/Ribasim7/Sumbawa.Rbn/16/"
basin = "SUMBAWA"

BIN = "PWSUPPLY_Return50per.BIN"
WADI_SHP = "11_WATERDISTRICT_" + basin + ".shp"
HeaderSize = 64
BlockSize = 1120

#parameter structure
PID=['H',0,2]
PCAP = ['f',8,4]
PCatchLab = ['I',12,4]
PFixDem = ['ffffffffffffffffffffffff',160,96]
PLossPlt = ['f',680,4]
PLossDis = ['f',684,4]
POnDem = ['H',688,2]
PRetSW = ['ffffffffffffffffffffffff',692,96]

#Calculate inflow nodes
FileLen = int(os.path.getsize(BIN))
NmbrItems = (FileLen - HeaderSize)/BlockSize


with open(BIN, mode='rb') as f:
    DATA = f.read()
f = open(BIN, 'r+b')
f.close()

print "ID = " + str(struct.unpack(PID[0], DATA[HeaderSize + PID[1]:HeaderSize + PID[1]+PID[2]])[0])
print "Capacity = " + str(struct.unpack(PCAP[0], DATA[HeaderSize + PCAP[1]:HeaderSize + PCAP[1]+PCAP[2]])[0])
print "Catchment label = " + str(struct.unpack(PCatchLab[0], DATA[HeaderSize + PCatchLab[1]:HeaderSize + PCatchLab[1]+PCatchLab[2]])[0])
print "Fixed Demand = " + str(struct.unpack(PFixDem[0], DATA[HeaderSize + PFixDem[1]:HeaderSize + PFixDem[1]+PFixDem[2]])[0])
print "Plant loss = " + str(struct.unpack(PLossPlt[0], DATA[HeaderSize + PLossPlt[1]:HeaderSize + PLossPlt[1]+PLossPlt[2]])[0])
print "On Demand = " + str(struct.unpack(POnDem[0], DATA[HeaderSize + POnDem[1]:HeaderSize + POnDem[1]+POnDem[2]])[0])
print "To Surface Water = " + str(struct.unpack(PRetSW[0], DATA[HeaderSize + PRetSW[1]:HeaderSize + PRetSW[1]+PRetSW[2]])[0])


#WADI_ATT = os.path.splitext(os.path.basename(WADI_SHP))[0]
#WADI_IN = ogr.Open(WADI_SHP)
#WADI_LYR = WADI_IN.GetLayerByName(WADI_ATT)
#WADI_LYR.ResetReading()
#
#ITEM_IDS = []
#AREA = []
#
#for idx, feat in enumerate(WADI_LYR):
#    ITEM_IDS.append(feat.GetFieldAsString(0))
#    AREA.append(feat.GetFieldAsDouble(1)/1000000) 
#WADI_IN.Destroy()
#
##Calculate inflow nodes
#FileLen = int(os.path.getsize(BIN))
#NmbrItems = (FileLen - HeaderSize)/BlockSize
#
#with open(BIN, mode='rb') as f:
#    DATA = f.read()
#f = open(BIN, 'r+b')   
##
#for item in range(HeaderSize,FileLen,BlockSize):
#    if str(struct.unpack(PID[0], DATA[item:item+2])[0]) in ITEM_IDS:
#        ITEM_idx = ITEM_IDS.index(str(struct.unpack(PID[0], DATA[item:item+2])[0]))
#        WD = str(struct.unpack(PID[0], DATA[item:item+2])[0])
#        f.seek(item + PCatchLab[1])
#        f.write(struct.pack(PCatchLab[0],int(WD)))
#        f.seek(item + PActInflow[1])     
#        f.write(struct.pack(PActInflow[0],int(WD)))
#        f.seek(item + PVirCatch[1])  
#        f.write(struct.pack(PVirCatch[0],AREA[ITEM_idx]))     
#
#f.close()
