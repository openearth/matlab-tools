# -*- coding: utf-8 -*-
"""
Created on Thu Apr 11 08:06:37 2019

@author: wcp_W1903446
"""

from os import makedirs
from os.path import basename, join
import zipfile
import os
import subprocess
import glob
from osgeo import gdal
from osgeo import osr
import numpy as np
from rasterutils import *

downloaddir = r'/mnt/d/RoadsNL/download'
tifdir = r'/mnt/d/RoadsNL/geotiff'
buftifdr = r'/mnt/d/RoadsNL/geotiff_buffered'
bufshp = r'/mnt/d/RoadsNL/shapes/major_roads_buffer_wegvakken_stresstest2018.shp'

def findTaluds(demfname):    
    slopefname = demfname.replace('.tif', '_slope.tif')
    taludfname = demfname.replace('.tif', '_talud.tif')

    # Generate slope
    #gdal.DEMProcessing(slopefname, demfname, 'slope', ['TILED=YES', 'COMPRESS=LZW'])
    cmd = 'gdaldem slope {} {} -co TILED=YES -co COMPRESS=LZW -alg ZevenbergenThorne'.format(demfname, slopefname)
    print(cmd)
    os.system(cmd)
    raster = gdal.Open(slopefname)
    band = raster.GetRasterBand(1)
    nodata = band.GetNoDataValue()
    arrSlope = band.ReadAsArray()

    # Identify taluds
    arr = classifyArray123(arrSlope, [0,5,20,40])
    writeArrayGrid(demfname, taludfname, arr, nodataval=0)

    # Cleanup
    raster = None
    band = None

def masktif(ZIP_FNAME, TIFDIR, BUFTIFDR, BUFSHP):
    print(' '.join(['extracting',ZIP_FNAME]))
    zip_ref = zipfile.ZipFile(ZIP_FNAME, 'r')
    zip_ref.extractall(TIFDIR)
    zip_ref.close()    
    # get extent of the gtiff and use to set -te xmin ymin xmax ymax:
    af = os.path.join(TIFDIR,basename(ZIP_FNAME).replace('.zip',''))
    tf = os.path.join(BUFTIFDR,basename(ZIP_FNAME).replace('.zip',''))
    
    print('------------------------------------')
    print(' '.join(['clipping',tf])) 
    cmd = '''gdalwarp -overwrite --config GDAL_CACHEMAX 4096 -wm 4096 -co COMPRESS=LZW -co TILED=YES -dstnodata -9999 -cutline \"{s}\" \"{i}\" \"{o}\"'''.format(
        s=BUFSHP, i=af, o=tf)        
    os.system(cmd)
    
    # Truncate file for space purposes
    fo = open(af, "w")
    fo.truncate()
    fo.close()
    
    return tf

# Loop over tiff tiles
for filename in os.listdir(downloaddir):      
    demclipped = os.path.join(buftifdr, basename(filename).replace('.tif.zip','') + '.tif')
    taludclipped = os.path.join(buftifdr, basename(filename).replace('.tif.zip','') + '_talud.tif')
    
    # skip if not needed
    if not(os.path.exists(taludclipped)):
        if not(os.path.exists(demclipped)) or os.stat(demclipped).st_size == 0:
            print demclipped
            #demclipped = masktif(os.path.join(downloaddir, filename), tifdir, buftifdr, bufshp)  
        else:
            findTaluds(demclipped)
    else:
        print('Skipping {}'.format(taludclipped))
    