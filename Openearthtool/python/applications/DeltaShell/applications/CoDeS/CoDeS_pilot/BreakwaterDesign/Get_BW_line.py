#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
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

from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.UI.Tools import NewLineTool

import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import Button, DockStyle


def get_BW_Alignment():
	# Create layer for the polygons
	BWLayer = CreateLayerForFeatures("Breakwater", [], None)
	BWLayer.Style.Line.Color = Color.Red
	BWLayer.Style.Line.Width = 3
	BWLayer.FeatureEditor = Feature2DEditor(None)
	BWLayer.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(3857)
	#BWlayer.DataSource.Features[0].Geometry.Coordinates[0].X
	def FeaturesChanges(s,e):
		if len(BWLayer.DataSource.Features)>=1:
			newLineTool.IsActive = False
			buttonActivate.Enabled = False
	
	BWLayer.LayerRendered += FeaturesChanges
	
	# Create new line tool for line (CloseLine = False)
	newLineTool = NewLineTool(None, "New polygon tool", CloseLine = False)
	
	
	# Define layer filter for newLineTool (layer to add the new features to)
	newLineTool.LayerFilter = lambda l : l == BWLayer
	newLineTool.DrawLineDistanceHints = True
	map = Map()
	satLayer = CreateSatelliteImageLayer()
	map.Layers.Add(BWLayer)
	map.Layers.Add(satLayer)
	map.ZoomToExtents()
	mapview = OpenView(map)
	
	# Add tool
	mapview.MapControl.Tools.Add(newLineTool)
	
	def Activate_BW(s,e):
		newLineTool.IsActive = True
		mapview.MapControl.ActivateTool(newLineTool)
	
	# Add button to reactivate tool
	buttonActivate = Button(Text = "Click Breakwater")
	buttonActivate.Dock = DockStyle.Top
	buttonActivate.Click += Activate_BW
	
	def Delete_BW(s,e):
		BWLayer.RenderRequired = True
		BWLayer.DataSource.Features.Clear()
		mapview.MapControl.SelectTool.Clear()
		newLineTool.IsActive = False
		buttonActivate.Enabled = True
	
	buttonDelete = Button(Text = "Delete Breakwater")
	buttonDelete.Dock = DockStyle.Top
	buttonDelete.Click += Delete_BW
	buttonDelete.AutoSize = False
	
	#mapview.MapControl.
	mapview.Controls.Add(buttonDelete)
	mapview.Controls.Add(buttonActivate)
	
	return BWLayer


