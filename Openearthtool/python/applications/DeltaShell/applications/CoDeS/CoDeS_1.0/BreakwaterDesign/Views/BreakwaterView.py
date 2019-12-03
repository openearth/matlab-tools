#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
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
import os
import clr

clr.AddReference("System.Windows.Forms")
from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Utilities.PythonObjects as _PythonObjects
from SharpMap.UI.Tools import NewLineTool
from SharpMap.Editors.Interactors import Feature2DEditor
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *

from System.Windows.Forms import DateTimePickerFormat
from System.Windows.Forms import MessageBox
from System.Windows.Forms import HorizontalAlignment
from System.Windows.Forms import TabPage
from System.Windows.Forms import DataGridView
from System.Windows.Forms import FolderBrowserDialog
from System.Windows.Forms import DialogResult
from System.Windows.Forms import RadioButton
from System.Windows.Forms import Panel
from System.Windows.Forms import CheckBox
from System.Windows.Forms import ComboBox
from System.Windows.Forms import NumericUpDown
from System.Windows.Forms import TrackBar
from System.Windows.Forms import BorderStyle,TableLayoutPanel, TableLayoutPanelGrowStyle, RowStyle,ColumnStyle, SizeType
from System.Windows.Forms import Button, DockStyle, AnchorStyles, Padding
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as _Env
from SharpMap.Extensions.Layers import OpenStreetMapLayer as _OSML
from SharpMap.Extensions.Layers import GdalRegularGridRasterLayer as _RegularGridRasterLayer

import Scripts.BreakwaterDesign.Utilities.EngineFunctionsBreakwater as bw
import Scripts.BreakwaterDesign.Utilities.BreakwaterCalculation as bwcalculation
import Scripts.BreakwaterDesign.Utilities.PlottingFunctionsBreakwater as bwplot
from Scripts.LinearWaveTheory.Utilities import plotLinWaveTheory as lw

from Scripts.GeneralData.Utilities import GridFunctions as _GridFunctions
import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions
from Scripts.GeneralData.Utilities import CoDesMapTools as _CoDesMapTools
from Scripts.GeneralData.Entities import Scenario as _Scenario 
from Scripts.BreakwaterDesign.Entities.BreakwaterData import BreakwaterData as _BreakwaterData



#import Scripts.BreakwaterDesign. as bw
from NetTopologySuite.Extensions.Features import Feature
import numpy as np

import System.Drawing as s


#========================
#define the label SPACING
#========================
sp_loc = 5 #start point/location for labels (from left edge)
label_width = 170 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 30 #vertical spacing between labels (from previous)
vert_sp = 10 # start point/location for labels (from top edge)
#combo = ComboBox()
#combo.Items.SyncRoot

def RefreshTool(inputData,scenario,oldView):
	Gui.DocumentViews.Remove(oldView)
	oldView.Dispose()
	inputView = BreakwaterView(inputData,scenario)
	inputView.Show()

