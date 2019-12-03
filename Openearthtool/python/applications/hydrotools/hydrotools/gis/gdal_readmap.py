#!/usr/bin/env python
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius

$Id: gdal_readmap.py 12904 2016-10-03 07:42:09Z winsemi $
$Date: 2016-10-03 00:42:09 -0700 (Mon, 03 Oct 2016) $
$Author: winsemi $
$Revision: 12904 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/gdal_readmap.py $
$Keywords: $

"""

import numpy as np
from osgeo import gdal
import sys
import logging


def gdal_readmap(file_name, file_format, give_geotrans=False):
    """ Read geographical file into memory
    Dependencies are osgeo.gdal and numpy
    Input:
        file_name: -- string: reference path to GDAL-compatible file
        file_format: -- string: file format according to GDAL acronym
        (see http://www.gdal.org/formats_list.html)
        give_geotrans (default=False): -- return the geotrans and amount of 
            cols/rows instead of x, y axis
    Output (if give_geotrans=False):
        x: -- 1D np-array: x-axis
        y: -- 1D np-array: y-axis
        data:           -- 2D np-array: raster data
        fill_val         -- float:       fill value
    Output (if give_geotrans=True):
        geotrans: -- 6-digit list with GDAL geotrans vector
        size: -- 2-digit tuple with (cols, rows)
        data:           -- 2D np-array: raster data
        fill_val         -- float:       fill value
    """
    # Open file for binary-reading
    mapFormat = gdal.GetDriverByName(file_format)
    mapFormat.Register()
    ds = gdal.Open(file_name)
    if ds is None:
        logging.warning('Could not open {:s} Shutting down'.format(file_name))
        sys.exit(1)
        # Retrieve geoTransform info
    geotrans = ds.GetGeoTransform()
    originX = geotrans[0]
    originY = geotrans[3]
    resX = geotrans[1]
    resY = geotrans[5]
    cols = ds.RasterXSize
    rows = ds.RasterYSize
    x = np.linspace(originX+resX/2, originX+resX/2+resX*(cols-1), cols)
    y = np.linspace(originY+resY/2, originY+resY/2+resY*(rows-1), rows)
    # Retrieve raster
    RasterBand = ds.GetRasterBand(1)   # there's only 1 band, starting from 1
    data = RasterBand.ReadAsArray(0, 0, cols, rows)
    fill_val = RasterBand.GetNoDataValue()
    RasterBand = None
    ds = None
    if give_geotrans==True:
        return geotrans, (ds.RasterXSize, ds.RasterYSize), data, fill_val
        
    else:
        return x, y, data, fill_val
