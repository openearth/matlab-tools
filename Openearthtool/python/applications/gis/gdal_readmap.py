#!/usr/bin/env python
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius
"""

import numpy as np
from osgeo import gdal
import sys
import logging


def gdal_readmap(file_name, file_format):
    """ Read geographical file into memory
    Dependencies are osgeo.gdal and numpy
    Input:
        file_name: -- string: reference path to GDAL-compatible file
        file_format: -- string: file format according to GDAL acronym
        (see http://www.gdal.org/formats_list.html)
    Output:
        x: -- 1D np-array: x-axis
        y: -- 1D np-array: y-axis
        data:           -- 2D np-array: raster data
        fill_val         -- float:       fill value
    """
    # Open file for binary-reading
    mapFormat = gdal.GetDriverByName(file_format)
    mapFormat.Register()
    ds = gdal.Open(file_name)
    if ds is None:
        logging.warning('Could not open {:s} Shutting down').format(file_name)
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
    return x, y, data, fill_val
