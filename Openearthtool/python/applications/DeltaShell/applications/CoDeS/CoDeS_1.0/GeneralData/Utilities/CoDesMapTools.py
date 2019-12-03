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
from System.Drawing import Font
from NetTopologySuite.Extensions.Features import Feature
from SharpMap.UI.Tools import NewLineTool
from SharpMap.Editors.Interactors import Feature2DEditor
from Libraries.MapFunctions import *
from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView
from SharpMap.Extensions.Layers import OpenStreetMapLayer as _OSML
from SharpMap.UI.Tools.Decorations import LegendTool
from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection

class MapLineToolClean:
	def __init__(self, MapView):
		self._MapView = MapView
		# Make lineTool
		self.newLineTool = NewLineTool(None, "New polygon tool", CloseLine = False)
		self.newLineTool.DrawLineDistanceHints = True
		self.LineLayer = None

	def AddToMapView(self, mapView):
		mapView.MapControl.Tools.Add(self.newLineTool)

	def SetLayer(self, linelayer):
		if (self.LineLayer != None):
			self.LineLayer.DataSource.FeaturesChanged -= self.LineLayerChanges
		
		self.LineLayer = linelayer 
		
		self.newLineTool.LayerFilter = lambda l : l == self.LineLayer
		self.LineLayer.DataSource.FeaturesChanged += self.LineLayerChanges

	def ActivateTool(self,IsActive):
		self._MapView.MapControl.ActivateTool(self.newLineTool)
		self.newLineTool.IsActive = IsActive
		
	def LineLayerChanges(self,s,e):
		if len(self.LineLayer.DataSource.Features)>=1:
			self.newLineTool.IsActive = False

	def ClearLines(self):
		self.LineLayer.RenderRequired = True
		self.LineLayer.DataSource.Features.Clear()
		self._MapView.MapControl.SelectTool.Clear()
			
	def get_LineGeometry(self):
		"""Get line geometry from feature layer, by default take first feature"""
		LineFeatures = self.LineLayer.GetFeatures(LineLayer.Envelope)
		for LineFeature in LineFeatures:
			return LineFeature
			
		return None

class MapLineTool:
	def __init__(self,MapView,linelayer,sr_epsgcode):
		
		self._MapView = MapView
		self.LineLayer = linelayer
		# Create layer
		#self.LineLayer = CreateLayerForFeatures("Structure", [], None)
		#self.LineLayer.Style.Line.Color = Color.Black
		#self.LineLayer.Style.Line.Width = 3
		#self.LineLayer.FeatureEditor = Feature2DEditor(None)
		#self.LineLayer.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(sr_epsgcode)
		
		#self._MapView.Map.Layers.Add(self.LineLayer)
		#self._MapView.Map.BringToFront(self.LineLayer)
		
		# Make lineTool
		self.newLineTool = NewLineTool(None, "New polygon tool", CloseLine = False)
		
		
		# Define layer filter for newLineTool (layer to add the new features to)
		self.newLineTool.LayerFilter = lambda l : l == self.LineLayer
		self.newLineTool.DrawLineDistanceHints = True
		self.LineLayer.DataSource.FeaturesChanged += self.LineLayerChanges
		#self.newLineTool.IsActive = True	

		#	Add control to map
		self._MapView.MapControl.Tools.Add(self.newLineTool)
		#self._MapView.MapControl.ActivateTool(self.newLineTool)
		
		
	def ActivateTool(self,IsActive):
		self._MapView.MapControl.ActivateTool(self.newLineTool)
		self.newLineTool.IsActive = IsActive
		
	def LineLayerChanges(self,s,e):
		if len(self.LineLayer.DataSource.Features)>=1:
			self.newLineTool.IsActive = False
				
	def ClearLines(self):
		self.LineLayer.RenderRequired = True
		self.LineLayer.DataSource.Features.Clear()			
		self._MapView.MapControl.SelectTool.Clear()	
			
	def get_LineGeometry(self):
		"""Get line geometry from feature layer, by default take first feature"""
		LineFeatures = self.LineLayer.GetFeatures(LineLayer.Envelope)
		self.ResultFeature = None
		
		for LineFeature in LineFeatures:
			self.ResultFeature = LineFeature
		
		

def ShowLegend(mapView):
	for tool in mapView.MapControl.Tools:
		if type(tool) is LegendTool:
			tool.Visible = True
			tool.LegendFont = Font(tool.LegendFont.FontFamily,9)
			

def AddLabelToLayerAndShow(Layer,Name):
	"""Adds label to layer and shows it on map (only for layers with one feature)"""
	Layer.DataSource.Features[0].Attributes = DictionaryFeatureAttributeCollection()
	Layer.DataSource.Features[0].Attributes.Add("Name",Name)
	ShowLayerLabels(Layer,"Name")

"""newView = View()		
kaartView = MapView()
OSMLlayer = _OSML()
kaartView.Map.Layers.Add(OSMLlayer)
kaartView.Dock = _swf.DockStyle.Fill
newClickTool = MapLineTool(kaartView)
newClickTool.

newView.Controls.Add(kaartView)
newView.ChildViews.Add(kaartView)
newView.Show()
		"""