#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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

class AddPointMapTool(MapTool):
	def __init__(self):
		self.Layer = None
	
	def OnMouseDown(self, worldPosition, e):
		if (self.Layer == None):
			return
		
		self.Layer.DataSource.Add(Feature(Geometry = CreatePointGeometry(worldPosition.X, worldPosition.Y)))
		self.Layer.RenderRequired = True

tool = AddPointMapTool()


map = Map()

satLayer = CreateSatelliteImageLayer()
featureLayer = CreateLayerForFeatures("Points",[],None)

tool.Layer = featureLayer

map.Layers.AddRange([featureLayer, satLayer])
map.ZoomToExtents()

mapview = OpenView(map)
mapview.MapControl.SelectTool.IsActive = False
mapview.MapControl.Tools.Add(tool)
tool.IsActive = True

