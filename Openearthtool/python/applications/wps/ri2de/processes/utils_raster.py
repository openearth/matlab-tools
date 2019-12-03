# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/utils_raster.py $
# $Keywords: $

from processes.utils_wcs import *
from processes.utils_vector import *

import glob
from osgeo import osr
from osgeo import gdalconst
from scipy.misc import imresize # image resampling
import cv2 # dilate band

# Cut a raster layer
def cut_wcs(xst, yst, xend, yend, layername, owsurl, outfname, crs=4326, all_box=False):
	linestr = 'LINESTRING ({} {}, {} {})'.format(xst, yst, xend, yend)
	l = LS(linestr, crs, owsurl, layername)
	l.line()
	l.getraster(outfname, all_box=all_box)
	l = None
	print('Writing: {}'.format(outfname))

# Write array to grid file
def write_array_grid(RasterGrid, RasterName, array, nodataval=-9999., output_type=gdal.GDT_Byte):
	SourceRaster = gdal.Open(RasterGrid)
	GeoTrans = SourceRaster.GetGeoTransform()    
	projection = osr.SpatialReference()
	projection.ImportFromWkt(SourceRaster.GetProjectionRef())  	
	xsize=SourceRaster.RasterXSize 
	ysize=SourceRaster.RasterYSize	
	driver = gdal.GetDriverByName('GTiff')
	Raster = driver.Create(RasterName , xsize, ysize, 1, output_type, [ 'COMPRESS=LZW', 'TILED=YES' ])
	Raster.SetGeoTransform(GeoTrans)
	Raster.SetProjection(projection.ExportToWkt())	
	band = Raster.GetRasterBand(1)    
	band.WriteArray(array)
	band.SetNoDataValue(nodataval)  
	return RasterName

# Get finest resolution
def get_finest_resolution(calc):
	# Resample and calculate
	xsize = -1
	ysize = -1 
	rst = ''
	for fname,weight in calc.items():
		raster = gdal.Open(fname)
		xs = raster.RasterXSize 
		ys = raster.RasterYSize		
		if (xs*ys) > (xsize*ysize):
			xsize = xs
			ysize = ys		
			rst = fname
	return xsize, ysize, rst

# Calculate vulnerability
def vulnerability_calc(calc, outfname):
	# Get finest resolution
	N=0.0
	xsize, ysize, rastname = get_finest_resolution(calc)
	print('Final resolution: [{} x {}]'.format(xsize,ysize))
	print('Taken from: {}'.format(rastname))

	# Compute total weight
	total_weight = 0.0
	for fname,weight in calc.items():
		total_weight += float(weight)

	# Resample and calculate	
	for fname,weight in calc.items():
		# Read band as float
		raster = gdal.Open(fname)
		band = raster.GetRasterBand(1)
		imgdata = band.ReadAsArray().astype(float)
		rel_weight = float(float(weight)/total_weight)

		# Interpolate / Resize / Normalize
		resdata = rel_weight * (imresize(imgdata, (ysize, xsize))/255.0) # 0..1	* relative weight
		
		# Init / Accumulate
		if N==0:
			z = resdata
		else:
			z = z + resdata
		
		# Inc		
		N+=1

	# Average and write [to 123]
	z = z * 3.0 # 123 conversion (green-yellow-red)
	print('Final resolution: [{} x {}]'.format(z.shape[1], z.shape[0]))
	write_array_grid(rastname, outfname, z, nodataval=0, output_type=gdal.GDT_Float32)

# Calculate slope
def dem_to_slope(dem, outfname):
	# Generate slope map [from degrees / wgs84]
	os.system('gdaldem slope -s 111120 -compute_edges {} {}'.format(dem, outfname))
	print('Writing: {}'.format(outfname))

# Classify a integer map in classes 123
def classify_land_cover(arr, class1, class2, class3):
	# Classification
	z = np.empty(arr.shape) # init as zeroes
	z[np.where(np.isin(arr, class1))] = 1
	z[np.where(np.isin(arr, class2))] = 2
	z[np.where(np.isin(arr, class3))] = 3
	return z

