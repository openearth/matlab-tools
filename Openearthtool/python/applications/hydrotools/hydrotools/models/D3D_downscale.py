# -*- coding: utf-8 -*-
"""
Created on Thu Oct 16 10:05:27 2014

@author: winsemi
"""
from osgeo import gdal, ogr
import os
import pdb
import numpy as np
from hydrotools.gis.gdal_readmap import gdal_readmap
from hydrotools.gis.gdal_writemap import gdal_writemap

def rasterize(mask_file, pol_file, attribute, out_file, out_type, out_format='GTiff'):
    """
    Rasterizes a polygon file using a mask. 
    Inputs:
        mask_file: path to raster mask (Geotiff)
        pol_file: path to polygon shapefile
        attribute: which attribute to rasterize
        out_file: path to output file
        out_type: datatype (e.g. Byte/Int16/UInt16/UInt32/Int32/Float32/Float64)
        out_format=GTiff: raster format (GDAL abbrevation) to use
    """
    
    command_template = 'gdal_rasterize -of {:s} -a {:s} -te {:f} {:f} {:f} {:f} ' + \
                '-tr {:f} {:f} -ot {:s} -a_nodata {:f} {:s} {:s}'

    mapFormat = gdal.GetDriverByName('GTiff')
    mapFormat.Register()
    ds = gdal.Open(mask_file)
    if ds is None:
        print('Could not open {:s} Shutting down').format(mask_file)
        sys.exit(1)
        # Retrieve geoTransform info
    geotrans = ds.GetGeoTransform()
    xmin = geotrans[0]
    ymax = geotrans[3]
    xres = geotrans[1]
    yres = geotrans[5]
    cols = ds.RasterXSize
    rows = ds.RasterYSize
    xmax = xmin+cols*xres
    ymin = ymax+rows*yres
    command = command_template.format(out_format, attribute, xmin, ymin, xmax,
                                      ymax, np.abs(xres), np.abs(yres),
                                      out_type, 2**32-1, pol_file, out_file)
    os.system(command)

def cut_area(src_arrays, xmin, xmax, ymin, ymax):
    """
    Function returns a limited array from src array along with the idx axes for y and x coordinates
    src_arrays: list of arrays from which to cut    
    centre: (y, x) coordinate of centre point
    window: size of window to use around the centre point
    
    """
    # now cut the array
    trg_arrays = []
    for src_array in src_arrays:
        trg_arrays.append(src_array[ymin:ymax, xmin:xmax])
    x_idx_cut = range(xmin, xmax)
    y_idx_cut = range(ymin, ymax)
    return trg_arrays, x_idx_cut, y_idx_cut

