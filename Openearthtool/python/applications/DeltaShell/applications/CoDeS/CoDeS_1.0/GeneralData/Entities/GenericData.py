#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Hidde Elzinga
#
#       hidde.elzinga@deltares.nl
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
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as _Envelope
import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions


class GenericData:
	"""Class which contains all classes """
	def __init__(self):
		
		self.InitialMapExtent = _Envelope(-31756.2409618447, 1453795.19199705, 6574369.24871948, 7166268.64778904)		
		
		self.SR_EPSGCode = 3857
		
		#Bathymetry data
		self.Bathymetry = None
		
		#Empty list: could contain a list of civilStructures
		self.CivilStructures = dict()
		
		# Coastline data
		self.Coastline = None
		
		#Sediment properties
		self.D50 = None
		self.D90 = None
		
		#Wave-properties
		self.Waves = None
		
		# Tide properties 
		self.Tide = None
	
	def GetDataExtent(self):
		
		dataExtent = self.InitialMapExtent
		
		#	List of geometries 
		
		geometriesList = []
		
		#	Check if structure geometries are present
			
		for strucName in self.CivilStructures.keys():			
			geometriesList.append(self.CivilStructures[strucName].StructureGeometry)
		
		# 	Check if a coastline is defined
		
		if self.Coastline <> None:
			geometriesList.append(self.Coastline.CoastlineGeometry)
		
		#	If geometries are present, overrule the default mapExtent
		if len(geometriesList) > 0:
			dataExtent = _GeometryFunctions.FindExtentOfGeometryList(geometriesList,150)

	
		
		return dataExtent
	

	def GetDepthValue(self, xValue, yValue):
		"""Function for two scalars
		Simply putting the scallars in a list, and calling its big brother"""
		return self.getDepthValues(self, [x], [y])
	
	
	def GetDepthValues(self, xValues, yValues):
		"""Function for two lists
		Simply calling the method in the private class bathymetry """
		return self._Bathymetry.getDepthValues(self, xValues, yValues)
	
	def GetBathymetryLayer():
		"""Returning a pre-fab kaartlaag, using the DeltaShell functionality"""
		#To be done
		return