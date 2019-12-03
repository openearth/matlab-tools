#!/usr/bin/env python
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius

$Id: ogr_burn.py 12362 2015-11-16 15:34:47Z winsemi $
$Date: 2015-11-16 16:34:47 +0100 (Mon, 16 Nov 2015) $
$Author: winsemi $
$Revision: 12362 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/ogr_burn.py $
$Keywords: $

"""

import numpy as np
from osgeo import gdal, osr
from scipy.interpolate import griddata

def ogr_burn(lyr, clone, burn_value, file_out='',
              gdal_type=gdal.GDT_Byte, format='MEM', fill_value=255, attribute=None):
    """
    ogr_burn burns polygons, points or lines from a geographical source (e.g. shapefile) onto a raster.
    Inputs:
        lyr:                Shape layer (e.g. read from ogr object) to burn
        clone:              clone file to use to define geotransform
        burn_value:         burn value
        zlib=False:         Set to True (recommended) to internally zip the
                            data
        fill_value=255      Set the fill value
        gdal_type=
        gdal.GDT_Float32:   Set the GDAL output data type.
        format='MEM':       File format (if 'MEM' is used, data is only kept in memory)
        fill_value=255:     fill value to use
        attribute=None:     alternative to burn_value, if set to attribute name, this attribute is used for burning instead of burn_value
    Output:
        The function returns a GDAL-compatible file (default = in-memory) and the numpy array raster
        TO-DO add metadata and projection information to GeoTIFF
    """
    # get geotransform
    ds_src = gdal.Open(clone, gdal.GA_ReadOnly)
    geotrans = ds_src.GetGeoTransform()
    xcount = ds_src.RasterXSize
    ycount = ds_src.RasterYSize
    # get the projection
    WktString = ds_src.GetProjection()
    srs = osr.SpatialReference()
    srs.ImportFromWkt(WktString)
    ds_src = None

    ds = gdal.GetDriverByName(format).Create(file_out, xcount, ycount, 1, gdal_type)
    ds.SetGeoTransform(geotrans)
    ds.SetProjection(srs.ExportToWkt())
    # create for target raster the same projection as for the value raster
    raster_srs = osr.SpatialReference()
    #    raster_srs.ImportFromWkt(raster.GetProjectionRef())
    #    target_ds.SetProjection(raster_srs.ExportToWkt())

    # rasterize zone polygon to raster
    if attribute is None:
        gdal.RasterizeLayer(ds, [1], lyr, burn_values=[burn_value])
    else:
        gdal.RasterizeLayer(ds, [1], lyr, options=["ATTRIBUTE={:s}".format(attribute)])
    band = ds.GetRasterBand(1)

    band.SetNoDataValue(fill_value)
    band = None
    ds = None
