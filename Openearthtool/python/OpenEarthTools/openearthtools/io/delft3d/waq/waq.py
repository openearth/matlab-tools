# -*- coding: utf-8 -*-
"""
Created on Mon May 19 13:48:51 2014

@author: gaytan_sa
"""


import numpy as np
import datetime
#from matplotlib.dates import date2num
import matplotlib.dates as date
#from decimal import Decimal


class waqinfo(object):
    

    def __init__(self, FileName):
        self.FileType    = FileName[-3:]
        self.FileName    = FileName
        self.ByteOrder   = []
        self.FormatType  = []
        self.Header      = []
        self.T0          = []
        self.Tunit       = []
        self.TStep       = []
        self.NumSegm     = []
        self.SegmName    = []
        self.NumSubs     = []
        self.SubsName    = []
        self.NBytesBlock = []
        self.DataStart   = []
        self.NTimes      = []
        
class lgainfo(object):
    

    def __init__(self, FileName):
        self.FileType      = 'lga'
        self.Filelga       = FileName[0:-3]+'lga'
        self.Filecco       = FileName[0:-3]+'cco'
        self.MNK           = []
        self.NoSegPerLayer = []
        self.NoSeg         = []
        self.NoExchMNK     = []
        self.Index         = []
        self.NumSegm       = []
        self.XY0           = []
        self.X             = []
        self.Y             = []
        self.xcen          = []
        self.ycen          = []
    
        
        
def openfile(FileName):
    "openfile(FileName)"
    
### Basic information
    S = waqinfo(FileName)
    
### Read the header of the file
    fl = open(S.FileName, 'rb')
    header = [];    
    count  = 4
    while (count > 0):
       local =  fl.read(40)
       header.append(local)
       count = count -1
    S.Header = header    
    
    
### Reads T0 in the file
    fl.seek(40*3)
    timeStr = fl.read(40)
    y  = np.int(timeStr[4:8])
    m  = np.int(timeStr[9:11])
    d  = np.int(timeStr[12:14])
    hh = np.int(timeStr[15:17])
    mm = np.int(timeStr[18:20])
    ss = np.int(timeStr[21:23])
    sunit = timeStr[-2]
    #tunit = np.int(timeStr[-3])
    T0 = datetime.datetime(y,m,d,hh,mm,ss)
    T0 = date.date2num(T0)

   
### Reads dt in the file
    if sunit=='s':
      tstep = 1./(24*60*60)
    elif sunit=='m':
      tstep = 1./(24*60)
    elif sunit=='h':
      tstep = 1./24
    elif sunit=='d':
      tstep = 1      
    else:
      tstep = np.nan

    S.T0    = T0
    S.TStep = tstep
    S.Tunit = sunit

### Reads the substances name
    fl.seek(40*4)
    nSub = np.fromfile(fl, np.int32, 1)
    fl.seek(40*4+8)
    subName = [];
        
    count = nSub
    while (count > 0):
          local =  fl.read(20)
          local = local.replace(" ", "")      
          subName.append(local)
          count = count -1
    
    S.SubsName = subName
    S.NumSubs  = nSub
    
    
### Reads the segment information       
    fl.seek(40*4+4)
    nSeg = np.fromfile(fl, np.int32, 1)
    segName = [];
    if S.FileType == 'map':
       S.SegmName = []
    else:
       S.SegmName = segName       
    S.NumSegm  = nSeg
    
    
### Reads bytes information         
    fl.seek(0,2)
    S.DataStart = (S.NumSubs*20)+(40*4)+(4*2)
    S.DataEnd   = int(fl.tell())
    fl.close
    S.NBytesBlock = (S.NumSegm*S.NumSubs+1)*4
    S.NTimes = (S.DataEnd-S.DataStart)/S.NBytesBlock
    
    fl.close
    return S
    

### Substance name to substance index
def indexsub(S,name): # subsname2subsindex
 
    names = S.SubsName
    iname = findindex(names,name)
    return iname

### Segment name to segment index
def indexseg(S,name):  
 
    if S.FileType == 'map':
       if name==[]:
          iname = range(S.NumSegm)
       else:
           iname = name
    else:
        names = S.SegmName
        iname = findindex(names,name)
    return iname
    
def findindex(names,name):    
   
    ni    = np.size(names)
    nj    = np.size(name)
    iname = []
    
    if name==[]:
       iname = range(ni)
    elif (type(name)==int) or (nj>1 and type(name[0])==int):  
        iname =  name    
    else:
        if nj==1:
           for i in range(ni):
               if names[i] == name:
                   iname.append(i)    
        elif nj>1 and type(name[0])==str:            
            for i in range(ni):
                for j in range(nj):
                    if names[i] == name[j]:
                        iname.append(i)
    return iname
    
    
    
### Reads data
def read(S,Sub,Seg,Time): 
    
   
    iSeg = indexseg(S,Seg)
    iSub = indexsub(S,Sub)
    fl   = open(S.FileName, 'rb')
    pos  = S.DataStart+S.NBytesBlock*Time
    fl.seek(pos)    
    t    = np.float(np.fromfile(fl, np.int32, 1));
    
    time = S.T0 + (t*S.TStep)
    dataBlock = np.fromfile(fl, np.float32, S.NumSegm*S.NumSubs)
    dataBlock = np.reshape(dataBlock, (S.NumSegm, S.NumSubs))
    dataBlock = np.transpose(dataBlock)
    data      = dataBlock[iSub,iSeg]
    data[data==-999] = np.NaN
    fl.close
    return time, data


### Reads data

def openlga(FileName):
    
    from corner2center import corner2center
    
    S = lgainfo(FileName)
    
    fl  = open(S.Filelga, 'rb')
    g_m   = np.fromfile(fl, np.int32, 1)
    g_n   = np.fromfile(fl, np.int32, 1)
    g_seg = np.fromfile(fl, np.int32, 1)
    g_k   = np.fromfile(fl, np.int32, 1)
    g_mm  = np.fromfile(fl, np.int32, 1)
    g_nn  = np.fromfile(fl, np.int32, 1)
    g_kk  = np.fromfile(fl, np.int32, 1)
    

    S.Index = np.fromfile(fl,np.int32,g_m*g_n)
    S.Index = np.reshape(S.Index, (g_n, g_m))
    S.Index = S.Index.astype(float)
    S.Index[S.Index<1] = np.NaN
    
    fl = open(S.Filecco, 'rb')
    mn = np.fromfile(fl,np.int32,2)
    xy = np.fromfile(fl, np.float32,2)
    xx = np.fromfile(fl, np.int32,3)
    np.fromfile(fl, np.int32,9)
   
    S.X = np.fromfile(fl, np.float32,mn[0]*mn[1])
    S.X  = np.reshape(S.X , (mn[0], mn[1]))
   
    S.Y = np.fromfile(fl, np.float32,mn[0]*mn[1])
    S.Y = np.reshape(S.Y, (mn[0], mn[1]))
    
    S.Y[S.Y==0] = np.NaN
    S.X[S.X==0] = np.NaN
    
    ### Basic information
    S.MNK            = [g_m[0], g_n[0], g_k[0]]
    S.NoSegPerLayer  = g_seg
    S.NoSeg          = g_seg*g_k
    S.xcen           = corner2center(S.X)
    S.ycen           = corner2center(S.Y)
    
    return S

def ingrid(dataIn,S):
    
    dataOut    = np.empty((len(S.X[:,1]) ,len(S.X[1,:])))
    dataOut[:] = np.NAN    
   
    for i in range(S.NoSeg):
       j = S.Index==i+1
       dataOut[j] = dataIn[i]
        
    return dataOut
    