# Classify raster [1,2,3] + 0 as nodata
def classify_raster(inputRaster, workdir, classes, typeLayer):
	# Read
	raster = gdal.Open(inputRaster, gdal.GA_ReadOnly)
	band = raster.GetRasterBand(1)
	array = band.ReadAsArray()    
	
	# Classify
	if typeLayer == '123':
		array = classify_array_123(array, classes)
	elif typeLayer == 'globcover':
		class1 = [20,30,50,70,110,120,170,220]
		class2 = [14,40,60,90,100,130,140,160,180]
		class3 = [11,150,190,200,210,230]		
		array = classify_land_cover(array, class1, class2, class3)
	elif typeLayer == 'corine':
		class1 = [23,24,25,26,27,28,29,30,31,32,33]
		class2 = [15,16,17,18,19,20,21,22]
		class3 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,34,35,36,37,38,39,40,41,42,43,44,48,49,50]		
		array = classify_land_cover(array, class1, class2, class3)
	elif typeLayer == 'culverts':		
		array = classify_array_123(array, [0, 0.99, 1.99])
	elif typeLayer == 'waterJRC':
		array = classifyDistanceByDilation(inputRaster, classes, 25) # JRC resolution
	
	# Write band
	outputRaster = os.path.join(workdir, 'classes.tif')
	write_array_grid(inputRaster, outputRaster, array, nodataval=-9999)
	print('Classify: {}'.format(outputRaster))

	return outputRaster
	
# Classify array [1,2,3]
def classify_array_123(arr, interval):
	interval = np.asarray(interval)
	z = np.empty(arr.shape) # init as zeroes
	z[(arr > interval[0])] = 1
	z[(arr > interval[1])] = 2
	z[(arr > interval[2])] = 3
	return z

# Burn a binary mask from a shapefile [return tif or band]
def burn_mask(height, width, shpfname, tifname, read=False):
	# Rasterize 1/0
	print('Writing: {}'.format(tifname))
	cmd = '''gdal_rasterize -co "COMPRESS=LZW" -co "TILED=YES" -burn 1 -ts {w} {h} {shp} {tif}'''.format(
		h=height, w=width, shp=shpfname, tif=tifname)	
	os.system(cmd)	

	# Sometimes we need the array, that's life
	if read:
		raster = gdal.Open(tifname, gdal.GA_ReadOnly)
		band = raster.GetRasterBand(1)
		return band.ReadAsArray() 	

# Rasterize a vector file [1/0]
def rasterize(rasterin, vectorin, rasterout, read=False):
	# Read geometry from given raster
	data = gdal.Open(rasterin, gdalconst.GA_ReadOnly)
	geo_transform = data.GetGeoTransform()	
	x_min = geo_transform[0]
	y_max = geo_transform[3]
	x_max = x_min + geo_transform[1] * data.RasterXSize
	y_min = y_max + geo_transform[5] * data.RasterYSize
	x_res = data.RasterXSize
	y_res = data.RasterYSize
	pixel_width = geo_transform[1]  

	# Read features and rasterize to output
	mb_v = ogr.Open(vectorin)
	mb_l = mb_v.GetLayer()  
	target_ds = gdal.GetDriverByName('GTiff').Create(rasterout, x_res, y_res, 1, gdal.GDT_Byte, [ 'COMPRESS=LZW', 'TILED=YES' ])
	target_ds.SetGeoTransform(geo_transform)
	band = target_ds.GetRasterBand(1)
	NoData_value = -999999
	band.SetNoDataValue(NoData_value)
	band.FlushCache()
	
	print('Writing: {}'.format(rasterout))
	gdal.RasterizeLayer(target_ds, [1], mb_l, burn_values=[1])	

	# Return band if necessary	
	if read:
		return band.ReadAsArray() 
	# Free
	target_ds = None