#dem_file = r'd:\FEWS\Curacao\python\hand_1000.tif'
#mesh_file = r'd:\FEWS\Curacao\python\shapefiles\flood_map.shp'
#attribute_id = 'ID'
#attribute_depth = 'VALUE'
#burn_file = r'd:\FEWS\Curacao\python\burn_IDs.tif'
#dem_normfile = r'd:\FEWS\Curacao\python\dem_norm.tif'
#flood_file = r'd:\FEWS\Curacao\python\flood_map.tif'
#error_thres = 0.001
#dem_at_miss = np.nan
#ignore_depth_max_thres = 10  # make any cells with a depth >= to this threshold equal to the value - threshold
#out_type = 'UInt32'
#
#
#ogr.UseExceptions()
#
#
## burn IDs of shapes to raster
#rasterize(dem_file, mesh_file, attribute_id, burn_file, out_type, out_format='GTiff')
##
## now load the DEM and the rasterized polygon file
#print('Reading {:s}').format(dem_file)
#x, y, dem, fill_dem = gdal_readmap(dem_file, 'GTiff')
#dem[dem==fill_dem] = dem_at_miss
#print('Reading {:s}').format(burn_file)
#x, y, burn, fill_burn = gdal_readmap(burn_file, 'GTiff')
##
### find maximum value in burn
##burn_max = burn.max()
##
#dem_norm = dem*0-9999.
#flood_map = dem*0-9999.
#shp = ogr.Open(mesh_file)
#lyr = shp.GetLayer()
### loop over all burn values, find the pixels and normalize elevation
##print('Normalizing elevation to lowest point in each unstruc cell...')
###for cell in range(0, burn_max):
#for n, feat in enumerate(lyr):
#    #if np.logical_and(n > 16000, n < 16100):
#    print('Feature {:d}').format(n)
#    geom = feat.GetGeometryRef()
#    # get the ID of the shape
#    cell = feat.GetField(attribute_id)
#    depth_cell = feat.GetField(attribute_depth)
#    xmin, xmax, ymin, ymax = geom.GetEnvelope()
##        xmin = min(min(pointsX), xmin)
##        xmax = max(max(pointsX), xmax)
##        ymin = min(min(pointsY), ymin)
##        ymax = max(max(pointsY), ymax)
#            
#        # Specify offset and rows and columns to limit search area
#    try:    
#        xidx_min = np.where(x < xmin)[0][-2]  # make window a little bit wider to make sure
#        xidx_max = np.where(x > xmax)[0][1]
#    
#        # the minimum y-coordinate is actually the maximum y-idx because GIS people turn around y-axes for some stupid reason!
#        yidx_max = np.where(y < ymin)[0][1]  # make window a little bit wider to make sure
#        yidx_min = np.where(y > ymax)[0][-2]
#    except:
#        print('Feature outside of elevation data')
#        # apparently the unstruc cell is outside the bounds of the elevation model, so continue with next cell
#        feat.Destroy()
#        continue
#    cut_arrays, xidx_cut, yidx_cut = cut_area([dem, burn], xidx_min,
#                                              xidx_max, yidx_min, yidx_max)
#    dem_cut = cut_arrays[0]
#    burn_cut = cut_arrays[1]
#    idx = np.where(burn_cut==cell)
#    if len(idx[0] > 0):
#        yidx = np.array(yidx_cut)[idx[0]]
#        xidx = np.array(xidx_cut)[idx[1]]
#        dem_norm[yidx, xidx] = dem[yidx, xidx] - dem[yidx, xidx].min()
#        # make a cdf of the elevation values
#        dem_vals = dem_norm[yidx, xidx]
#        dem_vals[np.isnan(dem_vals)] = 50
#        dem_vals.sort()
#        # initialize the minimum and maximum values
#        dem_min = dem_vals.min()
#        dem_max = 50  # bizarre high inundation depth of 50 meters
#        error_abs = 1e10
#        if depth_cell > 0:
#            # remove any ocean depth from the total depth
#            if depth_cell >= ignore_depth_max_thres:
#                depth_cell = np.max(depth_cell - ignore_depth_max_thres, 0)
#            while np.logical_and(error_abs > error_thres, dem_min < dem_max):
#                dem_av = (dem_min + dem_max)/2
#                # compute value at dem_av
#                average_depth_cell = np.mean(np.maximum(dem_av - dem_vals, 0))
#                error = (depth_cell-average_depth_cell)/depth_cell
#                # check if the error is positive (more water is needed) or negative (less water!)
#                if error > 0:
#                    dem_min = dem_av
#                else:
#                    dem_max = dem_av
#                error_abs = np.abs(error)
#                #print('Error = {:f}, min={:f}, max={:f}').format(error, dem_min, dem_max)
#                if dem_min == dem_max:
#                    print('convergence not reached in cell {:d}, probably a coastal cell!').format(cell)
#                    continue
#            flood_map[yidx, xidx] = np.maximum(dem_av - dem_norm[yidx, xidx], 0)
#            
#            
#        # now 
#    else:
#        print('Feature too small to cross any pixels')
#        # apparently the unstruc cell is outside the bounds of the elevation model, so continue with next cell
#    feat.Destroy()
#dem_norm[np.isnan(dem_norm)] = -9999.
#flood_map[flood_map==0] = -9999.
#gdal_writemap(dem_normfile, 'GTiff', x, y, dem_norm, -9999.)
#gdal_writemap(flood_file, 'GTiff', x, y, flood_map, -9999.)
#shp.Destroy()
##
##
###
# get geographical extent of raster