# -*- coding: utf-8 -*-
"""
Created on Tue Nov 10 14:46:12 2015

@author: eilan_dk
"""
import numpy as np
from osgeo import gdal

def MapToPixel(mx,my,gt):
    ''' Convert map to pixel coordinates
        @param  mx:    Input map x coordinate (double)
        @param  my:    Input map y coordinate (double)
        @param  gt:    Input geotransform (six doubles)
        @return: px,py Output coordinates (two ints)

        @change: changed int(p[x,y]+0.5) to int(p[x,y]) as per http://lists.osgeo.org/pipermail/gdal-dev/2010-June/024956.html
        @change: return floats
        @note:   0,0 is UL corner of UL pixel, 0.5,0.5 is centre of UL pixel
    '''
    if gt[2]+gt[4]==0: #Simple calc, no inversion required
        px = (mx - gt[0]) / gt[1]
        py = (my - gt[3]) / gt[5]
    else:
        px,py=ApplyGeoTransform(mx,my,InvGeoTransform(gt))
    #return int(px),int(py)
    return px,py

def PixelToMap(px,py,gt):
    ''' Convert pixel to map coordinates
        @param  px:    Input pixel x coordinate (double)
        @param  py:    Input pixel y coordinate (double)
        @param  gt:    Input geotransform (six doubles)
        @return: mx,my Output coordinates (two doubles)

        @note:   0,0 is UL corner of UL pixel, 0.5,0.5 is centre of UL pixel
    '''
    mx,my=ApplyGeoTransform(px,py,gt)
    return mx,my

def InvGeoTransform(gt_in):
    # Compute determinate
    det = gt_in[1] * gt_in[5] - gt_in[2] * gt_in[4]

    if( abs(det) < 0.000000000000001 ):
        return

    inv_det = 1.0 / det

    # compute adjoint, and divide by determinate
    gt_out = [0,0,0,0,0,0]
    gt_out[1] =  gt_in[5] * inv_det
    gt_out[4] = -gt_in[4] * inv_det

    gt_out[2] = -gt_in[2] * inv_det
    gt_out[5] =  gt_in[1] * inv_det

    gt_out[0] = ( gt_in[2] * gt_in[3] - gt_in[0] * gt_in[5]) * inv_det
    gt_out[3] = (-gt_in[1] * gt_in[3] + gt_in[0] * gt_in[4]) * inv_det

    return gt_out

def ApplyGeoTransform(inx,iny,gt):
    ''' Apply a geotransform
        @param  inx:       Input x coordinate (double)
        @param  iny:       Input y coordinate (double)
        @param  gt:        Input geotransform (six doubles)

        @return: outx,outy Output coordinates (two doubles)
    '''
    outx = gt[0] + inx*gt[1] + iny*gt[2]
    outy = gt[3] + inx*gt[4] + iny*gt[5]
    return (outx,outy)

def GetExtent(raster_file):
    ''' Return list of corner coordinates from a geotransform

        @type gt:   C{tuple/list}
        @param gt: geotransform
        @type cols:   C{int}
        @param cols: number of columns in the dataset
        @type rows:   C{int}
        @param rows: number of rows in the dataset
        @rtype:    C{[float,...,float]}
        @return:   coordinates of each corner
    '''
    ds=gdal.Open(raster_file)
    if ds == None:
        print "invallid file name or file "
    else:
        gt=ds.GetGeoTransform()
        cols = ds.RasterXSize
        rows = ds.RasterYSize

        ext=[]
        xarr=[0,cols]
        yarr=[0,rows]

        for px in xarr:
            for py in yarr:
                x=gt[0]+(px*gt[1])+(py*gt[2])
                y=gt[3]+(px*gt[4])+(py*gt[5])
                ext.append([x,y])
            yarr.reverse()

        return ext


def gdal_sample_points(lat, lon, raster_file, win_size=1, func=None):
    src_ds = gdal.Open(raster_file)
    if src_ds is None:
        print "invallid file name or file "
    else:
        gt = src_ds.GetGeoTransform()
        rb = src_ds.GetRasterBand(1)
        cols = src_ds.RasterXSize
        rows = src_ds.RasterYSize
        values = np.array([])
        if isinstance(lat, np.ndarray):
            lat = lat.tolist()
            lon = lon.tolist()
        if (np.size(lat) == 1) & (not isinstance(lat, list)):
            lon = [lon]
            lat = [lat]
        for my, mx in zip(lat, lon):

            # Convert from map to pixel coordinates.
            px, py = MapToPixel(mx, my, gt)
            if (px >= 0) & (px <= cols) & (py >= 0) & (py <= rows):  # check if within map extent
                if win_size > 1:
                    # limit window to raster extent
                    xoff = max(int(px - win_size / 2.), 0)
                    yoff = max(int(py - win_size / 2.), 0)
                    win_xsize = min(cols - xoff, win_size) + min(int(px - win_size / 2.), 0)
                    win_ysize = min(rows - yoff, win_size) + min(int(py - win_size / 2.), 0)
                    intval = rb.ReadAsArray(xoff, yoff, win_xsize, win_ysize)
                    if intval is None:
                        intval = [np.nan]
                else:
                    intval = rb.ReadAsArray(int(px), int(py), win_size, win_size)
                if func != None:
                    values = np.append(values, func(intval))
                else:
                    values = np.append(values, intval)
            else:
                values = np.append(values, np.nan)
        src_ds = None # close file
        return values
