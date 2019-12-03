#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Josh Friedman
#
#       josh.friedman@deltares.nl
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
#libraries
import clr
clr.AddReference("System.Windows.Forms")

from Libraries.MapFunctions import *
from SharpMap.UI.Tools import MapTool
from System.Windows.Forms import MouseButtons
from NetTopologySuite.Extensions.Features import PointFeature as _PointFeature

class AddPointMapTool(MapTool):
	def __init__(self):
		self.Layer = None
	
	def SetLayer(self, layer):  
		self.Layer = layer
	
	def OnMouseDown(self, worldPosition, e):
		if (self.Layer == None):
			return
		if not(e.Button == MouseButtons.Middle):
			self.Layer.DataSource.Features.Clear()
			self.Layer.DataSource.Add(_PointFeature(Geometry = CreatePointGeometry(worldPosition.X, worldPosition.Y)))
			self.Layer.RenderRequired = True

