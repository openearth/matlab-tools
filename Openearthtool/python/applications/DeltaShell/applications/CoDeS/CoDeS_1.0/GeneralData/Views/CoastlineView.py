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
from Scripts.GeneralData.Views.BaseView import *
import System.Windows.Forms as _swf
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
from SharpMap.UI.Tools import MapTool
from GisSharpBlog.NetTopologySuite.Geometries import Envelope
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
import Scripts.GeneralData.Entities.Scenario as _Scenario
import Scripts.GeneralData.Entities.Coastline as _Coastline
import DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapView as _MapView
import numpy as np
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools
from System.Drawing.Drawing2D import LineCap, DashStyle

import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions
from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.Layers import GroupLayer
from System import Array as _Array

class CoastlineView(BaseView):
	def __init__(self,scenario):
		
		BaseView.__init__(self)
		
		#	Variables for storage and selection of data
		self.Text = "Coastline"
		self.__scenario = scenario
		self.IsEditing = False
		
		self.InitializeControls()
		self.InitializeForScenario()

	def InitializeForScenario(self):
		self.mapView.Map = self.__scenario.GeneralMap
		
		# setup layers
		self.GroupLayer = self.__scenario.GroupLayerCoastline
		self.GroupLayer.Layers.Clear()
		self.CoastLineLayer = self.CreateCoastLineLayer()
		self.EditLayer = self.CreateEditLayer()
		self.ArrowLayer = self.CreateArrowLayer()
		
		self.EditLayer.DataSource.FeaturesChanged += lambda s,e: self.DrawArrow(self.EditLayer)
		
		for layer in [self.CoastLineLayer, self.EditLayer, self.ArrowLayer]:
			self.GroupLayer.Layers.Add(layer)
			self.mapView.Map.BringToFront(layer)
		
		# add maptool
		self.newClickTool = _CoDesMapTools.MapLineToolClean(self.mapView)
		self.newClickTool.SetLayer(self.EditLayer)
		self.newClickTool.AddToMapView(self.mapView)
		
		self.ResetControlsForCurrentFeature()

	def ResetControlsForCurrentFeature(self):
		coastLine = self.__scenario.GenericData.Coastline
		hasCoastLine = coastLine != None
		
		self.AddCoastLineFeature()
		
		self.DrawArrow(self.CoastLineLayer)
		
		self.tbName.Text = "" if not hasCoastLine else coastLine.Name
		self.btnStart.Enabled = not hasCoastLine and not self.IsEditing
		self.btnSave.Enabled = not hasCoastLine and self.IsEditing
		self.btnDelete.Enabled = hasCoastLine
		self.btnFlip.Enabled = hasCoastLine
		self.lblMessage.Text = ""
		
		self.mapView.MapControl.SelectTool.Clear()

	def InitializeControls(self):
		#region input
		
		self.lblName = _swf.Label()
		self.lblName.Top = 10
		self.lblName.Left = 10
		self.lblName.Width = 150
		self.lblName.Text = "Coastline name:"
		
		self.tbName = _swf.TextBox()
		self.tbName.Top = 10
		self.tbName.Left = 180
		self.tbName.Width = 150
		
		self.btnStart = _swf.Button()
		self.btnStart.Text = "Start drawing"
		self.btnStart.Top = 105
		self.btnStart.Left = 10
		self.btnStart.Width = 100
		self.btnStart.Click += self.btnStart_Click

		self.btnSave = _swf.Button()
		self.btnSave.Text = "Save"
		self.btnSave.Top = 105
		self.btnSave.Left = 120
		self.btnSave.Click +=  lambda s,e : self.btnSave_Click()
		
		self.btnDelete = _swf.Button()
		self.btnDelete.Text = "Delete"
		self.btnDelete.Top = 105
		self.btnDelete.Left = 205
		self.btnDelete.Click += self.btnDelete_Click
		self.btnDelete.Enabled = False
			
		self.btnFlip = _swf.Button()
		self.btnFlip.Text = "Flip Coastline"
		self.btnFlip.Top = 105
		self.btnFlip.Left = 290
		self.btnFlip.Width = 100
		self.btnFlip.Click += self.btnFlip_Click		
		
		self.leftPanel.Controls.Add(self.lblName)
		self.leftPanel.Controls.Add(self.tbName)
		self.leftPanel.Controls.Add(self.btnStart)
		self.leftPanel.Controls.Add(self.btnSave)
		self.leftPanel.Controls.Add(self.btnDelete)
		self.leftPanel.Controls.Add(self.btnFlip)
		#endregion

		#region map

		self.mapView = _MapView()
		self.mapView.Dock = _swf.DockStyle.Fill
		
		self.rightPanel.Controls.Add(self.mapView)
		self.ChildViews.Add(self.mapView)
		_CoDesMapTools.ShowLegend(self.mapView)

		#endregion

	def validate(self, text):
		"""returns T/F whether """
		return text != ""

	def btnSave_Click(self):
		self.IsEditing = False
		
		if(not self.validate(self.tbName.Text) or not self.EditLayer.DataSource.Features.Count != 0):
			#Some message if no text is given
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = "Required information is missing."
		
		else:
			#Some message while processing data
			self.lblMessage.ForeColor = Color.Black
			self.lblMessage.Text = "PROCESSING ... "

			#add coastline
			self.__scenario.GenericData.Coastline = _Coastline(self.tbName.Text, self.EditLayer.DataSource.Features[0].Geometry)
			self.EditLayer.DataSource.Features.Clear()
			self.newClickTool.ActivateTool(False)
			self.ResetControlsForCurrentFeature()
			
			self.lblMessage.ForeColor = Color.Green
			self.lblMessage.Text = "Coastline imported"

	def btnStart_Click(self, sender, e):
		self.IsEditing = True
		self.newClickTool.ActivateTool(True)		
		self.btnStart.Enabled = False
		self.btnSave.Enabled = True
		self.btnDelete.Enabled = True
		
	def btnDelete_Click(self, sender, e):
		self.IsEditing = False
		self.__scenario.GenericData.Coastline = None
		self.ResetControlsForCurrentFeature()
		
	def btnFlip_Click(self, sender, e):
		coastline = self.__scenario.GenericData.Coastline
		if coastline == None : 
			return

		_Array.Reverse(coastline.CoastlineGeometry.Coordinates)
		
		self.ResetControlsForCurrentFeature()

	def DrawArrow(self, layer):
		self.ArrowLayer.DataSource.Features.Clear()
		
		layerHasFeature = len(layer.DataSource.Features) > 0
		self.ArrowLayer.ShowInLegend = layerHasFeature
		
		if not layerHasFeature:
			return

		feature = layer.DataSource.Features[0]
		start_point = feature.Geometry.Coordinates.Get(0)
		end_point   = feature.Geometry.Coordinates.Get(1)
		
		DirectionCL = 90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X)))
		DirectionCrosshore = DirectionCL-90
		
		feature_length     = np.sqrt(((start_point.X-end_point.X)**2) + ((start_point.Y-end_point.Y)**2)).Value
		rel_max_dist_to_L = feature_length*0.7
		
		endpoints_arrows = np.array([start_point.X+np.sin(np.pi*DirectionCrosshore/180)*rel_max_dist_to_L,start_point.Y+np.cos(np.pi*DirectionCrosshore/180)*rel_max_dist_to_L])
		ArrowFeature = Feature(Geometry = CreateLineGeometry([np.array([start_point.X,start_point.Y]),np.array([endpoints_arrows[0].Value,endpoints_arrows[1].Value])]))
		
		self.ArrowLayer.DataSource.Features.Add(ArrowFeature)
		
	def CreateArrowLayer(self):
		cs = Map.CoordinateSystemFactory.CreateFromEPSG(self.__scenario.GenericData.SR_EPSGCode)
		layer = CreateLayerForFeatures("Offshore Direction", [], cs)
		
		layer.Style.Line.Color = Color.RoyalBlue
		layer.Style.Line.Width = 10
		layer.Style.Line.EndCap = LineCap.ArrowAnchor
		layer.Style.Line = layer.Style.Line # Refresh for generation of Legend!
		
		return layer
	
	def CreateEditLayer(self):
		cs = Map.CoordinateSystemFactory.CreateFromEPSG(self.__scenario.GenericData.SR_EPSGCode)
		layer = CreateLayerForFeatures("<name>", [], cs)
		layer.Style.Line.Color = Color.Red
		layer.Style.Line.Width = 3
		layer.Style.Line = layer.Style.Line
		layer.ShowInLegend = False
		layer.ShowInTreeView = False
		
		layer.FeatureEditor = Feature2DEditor(None)
		
		return layer
	
	def AddCoastLineFeature(self):
		coastline = self.__scenario.GenericData.Coastline
		self.CoastLineLayer.DataSource.Features.Clear()
		
		hasCoastlineGeometry = coastline != None and coastline.CoastlineGeometry != None
		self.CoastLineLayer.ShowInLegend = hasCoastlineGeometry
		
		if not hasCoastlineGeometry:
			return
			
		feature = Feature(Geometry = coastline.CoastlineGeometry)
		self.CoastLineLayer.DataSource.Features.Add(feature)
		
		_CoDesMapTools.AddLabelToLayerAndShow(self.CoastLineLayer, coastline.Name)
	
	def CreateCoastLineLayer(self):
		
		cs = Map.CoordinateSystemFactory.CreateFromEPSG(self.__scenario.GenericData.SR_EPSGCode)
		
		layer = CreateLayerForFeatures("Coastline", [], cs)
		layer.Style.Line.Color = Color.Black
		layer.Style.Line.Width = 3
		layer.Style.Line.DashStyle = DashStyle.Dash
		layer.Style.Line = layer.Style.Line
		layer.FeatureEditor = Feature2DEditor(None)
		
		return layer

#scenario = _Scenario()

#from Scripts.GeneralData.Utilities.ScenarioPersister import *
#path = "D:\\temp\\newScenario.dat"
#scenarioPersister = ScenarioPersister()
#scenario = scenarioPersister.LoadScenario(path) 

#coastlineView = CoastlineView(scenario)

#coastlineView.Show()


