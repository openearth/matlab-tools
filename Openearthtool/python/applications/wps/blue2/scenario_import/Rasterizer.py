# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala
#
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
# $Keywords: $

import os
import numpy
import fiona
import rasterio
import rasterio.features
import rasterio.mask
from affine import Affine
from shapely.geometry import shape

## TO READ WCS outputs
class Rasterizer:
	
	def __init__(self, out, tif, shp, f):
		""" NetCDF file object """
		self.model_mask = tif
		self.shapefile_division = shp
		self.outdir = out
		self.field = f

	def rasterizeAll(self):
		""" For every geometry inside the shapefile, mask the tif and get another raster """		
		res = dict()
		with fiona.open(self.shapefile_division, 'r') as vector, \
			rasterio.open(self.model_mask, 'r') as raster:			
			for feature in vector:
				# Geometry and ID
				geometry = shape(feature['geometry'])		
				tag = feature['properties'][self.field]
				out_fn = os.path.join(self.outdir, """mask_{}.tif""".format(tag))
				res[tag] = (out_fn, geometry)

				# Rasterize geometry if needed
				if os.path.exists(out_fn):
					print('Skip-OK ' + out_fn)
				else:
					try:
						out_image, out_transform = rasterio.mask.mask(raster, [geometry])
						out_meta = raster.meta.copy()
						out_meta.update({"driver": "GTiff",
							"height": out_image.shape[1],
							"width": out_image.shape[2],
							"transform": out_transform
						})
						with rasterio.open(out_fn, "w", **out_meta) as dest:
							dest.write(out_image)
						
						print('Write-OK: ' + out_fn)
					except: 
						print('Write-ERR: ' + out_fn)						
		
		# MaskTiff + Geometry
		return res