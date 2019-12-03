#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Jochem Boersma
#
#       jochem.boersma@witteveenbos.com
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
## Module for WavePenetration
## Developed for CoDeS
## Author: J.H.Boersma / Witteveen+Bos
## Date: April 6th, 2016



## =====Import necessary modules================================
#External modules
import clr
clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf
import System.Drawing as _sd

import DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapView as _MapView
from SharpMap.Rendering.Thematics import GradientTheme
from SharpMap.Layers import PointCloudLayer
from SharpMap.Data.Providers import PointCloudFeatureProvider
from NetTopologySuite.Extensions.Coverages import PointValue, PointCloud
from Scripts.WavePenetration.Entities import WavePenetrationInput as _WavePenetrationInput
from Scripts.WavePenetration.Entities import WavePenetrationData as _WavePenetrationData


#Calculation modules
import numpy as _np
import math

#Own modules
from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Utilities.GridFunctions as _GridFunc
import Scripts.GeneralData.Utilities.Conversions as _Conversions
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDeSMapTools				#Remark the capital S of CoDeS
import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions
import Scripts.GeneralData.Utilities.PythonObjects as _PythonObjects

from Scripts.WavePenetration.Utilities import applyWavePen as _wp
from Scripts.WavePenetration.Utilities import WavePenUtils as _wpU