class BreakwaterView(BaseView):
	
	def __init__(self, inputData,scenario):		
		BaseView.__init__(self)		
		self.InputData = inputData
		
		self.__scenario = scenario
		self.ToolDataAvailable = False
		if 'BreakwaterData' in self.__scenario.ToolData:
			self.InputData = self.__scenario.ToolData['BreakwaterData'].inputData
			self.InputData.unbindall()
			self.ToolDataAvailable = True
		
		# Make sure InputData is always saved when changed
		self.__scenario.ToolData['BreakwaterData'] = _BreakwaterData(self.InputData)
		self.InputData.bind_to(self.SaveToToolData)
		
		# Do NOT change text of View:
		self.Text = "Breakwater Design"
		# The selected structure
		self.currentStructure = None
		
		# Create in-memory mapview for displaying breakwater later on
		self.MakeMapView()
		
		# 	Create panel to contain mapview
		
		self.group_MAP = Panel()
		self.group_MAP.Dock = DockStyle.Fill
		self.group_MAP.Controls.Add(self.mapview)
		
		#	Make sure map controls are working
		self.ChildViews.Add(self.mapview)
		self.rightPanel.Controls.Add(self.group_MAP)
				
		self.inputTabs = self.make_InputTabs(False)
		
		self.buttonCalculate = Button()
		self.buttonCalculate.Dock = DockStyle.Bottom
		self.buttonCalculate.Text = "Calculate"
		self.buttonCalculate.Height = label_width/5
		self.buttonCalculate.Width = label_width*0.5
		self.buttonCalculate.Click += lambda s,e : self.StartBreakwaterCalculation(s,e)
		
		#group_INTABS.Controls.Add(self.buttonCalculate)
		
		self.leftPanel.Controls.Add(self.buttonCalculate)
		self.leftPanel.Controls.Add(self.inputTabs)
		
		#self.leftPanel.Controls.Add(group_INTABS)
		self.rightPanel.Controls.Add(self.group_MAP)
		
		if not self.InputData.is2D:
			self.group_MAP.Visible = False
		
		
		#self.buttonCalculate.BringToFront()

	def make_InputTabs(self,isFrozen):
		
		inputTabs = TabControl()
		inputTabs.Dock = DockStyle.Fill
		#inputTabs.Width = 2*label_width+3*spacer_width
		
		self.tab_GENERAL = TabPage()
		self.tab_GENERAL.Text = "General"
		self.tab_GENERAL.Enabled = not isFrozen		
		self.CreateInputDataGroupBox_GENERAL()
		inputTabs.Controls.Add(self.tab_GENERAL)
		
		
		inputGroup_WAVES = self.CreateInputDataGroupBox_WAVES()
		inputGroup_STONE = self.CreateInputDataGroupBox_STONE()
		inputGroup_FAC = self.CreateInputDataGroupBox_FAC()
		inputGroup_UNITCOST = self.CreateInputDataGroupBox_UNITCOST()
		
		
		#self.tab_GENERAL.Controls.Add(inputGroup_GENERAL)
		
		
		self.tab_WAVE = TabPage()
		self.tab_WAVE.Controls.Add(inputGroup_WAVES)
		self.tab_WAVE.Text = "Wave"
		self.tab_WAVE.Enabled = not isFrozen
		inputTabs.Controls.Add(self.tab_WAVE)
		
		self.tab_STONE = TabPage()
		self.tab_STONE.Text = "Armour"
		self.tab_STONE.Controls.Add(inputGroup_STONE)
		self.tab_STONE.Enabled = not isFrozen
		inputTabs.Controls.Add(self.tab_STONE)
		
		self.tab_FAC = TabPage()
		self.tab_FAC.Text = "Reduction factors"
		self.tab_FAC.Controls.Add(inputGroup_FAC)
		self.tab_FAC.Enabled = not isFrozen
		inputTabs.Controls.Add(self.tab_FAC)
		
		self.tab_UNIT = TabPage()
		self.tab_UNIT.Text = "Unit rates"
		self.tab_UNIT.Controls.Add(inputGroup_UNITCOST)
		self.tab_UNIT.Enabled = not isFrozen
		inputTabs.Controls.Add(self.tab_UNIT)
		
		return inputTabs

	def CreateInputDataGroupBox_GENERAL(self):
		
		def check_for_1D(sender): # Checks if user checked 1D or 2D
			if sender.Text == "2D":
				self.InputData.is2D = False				
				self.group_MAP.Visible = False
				self.bathyLabel.Visible = False
				self.bathyText.Visible = False
				self.structureLabel.Visible = False
				self.structureCombo.Visible = False
				self.btnRefreshData.Visible = False
				
				if not self.tab_GENERAL.Controls.Contains(Lab_z):
					self.tab_GENERAL.Controls.Add(Lab_z)
					self.tab_GENERAL.Controls.Add(Tb_z)
			if sender.Text == "3D":
				self.InputData.is2D = True
				self.group_MAP.Visible = True
				self.bathyLabel.Visible = True
				self.bathyText.Visible = True
				self.structureLabel.Visible = True
				self.structureCombo.Visible = True
				self.btnRefreshData.Visible = True
				
				if self.tab_GENERAL.Controls.Contains(Lab_z):
					self.tab_GENERAL.Controls.Remove(Lab_z)
					self.tab_GENERAL.Controls.Remove(Tb_z)
		
		def check_for_autocrest(sender): # Checks for autocrest and removes labels
			if sender.Checked:
				self.InputData.autocrest = True
				if self.tab_GENERAL.Controls.Contains(Lab_Ch):
					self.tab_GENERAL.Controls.Remove(Lab_Ch)
					self.tab_GENERAL.Controls.Remove(Tb_Ch)
				if not self.tab_GENERAL.Controls.Contains(safetylevelCombo):
					self.tab_GENERAL.Controls.Add(safetylevelCombo)
					self.tab_GENERAL.Controls.Add(safetylevelLabel)
					self.tab_GENERAL.Controls.Add(QthresLabel)
			else:
				self.InputData.autocrest = False
				if not self.tab_GENERAL.Controls.Contains(Lab_Ch):
					self.tab_GENERAL.Controls.Add(Lab_Ch)
					self.tab_GENERAL.Controls.Add(Tb_Ch)
				if self.tab_GENERAL.Controls.Contains(safetylevelCombo):
					self.tab_GENERAL.Controls.Remove(safetylevelCombo)
					self.tab_GENERAL.Controls.Remove(safetylevelLabel)
					self.tab_GENERAL.Controls.Remove(QthresLabel)
		
		def change_qthres(sender):
			self.InputData.qthres = bw.get_Qthres_Index(sender.SelectedIndex)
			self.InputData.situation = sender.SelectedItem
			self.InputData.situationIndex = sender.SelectedIndex
			alowovertop = ("%.4f" % self.InputData.qthres).rstrip('0').rstrip('.')
			QthresLabel.Text = "Allowable overtopping = " + alowovertop + " l/s/m" 
		
		def change_Structure(sender):
			self.currentStructure = self.__scenario.GenericData.CivilStructures[sender.SelectedItem]
			self.mapview.MapControl.SelectTool.Clear()
			#self.InputData.mapview.MapControl.SelectTool.Select([self.__scenario.GenericData.CivilStructures[sender.SelectedItem].StructureLayer.DataSource.Features[0]])
		
		counter = 0
		radiobuttonLabel = Label()
		radiobuttonLabel.Text = "Method:"
		radiobuttonLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		radiobuttonLabel.Width = label_width
		self.tab_GENERAL.Controls.Add(radiobuttonLabel)
		
		radiobutton2D = RadioButton()
		radiobutton2D.Text = "3D"
		radiobutton2D.Location = s.Point(sp_loc+label_width+spacer_width,vert_spacing * counter+vert_sp)
		radiobutton2D.Width = 0.4*label_width
		if self.InputData.is2D:
			radiobutton2D.Checked = True
		else:
			radiobutton2D.Checked = False
		if (self.group_MAP != None):
			radiobutton2D.CheckedChanged += lambda s,e : check_for_1D(s)
		self.tab_GENERAL.Controls.Add(radiobutton2D)
		
		radiobutton1D = RadioButton()
		radiobutton1D.Text = "2D"
		radiobutton1D.Location = s.Point(sp_loc+1.5*label_width,vert_spacing * counter+vert_sp)
		if self.InputData.is2D:
			radiobutton1D.Checked = False
		else:
			radiobutton1D.Checked = True
		if (self.group_MAP != None):
			radiobutton1D.CheckedChanged += lambda s,e : check_for_1D(s)
		self.tab_GENERAL.Controls.Add(radiobutton1D)
		
		
		counter = counter + 1
		checkboxAutoCrest = CheckBox()
		checkboxAutoCrest.Text = "Automated crestheight calculation"
		checkboxAutoCrest.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		checkboxAutoCrest.AutoSize = True
		if self.InputData.autocrest:
			checkboxAutoCrest.Checked = True
		else:
			checkboxAutoCrest.Checked = False
		
		checkboxAutoCrest.CheckedChanged += lambda s,e : check_for_autocrest(s)
		self.tab_GENERAL.Controls.Add(checkboxAutoCrest)
		
		counter = counter + 1
		[Lab_cota,Tb_cota] = _PythonObjects.CreateInputLabelAndNumeric(self.tab_GENERAL, "Slope 1:", self.InputData,"cota", vert_spacing * counter+vert_sp,1,8,1,1)
		counter = counter + 1
		[Lab_Cw,Tb_Cw] = _PythonObjects.CreateInputLabelAndNumeric(self.tab_GENERAL, "Crestwidth (m)", self.InputData,"crestwidth", vert_spacing * counter+vert_sp,1,100,2,0.25)
		counter = counter + 1
		[Lab_Ch,Tb_Ch] = _PythonObjects.CreateInputLabelAndNumeric(self.tab_GENERAL, "Crestheight (m+MSL)", self.InputData,"crestheight", vert_spacing * counter+vert_sp,0,100,2,0.25)
		counter = counter + 1
		[Lab_z,Tb_z] = _PythonObjects.CreateInputLabelAndNumeric(self.tab_GENERAL, "Local depth (m)", self.InputData,"z", vert_spacing * counter+vert_sp,0,1000000,1,0.5)
		
		
		
		if radiobutton2D.Checked:
			self.tab_GENERAL.Controls.Remove(Lab_z)
			self.tab_GENERAL.Controls.Remove(Tb_z)
		if checkboxAutoCrest.Checked:
			self.tab_GENERAL.Controls.Remove(Lab_Ch)
			self.tab_GENERAL.Controls.Remove(Tb_Ch)
		
		counter = counter + 1
		safetylevelCombo = ComboBox()
		safetyLevelCombo = bw.get_situation_list(safetylevelCombo)
		safetylevelCombo.Location = s.Point(sp_loc+0.75*label_width,vert_spacing * counter+vert_sp)
		safetylevelCombo.Width = 1.25*label_width
		safetylevelCombo.SelectedIndex = self.InputData.situationIndex
		self.InputData.qthres = bw.get_Qthres_Index(safetylevelCombo.SelectedIndex)
		self.InputData.situation = safetylevelCombo.SelectedItem
		safetylevelCombo.SelectionChangeCommitted += lambda s,e : change_qthres(s)
		
		safetylevelLabel = Label()
		safetylevelLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		safetylevelLabel.Text = "Safety level"
		safetylevelLabel.Width = 0.75*label_width
		
		counter = counter + 1
		QthresLabel = Label()
		alowovertop = ("%.4f" % float(self.InputData.qthres)).rstrip('0').rstrip('.')
		QthresLabel.Text = "Allowable overtopping = " + alowovertop + " l/s/m" 
		QthresLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		QthresLabel.AutoSize = True
		
		if checkboxAutoCrest.Checked:
			self.tab_GENERAL.Controls.Add(safetylevelCombo)
			self.tab_GENERAL.Controls.Add(safetylevelLabel)
			self.tab_GENERAL.Controls.Add(QthresLabel)
			self.tab_GENERAL.Controls.Remove(Lab_Ch)
			self.tab_GENERAL.Controls.Remove(Tb_Ch)
		
		counter = counter + 1
		
		self.bathyLabel = Label()
		self.bathyLabel.Text = "Bathymetry"
		self.bathyLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		self.bathyLabel.Width = 80
		
		self.bathyText = RichTextBox()		
		self.bathyText.Enabled = False
		
		self.bathyText.Location = s.Point(sp_loc + 0.75*label_width,vert_spacing * counter+vert_sp)
		self.bathyText.Width = 1.25*label_width
		self.bathyText.Height = 3*vert_spacing
		
		counter = counter + 3.25
		
		self.structureLabel = Label()
		self.structureLabel.Text = "Structure"
		self.structureLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		self.structureLabel.Width = 80
		
		#	Choose Civilstructure to use as basis for the design
		
		self.structureCombo = ComboBox()		
		self.structureCombo.Location = s.Point(sp_loc + 0.75*label_width,vert_spacing * counter+vert_sp)
		self.structureCombo.Width = 1.25*label_width
		self.structureCombo.SelectionChangeCommitted += lambda s,e : change_Structure(s)
		
		counter = counter+1
		
		self.btnRefreshData = Button()
		self.btnRefreshData.Location = s.Point(sp_loc + 0.75*label_width,vert_spacing * counter+vert_sp)
		self.btnRefreshData.Text = "Refresh General Data"
		self.btnRefreshData.Width = 150
		self.btnRefreshData.Click += lambda s,e: self.CheckGenericDataAndFillText()
		
		self.tab_GENERAL.Controls.Add(self.btnRefreshData)
		self.tab_GENERAL.Controls.Add(self.bathyLabel)
		self.tab_GENERAL.Controls.Add(self.bathyText)
		self.tab_GENERAL.Controls.Add(self.structureLabel)
		self.tab_GENERAL.Controls.Add(self.structureCombo)
		
		if not self.InputData.is2D:
			self.bathyLabel.Visible = False
			self.bathyText.Visible = False
			self.structureLabel.Visible = False
			self.structureCombo.Visible = False
			self.btnRefreshData.Visible = False
		
		self.CheckGenericDataAndFillText()
		
	def SaveToToolData(self,inputData):
		self.__scenario.ToolData['BreakwaterData'] = _BreakwaterData(self.InputData)
		
	def CheckGenericDataAndFillText(self):
		
		#	Check type of bathymetry which is present
		currentBathymetry = self.__scenario.GenericData.Bathymetry
		
		bathymetryText = ""
		
		if currentBathymetry <> None:
			if currentBathymetry.BathymetryType == "Asciigrid":
				
				bathyPath = self.CheckBathymetryPresence()
				bathymetryText = "Ascii-grid (" + bathyPath + ")"
				
			elif currentBathymetry.BathymetryType == "Slope":
				bathymetryText = "Slope 1:" + str(currentBathymetry.SlopeValue) 
		
		# Fill in BathyText
		self.bathyText.Text = bathymetryText
		
		#	Check if coastline has been selected
		#coastlineName = ""		
		
		#if self.__scenario.GenericData.Coastline <> None:
		#	coastlineName =  self.__scenario.GenericData.Coastline.Name
		
		#self.coastlineText.Text = coastlineName
		
		# Clear Combo box
		self.structureCombo.Items.Clear()
		
		# Fill in Combo box
		for structureName in self.__scenario.GenericData.CivilStructures.keys():
			self.structureCombo.Items.Add(structureName)
		
		if len(self.__scenario.GenericData.CivilStructures)>0:
			self.structureCombo.SelectedIndex = 0
			self.currentStructure = self.__scenario.GenericData.CivilStructures[self.structureCombo.SelectedItem]
		
	def CreateInputDataGroupBox_WAVES(self):
		
		#Check for Nearshore
		def check_if_NS(group_IN,sender):
			if sender.Text == "Nearshore":
				self.InputData.isOffshore = False
				if group_IN.Controls.Contains(Lab_OD):
					group_IN.Controls.Remove(Lab_OD)
					group_IN.Controls.Remove(Tb_OD)
			if sender.Text == "Offshore":
				self.InputData.isOffshore = True
				if not group_IN.Controls.Contains(Lab_OD):
					group_IN.Controls.Add(Lab_OD)
					group_IN.Controls.Add(Tb_OD)
		
		
		group_IN = Panel()
		#group_IN.Text = "Input"
		#group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
		group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
		group_IN.Dock = DockStyle.Fill
		
		counter = 0
		radiobuttonLabel = Label()
		radiobuttonLabel.Text = "Location:"
		radiobuttonLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		radiobuttonLabel.Width = label_width
		group_IN.Controls.Add(radiobuttonLabel)
		
		radiobutton1 = RadioButton()
		radiobutton1.Text = "Offshore"
		if self.InputData.isOffshore: 
			radiobutton1.Checked = True
		radiobutton1.Location = s.Point(sp_loc+label_width,vert_spacing * counter+vert_sp)
		
		#if (group_MAP != None):
		radiobutton1.CheckedChanged += lambda s,e : check_if_NS(group_IN,s)
		group_IN.Controls.Add(radiobutton1)
		
		counter = counter +1
		radiobutton2 = RadioButton()
		radiobutton2.Text = "Nearshore"
		if not self.InputData.isOffshore:
			radiobutton2.Checked = True
		radiobutton2.Location = s.Point(sp_loc+label_width,vert_spacing * counter+vert_sp)
		radiobutton2.CheckedChanged += lambda s,e : check_if_NS(group_IN,s)
		group_IN.Controls.Add(radiobutton2)
		
		counter = counter + 1
		[self.Lab_Hs,self.Tb_Hs] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Hs (m)", self.InputData,"Hs0", vert_spacing * counter+vert_sp,0.1,20,2,0.25)
		counter = counter + 1
		[Lab_Tp,Tb_Tp] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Tp (s)", self.InputData,"Tp0", vert_spacing * counter+vert_sp,0,50,1,0.2)
		counter = counter + 1
		[Lab_Dir,Tb_Dir] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Dir (degSN)", self.InputData,"theta0", vert_spacing * counter+vert_sp,0,90,0,5)
		counter = counter + 1
		[Lab_SWL,Tb_SWL] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "SWL (m+MSL)", self.InputData,"SWL", vert_spacing * counter+vert_sp,-20,20,2,0.25)
		counter = counter + 1
		[Lab_SD,Tb_SD] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Stormduration (h)", self.InputData,"stormdur", vert_spacing * counter+vert_sp,1,20000,1,1)
		counter = counter + 1
		[Lab_GBr,Tb_GBr] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Breaker parameter", self.InputData,"gammabreak", vert_spacing * counter+vert_sp,0.4,1,2,0.01)
		counter = counter + 1
		[Lab_OD,Tb_OD] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Offshore Depth (m)", self.InputData,"z0", vert_spacing * counter+vert_sp,0.1,10000000,1,0.1)
		
		
		if not self.InputData.isOffshore:
			group_IN.Controls.Remove(Lab_OD)
			group_IN.Controls.Remove(Tb_OD)
		
		
		return group_IN

	def CreateInputDataGroupBox_STONE(self):
		
		def change_armourtype(sender):
			self.InputData.Armour_Type = sender.SelectedItem
			self.InputData.Armour_TypeIndex = sender.SelectedIndex
		
		group_IN = Panel()
		#group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
		group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
		group_IN.Dock = DockStyle.Fill
		
		counter = 0
		armourtypeCombo = ComboBox()
		armourtypeCombo = bw.get_armour_types(armourtypeCombo)
		
		armourtypeCombo.Location = s.Point(sp_loc+label_width,vert_spacing * counter+vert_sp)
		armourtypeCombo.Width = label_width
		armourtypeCombo.SelectedIndex = self.InputData.Armour_TypeIndex
		self.InputData.Armour_Type = armourtypeCombo.SelectedItem
		armourtypeCombo.SelectionChangeCommitted += lambda s,e : change_armourtype(s)
		group_IN.Controls.Add(armourtypeCombo)
		
		armourtypeLabel = Label()
		armourtypeLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
		armourtypeLabel.Text = "Armour type"
		armourtypeLabel.Width = label_width
		group_IN.Controls.Add(armourtypeLabel)
		
		
		
		counter = counter + 1
		[Lab_RD,Tb_RD] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Rock Density (kg/m3)", self.InputData,"rhos", vert_spacing * counter+vert_sp,100,10000,0,10)
		counter = counter + 1
		[Lab_WD,Tb_WD] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Water Density (kg/m3)", self.InputData,"rhow", vert_spacing * counter+vert_sp,100,10000,0,10)
		counter = counter + 1
		[Lab_LC,Tb_LC] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Layer coefficient (kt)", self.InputData,"kt", vert_spacing * counter+vert_sp,0,1,2,.01)
		counter = counter + 1
		[Lab_P,Tb_P] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Notional permeability (P)", self.InputData,"P", vert_spacing * counter+vert_sp,0.1,0.6,1,0.1)
		counter = counter + 1
		[Lab_S,Tb_S] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Damage number (S)", self.InputData,"S", vert_spacing * counter+vert_sp,1,17,0,1)
		
		
		return group_IN
	
	def CreateInputDataGroupBox_FAC(self):
		
		group_IN = Panel()
		#group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
		group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
		group_IN.Dock = DockStyle.Fill
		
		counter = 0
		[Lab_GBe,Tb_GBe] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Berm reduction", self.InputData,"gammab", vert_spacing * counter+vert_sp,0.1,1,2,0.1)
		counter = counter + 1
		[Lab_GF,Tb_GF] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Roughness reduction", self.InputData,"gammaf", vert_spacing * counter+vert_sp,0.1,1,2,0.1)
		counter = counter + 1
		[Lab_AI,Tb_AI] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Angle of incidence (deg)", self.InputData,"angleinc", vert_spacing * counter+vert_sp,0,90,0,1)
		
		return group_IN

	def CreateInputDataGroupBox_UNITCOST(self):
		
		group_IN = Panel()
		#group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
		group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
		group_IN.Dock = DockStyle.Fill
		
		counter = 0
		[Lab_GBe,Tb_GBe] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Unitrate Armour (E/m3)", self.InputData,"unitCostArmour", vert_spacing * counter+vert_sp,1,1000000,1,1)
		counter = counter + 1
		[Lab_GF,Tb_GF] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Unitrate Filter (E/m3)", self.InputData,"unitCostFilter", vert_spacing * counter+vert_sp,1,1000000,1,1)
		counter = counter + 1
		[Lab_AI,Tb_AI] = _PythonObjects.CreateInputLabelAndNumeric(group_IN, "Unitrate Core (E/m3)", self.InputData,"unitCostCore", vert_spacing * counter+vert_sp,1,1000000,1,1)
		
		return group_IN
	

	def CheckBathymetryPresence(self):
		#	Check if bathymetry is present in Scenario.GenericData
		
		if self.__scenario.GenericData.Bathymetry <> None:
			currentBathy = self.__scenario.GenericData.Bathymetry
			#	Check if file exists on disk
			
			if os.path.isfile(currentBathy.SourcePath):
				return currentBathy.SourcePath
		
		
		return ""
			
	def MakeMapView(self):
		
		self.mapview = MapView()
		self.mapview.Map = self.__scenario.GeneralMap
		self.mapview.Dock = DockStyle.Fill
		_CoDesMapTools.ShowLegend(self.mapview)
		SR_code = self.__scenario.GenericData.SR_EPSGCode

	def make_OutputTabs(self):
		self.outputTabs = TabControl()
		self.outputTabs.Dock = DockStyle.Fill
		self.outputTabs.Width = 2*label_width+3*spacer_width
		
		self.plot1 =  bwplot.Plot_Crossection(self.InputData,self.OutputData)
		
		self.tab_PLOT1 = TabPage() #for the plot
		self.tab_PLOT1.Text = "Cross-section"
		self.tab_PLOT1.Controls.Add(self.plot1)
		
		def Slider_changed(sender,plot3):
			# Re-create plot for cross-section
			self.OutputData.cross_ind = sender.Value-1
			self.InputData.cross_ind = sender.Value-1
			for ind in range(0,len(self.tab_PLOT1.Controls)):
				if self.tab_PLOT1.Controls[ind].Text == "Plot1":
					ind_to_rem = ind
			self.tab_PLOT1.Controls.Remove(self.tab_PLOT1.Controls[ind_to_rem])
			plot2 =  bwplot.Plot_Crossection(self.InputData,self.OutputData)
			self.tab_PLOT1.Controls.Add(plot2)
			plot2.BringToFront()
			
			# Re-create volume text
			Volumes_Text = bwplot.Create_VolumesText(self.InputData,self.OutputData)
			self.Outputlabel3.Text = Volumes_Text
			
			# Re-create profile figure
			lw.addBreakwaterDashes_ind(plot3, self.OutputData.profile, self.OutputData.cross_ind)
			
		if self.InputData.is2D:
			chart2 = lw.plotProfile(self.OutputData.profile,self.OutputData.crestheight,self.OutputData.layer) # Chart Profile
			#chart2 = lw.addBreakWaterDashes(chart2,self.InputData.profile)
			plot3 = ChartView()
			plot3.Chart = chart2
			plot3.Dock = DockStyle.Fill
			lw.addBreakwaterDashes_ind(plot3, self.OutputData.profile, self.OutputData.cross_ind)
			tab_PLOT2 = TabPage()
			tab_PLOT2.Text = "Profile"
			tab_PLOT2.Controls.Add(plot3)
		
		if self.InputData.is2D:
			Slider = TrackBar()
			#Slider.Size = Size(150, 30)
			Slider.Dock = DockStyle.Bottom
			Slider.Minimum = 1
			Slider.Maximum = len(self.OutputData.profile['mean_z'])
			Slider.TickFrequency = 1
			Slider.LargeChange = 1
			Slider.SmallChange = 1
			Slider.Text = "Cross-section number"
			Slider.Value = self.OutputData.cross_ind+1
			Slider.ValueChanged += lambda s,e : Slider_changed(s,plot3)
			self.tab_PLOT1.Controls.Add(Slider)
		
		if self.InputData.is2D:
			tab_MAP1 = TabPage()
			tab_MAP1.Text = "Map"
			MapOut1 = MapView()
			MapOut1.Map = self.__scenario.GeneralMap
			_CoDesMapTools.ShowLegend(MapOut1)
			MapOut1.Dock = DockStyle.Fill
			tab_MAP1.Controls.Add(MapOut1)
		else:
			MapOut1 = []
		
		
		
		self.Dimensions_Text = bwplot.Create_DimensionsText(self.InputData,self.OutputData)
		self.Conditions_Text = bwplot.Create_ConditionsText(self.InputData,self.OutputData)
		self.Volumes_Text = bwplot.Create_VolumesText(self.InputData,self.OutputData)
		self.Overtopping_Text = bwplot.Create_OvertoppingText(self.InputData,self.OutputData)
				
		tab_TEXT1 = TabPage()
		tab_TEXT2 = TabPage()
		tab_TEXT3 = TabPage()
		tab_TEXT4 = TabPage()
		
		self.Outputlabel1 = RichTextBox()
		self.Outputlabel1.Dock = DockStyle.Fill
		self.Outputlabel1.Font = s.Font(self.Outputlabel1.Font.FontFamily, 10)
		self.Outputlabel1.BackColor = Color.FromArgb(249,249,249)
		self.Outputlabel1.BorderStyle = BorderStyle.None
		self.Outputlabel1.ReadOnly = True
		self.Outputlabel1.Text = self.Dimensions_Text
		tab_TEXT1.Controls.Add(self.Outputlabel1)
		tab_TEXT1.Text = "Dimensions"
		
		self.Outputlabel2 = RichTextBox()
		self.Outputlabel2.Dock = DockStyle.Fill
		self.Outputlabel2.Font = s.Font(self.Outputlabel2.Font.FontFamily, 10)
		self.Outputlabel2.BackColor = Color.FromArgb(249,249,249)
		self.Outputlabel2.BorderStyle = BorderStyle.None
		self.Outputlabel2.ReadOnly = True
		self.Outputlabel2.Text = self.Conditions_Text
		tab_TEXT2.Controls.Add(self.Outputlabel2)
		tab_TEXT2.Text = "Conditions"
		
		self.Outputlabel3 = RichTextBox()
		self.Outputlabel3.Font = s.Font(self.Outputlabel3.Font.FontFamily, 10)
		self.Outputlabel3.Dock = DockStyle.Fill
		self.Outputlabel3.BackColor = Color.FromArgb(249,249,249)
		self.Outputlabel3.BorderStyle = BorderStyle.None
		self.Outputlabel3.ReadOnly = True
		self.Outputlabel3.Text = self.Volumes_Text
		tab_TEXT3.Controls.Add(self.Outputlabel3)
		tab_TEXT3.Text = "Volumes & Costs"
		
		self.Outputlabel4 = RichTextBox()
		self.Outputlabel4.Dock = DockStyle.Fill
		self.Outputlabel4.Font = s.Font(self.Outputlabel4.Font.FontFamily, 10)
		self.Outputlabel4.BackColor = Color.FromArgb(249,249,249)
		self.Outputlabel4.BorderStyle = BorderStyle.None
		self.Outputlabel4.ReadOnly = True
		self.Outputlabel4.Text = self.Overtopping_Text
		tab_TEXT4.Controls.Add(self.Outputlabel4)
		tab_TEXT4.Text = "Overtopping"
		
		self.outputTabs.Controls.Add(self.tab_PLOT1)
		if self.InputData.is2D:
			self.outputTabs.Controls.Add(tab_PLOT2)
		if self.InputData.is2D:
			self.outputTabs.Controls.Add(tab_MAP1)
			#ChildViews.Add(MapOut1)
		
		self.outputTabs.Controls.Add(tab_TEXT1)
		self.outputTabs.Controls.Add(tab_TEXT2)
		self.outputTabs.Controls.Add(tab_TEXT3)
		self.outputTabs.Controls.Add(tab_TEXT4)
		
	def ChangeofBreakWaterinput(self,inputData):
		#self.InputData = inputData
		self.OutputData = bwcalculation.CalculateBreakwater(self.InputData)
		
		# Update texts in output tabs
		self.Dimensions_Text = bwplot.Create_DimensionsText(self.InputData,self.OutputData)
		self.Conditions_Text = bwplot.Create_ConditionsText(self.InputData,self.OutputData)
		self.Volumes_Text = bwplot.Create_VolumesText(self.InputData,self.OutputData)
		self.Overtopping_Text = bwplot.Create_OvertoppingText(self.InputData,self.OutputData)
		
		self.Outputlabel1.Text = self.Dimensions_Text
		self.Outputlabel2.Text = self.Conditions_Text
		self.Outputlabel3.Text = self.Volumes_Text
		self.Outputlabel4.Text = self.Overtopping_Text
		
		# Re create cross-section plot
		for ind in range(0,len(self.tab_PLOT1.Controls)):
			if self.tab_PLOT1.Controls[ind].Text == "Plot1":
				ind_to_rem = ind
		self.tab_PLOT1.Controls.Remove(self.tab_PLOT1.Controls[ind_to_rem])
		plot2 =  bwplot.Plot_Crossection(self.InputData,self.OutputData)
		self.tab_PLOT1.Controls.Add(plot2)
		plot2.BringToFront()
		
		# Safe input data to ToolData
		self.__scenario.ToolData['BreakwaterData'] = _BreakwaterData(self.InputData)
		#self.__scenario.ToolData.BreakwaterData = _BreakwaterData(self.InputData)
		# Unbind all observers in the ToolData
		#self.__scenario.ToolData.BreakwaterData.inputData.unbindall()
		
	
	def StartBreakwaterCalculation(self,sender,e):
		
		self.InputData.profile = {}
		self.IsNegative = False
		# Check if Breakwater is clicked
		if self.currentStructure==None and self.InputData.is2D:
			MessageBox.Show("Please click a breakwater structure via the General Data tab","No breakwater defined!")
			return
				
		# Check if crestheight is above SWL
		
		if not self.InputData.autocrest and self.InputData.crestheight <= self.InputData.SWL:
			MessageBox.Show("Please increase the crest height","Crestheight is lower than SWL")
			return
			
		if self.InputData.is2D:
					
			# Check if grid is present in scenario object
			
			currentBathymetry = self.__scenario.GenericData.Bathymetry
			
			if currentBathymetry <> None:
				if currentBathymetry.BathymetryType == "Asciigrid": 
					BathymetryPath = currentBathymetry.SourcePath
			
					if BathymetryPath <> "":
						
						# Get bathy grid from path
						grid = bw.get_bathygrid(BathymetryPath)		
						
						# Check if the depth values need to be multiplied by -1 to make them positive
						
						Multiplication = 1
						
						if currentBathymetry.IsDepth == False:									
							Multiplication = -1	
						
						# Get lineGeometry from layer
						
						LineGeometry = self.currentStructure.StructureGeometry 
						
						# Get profile
						Profile = _GridFunctions.GetProfileFromGrid(LineGeometry,grid,self.__scenario.GenericData.SR_EPSGCode,self.InputData.ProfileSteps)
						#BWlineClone = LineGeometry.Clone()
						self.InputData.profile['dist'] = np.array(Profile["dist_UTM"])
						self.InputData.profile['z'] = np.array(Profile["Z"]) * Multiplication
						self.InputData.profile['x'] = np.array(Profile["UTM_X"])
						self.InputData.profile['y'] = np.array(Profile["UTM_Y"])
				elif currentBathymetry.BathymetryType == "Slope":					
					if self.__scenario.GenericData.Coastline == None:
						MessageBox.Show("A coastline geometry is needed to use a slope bathymetry. Please draw a coastline via the General Data tab")
						return
					
					
					# Check if the depth values need to be multiplied by -1 to make them positive
					# Get lineGeometry from layer
					
					LineGeometry = self.currentStructure.StructureGeometry
										
					# Get profile
					Profile = _GridFunctions.GetProfileFromSlope(LineGeometry,self.__scenario.GenericData.SR_EPSGCode,self.InputData.ProfileSteps,self.__scenario.GenericData.Coastline.CoastlineGeometry,currentBathymetry.SlopeValue)
					
					#BWlineClone = LineGeometry.Clone()
					self.InputData.profile['dist'] = np.array(Profile["dist_UTM"])
					self.InputData.profile['z'] = np.array(Profile["Z"]) 
					self.InputData.profile['x'] = np.array(Profile["UTM_X"])
					self.InputData.profile['y'] = np.array(Profile["UTM_Y"]) 
					
			else:
				MessageBox.Show("There is no bathymetry defined. Please add a bathymetry via the General Data tab")
				return
		else:
			BWlineClone = []
			LineGeometry = []
		
		
		inputClone =  self.InputData.Clone()
		
		if self.InputData.is2D:
			# Check if all depths are positive
			if np.all(inputClone.profile['z'] < 0):
				self.IsNegative = True
	
		if self.IsNegative:
			MessageBox.Show("No bathymetry data found or you defined your breakwater on land. \nPlease redefine breakwater","No data or land data")
			return
		
		
		self.OutputData = bwcalculation.CalculateBreakwater(self.InputData)
		
		
		# Bind oberservs to input data, for dynamic interaction
		self.InputData.unbindall()
		self.InputData.bind_to(self.ChangeofBreakWaterinput)
		
		# Safe input data to ToolData
		self.__scenario.ToolData['BreakwaterData'] = _BreakwaterData(self.InputData)
		
		self.make_OutputTabs()
		
		self.rightPanel.Controls.Remove(self.group_MAP)
		self.rightPanel.Controls.Add(self.outputTabs)
		
		self.buttonCalculate.Text = "Refresh"
		self.buttonCalculate.Enabled = True
		self.buttonCalculate.Click -= lambda s,e : self.StartBreakwaterCalculation(s,e)
		self.buttonCalculate.Click += lambda s,e : RefreshTool(self.InputData,self.__scenario,self)
		
		
		
		
