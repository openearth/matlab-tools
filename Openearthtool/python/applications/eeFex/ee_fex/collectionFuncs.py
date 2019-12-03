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

# import all necessary packages
# ====================================
#JFriedman
#Nov 30/2015
#=====================================

import ee
from . import eeFuncs as EE

# global constants of Landsat missions
# ====================================
collection_names = {'IM_L4': 'LANDSAT/LT4_L1T_TOA',
                    'IM_L5': 'LANDSAT/LT5_L1T_TOA',
                    'IM_L7': 'LANDSAT/LE7_L1T_TOA',
                    'IM_L8': 'LANDSAT/LC8_L1T_TOA',
                    'S2': 'COPERNICUS/S2'}  # collections according to EE
band_names = {'IM_L4': ['B1', 'B2', 'B3', 'B4', 'B5'],  # designated band numbers
              'IM_L5': ['B1', 'B2', 'B3', 'B4', 'B5'],
              'IM_L7': ['B1', 'B2', 'B3', 'B4', 'B5'],
              'IM_L8': ['B2', 'B3', 'B4', 'B5', 'B6', 'B8'],
              'S2': ['B2', 'B3', 'B4', 'B8', 'B11']}
band_std_names = {'IM_L4': ['B', 'G', 'R', 'NIR', 'SWIR'],  # designated band numbers
                  'IM_L5': ['B', 'G', 'R', 'NIR', 'SWIR'],
                  'IM_L7': ['B', 'G', 'R', 'NIR', 'SWIR'],
                  'IM_L8': ['B', 'G', 'R', 'NIR', 'SWIR', 'P'],
                  'S2': ['B', 'G', 'R', 'NIR', 'SWIR']}

# get all applicable images (by collection) for the site + daters
# ==============================================================
def combineCollections(satellites, sdate, edate, aoi, cc):
	C = {}
	images, collections = [], []
	N = 0
	dater, clouder = {}, {}

	for val in satellites:
		if val == 'IM_L8':  # separate for newest landsat missions since pansharpening is possible

			C[val] = (ee.ImageCollection(collection_names[val])  # get selected collection
				          .filterDate(sdate, edate).filterBounds(aoi.centroid(1))  # filter by temporal bounds
				          .filterMetadata('CLOUD_COVER', 'less_than', cc)  # make sure to avoid cloudy images
				          .select(band_names[val], band_std_names[val])  # rename bands to standard names
				          .map(EE.pansharp)  # pansharp RGB
				          .map(EE.pansharpIR))  # pansharp NIR
			num = len(C[val].getInfo()['features'])  # number of images in collection
			if num > 0:  # only proceed if image collection NOT empty!
				collections.append(val)  # get names of image collections WITH images
				ft = C[val].map(EE.getMetaData)  # get dates + cloud cover for images in collection
				d, c = EE.formatMetaData(ft)  # extract dates + cloud cover
				dater[val] = d
				clouder[val] = c
			else:
				del C[val]  # delete image collection DATA in dictionary

		elif val == 'S2':

			C[val] = (ee.ImageCollection(collection_names[val])  # get selected collection
				.filterDate(sdate, edate).filterBounds(aoi.centroid(1))  # filter by temporal bounds
				.filterMetadata('CLOUDY_PIXEL_PERCENTAGE', 'less_than', cc)  # make sure to avoid cloudy images
				.select(band_names[val], band_std_names[val]))  # rename bands to standard names
			# .map(EE.dummyShift).map(EE.dummyShiftIR))
			num = len(C[val].getInfo()['features'])  # number of images in collection
			# print num
			if num > 0:  # only proceed if image collection NOT empty!
				collections.append(val)  # get names of image collections WITH images
				ft = C[val].map(EE.getMetaDataS2)  # get dates + cloud cover for images in collection
				d, c = EE.formatMetaData(ft)  # extract dates + cloud cover
				dater[val] = d
				clouder[val] = c
			else:
				del C[val]  # delete image collection DATA in dictionary

		else:

			C[val] = (ee.ImageCollection(collection_names[val])  # get selected collection
						.filterDate(sdate, edate).filterBounds(aoi.centroid(1))  # filter by temporal bounds
						.filterMetadata('CLOUD_COVER', 'less_than', cc)  # make sure to avoid cloudy images
						.select(band_names[val], band_std_names[val])  # rename bands to standard names
						.map(EE.dummyShift).map(EE.dummyShiftIR))
			num = len(C[val].getInfo()['features'])  # number of images in collection
			# print num
			if num > 0:  # only proceed if image collection NOT empty!
				collections.append(val)  # get names of image collections WITH images
				ft = C[val].map(EE.getMetaData)  # get dates + cloud cover for images in collection
				d, c = EE.formatMetaData(ft)  # extract dates + cloud cover
				dater[val] = d
				clouder[val] = c
			else:
				del C[val]  # delete image collection DATA in dictionary

		N += num

	if not C:
		images, dater, clouder = [], [], []
		N = 0
	else:
		# compile collection together -> sort by dater/time
		images = ee.ImageCollection(C[collections[0]])  # first GOOD collection WITH images
		for collection in collections[1:]:  # loop through REST of collections
			images = eval('images.merge(C["%s"])' % collection)  # merge collections TOGETHER
		images = ee.ImageCollection(
			images)  # .sort('system:time_start', True)) # SORT image collection in together in time
		images = images.select(['R', 'G', 'B', 'NIR', 'SWIR'])  # select specific bands for analysis

	return images, dater, clouder, N