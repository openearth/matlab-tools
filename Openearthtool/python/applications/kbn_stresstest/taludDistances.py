# -*- coding: utf-8 -*-
"""
Created on Thu Apr 11 08:06:37 2019

@author: wcp_W1903446
"""

import os
from osgeo import gdal
from osgeo import osr
import numpy as np
from rasterutils import *


def getTaludDistance(taludfname, demfname, outfname, nodata=0):
    
    # Read corners of geotiff [dem square]
    r = gdal.Open(demfname)
    gt = r.GetGeoTransform()   
    px = r.RasterXSize
    py = r.RasterYSize
    x0 = gt[0]
    y1 = gt[3]
    x1 = gt[0]+(px*gt[1])+(py*gt[2])
    y0 = gt[3]+(px*gt[4])+(py*gt[5])

    # Rasterize road layer
    roadsMaskTif = demfname.replace('.tif', '_roads.tif')
    cmd = '''gdal_rasterize -burn 1 -a_nodata 0.0 -tr {res} {res} -te {xmin} {ymin} {xmax} {ymax} -of GTiff -co COMPRESS=LZW -co TILED=YES -l {l} PG:\"host={h} dbname={d} user={u} password={p}\" \"{o}\"'''.format(
        res=gt[1], l='wegverharding', xmin=x0, ymin=y0, xmax=x1, ymax=y1, h='al-pg010.xtr.deltares.nl', u='admin', p='&Ez3)r5{Gc', d='hobbelkaart', o=roadsMaskTif)        
    #print (cmd)    
    os.system(cmd)    
    
    # Run proximity algorithm
    roadsDistTiff = demfname.replace('.tif', '_roads_dist.tif')
    cmd = '''python C:\\ProgramData\\Anaconda3\\Scripts\\gdal_proximity.py -co COMPRESS=LZW -co TILED=YES {i} {o}'''.format(
        i=roadsMaskTif, o=roadsDistTiff)
    #print (cmd)    
    os.system(cmd)

    # Read Talud presence
    r1 = gdal.Open(taludfname)
    b1 = r1.GetRasterBand(1)
    arrTalud = b1.ReadAsArray()
    nodataInd = np.where(arrTalud == 0)
    slopeInd = np.where(arrTalud > 1)
    flatInd = np.where(arrTalud == 1)

    # Read distance
    r2 = gdal.Open(roadsDistTiff)
    b2 = r2.GetRasterBand(1)
    arrDistance = b2.ReadAsArray() # buffered dist

    # Classify distance
    arr = classifyArray32(arrDistance, [10, 4])
    arr[nodataInd] = 0
    arr[flatInd] = 1
    writeArrayGrid(demfname, outfname, arr, nodataval=0)   

    # Save space
    del r2
    del b2
    os.unlink(roadsDistTiff) 

# In/out
bufDir = r'D:\data\geotiff_buffered'
outDir = r'C:\Users\wcp_w1903446\Desktop\roads_NL_talud_dist'

# Loop over tiff tiles
for filename in glob.iglob('{src}/*talud.tif'.format(src=bufDir), recursive=True):   
    taludfname = os.path.join(bufDir, basename(filename))
    demfname = os.path.join(bufDir, basename(filename.replace('_talud', '')))
    outfname = os.path.join(outDir, basename(filename.replace('_talud', '_dist')))

    if not os.path.exists(outfname):
        print(outfname)
        getTaludDistance(taludfname, demfname, outfname)