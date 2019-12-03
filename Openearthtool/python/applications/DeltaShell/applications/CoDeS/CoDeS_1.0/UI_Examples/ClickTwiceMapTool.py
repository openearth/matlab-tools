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
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *

from SharpMap.UI.Tools import MapTool
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate

import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import MessageBox

class GetTwoMapCoordinatesTool(MapTool):
	def __init__(self):
		self.FirstCoordinate = None
		self.SecondCoordinate = None
		self.FunctionToExecute = None
	
	def OnMouseDown(self, worldPosition, e):
		if (self.FirstCoordinate != None and self.SecondCoordinate != None):
			self.SecondCoordinate = None
			self.FunctionToExecute = None
			return
		if (self.FirstCoordinate == None):
			self.FirstCoordinate = worldPosition
			return
			
		if(self.SecondCoordinate == None):
			self.SecondCoordinate = worldPosition
			
			if (self.FunctionToExecute != None):
				self.FunctionToExecute(self.FirstCoordinate, self.SecondCoordinate)	
			else :
				MessageBox.Show("FunctionToExecute is None")
			return
		
def ShowTest(firstCoordinate, secondCoordinate):
	MessageBox.Show("First : " + str(firstCoordinate) + " \nSecond : " + str(secondCoordinate))

getTwoMapCoordinatesTool = GetTwoMapCoordinatesTool()
getTwoMapCoordinatesTool.FunctionToExecute = ShowTest

map = Map()
satLayer = CreateSatelliteImageLayer()
map.Layers.Add(satLayer)

mapview = OpenView(map)

mapview.MapControl.SelectTool.IsActive = False
mapview.MapControl.Tools.Add(getTwoMapCoordinatesTool)
getTwoMapCoordinatesTool.IsActive = True

#mapview.MapControl.Tools.Remove(getTwoMapCoordinatesTool)