# Apply a road mask [buffer around roads] to a given raster
def apply_road_mask(cf, rasterfname, shpfname, workdir):

	# Read band
	print('Masking: {}'.format(rasterfname))
	raster = gdal.Open(rasterfname, gdal.GA_Update)
	band = raster.GetRasterBand(1)
	array = band.ReadAsArray() 
	shape = array.shape
	
	# Burn mask
	burn_mask(shape[0], shape[1], shpfname, os.path.join(workdir, 'roads.tif'))

	# Apply mask and update raster
	rasterm = gdal.Open(os.path.join(workdir, 'roads.tif'))
	bandm = rasterm.GetRasterBand(1)
	mask = bandm.ReadAsArray().astype(float)
	array = array * mask
	band.SetNoDataValue(0)
	band.WriteArray(array)

# Dilate function for 
# Ex: JRC raster is 25m resolution approx
def dilate_band(array, meters, resolution=25):
	# Establish how many pixels we will dilate
	degs = int(meters/resolution) 
	
	# Dilate band
	kernel = np.ones((degs,degs),np.uint8)
	res = cv2.dilate(array, kernel, iterations = 5)	
	return res

# Classify raster by dilation image techniques
def classifyDistanceByDilation(inputRaster, classes, resolution):
	# Read band
	raster = gdal.Open(inputRaster, gdal.GA_ReadOnly)
	band = raster.GetRasterBand(1)
	array = band.ReadAsArray() 	
	
	# Dilate bands [red and yellow]
	bred = dilate_band(array, classes[1], resolution)
	byellow = dilate_band(array, classes[2], resolution)
	res = bred + byellow + 1 # classify 1,2,3
	
	return res

# Combine two shapefiles into a raster 123
def combine_culverts(workdir, roadsShp, culvertsShpRed, culvertsShpYell, height, width, outputRaster):
	# Burn roads
	roadsTif = os.path.join(workdir, 'roads.tif')
	broads = burn_mask(height, width, roadsShp, roadsTif, read=True)

	# Get bands for the two distances
	culvertsTifRed = culvertsShpRed.replace('.shp', '.tif')
	culvertsTifYell = culvertsShpYell.replace('.shp', '.tif')
	bred = rasterize(roadsTif, culvertsShpRed, culvertsTifRed, read=True)
	byellow = rasterize(roadsTif, culvertsShpYell, culvertsTifYell, read=True)
	
	# classify 1,2,3 = Green is safe and apply mask
	res = (bred + byellow + broads) * broads
	
	# Write output	
	print('Writing: {}'.format(outputRaster))
	write_array_grid(roadsTif, outputRaster, res, nodataval=0) #transparent

def mean_soil_layers(workdir, prefix):
	res = []
	# All soil layers
	for rn in glob.glob(os.path.join(workdir, '{}*tif'.format(prefix))):
		raster = gdal.Open(rn, gdal.GA_ReadOnly)
		band = raster.GetRasterBand(1)
		res.append(band.ReadAsArray().tolist())
	# Mean
	return np.mean(np.array(res), axis=0), rn

# Combine 7 layers of 3 different soil information maps into a vulnerability map
def combine_soil_layers(workdir, soilfname):
	# Calculate layers mean
	clay, clf = mean_soil_layers(workdir, 'CLYPPT')
	silt, slf = mean_soil_layers(workdir, 'SLTPPT')
	sand, snf = mean_soil_layers(workdir, 'SNDPPT')

	# Get maximums [of the means]
	truth = np.maximum(np.maximum(clay, silt), sand)

	# Create an array with 1 for sand, 2 for silt, 3 clay
	res = np.where(truth == clay, 3, truth)
	res = np.where(truth == silt, 2, res)
	res = np.where(truth == sand, 1, res)
	res = np.where(truth == 255, 0, res)
	
	return write_array_grid(clf, soilfname, res, nodataval=0)
