#!/usr/bin/env python
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius

$Id: gdal_grid.py 12023 2015-06-22 07:25:07Z winsemi $
$Date: 2015-06-22 09:25:07 +0200 (Mon, 22 Jun 2015) $
$Author: winsemi $
$Revision: 12023 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/gdal_grid.py $
$Keywords: $

"""

import numpy as np
from osgeo import gdal
from scipy.interpolate import griddata

def gdal_grid(filename, points, values, mesh_axes, method='linear',
              chunksizes=(0, 0), chunk_overlap=(0, 0), zlib=False,
              fill_value=-9999, gdal_type=gdal.GDT_Float32):
    """
    gdal_grid interpolates irregularly spaced samples to a surface grid
    This function can be applied on very large grids, as it allows a user to 
    perform the interpolation across chunks, and it directly writes
    results to a GeoTIFF rather than keeping all data in memory
    Inputs:
        filename:           path to GeoTIFF file (output of this function)
        points:             tuple (y, x) with lists of #n x and y data point
                            locations
        values:             data values (#n) in point locations
        mesh_axes:          tuple of 2 axes (y, x)
        method='linear':    interpolation method used (see
                            scipy.interpolate.griddata for options)
        chunksizes=(0, 0):   tuple giving size (x, y) of of chunk sizes.
                            If set at (0, 0), No chuncking is used
        chunk_overlap(0, 0):To ensure a smooth surface, some overlap is often
                            required while chunking. Use this variable to
                            control the amount (x, y) of cells used as overlap
        zlib=False:         Set to True (recommended) to internally zip the
                            data
        fill_value=-9999    Set the fill value
        gdal_type=
        gdal.GDT_Float32:   Set the GDAL output data type.
    Output:
        The function only returns a GeoTIFF file as output.
        TO-DO add metadata and projection information to GeoTIFF
    """
    yax = mesh_axes[0]
    xax = mesh_axes[1]
    # make sure yaxis is decreasing as this is the common way in GIS (for some
    # nOOb reason....uuuuuggghhhh)
    if yax[1] > yax[0]:
        yax = np.flipud(yax)
    if chunksizes[0] == 0:
        yBlockSize = len(yax)
    else:
        yBlockSize = chunksizes[0]
    if chunksizes[1] == 0:
        xBlockSize = len(xax)
    else:
        xBlockSize = chunksizes[1]
    rows = len(yax)
    cols = len(xax)
    y_overlap = chunk_overlap[0]
    x_overlap = chunk_overlap[1]
    if method == 'nearest':
        minimum_values = 1  # for nearest, at least 4 points are needed
    elif method == 'linear':
        minimum_values = 4  # for bilinear, at least 4 points are needed
    else:
        minimum_values = 4

    # set up the GTiff file
    gdal.AllRegister()
    driver = gdal.GetDriverByName('GTiff')
    # Processing
    if zlib:
        Dataset = driver.Create(filename, len(xax),
                                len(yax), 1, gdal_type,
                                ['COMPRESS=DEFLATE'])
    else:
        Dataset = driver.Create(filename, len(xax), len(yax), 1, gdal_type)
    # Give georeferences
    xul = xax[0]-(xax[1]-xax[0])/2
    yul = yax[0]+(yax[0]-yax[1])/2
    Dataset.SetGeoTransform([xul, xax[1]-xax[0], 0, yul, 0, yax[1]-yax[0]])
    # get rasterband entry
    Band = Dataset.GetRasterBand(1)
    # fill rasterband with array
    for i in range(0, rows, yBlockSize):
        if i + yBlockSize < rows:
            numRows = yBlockSize
        else:
            numRows = rows - i
            if numRows % 2 == 1:
                # round to a even number
                numRows -= 1
        i2 = i + numRows
        i_overlap = np.maximum(i - y_overlap, 0)
        i2_overlap = np.minimum(i2 + y_overlap, len(yax))
        for j in range(0, cols, xBlockSize):
            if j + xBlockSize < cols:
                numCols = xBlockSize
            else:
                numCols = cols - j
                if numCols % 2 == 1:
                    # round to a even number
                    numCols -= 1
            j2 = j + numCols
            j_overlap = np.maximum(j - x_overlap, 0)
            j2_overlap = np.minimum(j2 + x_overlap, len(xax))
            print('Interpolating data-block y: {:g} -- {:g}; x: {:g} -- {:g}').format(i, i2, j, j2)
            # select points
            array_test = np.vstack((points[:, 0] > xax[j_overlap],
                                    points[:, 0] < xax[j2_overlap-1],
                                    points[:, 1] < yax[i_overlap],
                                    points[:, 1] > yax[i2_overlap-1]))
            select = np.where(np.all(array_test, axis=0))
            if len(select[0]) >= minimum_values:
                points_select = points[select]
                values_select = values[select]
                grid_x, grid_y = np.meshgrid(xax[j:j2], yax[i:i2])
                try:
                    grid_z0 = griddata(points_select,
                                       values_select,
                                       (grid_x, grid_y),
                                       method=method)
                    grid_z0[np.isnan(grid_z0)] = fill_value
                except:
                    print('WARNING: Points not adequately sampling the chunk size.')
                    grid_z0 = np.ones((i2-i, j2-j))*fill_value
                        
            else:
                # no data points in grid selection found, return missings
                grid_z0 = np.ones((i2-i, j2-j))*fill_value
            # write to file
            Band.WriteArray(grid_z0, j, i)

    Band.FlushCache()
    Band.SetNoDataValue(fill_value)
    Dataset = None
   