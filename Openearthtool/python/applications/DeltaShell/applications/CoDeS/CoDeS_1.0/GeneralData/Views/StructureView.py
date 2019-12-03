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
import numpy as np

from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *

from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools
import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions
import Scripts.GeneralData.Entities.Scenario as _Scenario
import Scripts.GeneralData.Entities.CivilStructure as _CivilStructure


from GeoAPI.Geometries import ICoordinate as _ICoordinate
from SharpMap.Layers import GroupLayer
from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.UI.Tools import MapTool
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML

import DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapView as _MapView

from GisSharpBlog.NetTopologySuite.Geometries import Envelope
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate

from System import Array as _Array
import System.Windows.Forms as _swf
from System.Drawing.Drawing2D import LineCap, DashStyle

class StructureView(BaseView):
	
	def __init__(self,scenario):
		BaseView.__init__(self)
		
		#	Variables for storage and selection of data
		self.Text = "Civil structure"
		self.__scenario = scenario
		self.IsEditing = False
				
		self.InitializeControls()
		self.StructureLayerList = dict()
		
		self.InitializeForScenario()
	
	def InitializeForScenario(self):
		
		self.mapView.Map = self.__scenario.GeneralMap
		self.GroupLayer = self.__scenario.GroupLayerStructures
		self.GroupLayer.Layers.Clear()
		
		self.EditLayer = self.CreateEditLayer()
		
		self.mapView.Map.BringToFront(self.EditLayer)
		self.GroupLayer.Layers.Add(self.EditLayer)
		
		self.newClickTool = _CoDesMapTools.MapLineToolClean(self.mapView)
		self.newClickTool.SetLayer(self.EditLayer)
		self.newClickTool.AddToMapView(self.mapView)
		
		self.cbName.Items.Clear()
		self.StructureLayerList.Clear()
		
		for structure in self.__scenario.GenericData.CivilStructures.values():
			layer = self.CreateStructureLayer(structure)
			self.GroupLayer.Layers.Add(layer)
			self.mapView.Map.BringToFront(layer)
			
			self.StructureLayerList[structure.Name] = layer
			self.cbName.Items.Add(structure.Name)
		
		self.ResetButtonStates()
		self.mapView.MapControl.Refresh()
		
	def InitializeControls(self):
		
		#region input
		self.lblName = _swf.Label()
		self.lblName.Top = 10
		self.lblName.Left = 10
		self.lblName.Width = 150
		self.lblName.Text = "Structure name:"
		
		self.cbName = _swf.ComboBox()
		self.cbName.Top = 10
		self.cbName.Left = 180
		self.cbName.Width = 150
		self.cbName.SelectedIndexChanged +=  lambda s,e : self.cbName_SelectedIndexChanged()
		self.cbName.Text = "<Type name or select>"
		
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
		self.btnSave.Enabled = False
		
		self.btnClear = _swf.Button()
		self.btnClear.Text = "Clear input"
		self.btnClear.Top = 105
		self.btnClear.Left = 205
		self.btnClear.Click += self.btnClear_Click
		self.btnClear.Enabled = False
		
		self.btnDelete = _swf.Button()
		self.btnDelete.Text = "Delete structure"
		self.btnDelete.Top = 105
		self.btnDelete.Left = 290
		self.btnDelete.Width = 100
		self.btnDelete.Click += self.btnDelete_Click
		self.btnDelete.Enabled = False
		
		self.lblFlip = _swf.Label()
		self.lblFlip.Top = 135
		self.lblFlip.Left = 10
		self.lblFlip.Width = 200
		self.lblFlip.Text = "Round cap shows offshore position"
		
		self.btnFlip = _swf.Button()
		self.btnFlip.Top = 135
		self.btnFlip.Left = 290
		self.btnFlip.Width = 100
		self.btnFlip.Text = "Flip structure"
		self.btnFlip.Click += self.btnFlip_Click
		self.btnFlip.Enabled = False
		
		self.leftPanel.Controls.Add(self.lblName)
		self.leftPanel.Controls.Add(self.cbName)
		
		self.leftPanel.Controls.Add(self.btnStart)
		self.leftPanel.Controls.Add(self.btnSave)
		self.leftPanel.Controls.Add(self.btnClear)
		self.leftPanel.Controls.Add(self.btnDelete)
		self.leftPanel.Controls.Add(self.lblFlip)
		self.leftPanel.Controls.Add(self.btnFlip)
		#endregion

		#region map
		
		self.mapView = _MapView()
		self.mapView.Dock = _swf.DockStyle.Fill
		
		_CoDesMapTools.ShowLegend(self.mapView)
		
		self.rightPanel.Controls.Add(self.mapView)
		self.ChildViews.Add(self.mapView)

		#endregion	
	
	def FindMapExtent(self):
		#	Find the extent of all structure features
		geometriesList = []
				
		for strucName in self.__scenario.GenericData.CivilStructures.keys():
			geometriesList.append(self.__scenario.GenericData.CivilStructures[strucName].StructureGeometry)
		
		mapExtent = None
		
		if len(geometriesList) > 0:
			mapExtent = _GeometryFunctions.FindExtentOfGeometryList(geometriesList,150)
			
		return mapExtent

	def validateName(self, text):
		"""returns T/F whether """
		return (text != "<Type name or select>") and (text != "") 
	
	def validate(self, text):
		"""returns T/F whether """
		return text != ""

	def cbName_SelectedIndexChanged(self):
				
		civilStructure = self.__scenario.GenericData.CivilStructures[self.cbName.Text]
	
		layer = self.StructureLayerList[self.cbName.Text]
		self.mapView.MapControl.SelectTool.Clear()
		self.mapView.Refresh()
		self.mapView.MapControl.SelectTool.Select([layer.DataSource.Features[0]])
		
		self.ResetButtonStates()

	def btnSave_Click(self):
		structureName = self.cbName.Text
		
		if(not self.validateName(structureName) or 
			not self.newClickTool.LineLayer.DataSource.Features.Count != 0):
				
			#Some message if no text is given
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = "Required information is missing."
			return
		
		if self.cbName.Text in self.__scenario.GenericData.CivilStructures:
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = "Name already in use"
			return
		
		self.IsEditing = False
	
		#Some message while processing data
		self.lblMessage.ForeColor = Color.Black
		self.lblMessage.Text = "Processing ... "
		
		# Height and Width are not stored!
		civilStructure = _CivilStructure(structureName)
		civilStructure.StructureGeometry = self.EditLayer.DataSource.Features[0].Geometry
		self.__scenario.GenericData.CivilStructures[civilStructure.Name] = civilStructure
		self.cbName.Items.Add(civilStructure.Name)
		
		# add new structurelayer
		structureLayer = self.CreateStructureLayer(civilStructure)
		self.StructureLayerList[civilStructure.Name] = structureLayer
		
		self.GroupLayer.Layers.Add(structureLayer)
		self.mapView.Map.BringToFront(structureLayer)
		
		self.EditLayer.DataSource.Features.Clear()
		self.mapView.MapControl.SelectTool.Clear()
		 
		self.lblMessage.ForeColor = Color.Green
		self.lblMessage.Text = "Structure imported"

		self.clear_Input()
		self.btnClear.Enabled = False
		self.newClickTool.ActivateTool(False)
		self.btnStart.Enabled = True
		self.btnSave.Enabled = False
		self.btnDelete.Enabled = False
		if self.cbName.Text in self.StructureLayerList:
			self.btnFlip.Enabled = True
			self.btnDelete.Enabled = True
			
	def btnStart_Click(self, sender, e):
		self.lblMessage.Text = ""
				
		self.newClickTool.ActivateTool(True)
		self.IsEditing = True
		self.ResetButtonStates()
		
	def btnClear_Click(self, sender, e):
		self.clear_Input()
		self.EditLayer.DataSource.Features.Clear()
		self.mapView.MapControl.SelectTool.Clear()
			
		self.btnStart.Enabled = True
		self.btnFlip.Enabled = False

	def btnDelete_Click(self, sender, e):
		structureName = self.cbName.Text
		if structureName in self.StructureLayerList:
			layertoRem = self.StructureLayerList[structureName]
			del self.__scenario.GenericData.CivilStructures[structureName]
			del self.StructureLayerList[structureName]
			
			self.cbName.Items.Remove(structureName)
			self.clear_Input()		
		
			if layertoRem != None:
				self.GroupLayer.Layers.Remove(layertoRem)
				
		self.ResetButtonStates()		
		
		if len(self.StructureLayerList)==0:
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = "All breakwaters deleted"
		
	def btnFlip_Click(self, sender, e):
		structureName = self.cbName.Text
		
		if structureName in self.StructureLayerList: 
			self.FlipGeometry(self.StructureLayerList[structureName])
			return
		else:
			self.FlipGeometry(self.EditLayer)		
		
				
		self.lblMessage.ForeColor = Color.Green
		self.lblMessage.Text = "Structure flipped and saved"

	def clear_Input(self):
		
		self.cbName.Text = "<Type name or select>"
		self.newClickTool.ActivateTool(False)
		self.IsEditing = False
		self.ResetButtonStates()

	def CreateStructureLayer(self, structure):
		cs = Map.CoordinateSystemFactory.CreateFromEPSG(self.__scenario.GenericData.SR_EPSGCode)
		
		feature = Feature(Geometry = structure.StructureGeometry)
		layer = CreateLayerForFeatures(structure.Name, [feature], cs)
		layer.FeatureEditor = Feature2DEditor(None)
		
		layer.Style.Line.Color = Color.Black
		layer.Style.Line.Width = 7
		layer.Style.Line.EndCap = LineCap.RoundAnchor
		layer.Style.Line = layer.Style.Line # Refresh style icon
		
		# Provide Label
		_CoDesMapTools.AddLabelToLayerAndShow(layer,structure.Name)
		
		return layer

	def CreateEditLayer(self):
		cs = Map.CoordinateSystemFactory.CreateFromEPSG(self.__scenario.GenericData.SR_EPSGCode)
		
		layer = CreateLayerForFeatures("<name>", [], cs)
		layer.FeatureEditor = Feature2DEditor(None)
		layer.ShowInLegend = False
		layer.ShowInTreeView = False
		
		layer.Style.Line.Color = Color.Red
		layer.Style.Line.Width = 7
		layer.Style.Line.EndCap = LineCap.RoundAnchor
		layer.Style.Line = layer.Style.Line # Refresh style icon
		
		return layer
	
	def FlipGeometry(self, layer):
		if not (layer.DataSource.Features.Count > 0): 
			return
			
		_Array.Reverse(layer.DataSource.Features[0].Geometry.Coordinates)
		layer.RenderRequired = True

	def ResetButtonStates(self):
		
		existingStructureSelected = self.cbName.Text in self.StructureLayerList
		
		self.btnStart.Enabled = not self.IsEditing
		self.btnSave.Enabled = self.IsEditing
		self.btnClear.Enabled = self.IsEditing
		self.btnDelete.Enabled = existingStructureSelected		
		self.btnFlip.Enabled = existingStructureSelected or self.EditLayer.DataSource.Features.Count > 0
		
		
"""from Scripts.GeneralData.Utilities.ScenarioPersister import *
path = "D:\\temp\\newScenario.dat"
scenarioPersister = ScenarioPersister()
newScenario = scenarioPersister.LoadScenario(path) 
structView = StructureView(newScenario)

structView.Show()"""
#scenario = _Scenario()
#scenario.GenericData.Coastline = newCoast
#structView = StructureView(scenario)
#structView._StructureView__scenario.GeneralMap.FindLayer("T1")

#structView.Show()


