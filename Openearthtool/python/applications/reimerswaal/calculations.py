import os
import random
import time
import json
import affine
import numpy as np
from osgeo import gdal
from utils_geoserver import *

def runScenario(data, conf):
	# General setup
	res = data['resolution']
	tif_dir = conf['DATA_RESAMP_DIR']
	wkspace_data = conf['WORKSPACE_DATA']
	wkspace_temp = conf['WORKSPACE_TEMP']

	# For every scenario [read data]
	arrmax = []
	cols = 0
	rows = 0	
	srcds = None
	for s in data['scenarios']:				
		try:
			fname = '{}_{}m.tif'.format(s.lower(), res)
			ds = gdal.Open(os.path.join(tif_dir, fname))
			arr = np.array(ds.GetRasterBand(1).ReadAsArray())
			if arrmax == []:
				arrmax = arr
				srcds = ds		
				[cols, rows] = arr.shape
			else:
				arrmax = np.maximum(arrmax, arr)
		except:
			return { 'err' : 'Tiff does not exist {}'.format(fname) }

	# Get temp file
	layname = str(time.time()).replace('.','')
	tmptif = os.path.join(conf['TEMP_DIR'], layname+'.tif')
	
	# Write tiff	
	driver = gdal.GetDriverByName("GTiff")
	outdata = driver.Create(tmptif, rows, cols, 1, gdal.GDT_Float32)
	outdata.SetGeoTransform(srcds.GetGeoTransform())
	outdata.SetProjection(srcds.GetProjection())
	outdata.GetRasterBand(1).WriteArray(arrmax)
	outdata.GetRasterBand(1).SetNoDataValue(srcds.GetRasterBand(1).GetNoDataValue())
	outdata.FlushCache()
	
	# Upload to GeoServer
	geo=utilsGeoserver(conf)
	geo.geoserverUploadGtif(tmptif, wkspace_temp)

	return '{}:{}'.format(wkspace_temp, layname)

def runSelection(data, conf):
	# I/O
	result = {}
	layer = data['layername']
	geodata = data['geojson']

	# Open the right tif file
	wkspace, layname = layer.split(':')
	if wkspace == 'TempLayers':
		fname = os.path.join(conf['TEMP_DIR'], layname + '.tif')
	else:
		fname = os.path.join(conf['DATA_RESAMP_DIR'], layname + '.tif')	
	print 'Reading {}'.format(fname)
	try:
		src_ds = gdal.Open(fname) 
		gt = src_ds.GetGeoTransform()
		rb = src_ds.GetRasterBand(1)
		xOrigin = gt[0]
		yOrigin = gt[3]
		pixelWidth = gt[1]
		pixelHeight = -gt[5]
		data_array = np.array(src_ds.GetRasterBand(1).ReadAsArray())
	except:
		return { 'err' : 'Tiff does not exist {}'.format(fname) }

	# Loop over all features
	for feature in geodata['features']:		
		iden = feature['properties']['id']
		geom = feature['geometry']
		
		# If it is a valid geometry
		if geom['type'] == 'Point':			
			try:
				i = int((geom['coordinates'][0] - xOrigin) / pixelWidth)
				j = int((yOrigin - geom['coordinates'][1]) / pixelHeight)
				result[iden] = float(data_array[j][i])
			except:
				result[iden] = -99999 # out of tif bounds
		else:
			result[iden] = -99999 # N/A, geom is not a point

	return result
