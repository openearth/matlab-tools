#!/usr/bin/env python
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius

$Id: gdal_warp.py 12467 2015-12-23 09:52:58Z winsemi $
$Date: 2015-12-23 10:52:58 +0100 (Wed, 23 Dec 2015) $
$Author: winsemi $
$Revision: 12467 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/gdal_warp.py $
$Keywords: $

"""

import numpy as np
from osgeo import gdal, gdalconst, osr
from scipy.interpolate import griddata
import pdb

def gdal_warp(src_filename, clone_filename, dst_filename, gdal_type=gdalconst.GDT_Float32,
              gdal_interp=gdalconst.GRA_Bilinear, format='GTiff', ds_in=None, override_src_proj=None):
    """
    Equivalent of the gdalwarp executable, commonly used on command line.
    The function prepares from a source file, a new file, that has the same 
    extent and projection as a clone file.
    The clone file should contain the correct projection. 
    The same projection will then be produced for the target file.
    If the clone does not have a projection, EPSG:4326 (i.e. WGS 1984 lat-lon)
    will be assumed.

    :param src_filename: string - file with data that will be warped
    :param clone_filename: string - containing clone file (with projection information)
    :param dst_filename: string - destination file (will have the same extent/projection as clone)
    :param gdal_type: - data type to use for output file (default=gdalconst.GDT_Float32)
    :param gdal_interp: - interpolation type used (default=gdalconst.GRA_Bilinear)
    :param format: - GDAL data format to return (default='GTiff')
    :return: No parameters returned, instead a file is prepared
    """
    if ds_in is None:
        src = gdal.Open(src_filename, gdalconst.GA_ReadOnly)
    else:
        src = ds_in
    src_proj = src.GetProjection()
    if override_src_proj is not None:
        srs = osr.SpatialReference()
        srs.ImportFromEPSG(override_src_proj)
        src_proj = srs.ExportToWkt()        
    src_nodata = src.GetRasterBand(1).GetNoDataValue()
    # replace nodata value temporarily for some other value
    src.GetRasterBand(1).SetNoDataValue(np.nan)
    # We want a section of source that matches this:
    clone_ds = gdal.Open(clone_filename, gdalconst.GA_ReadOnly)
    clone_proj = clone_ds.GetProjection()
    if not clone_proj:
        # assume a WGS 1984 projection
        srs = osr.SpatialReference()
        srs.ImportFromEPSG(4326)
        clone_proj = srs.ExportToWkt()
    clone_geotrans = clone_ds.GetGeoTransform()
    wide = clone_ds.RasterXSize
    high = clone_ds.RasterYSize
    # Output / destination
    dst_mem = gdal.GetDriverByName('MEM').Create('', wide, high, 1, gdal_type)
    dst_mem.SetGeoTransform(clone_geotrans)
    dst_mem.SetProjection(clone_proj)
    if not(src_nodata is None):
        dst_mem.GetRasterBand(1).SetNoDataValue(src_nodata)


    # Do the work, UUUUUUGGGGGHHHH: first make a nearest neighbour interpolation with the nodata values
    # as actual values and determine which indexes have nodata values. This is needed because there is a bug in
    # gdal.ReprojectImage, nodata values are not included and instead replaced by zeros! This is not ideal and if
    # a better solution comes up, it should be replaced.

    gdal.ReprojectImage(src, dst_mem, src_proj, clone_proj, gdalconst.GRA_NearestNeighbour)
    data = dst_mem.GetRasterBand(1).ReadAsArray(0, 0)
    idx = np.where(data==src_nodata)
    # now remove the dataset
    del data

    # now do the real transformation and replace the values that are covered by NaNs by the missing value
    if not(src_nodata is None):
        src.GetRasterBand(1).SetNoDataValue(src_nodata)

    gdal.ReprojectImage(src, dst_mem, src_proj, clone_proj, gdal_interp)
    data = dst_mem.GetRasterBand(1).ReadAsArray(0, 0)
    data[idx] = src_nodata
    dst_mem.GetRasterBand(1).WriteArray(data, 0, 0)

    if format=='MEM':
        return dst_mem
    else:
        # retrieve numpy array of interpolated values
        # write to final file in the chosen file format
        gdal.GetDriverByName(format).CreateCopy(dst_filename, dst_mem, 0)
