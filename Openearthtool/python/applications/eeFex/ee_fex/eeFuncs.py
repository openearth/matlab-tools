#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerben Hagenaars
#
#       Gerben.Hagenaars@deltares.nl
#       
#       Wiebe de Boer
#
#       Wiebe.deBoer@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
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
# This tool is developed as part of the research cooperation between
# Deltares and the Korean Institute of Science and Technology (KIOST).
# The development is funded by the CoMIDAS project of the South Korean
# government and the Deltares strategic research program Coastal and
# Offshore Engineering. This financial support is highly appreciated.
#
# ==============================
# Earth Engine Map Functions
# ==============================
# JFriedman
# June 17/2015
# ==============================

# import all necessary packages
# =============================
import ee
import datetime
import numpy as np

# pansharp RGB bands (for Landsat 8)
# ==================================
def pansharp(image):
	rgb = image.select(['R', 'G', 'B'])
	pan = image.select('P')
	hsv = rgb.rgbtohsv()
	intensity = pan.add(hsv.select('value'))
	huesat = hsv.select('hue', 'saturation')
	copy = ee.Image.cat(huesat, intensity).hsvtorgb().select(['red', 'green', 'blue'], ['R', 'G', 'B'])
	return image.addBands(copy, ['R', 'G', 'B'], True)


# pansharp SWIR + NIR band (for Landsat 8)
# =================================
def pansharpIR(image):
	rgb = image.select(['NIR', 'SWIR', 'G'])
	pan = image.select('P')
	hsv = rgb.rgbtohsv()
	intensity = pan.add(hsv.select('value'))
	huesat = hsv.select('hue', 'saturation')
	copy = ee.Image.cat(huesat, intensity).hsvtorgb().select(['red', 'green'], ['NIR', 'SWIR'])
	return image.addBands(copy, ['NIR', 'SWIR'], True)


# change to hsv/rgb for other satellites (silly!)
# ================================================
def dummyShift(image):
	copy = image.select(['R', 'G', 'B']).rgbtohsv().hsvtorgb().select(['red', 'green', 'blue'], ['R', 'G', 'B'])
	return image.addBands(copy, ['R', 'G', 'B'], True)


# change to hsv/rgb for other satellites (silly!)
# ================================================
def dummyShiftIR(image):
	copy = (image.select(['NIR', 'SWIR', 'B']).rgbtohsv()
		.hsvtorgb().select(['red', 'green', 'blue'], ['NIR', 'SWIR', 'B']))
	return image.addBands(copy, ['NIR', 'SWIR'], True)


# water "mask" from NDWI normalized difference (NIR is absorbed by water)
# =======================================================================
def getWater(image, waterThresh, vecFac):
	NDWI = image.normalizedDifference(['NIR', 'G']).lte(waterThresh)
	#  NDWI = NDWI.focal_mode(vecFac).focal_max(vecFac*1.1).focal_min(vecFac)
	return NDWI


# get vector from raster layer of water "mask"
# =============================================
def findCoast(NDWI, aoi, res):
	NDWI = NDWI.mask(NDWI.gt(0)).uint32()  # requires an integer -> vectors
	return NDWI.reduceToVectors(None, aoi, res)


# map function to reduce image collection by date limits to an interval mean (i.e. percent by pixel)
# ===================================================================================================
def cloudReduce(collection, sdate, edate, delta, pct, clouder, imCutoff):
	temp_sdate = datetime.datetime.strptime(sdate, '%Y-%m-%d')
	real_edate = min([datetime.datetime.now(), datetime.datetime.strptime(edate, '%Y-%m-%d')])
	X, dateLims = [], []
	spct = str(pct)
	while temp_sdate < real_edate:  # go through dates -> get images
		if delta:  # only if supplied
			temp_edate = temp_sdate + datetime.timedelta(days=delta)  # diff is in DAYS (PAY ATTENTION!)
		else:
			temp_edate = real_edate
		ee_sdate = datetime.datetime.strftime(temp_sdate, '%Y-%m-%d')
		ee_edate = datetime.datetime.strftime(temp_edate, '%Y-%m-%d')
		img_count = len(collection.getInfo()['features'])  # put length of images to list 
		if img_count >= imCutoff:  # reduce to percentiles if there are enough images!
			temp = (collection.filterDate(ee_sdate, ee_edate)
				        .reduce(ee.Reducer.percentile([pct]))
				        .select(['R_p' + spct, 'G_p' + spct, 'B_p' + spct, 'NIR_p' + spct, 'SWIR_p' + spct],
			                    ['R', 'G', 'B', 'NIR', 'SWIR']))
		#  .reduce(ee.Reducer.intervalMean(pct, pct+1))
		#  .select(['R_mean','G_mean','B_mean','NIR_mean','SWIR_mean'],['R','G','B','NIR','SWIR']))
		else:
			temp = (collection.filterDate(ee_sdate, ee_edate)
				        .filterMetadata('CLOUD_COVER', 'less_than',
			                            np.mean(clouder) + 0.01)  # remove the cloudy images -> disrupting reduction
				        .reduce(ee.Reducer.percentile([pct]))
				        .select(['R_p' + spct, 'G_p' + spct, 'B_p' + spct, 'NIR_p' + spct, 'SWIR_p' + spct],
			                    ['R', 'G', 'B', 'NIR', 'SWIR']))
		# .reduce(ee.Reducer.intervalMean(pct, pct+1))
		# .select(['R_mean','G_mean','B_mean','NIR_mean','SWIR_mean'],['R','G','B','NIR','SWIR']))

		X.append(temp)
		dateLims.append([temp_sdate, temp_edate])
		temp_sdate = temp_edate
	return ee.ImageCollection(X), dateLims


# function to map image collection -> get dates + cloud cover by image
# =====================================================================
def getMetaData(im):
	d = ee.Date(im.get('system:time_start')).format('yyyyMMdd_HHmmss')  # format date
	cc = ee.String(im.get('CLOUD_COVER'))  # get cloud cover
	return ee.Feature(ee.Geometry.Point([0, 0]), {'clouds': cc, 'date': d})


# function to map image collection -> get dates + cloud cover by image
# =====================================================================
def getMetaDataS2(im):
	d = ee.Date(im.get('system:time_start')).format('yyyyMMdd_HHmmss')  # format date
	cc = ee.String(im.get('CLOUDY_PIXEL_PERCENTAGE'))  # get cloud cover
	return ee.Feature(ee.Geometry.Point([0, 0]), {'clouds': cc, 'date': d})


# function to extract data from feature (i.e. getInfo + format)
# =============================================================
def formatMetaData(ft):
	temp = ft.getInfo()
	clouder = [cc['properties']['clouds'] for cc in temp['features']]
	dater = [dd['properties']['date'] for dd in temp['features']]
	dater = [datetime.datetime.strptime(dd, '%Y%m%d_%H%M%S') for dd in dater]
	return dater, clouder