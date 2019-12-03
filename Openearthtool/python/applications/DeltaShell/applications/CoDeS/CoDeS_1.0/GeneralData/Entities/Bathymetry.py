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
import clr
clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf 

class BathymetryType:
    Slope = "Slope"
    Ascii = "Asciigrid"

class Bathymetry:
	"""Class contains all data and metadata of the bathymetry which is """
	 
	def __init__(self,bathymetryType,isDepth):
		#	Bathymetry based on slope
		self.IsDepth = isDepth
		self.BathymetryType = bathymetryType
	
	def GetDepthValues(self):
		"""Function to extract depth, based on """
		
		if self.BathymetryType == BathymetryType.Slope:
			_swf.MessageBox.Show("Slope is " + str(self.SlopeValue))
		
		if self.BathymetryType == BathymetryType.Ascii:
			_swf.MessageBox.Show("Source is " + str(self.SourcePath))
			
		
		#Implemented in module BathymetryData
		#To be done


class SlopeBathymetry(Bathymetry):
	def __init__(self,slopeValue):
		Bathymetry.__init__(self,"Slope",True)
		self.SlopeValue = slopeValue
	def GetDepthValues(self):
		_swf.MessageBox.Show("Get values from slope bathymetry" )
	
class AsciiBathymetry(Bathymetry):
	def __init__(self,regularGrid,sourcePath,isDepth):
		Bathymetry.__init__(self,"Asciigrid",isDepth)
		
		 #construction of private property
		#This contains the 'data-matrix' which should not be exposed.
		self.__regularGrid = regularGrid
		
		#Construction of other props		
		self.OriginalSpatialReference = None
		
		#Path of the sourcefile where Bathymetry is coming from
		self.SourcePath = sourcePath
		self.UnitDescription = ''
		
"""		
SlopeBathy = SlopeBathymetry(0.1)
SlopeBathy.GetDepthValues()"""	