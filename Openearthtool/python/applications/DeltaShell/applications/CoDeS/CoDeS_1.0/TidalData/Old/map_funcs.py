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
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
from Scripts.UI_Examples.View import *
from SharpMap.UI.Tools import MapTool
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import MouseButtons
import System.Drawing as s
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML

#input two labels -> update based on map click
def ClickMap(L_lat,L_lon):
	class LatLonInput():
		def __init__(self):
			self.lat = None
			self.lon = None
	
	#define tool -> assign it to "tool"
	class AddPointMapTool(MapTool):
		def __init__(self):
			self.Layer = None
		
		def OnMouseDown(self, worldPosition, e):
			if (self.Layer == None):
				return
			if not(e.Button == MouseButtons.Middle):
				self.Layer.DataSource.Features.Clear()
				self.Layer.DataSource.Add(Feature(Geometry = CreatePointGeometry(worldPosition.X, worldPosition.Y)))
				self.Layer.RenderRequired = True
				
	#determines if change in feature (i.e. clicked -> save to lon/lat)
	def FeaturesChanges(vals):
		if len(tool.Layer.DataSource.Features) > 0:
			PT = TransformGeometry(tool.Layer.DataSource.Features[0].Geometry, 3395,4326)
			vals.lon = PT.Coordinate.X
			vals.lat = PT.Coordinate.Y
			
			L_lat.Text = "%.4f" %(vals.lat) #assign value to textbox
			L_lon.Text = "%.4f" %(vals.lon) #assign value to textbox
	
	#define tool with feature of points
	tool = AddPointMapTool()
	tool.Layer = CreateLayerForFeatures("Points",[],None)
	vals = LatLonInput()
			
	tool.Layer.LayerRendered  += lambda s,e: FeaturesChanges(vals)
	tool.IsActive = True
	
	#map = Map()
	#OSML_layer = OSML()
	#map.Layers.Add(tool.Layer)
	#map.Layers.Add(OSML_layer)
	#map.ZoomToExtents()
	#mapview = MapView()
	#mapview.Map = map
	#mapview.Dock = DockStyle.Fill
	#mapview.Map.ZoomToFit(Env(350000.0,800000.0,6700000.0,7100000.0))
	
	# Add tool
	mapview.MapControl.Tools.Add(tool)
	mapview.MapControl.SelectTool.IsActive = False #get rid of mouse movement
	
	return mapview

#old function for assigning new point on map from textbox change -> REMOVED!
"""def MoveMapPoint(vals,locLayer):
	
	loc = Feature(Geometry = CreatePointGeometry(vals.lon,vals.lat))
	loc.Geometry = TransformGeometry(loc.Geometry, 4326,3395)
	locLayer.DataSource.Features.Clear()
	locLayer.DataSource.Add(loc)
	locLayer.RenderRequired = True"""

#==================
#HOW TO IMPLEMENT!
#==================

"""#set the two labels for the lat/lon
L_lat = TextBox()
L_lat.Dock = DockStyle.Bottom
L_lat.Enabled = False
L_lon = TextBox()
L_lon.Dock = DockStyle.Bottom
L_lon.Enabled = False

#get the mapview + layers + L
mapview = ClickMap(L_lat,L_lon)

#build view then add mapview + labels
view_IN = View()
view_IN.ChildViews.Add(mapview)
view_IN.Controls.Add(L_lat)
view_IN.Controls.Add(L_lon)
view_IN.Controls.Add(mapview)
view_IN.Show()"""




