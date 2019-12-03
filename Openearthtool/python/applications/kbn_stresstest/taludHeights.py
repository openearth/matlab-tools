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


def getTaludHeight(taludfname, demfname, outhname, nodata=0):
    # Get flat pixels != 1 [classes 2 and 3] - Create binary mask
    r = gdal.Open(taludfname)
    b = r.GetRasterBand(1)
    arrTalud = b.ReadAsArray()
    noDataInd=np.where(arrTalud == nodata)
    flatInd=np.where(arrTalud == 1)
    slopeInd=np.where(arrTalud > 1)

    # Multiply mask by the height
    r = gdal.Open(demfname)
    b = r.GetRasterBand(1)
    arrHeight = b.ReadAsArray()
    flatmeanheight = np.mean(arrHeight[flatInd])
    print('Mean height [flat] = {}'.format(flatmeanheight))

    # Height of the talud [height - meanheight of the flat area]
    heightTalud = arrHeight
    heightTalud[noDataInd] = 0
    heightTalud[flatInd] = 0
    heightTalud[slopeInd] = arrHeight[slopeInd] - flatmeanheight
    arr = classifyArrayThr(heightTalud, 2)
    arr[flatInd] = 1
    arr[noDataInd] = 0
    print(outhname)
    writeArrayGrid(demfname, outhname, arr, nodataval=nodata)

# In/out
bufDir = r'D:\data\geotiff_buffered'
outDir = r'C:\Users\wcp_w1903446\Desktop\roads_NL_talud_height'

# Loop over tiff tiles
for filename in glob.iglob('{src}/*talud.tif'.format(src=bufDir), recursive=True):   
    taludfname = os.path.join(bufDir, basename(filename))
    demfname = os.path.join(bufDir, basename(filename.replace('_talud', '')))
    outhname = os.path.join(outDir, basename(filename.replace('_talud', '_height')))
    
    if not os.path.exists(outhname):
        getTaludHeight(taludfname, demfname, outhname)