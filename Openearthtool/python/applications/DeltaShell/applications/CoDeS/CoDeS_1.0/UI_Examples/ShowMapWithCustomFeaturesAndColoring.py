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
from Libraries.StandardFunctions import *
from Libraries.MapFunctions import *
from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection
from SharpMap.Rendering.Thematics import CategorialTheme, CategorialThemeItem
from SharpMap.Styles import VectorStyle 

nameAttributeName = "Name"

# create 2 features with a Name attribute
feature1 = Feature()
feature1.Geometry = CreateLineGeometry([[1,1], [4,4]])
feature1.Attributes=DictionaryFeatureAttributeCollection()
feature1.Attributes.Add(nameAttributeName, "abc")

feature2 = Feature()
feature2.Geometry = CreateLineGeometry([[-4,-4], [-1,-1]])
feature2.Attributes=DictionaryFeatureAttributeCollection()
feature2.Attributes.Add(nameAttributeName, "def")

# Create custom layer for the features
newFeatures = [ feature1, feature2 ]
customLayer = CreateLayerForFeatures("MyFeatures", newFeatures, None)

# create a style for "abc" features
style1 = VectorStyle()
style1.Line.Color = Color.Red
style1.Line.Width = 3
style1.Line = style1.Line # needed to refresh symbol of vectorstyle

# create a themeitem for "abc" features
abcItem = CategorialThemeItem()
abcItem.Category = "abc"
abcItem.Value = "abc"
abcItem.Style = style1

# create a style for "def" features
style2 = VectorStyle()
style2.Line.Color = Color.Green
style2.Line.Width = 3
style2.Line = style2.Line

# create a style for "def" features
defItem = CategorialThemeItem()
defItem.Category = "def"
defItem.Value = "def"
defItem.Style = style2 # needed to refresh symbol of vectorstyle

# create theme for styling (coloring) features based on Name attribute 
theme = CategorialTheme(nameAttributeName,VectorStyle())
theme.ThemeItems.AddRange([abcItem, defItem])

# assign theme to custom layer
customLayer.Theme = theme

# open a view for the map to see the custom layer 
map = Map()
map.Layers.Add(customLayer)
OpenView(map)