## =============================================================
class WavePenetrationView(BaseView):
	def __init__(self,scenario):
		BaseView.__init__(self)		
		
		
		#Variables for storage and selection of data and layers
		self.__scenario = scenario
		self.GroupLayer = self.__scenario.GroupLayerWavePenetration
		self.ActiveLayer = None
		
		# Check if tool data is available 
		if 'WavePenetrationData' in self.__scenario.ToolData:
			self.inputData = self.__scenario.ToolData['WavePenetrationData'].InputData
			#_swf.MessageBox.Show('Data found')
		else:
			self.inputData = _WavePenetrationInput()
			self.__scenario.ToolData['WavePenetrationData'] = _WavePenetrationData(self.inputData)
			#_swf.MessageBox.Show('Default data')
			
		
		#Title of tab:
		self.Text = "Wave penetration"
		self.InitializeControls()
		
		#Set scrollbars
		self.SetScrollBarsLeftPanel(20)
		
		#Initialize two breakwaters and a coastline
		self.BreakwaterL = None
		self.BreakwaterR = None
		self.Coastline = None


	## =========================================================
	def InitializeControls(self):
		#region import
		
		#region Radiobuttons
		self.rbtnManualData = _swf.RadioButton()
		self.rbtnManualData.Text = "Manual input"
		self.rbtnManualData.Top = 20
		self.rbtnManualData.Left = 10
		self.rbtnManualData.Width = 120
		self.rbtnManualData.Checked = True
		self.rbtnManualData.Click += lambda s,e : self.rbtnManualData_Click()
		
		#TBD: voor onderscheid in handmatige en General Wave Data. Deze knop wordt niet aangemaakt.
		self.rbtnSelectData = _swf.RadioButton()
		self.rbtnSelectData.Text = "Select from Wave Data"
		self.rbtnSelectData.Top = 20
		self.rbtnSelectData.Left = 140
		self.rbtnSelectData.Width = 200
		self.rbtnSelectData.Checked = False
		self.rbtnSelectData.Click += lambda s,e : self.rbtnSelectData_Click()
		#endregion
		#region WaveHeight
		self.lblHeight = _swf.Label()
		self.lblHeight.Top = 60
		self.lblHeight.Left = 10
		self.lblHeight.Width = 125
		self.lblHeight.Text = "Wave height:"
		
		self.tbHeight = _swf.NumericUpDown()
		self.tbHeight.Maximum = 20
		self.tbHeight.Minimum = 0.01
		self.tbHeight.Value = self.inputData.Hs
		self.tbHeight.Increment = 0.1
		self.tbHeight.DecimalPlaces = 1
		self.tbHeight.Top = 60
		self.tbHeight.Left = 140
		self.tbHeight.Width = 150
		self.tbHeight.ValueChanged += lambda s,e : _PythonObjects.SetValue(self.inputData,"Hs", self.tbHeight.Value)
		
		self.lblHeightUnit = _swf.Label()
		self.lblHeightUnit.Top = 60
		self.lblHeightUnit.Left = 300
		self.lblHeightUnit.Width = 50
		self.lblHeightUnit.Text = "m."
		#endregion
		#region WavePeriod
		self.lblPeriod = _swf.Label()
		self.lblPeriod.Top = 90
		self.lblPeriod.Left = 10
		self.lblPeriod.Width = 125
		self.lblPeriod.Text = "Wave period:"
		
		self.tbPeriod = _swf.NumericUpDown()
		self.tbPeriod.Maximum = 50
		self.tbPeriod.Minimum = 1
		self.tbPeriod.Value = self.inputData.Tp
		self.tbPeriod.Increment = 0.2
		self.tbPeriod.DecimalPlaces = 1
		self.tbPeriod.Top = 90
		self.tbPeriod.Left = 140
		self.tbPeriod.Width = 150
		self.tbPeriod.ValueChanged += lambda s,e : _PythonObjects.SetValue(self.inputData,"Tp", self.tbPeriod.Value)
		
		self.lblPeriodUnit = _swf.Label()
		self.lblPeriodUnit.Top = 90
		self.lblPeriodUnit.Left = 300
		self.lblPeriodUnit.Width = 50
		self.lblPeriodUnit.Text = "sec."
		
		#endregion
		#region WaveDirection
		self.lblDirection = _swf.Label()
		self.lblDirection.Top = 120
		self.lblDirection.Left = 10
		self.lblDirection.Width = 125
		self.lblDirection.Text = "Wave direction:"
		
		self.tbDirection = _swf.NumericUpDown()
		self.tbDirection.Maximum = 360
		self.tbDirection.Minimum = 0
		self.tbDirection.Value = self.inputData.waveDir
		self.tbDirection.Increment = 5
		self.tbDirection.DecimalPlaces = 0
		self.tbDirection.Top = 120
		self.tbDirection.Left = 140
		self.tbDirection.Width = 150
		self.tbDirection.ValueChanged += lambda s,e : _PythonObjects.SetValue(self.inputData,"waveDir", self.tbDirection.Value)
		
		self.lblDirectionUnit = _swf.Label()
		self.lblDirectionUnit.Top = 120
		self.lblDirectionUnit.Left = 300
		self.lblDirectionUnit.Width = 50
		self.lblDirectionUnit.Text = "deg."
		#endregion
		#region WaveSpreading
		self.lblDispersion = _swf.Label()
		self.lblDispersion.Top = 150
		self.lblDispersion.Left = 10
		self.lblDispersion.Width = 125
		self.lblDispersion.Text = "Wave spreading:"
		
		self.tbDispersion = _swf.NumericUpDown()
		self.tbDispersion.Maximum = 180
		self.tbDispersion.Minimum = 1
		self.tbDispersion.Value = self.inputData.Smax
		self.tbDispersion.Increment = 5
		self.tbDispersion.DecimalPlaces = 0
		self.tbDispersion.Top = 150
		self.tbDispersion.Left = 140
		self.tbDispersion.Width = 150
		self.tbDispersion.ValueChanged += lambda s,e : _PythonObjects.SetValue(self.inputData,"Smax", self.tbDispersion.Value)
		
		self.lblDispersionUnit = _swf.Label()
		self.lblDispersionUnit.Top = 150
		self.lblDispersionUnit.Left = 300
		self.lblDispersionUnit.Width = 50
		self.lblDispersionUnit.Text = "deg."
		
		#For now: spectrum is not taken into account. Therefore, disable tb.
		self.tbDispersion.Enabled = False
		
		#endregion
		#region Wave param groupbox
		self.groupWave = _swf.GroupBox()
		self.groupWave.AutoSize = 1		
		self.groupWave.Text = "Wave parameters"
		self.groupWave.Dock = _swf.DockStyle.Top
		
		self.groupWave.Controls.Add(self.rbtnManualData)
		#TBD: implementation of making selection from Wave Data.
		#self.groupWave.Controls.Add(self.rbtnSelectData)
		
		self.groupWave.Controls.Add(self.lblHeight)
		self.groupWave.Controls.Add(self.tbHeight)
		self.groupWave.Controls.Add(self.lblHeightUnit)
		
		self.groupWave.Controls.Add(self.lblPeriod)
		self.groupWave.Controls.Add(self.tbPeriod)
		self.groupWave.Controls.Add(self.lblPeriodUnit)
		
		self.groupWave.Controls.Add(self.lblDirection)
		self.groupWave.Controls.Add(self.tbDirection)
		self.groupWave.Controls.Add(self.lblDirectionUnit)
		
		self.groupWave.Controls.Add(self.lblDispersion)
		self.groupWave.Controls.Add(self.tbDispersion)
		self.groupWave.Controls.Add(self.lblDispersionUnit)
		#endregion

		#region harbordepth input field
		self.lblHarborDepth = _swf.Label()
		self.lblHarborDepth.Top = 20
		self.lblHarborDepth.Left = 10
		self.lblHarborDepth.Width = 125
		self.lblHarborDepth.Text = "Harbor depth:"
		
		self.tbHarborDepth = _swf.NumericUpDown()
		self.tbHarborDepth.Maximum = 100000
		self.tbHarborDepth.Minimum = 1
		self.tbHarborDepth.Value = self.inputData.harborDepth
		self.tbHarborDepth.Increment = 0.2
		self.tbHarborDepth.DecimalPlaces = 1
		self.tbHarborDepth.Top = 20
		self.tbHarborDepth.Left = 140
		self.tbHarborDepth.Width = 150
		self.tbHarborDepth.ValueChanged += lambda s,e : _PythonObjects.SetValue(self.inputData,"harborDepth", self.tbHarborDepth.Value)
		
		self.lblHarborDepthUnit = _swf.Label()
		self.lblHarborDepthUnit.Top = 20
		self.lblHarborDepthUnit.Left = 300
		self.lblHarborDepthUnit.Width = 50
		self.lblHarborDepthUnit.Text = "m."
		#endregion
		#region Breakwaters/Coastline dropdowns
		self.lblBreakWaterL = _swf.Label()
		self.lblBreakWaterL.Top = 50
		self.lblBreakWaterL.Left = 10
		self.lblBreakWaterL.Width = 125
		self.lblBreakWaterL.Text = "Breakwater left:"

		self.lblBreakWaterR = _swf.Label()
		self.lblBreakWaterR.Top = 80
		self.lblBreakWaterR.Left = 10
		self.lblBreakWaterR.Width = 125
		self.lblBreakWaterR.Text = "Breakwater right:"
		
		self.lblCoastline = _swf.Label()
		self.lblCoastline.Top = 110
		self.lblCoastline.Left = 10
		self.lblCoastline.Width = 125
		self.lblCoastline.Text = "Coastline:"
		
		#Drie combo-boxen moeten gevuld worden met de reeds aanwezige data. 		
		self.dropdownBreakWaterL = _swf.ComboBox()
		self.dropdownBreakWaterR = _swf.ComboBox()
		self.dropdownCoastline = _swf.ComboBox()
		for structureName in self.__scenario.GenericData.CivilStructures.keys():
			self.dropdownBreakWaterL.Items.Add(structureName)
			self.dropdownBreakWaterR.Items.Add(structureName)
		if self.dropdownBreakWaterL.Items.Count>1:
			if self.inputData.bwLeftKey in self.__scenario.GenericData.CivilStructures:
				self.dropdownBreakWaterL.SelectedItem = self.inputData.bwLeftKey
			else:
				self.dropdownBreakWaterL.SelectedIndex = 0
			
			if self.inputData.bwRightKey in self.__scenario.GenericData.CivilStructures:
				self.dropdownBreakWaterR.SelectedItem = self.inputData.bwRightKey
			else:
				self.dropdownBreakWaterR.SelectedIndex = 1
			
		self.dropdownBreakWaterL.SelectedIndexChanged += lambda s,e: _PythonObjects.SetValue(self.inputData,"bwLeftKey", self.dropdownBreakWaterL.SelectedItem)
		self.dropdownBreakWaterR.SelectedIndexChanged += lambda s,e: _PythonObjects.SetValue(self.inputData,"bwRightKey", self.dropdownBreakWaterR.SelectedItem)
		
			
		
		
		#Coastline only can put in, when coastline is determined
		if not (self.__scenario.GenericData.Coastline == None):
			self.dropdownCoastline.Items.Add(self.__scenario.GenericData.Coastline.Name)
			self.dropdownCoastline.Text = self.__scenario.GenericData.Coastline.Name
		#In all cases: disable the textbox: only one entry is possible 
		self.dropdownCoastline.Enabled = False

		#Disabling entering text by user
		#self.dropdownBreakWaterL.DropDownStyle = _swf.ComboBoxStyle.Simple
		#self.dropdownBreakWaterR.DropDownStyle = _swf.ComboBoxStyle.Simple
		#self.dropdownCoastline.DropDownStyle = _swf.ComboBoxStyle.Simple


		#Aligning the dropdown boxes
		self.dropdownBreakWaterL.Top = 50
		self.dropdownBreakWaterL.Left = 140
		self.dropdownBreakWaterL.Width = 150
		
		self.dropdownBreakWaterR.Top = 80
		self.dropdownBreakWaterR.Left = 140
		self.dropdownBreakWaterR.Width = 150
		
		self.dropdownCoastline.Top = 110
		self.dropdownCoastline.Left = 140
		self.dropdownCoastline.Width = 150
		
		#endregion	
		#region harbor buttons
		self.btnUpdate = _swf.Button()
		self.btnUpdate.Text = "Update breakwaters and coast"
		self.btnUpdate.Top = 50
		self.btnUpdate.Left = 300
		self.btnUpdate.Width = 80
		self.btnUpdate.Height = 40
		self.btnUpdate.Click += self.updateData
		
		self.btnGuessLR = _swf.Button()
		self.btnGuessLR.Text = "Check left and right"
		self.btnGuessLR.Top = 93
		self.btnGuessLR.Left = 300
		self.btnGuessLR.Width = 80
		self.btnGuessLR.Height = 40
		self.btnGuessLR.Click += lambda s,e : self.guessBW()
		#endregion
		#region Harbor Param groupbox
		self.groupHarbor = _swf.GroupBox()
		self.groupHarbor.AutoSize = 1		
		self.groupHarbor.Text = "Harbor parameters"
		self.groupHarbor.Dock = _swf.DockStyle.Top
						
		self.groupHarbor.Controls.Add(self.lblHarborDepth)
		self.groupHarbor.Controls.Add(self.tbHarborDepth)
		self.groupHarbor.Controls.Add(self.lblHarborDepthUnit)
		
		self.groupHarbor.Controls.Add(self.lblBreakWaterL)
		self.groupHarbor.Controls.Add(self.dropdownBreakWaterL)
				
		self.groupHarbor.Controls.Add(self.lblBreakWaterR)
		self.groupHarbor.Controls.Add(self.dropdownBreakWaterR)
		
		self.groupHarbor.Controls.Add(self.lblCoastline)
		self.groupHarbor.Controls.Add(self.dropdownCoastline)
				
		self.groupHarbor.Controls.Add(self.btnUpdate)
		self.groupHarbor.Controls.Add(self.btnGuessLR)
		#endregion
		
		#region grid size input field
		self.lblGridSize = Label()
		self.lblGridSize.Top = 20
		self.lblGridSize.Left = 10
		self.lblGridSize.Width = 125
		self.lblGridSize.Text = "Grid points:"
		
		self.tbGridSize = _swf.NumericUpDown()
		self.tbGridSize.Maximum = 100000
		self.tbGridSize.Minimum = 1
		self.tbGridSize.Value = self.inputData.gridPoints
		self.tbGridSize.Increment = 100
		self.tbGridSize.DecimalPlaces = 0
		self.tbGridSize.Top = 20
		self.tbGridSize.Left = 140
		self.tbGridSize.Width = 150
		self.tbGridSize.ValueChanged += lambda s,e : _PythonObjects.SetValue(self.inputData,"erdPoints", self.tbGridSize.Value)
		
		self.lblGridSizeUnit = _swf.Label()
		self.lblGridSizeUnit.Top = 20
		self.lblGridSizeUnit.Left = 300
		self.lblGridSizeUnit.Width = 50
		self.lblGridSizeUnit.Text = "pts."
		#endregion
		#region calculate button
		self.btnCalculate = _swf.Button()
		self.btnCalculate.Text = "Calculate!"
		self.btnCalculate.Top = 50
		self.btnCalculate.Left = 10
		#Better width: based on the width of the LeftPanel.
		self.btnCalculate.Height = 30
		self.btnCalculate.Width = 100		
		self.btnCalculate.Anchor = _swf.AnchorStyles.Right | _swf.AnchorStyles.Left 
		self.btnCalculate.Dock = _swf.DockStyle.Bottom	
		self.btnCalculate.Click += lambda s,e : self.btnCalculate_Click()
		
		#endregion
		#region Calculate Param groupbox
		self.groupCalc = _swf.GroupBox()
		#groupCalc.AutoSize = 1
		self.groupCalc.Height = 90
		self.groupCalc.Text = "Calculation parameters"
		self.groupCalc.Padding.All = 8
		self.groupCalc.Dock = _swf.DockStyle.Top
		
		self.groupCalc.Controls.Add(self.lblGridSize)
		self.groupCalc.Controls.Add(self.tbGridSize)
		self.groupCalc.Controls.Add(self.lblGridSizeUnit)
		self.groupCalc.Controls.Add(self.btnCalculate)		
		#endregion
		
		#Reverse order: to put fill them from bottom to top.
		self.leftPanel.Controls.Add(self.groupCalc)
		self.leftPanel.Controls.Add(self.groupHarbor)
		self.leftPanel.Controls.Add(self.groupWave)
		#endregion
		
		#region map
		self.mapView = _MapView()
		self.mapView.Map = self.__scenario.GeneralMap
		self.mapView.Dock = _swf.DockStyle.Fill
		_CoDeSMapTools.ShowLegend(self.mapView)
		
		#On the map: add the grouplayer (if it not exists)
		if not self.mapView.Map.Layers.Contains(self.GroupLayer):
			self.mapView.Map.Layers.Add(self.GroupLayer)

		#Put the mapview into the right panel.
		self.rightPanel.Controls.Add(self.mapView)
		self.ChildViews.Add(self.mapView)
		#endregion
		
		self.guessBW(False)
	
	
	#region functions for input buttons
	def rbtnSelectData_Click(self):
		#When the radiobutten of select data is clicked: perform actions
		if self.rbtnSelectData.Checked:
			self.rbtnManualData.Checked = False
			
			#Disable fields (only gray: don't remove values)
			self.tbHeight.Enabled = False
			self.tbPeriod.Enabled = False
			self.tbDirection.Enabled = False
		return
	
	
	## =========================================================
	def rbtnManualData_Click(self):
		#When radiobutton of manual input is clicked: perform actions
		if self.rbtnManualData.Checked:
			self.rbtnSelectData.Checked = False
			
			#Enable fields
			self.tbHeight.Enabled = True
			self.tbPeriod.Enabled = True
			self.tbDirection.Enabled = True
		return
	
	
	## =========================================================
	def updateData(self, sender, e):
		#After updating other data, the combo-boxes of the breakwaters should be refreshed
		
		#Remove all current entries
		self.dropdownBreakWaterL.Items.Clear()
		self.dropdownBreakWaterR.Items.Clear()
		self.dropdownCoastline.Items.Clear()
		
		#Erase the text in the boxes, since the displayed text is separated from the selected items
		self.dropdownBreakWaterL.Text = ""
		self.dropdownBreakWaterR.Text = ""
				
		#Fill dropdownmenu's with new CivilStructures
		for structureName in self.__scenario.GenericData.CivilStructures.keys():
			self.dropdownBreakWaterL.Items.Add(structureName)
			self.dropdownBreakWaterR.Items.Add(structureName)
		
		if self.dropdownBreakWaterL.Items.Count>1:
			self.dropdownBreakWaterL.SelectedIndex = 0
			self.dropdownBreakWaterR.SelectedIndex = 1
		
		#Get name of Coastline
		#for coastlineName in self.__scenario.GenericData.Coastline.keys():
		#	self.dropdownCoastline.Items.Add(coastlineName)
		if not (self.__scenario.GenericData.Coastline == None):
			self.dropdownCoastline.Items.Add(self.__scenario.GenericData.Coastline.Name)
			self.dropdownCoastline.Text = self.__scenario.GenericData.Coastline.Name
		
		#For the user: show some message line.		
		self.lblMessage.ForeColor = _sd.Color.Black
		self.lblMessage.Text = "Breakwaters and Coastline updated"
		
		#Erase the eventualy loaded structures
		self.BreakwaterL = None
		self.BreakwaterR = None
		self.Coastline = None

		
		
		return
	
	
	## =========================================================
	def guessBW(self, sendMess = True):
		#Guess which of the two breakwaters are left or right.
		if not self.validGeometries():
			return
		
		#Get BreakWaters and coastline
		self.extractGeometries()
		
		#The left breakwater is the one which Startpoint is closest towards StartPoint of Coastline
		#So test must be based on Start- and Endpoint of coastline.
		distStartCToLeftBW = self.Coastline.StartPoint.Distance(self.BreakwaterL.StartPoint)
		distStartCToRightBW = self.Coastline.StartPoint.Distance(self.BreakwaterR.StartPoint)
		
		distEndCToLeftBW = self.Coastline.EndPoint.Distance(self.BreakwaterL.StartPoint)
		distEndCToRightBW = self.Coastline.EndPoint.Distance(self.BreakwaterR.StartPoint)
		
		#If start is closed to one, and end to the other, then it is clear which one is left and right
		if (distStartCToLeftBW < distStartCToRightBW) & (distEndCToLeftBW > distEndCToRightBW):
			if sendMess:
				#Keep them as is, show some message line.		
				self.lblMessage.ForeColor = _sd.Color.Black
				self.lblMessage.Text = "Left and right breakwater correctly defined"
			
		elif (distStartCToLeftBW > distStartCToRightBW) & (distEndCToLeftBW < distEndCToRightBW):
			#revert both entities, (only in dropdown menus, since it is extracted again at calculation)
			#Store entries
			itemBWL = self.dropdownBreakWaterL.SelectedItem
			itemBWR = self.dropdownBreakWaterR.SelectedItem
			
			#Swap text
			self.dropdownBreakWaterL.SelectedItem = itemBWR
			self.dropdownBreakWaterR.SelectedItem = itemBWL

			#Some message line.		
			if sendMess:
				self.lblMessage.ForeColor = _sd.Color.Black
				self.lblMessage.Text = "Left and right breakwater swapped"
			
		else:
			if sendMess:
				#Some message line.		
				self.lblMessage.ForeColor = _sd.Color.Black
				self.lblMessage.Text = "Left and right breakwater not determined. No changes"
		
		#Erase the loaded structures
		self.BreakwaterL = None
		self.BreakwaterR = None
		self.Coastline = None
		return
	#endregion

	
	#region function for calculate button
	def btnCalculate_Click(self):
		"""After clicking 'calculate!' button"""
		
		if not self.validGeometries():
			return
		
		#Get BreakWaterHeads from General Data
		self.extractGeometries()
		
		
		
		#Message for user
		self.lblMessage.ForeColor = _sd.Color.Black
		self.lblMessage.Text = "Calculating..."
		self.Refresh()

		#region extract HARBOR PARAMETERS
		#Polygon of harbor (list of (x,y)-pairs)
		harborPolygon = _wpU.CreateHarborPolygon(self.BreakwaterL, self.Coastline, self.BreakwaterR)

		#We have decided that the Endpoint will be the position of the breakwater head
		xLbw = self.BreakwaterL.EndPoint.X
		yLbw = self.BreakwaterL.EndPoint.Y
		
		xRbw = self.BreakwaterR.EndPoint.X
		yRbw = self.BreakwaterR.EndPoint.Y
		
		#Center of harbor entry (i.e. the base of the point layer) 
		harborEntry = [(xRbw+xLbw)/2, (yRbw+yLbw)/2]
				
		#Get width and angle of the BW head coordinates
		xbwDiff = (xRbw-xLbw)
		ybwDiff = (yRbw-yLbw)
		harborWidth = _np.hypot(xbwDiff, ybwDiff)						#[m] 
		deltaRad = _np.arctan2(ybwDiff, xbwDiff)						#[rad] angle of breakwaters, with harbor as positive y]
		delta = deltaRad * (180/math.pi)								#[deg]
		
		
		#Convert the waveDir towards the relative direction in degree
		#waveDir is the direction where the waves are COMING FROM, in degree northing  
		#(where 90 is straight perpendicular into harbor entry)
		relDir = (90 - delta - self.inputData.waveDir) % 360
		#endregion
		
		
		#Check if relative direction is valid
		if not self.validWaveDir(relDir):
			return
		
		
		#Define the (local) extents of the harbor, based on the geometry of the breakwaters
		#The polygon is already known. Evenso the harbor-entry-center and the angle. 
		localHarborExtend = _wpU.GetLocalHarborExtend(harborPolygon,harborEntry, deltaRad)
		
				
		#Defining local grid (with default value)
		xLocal, yLocal = _wpU.HarborMeshGrid(localHarborExtend, self.inputData.gridPoints)
		
		
		#Calculation of diagram
		Kdiffr = _wp.calcGodaDiagram(xLocal, yLocal, harborWidth, self.inputData.harborDepth, self.inputData.Hs, self.inputData.Tp, relDir, self.inputData.Smax)
		waveHeightField = Kdiffr * self.inputData.Hs
		
		
		#new at 2016-08-26: cutting the waveheight, based on the harborDepth. 
		#It should never be higher then half the depth.
		maxVal = 0.5 * self.inputData.harborDepth
		ixHighVals = waveHeightField > maxVal 
		waveHeightField[ixHighVals] = maxVal
		
		
		#Message for user
		self.lblMessage.ForeColor = _sd.Color.Black
		self.lblMessage.Text = "Drawing..."
		self.Refresh()
		
		
		#Now: writing to screen
		xGlob, yGlob = _wpU.RotateToGlobalMap(xLocal, yLocal, harborEntry, deltaRad)
		
		xVec = _np.ravel(xGlob)
		yVec = _np.ravel(yGlob)
		vVec = _np.ravel(waveHeightField)
		
		
		puntenWolk = PointCloud()
		for ind in range(_np.size(xVec)):
			
			#Check whether the point is inside the polygon of the harbor.
			if _wpU.PointInPolygon(xVec[ind], yVec[ind], harborPolygon):
				punt = PointValue()
				punt.X = xVec[ind]
				punt.Y = yVec[ind]
				punt.Value = vVec[ind]
				puntenWolk.PointValues.Add(punt)			
		
		
		#Showing the new map
		# create layer for points
		pointCloudFeatureProvider = PointCloudFeatureProvider()
		pointCloudFeatureProvider.PointCloud = puntenWolk
		
		#Determine limits of layervalues
		GolfHoogteLayer = PointCloudLayer()
		GolfHoogteLayer.DataSource = pointCloudFeatureProvider
		GolfHoogteLayer.Name = "WaveHeight"
		_GridFunc.SetGradientTheme(GolfHoogteLayer, 'Value', 6, 0, GolfHoogteLayer.MaxDataValue)
		
		
		
		#Before adding new Layer: remove the old.
		self.GroupLayer.Layers.Clear()
		
		#The layer should be added into the GroupLayer. Set it as second-last layer and zoom to extend of harbor:
		self.GroupLayer.Layers.Add(GolfHoogteLayer)
		self.mapView.Map.SendToBack(GolfHoogteLayer)
		self.mapView.Map.BringForward(GolfHoogteLayer)
		#self.mapView.Map.ZoomToFit(GolfHoogteLayer.Envelope, True)
		
		
		#Return some message after processing data
		self.lblMessage.ForeColor = _sd.Color.Green
		self.lblMessage.Text = "Wave height in harbor calculated"
	#endregion

	#region assist functions
	def validGeometries(self):
		"""
		Function to check whether all necessary geometries are present, with corresponding messageboxes
		"""
			
		#If no selection is made, then the BWs are still None, the SelectedTexts are empty
		#Also: they must be different. Check on names.
		if (self.dropdownBreakWaterL.SelectedItem == None) | (self.dropdownBreakWaterR.SelectedItem == None):
			self.lblMessage.ForeColor = _sd.Color.Red
			self.lblMessage.Text = "Required information is missing"

			_swf.MessageBox.Show("Please select two existing breakwater structures.", "No breakwater defined")
			return False
		
		elif (self.dropdownBreakWaterL.SelectedItem == self.dropdownBreakWaterR.SelectedItem):
			self.lblMessage.ForeColor = _sd.Color.Red
			self.lblMessage.Text = "Breakwaters are invalid"				
			
			_swf.MessageBox.Show("Please select two different breakwater structures.", "No breakwater defined")
			return False
		
		#Check on existence of Coastline
		if (self.dropdownCoastline.Text == ""):
			self.lblMessage.ForeColor = _sd.Color.Red
			self.lblMessage.Text = "Required information is missing"

			_swf.MessageBox.Show("Please determine a coastline.", "No coastline defined")
			return False
		
		return True
	
	
	## =============================================================
	def extractGeometries(self):
		"""
		Function to set the geometries, based on the input boxes.
		Assumed that they are valid: SelectedItem is not None
		"""
				
		#Extract the geometry of the breakwaters, based on the (non empty) selected items in the dropdown menu's
		self.BreakwaterL = self.__scenario.GenericData.CivilStructures[self.dropdownBreakWaterL.SelectedItem].StructureGeometry
		self.BreakwaterR = self.__scenario.GenericData.CivilStructures[self.dropdownBreakWaterR.SelectedItem].StructureGeometry
		self.Coastline = self.__scenario.GenericData.Coastline.CoastlineGeometry
		return
	
	
	## =============================================================
	def validWaveDir(self, relDir):
		"""
		Function to get a warning/message when waves are not coming in.
		RELDIR in nautic degrees
		
		RELDIR should be between 0 and +180, otherwise: the wave will not enter, but move away
		"""
		
		#Minimal value is always 0 (since modulo), so
		if (relDir > 180.):
			#visualy direct the user towards the textbox
			self.tbDirection.BackColor = _sd.Color.PeachPuff
			
			#In message line.		
			self.lblMessage.ForeColor = _sd.Color.Red
			self.lblMessage.Text = "Invalid wave direction"
			
			#Message for user.
			_swf.MessageBox.Show("Please enter wave direction with incoming\nwaves with respect to the harbor entry.","Specify wave direction")
			return False
		else:
			#Reset color when succesfull change
			self.tbDirection.BackColor = _sd.SystemColors.Window
			return True
	
	#endregion
