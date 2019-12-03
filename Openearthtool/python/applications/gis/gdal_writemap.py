#!/usr/bin/env python
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius
"""

import numpy as np
from osgeo import gdal
import os
import sys
import logging

def gdal_writemap(file_name, file_format, x, y, data, fill_val):
    """ Write geographical file from numpy array
    Dependencies are osgeo.gdal and numpy
    Input:
        file_name: -- string: reference path to GDAL-compatible file
        file_format: -- string: file format according to GDAL acronym
        (see http://www.gdal.org/formats_list.html)
        x: -- 1D np-array: x-axis
        y: -- 1D np-array: y-axis
        data: -- 2D np-array: raster data
        fill_val: -- float: fill value
    """

    gdal.AllRegister()
    driver1 = gdal.GetDriverByName('GTiff')
    driver2 = gdal.GetDriverByName(file_format)
    # Processing
    temp_file_name = str('{:s}.tif').format(file_name)
    logging.info(str('Writing to temporary file {:s}').format(temp_file_name))
    TempDataset = driver1.Create(temp_file_name, data.shape[1],
                                 data.shape[0], 1, gdal.GDT_Float32)
    # Give georeferences
    xul = x[0]-(x[1]-x[0])/2
    yul = y[0]+(y[0]-y[1])/2
    TempDataset.SetGeoTransform([xul, x[1]-x[0], 0, yul, 0, y[1]-y[0]])
    # get rasterband entry
    TempBand = TempDataset.GetRasterBand(1)
    # fill rasterband with array
    TempBand.WriteArray(data, 0, 0)
    TempBand.FlushCache()
    TempBand.SetNoDataValue(fill_val)
    # Create data to write to correct format (supported by 'CreateCopy')
    logging.info(str('Writing to {:s}').format(file_name))
    driver2.CreateCopy(file_name, TempDataset, 0)
    TempDataset = None
    os.remove(temp_file_name)

