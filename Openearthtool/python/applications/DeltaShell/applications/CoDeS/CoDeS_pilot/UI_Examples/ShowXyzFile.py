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
from SharpMap import XyzFile
from SharpMap.Data.Providers import FeatureCollection
from SharpMap.Layers import PointCloudLayer
from NetTopologySuite.Extensions.Coverages import PointValue
from SharpMap.Rendering.Thematics import ThemeFactory, ColorBlend

from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *

def SetTheme(layer):
	"""Sets the theme (coloring) of the layer"""
	attributeName = "Value"
	colorBlend = ColorBlend.Rainbow5
	size = 10
	nrOfClasses = 10
	layer.Theme = ThemeFactory.CreateGradientTheme(attributeName, layer.Style, colorBlend, layer.MinDataValue, layer.MaxDataValue, size,size,False,True,nrOfClasses)

# read points from XYZ file
file = XyzFile()
points = [feature for feature in file.Read(r"C:\dcsmv6.xyz")]

# create layer for points
layer = PointCloudLayer()
layer.DataSource = FeatureCollection(points, PointValue)
layer.Name = "dcsmv6"

SetTheme(layer)

# open map with layer
map = Map()
map.Layers.Add(layer)
OpenView(map)



