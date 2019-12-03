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

import netCDF4
import os
import rasterio
import numpy as np
import geopandas as gpd
from shapely.geometry.multipolygon import MultiPolygon

## TO READ Netcdf outputs
class ncFile:
	
	def __init__(self, fname):
		""" NetCDF file object """
		self.dset = netCDF4.Dataset(fname)
		self.longnames = []
		self.variables = []
		self.units = []
		self.timesteps = []
		
		self.variables = self.getVariables()
		self.timesteps = self.getTimeSteps()
		

	def getVariables(self):
		""" Gets all variables with 3 dimensions at least """		
		self.datavars = []
		for key, value in self.dset.variables.items():			
		    if value.ndim > 2:
		        self.longnames.append(value.long_name)
		        self.units.append(value.units)
		        self.datavars.append(key)		
		return self.datavars

	def getTimeSteps(self, tname="time"):
		""" Gets all available time steps in datetime format """				
		nctime = self.dset.variables[tname][:] 		# get values
		t_unit = self.dset.variables[tname].units 	# get unit  "days since 1950-01-01T00:00:00Z"
		t_cal = u"gregorian" # or standard
		self.timesteps = netCDF4.num2date(nctime, units=t_unit, calendar=t_cal)
		self.timesteps_str = [date.strftime('"%Y-%m-%d"') for date in self.timesteps]
		return self.timesteps

	def maskNetdfwithGeometries(self, varname, masksdict, crs):
		""" Given a geometry get back all timesteps array masked """
		# Define data frame
		df = gpd.GeoDataFrame(columns=['id', 'geometry'] + self.timesteps_str, index=masksdict.keys())
		geoms = []
		all_data = self.dset.variables[varname][:,:,:]
		
		for idg, geomandtif in masksdict.items(): 	# every shape
			print('|', end=''),
			(tifm, g) = geomandtif
			row = {}
			row['id'] = idg			
			row['geometry'] = g
			# Process mask
			with rasterio.open(tifm, 'r+') as r:
				arr_mask = r.read(1, masked=True)				
				for t in range(0, len(self.timesteps_str)): # every timestep is a column
					data = all_data[t,:,:]	# subset time
					try:
						row[self.timesteps_str[t]] = float(np.nanmean(data*arr_mask))
					except:
						row[self.timesteps_str[t]] = 0 # nodata
			# Add row
			df.loc[idg] = gpd.GeoSeries(row)

		# Set geometry
		df.set_geometry('geometry')
		df.crs = {'init' :'epsg:{}'.format(crs)}
		print('')
		return df

