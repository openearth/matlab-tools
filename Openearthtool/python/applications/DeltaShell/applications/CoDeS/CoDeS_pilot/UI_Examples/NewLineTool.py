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

from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.UI.Tools import NewLineTool

import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import Button, DockStyle

# Create layer for the polygons
customLayer = CreateLayerForFeatures("My polygons", [], None)
customLayer.Style.Line.Color = Color.Red
customLayer.Style.Line.Width = 3
customLayer.FeatureEditor = Feature2DEditor(None)

# Create new line tool for polygons (CloseLine = True)
newLineTool = NewLineTool(None, "New polygon tool", CloseLine = True)

# Define layer filter for newLineTool (layer to add the new features to)
newLineTool.LayerFilter = lambda l : l == customLayer

map = Map()
satLayer = CreateSatelliteImageLayer()
map.Layers.Add(customLayer)
map.Layers.Add(satLayer)
map.ZoomToExtents()
mapview = OpenView(map)

# Add tool
mapview.MapControl.Tools.Add(newLineTool)

# Add button to reactivate tool
buttonActivate = Button(Text = "Activate new line tool")
buttonActivate.Dock = DockStyle.Top
buttonActivate.Click += lambda s,e : mapview.MapControl.ActivateTool(newLineTool)

mapview.Controls.Add(buttonActivate)

