#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Aline Kaji
#
#       aline.kaji@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
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
import os
import clr
clr.AddReference("System.Windows.Forms")

import System.Drawing as _drawing
import System.Windows.Forms as _swf
from Scripts.CoastlineDevelopment.Views import CoastlineDevelopmentView as _CoastlineDevelopmentView
from Scripts.Tests.TestScripts import MakeTestFeatures as _MakeTestFeatures

testScenario = _MakeTestFeatures.GetTestScenario()
from Scripts.CoastlineDevelopment.Entities import CoastlineOutput as _CoastlineOutput
from Scripts.CoastlineDevelopment.Entities import CoastlineInput as _CoastlineInput
from Libraries.StandardFunctions import *
from Libraries.MapFunctions import *
from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection
from SharpMap.Rendering.Thematics import CategorialTheme, CategorialThemeItem, ColorBlend
from SharpMap.Styles import VectorStyle 
from Scripts.CoastlineDevelopment.Utilities.CoastlineEvolution import *
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env

from Scripts.GeneralData.Entities import Scenario as _scenario

from SharpMap.UI.Tools.Decorations import LegendTool

from Scripts.GeneralData.Views.BaseView import *

DefaultInputValues  = _CoastlineInput.InputData()
DefaultOutputValues = _CoastlineOutput.OutputData()

def PlotCoastlineEvolution(InputValues,OutputValues):
	
	newFeatures = []
	theme = CategorialTheme("Years",VectorStyle())
	Item = []
	
	# Add initial coastline
	feature1 = Feature()
	feature1.Geometry = CreateLineGeometry(OutputValues.Coastline_utm[0])
	feature1.Attributes = DictionaryFeatureAttributeCollection()
	feature1.Attributes.Add("Years","Initial Coastline")
	
	style = VectorStyle()
	style.Line.Color = Color.Black
	style.Line.Width = 3
	style.Line = style.Line # needed to refresh symbol of vectorstyle
	
	# create a themeitem for "abc" features
	abcItem = CategorialThemeItem()
	abcItem.Category = "Initial Coastline"
	abcItem.Value = "Initial Coastline"
	abcItem.Style = style
	
	Item.append(abcItem)
	
	newFeatures.append(feature1)
	
	for ind in range(1,len(OutputValues.Years)):
		
		feature1 = Feature()
		feature1.Geometry = CreateLineGeometry(OutputValues.Coastline_utm[ind])
		feature1.Attributes = DictionaryFeatureAttributeCollection()
		feature1.Attributes.Add("Years", str(OutputValues.Years[ind]))
	
		style = VectorStyle()
		style.Line.Color = ColorBlend.Rainbow7.GetColor(1./len(OutputValues.Years)*(ind))
		style.Line.Width = 3
		style.Line = style.Line # needed to refresh symbol of vectorstyle
		
		# create a themeitem for "abc" features
		abcItem = CategorialThemeItem()
		abcItem.Category = str(OutputValues.Years[ind])
		abcItem.Value = str(OutputValues.Years[ind])
		abcItem.Style = style
		
		Item.append(abcItem)
		
		newFeatures.append(feature1)
	
	# Create custom layer for the features
	#LayOutput = map.Map.GetLayerByName("Coastline Development")
	#map.Map.Layers.Remove(LayOutput)
	coastlineLayer = CreateLayerForFeatures("Coastline Position", newFeatures, CreateCoordinateSystem(3857))
	
	# create theme for styling (coloring) features based on Name attribute 
	theme.ThemeItems.AddRange(Item)
	
	# assign theme to custom layer
	coastlineLayer.Theme = theme
	
	# Add to baseview map
	GroupLayer.Layers.Insert(0,coastlineLayer)
	coastlineLayer.RenderOrder = 0
	coastlineLayer.ShowInLegend = True
	
	# Add legend (remove)
	"""for tool in map.MapControl.Tools:
		if type(tool) is LegendTool:
			tool.Visible = True"""

def PlotTransports(InputValues,OutputValues):

	GroupLayer.Layers.Clear()
	
	transport_features = []
	ind = 0
	# Plot transports per transect
	for ind in range(0,len(InputValues.Profiles_utm)):
		
		# Get location of cross-shore transects
		transects = np.array(InputValues.Profiles_utm[ind])
		
		# Get positive transport direction
		pos_dir = OutputValues.TransectOrientation[ind] - 90
		
		# Calculate transect length
		feature_length = np.sqrt((transects[1,0] - transects[0,0])**2 + (transects[1,1] - transects[0,1])**2)
		
		# Calculate location of transport arrow base
		baseX = transects[0,0] + np.sin(np.pi*(OutputValues.TransectOrientation[ind]-180)/180) * feature_length * np.array([0.25,0.50,0.75])
		baseY = transects[0,1] + np.cos(np.pi*(OutputValues.TransectOrientation[ind]-180)/180) * feature_length * np.array([0.25,0.50,0.75])
		
		# Get transports
		neg_pos_net = [OutputValues.SedTransPos[ind], OutputValues.SedTransNeg[ind], OutputValues.SedTransNet[ind]]
		
		# Normalize transport arrows
		rel_max_dist_to_L  = feature_length*0.3
		
		# Calculate location of transport arrow head
		endX = baseX + np.sin(np.pi * pos_dir/180) * rel_max_dist_to_L * (neg_pos_net/(np.max(np.abs(neg_pos_net)) + (10**(-20))))
		endY = baseY + np.cos(np.pi * pos_dir/180) * rel_max_dist_to_L * (neg_pos_net/(np.max(np.abs(neg_pos_net)) + (10**(-20))))
		
		# Create features
		for i in range(0,3):
			feature1 = Feature()
			feature1.Geometry = CreateLineGeometry([[baseX[i],baseY[i]],[endX[i],endY[i]]])
			feature1.Attributes = DictionaryFeatureAttributeCollection()
			feature1.Attributes['title'] = str(int(np.abs(neg_pos_net[i]))) + " m3/yr."
		
			transport_features.append(feature1)

		
	#transport_features_layer = CreateLayerForFeatures("Transport arrows and values", transport_features, CreateCoordinateSystem(InputValues.Profiles_utm_codes[0]))	
	transport_features_layer = CreateLayerForFeatures("Transport arrows and values", transport_features, CreateCoordinateSystem(3857))	
	style_var = transport_features_layer.Style
	transport_features_layer.Style.Line.Color    = Color.LightSeaGreen
	transport_features_layer.Style.Line.Width    = 10
	transport_features_layer.Style.Line.EndCap   = _drawing.Drawing2D.LineCap.ArrowAnchor
	 
		
	ShowLayerLabels(transport_features_layer, "title")
	GroupLayer.Layers.Insert(0,transport_features_layer)
	
	ZoomToLayer(cross_shore_layer)
	
newView = _CoastlineDevelopmentView(testScenario)
newView.Show()

GroupLayer = testScenario.GroupLayerCoastlineDevelopment
ActiveLayer = None

#DefaultOutputValues.Coastline_utm
#DefaultOutputValues.Years
from Scripts.CoastlineDevelopment.Utilities import CoastlineEvolution as _CoastlineEvolution
_CoastlineEvolution.coastline_engine(DefaultOutputValues,DefaultInputValues,True)
PlotCoastlineEvolution(DefaultInputValues,DefaultOutputValues)
