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
#Breakwater Tool SHELL (run me!)
#========================
#BJT van der spek Mar. 11, 2015
#========================

#========================
#load necessary libraries
#========================

#region load libraries
import os
import clr
clr.AddReference("System.Windows.Forms")
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
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
from NetTopologySuite.Extensions.Features import Feature
import numpy as np
from Scripts.UI_Examples.View import *
from datetime import datetime
import System.Drawing as s
#import Scripts.TidalData as td
import Scripts.BreakwaterDesign as bw
import Scripts.LinearWaveTheory as lw
#from Scripts.BreakwaterDesign.UI_functions_BW import *
from Scripts.BathymetryData import GridFunctions
from Scripts.BathymetryData.Bathy_UI_functions import SetGradientTheme
from SharpMap.Extensions.Layers import GdalRegularGridRasterLayer as _RegularGridRasterLayer
from Libraries.StandardFunctions import *
from Libraries.MapFunctions import *
from Libraries.ChartFunctions import *
#endregion

#=============================
#define input + clone function
#=============================

#class containing all inputs
class BuildInput:
	def __init__(self):
		self.counterTAB = 0
		self.Hs = 3
		self.Hs0 = 3
		self.Tp = 12
		self.Tp0 = 12
		self.SWL = 1
		self.cota = 3
		self.z = 10
		self.z0 = 100
		self.angleinc = 0
		self.theta = 0
		self.theta0 = 0
		self.Armour_Type = "Rock"
		self.Armour_TypeIndex = 0
		self.rhos = 2650
		self.rhow = 1000
		self.P = 0.4
		self.S = 2
		self.stormdur = 6
		self.autocrest = True
		self.crestheight = 0
		self.crestwidth = 5
		self.situation = "n"
		self.situationIndex = 0
		self.gammab = 1
		self.gammabreak = 0.73
		self.gammaf = 0.4
		self.kt = 1
		self.g = 9.81
		self.cpl = 6.2
		self.cs = 1.0
		self.qthres = 0.1
		self.length = 1000
		self.cross_ind = 0
		self.profile = {}
		self.is2D = True
		self.isOffshore = True
		self.IsNegative = False
		self.BWlayer = None
		self.mapview = None
		self.RasterPath = ""
		self.MakePositive = False
		
	def Clone(self):
		newInput = BuildInput()
		newInput.counterTAB = self.counterTAB
		newInput.Hs = self.Hs
		newInput.Hs0 = self.Hs0
		newInput.Tp = self.Tp
		newInput.Tp0 = self.Tp0
		newInput.SWL = self.SWL
		newInput.theta = self.theta
		newInput.theta0 = self.theta0
		newInput.cota = self.cota
		newInput.z = self.z
		newInput.z0 = self.z0
		newInput.angleinc = self.angleinc
		newInput.Armour_Type = self.Armour_Type
		newInput.Armour_TypeIndex = self.Armour_TypeIndex
		newInput.rhos = self.rhos
		newInput.rhow = self.rhow
		newInput.P = self.P
		newInput.S = self.S
		newInput.stormdur = self.stormdur
		newInput.autocrest = self.autocrest
		newInput.crestheight = self.crestheight
		newInput.crestwidth = self.crestwidth
		newInput.situation = self.situation
		newInput.situationIndex = self.situationIndex
		newInput.gammab = self.gammab
		newInput.gammaf = self.gammaf
		newInput.gammabreak = self.gammabreak 
		newInput.kt = self.kt
		newInput.g = self.g
		newInput.cpl = self.cpl 
		newInput.cs = self.cs
		newInput.qthres = self.qthres
		newInput.length = self.length
		newInput.cross_ind = self.cross_ind
		newInput.profile = self.profile
		newInput.is2D = self.is2D
		newInput.isOffshore = self.isOffshore
		newInput.IsNegative = self.IsNegative
		newInput.BWlayer = self.BWlayer
		newInput.mapview = self.mapview
		newInput.RasterPath = self.RasterPath
		newInput.MakePositive = self.MakePositive
		return newInput

#========================
#define the label SPACING
#========================
sp_loc = 5 #start point/location for labels (from left edge)
label_width = 170 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 30 #vertical spacing between labels (from previous)
vert_sp = 10 # start point/location for labels (from top edge)


def SetValue(object, propertyName, value):
	script = "object." + propertyName + "=value"
	exec(script)

def GetValue(object, propertyName):
	script = "object." + propertyName
	return eval(script)

def make_InputTabs(inputData,group_MAP,isFrozen):

		
		inputTabs = TabControl()
		inputTabs.Dock = DockStyle.Fill
		#inputTabs.Width = 2*label_width+3*spacer_width
		
		inputGroup_GENERAL = CreateInputDataGroupBox_GENERAL(group_MAP,inputData)
		inputGroup_WAVES = CreateInputDataGroupBox_WAVES(inputData)
		inputGroup_STONE = CreateInputDataGroupBox_STONE(inputData)
		inputGroup_FAC = CreateInputDataGroupBox_FAC(inputData)
		
		tab_GENERAL = TabPage()
		tab_GENERAL.Controls.Add(inputGroup_GENERAL)
		tab_GENERAL.Text = "General"
		tab_GENERAL.Enabled = not isFrozen
		inputTabs.Controls.Add(tab_GENERAL)
		
		tab_WAVE = TabPage()
		tab_WAVE.Controls.Add(inputGroup_WAVES)
		tab_WAVE.Text = "Wave"
		tab_WAVE.Enabled = not isFrozen
		inputTabs.Controls.Add(tab_WAVE)
		
		tab_STONE = TabPage()
		tab_STONE.Text = "Armour"
		tab_STONE.Controls.Add(inputGroup_STONE)
		tab_STONE.Enabled = not isFrozen
		inputTabs.Controls.Add(tab_STONE)
		
		tab_FAC = TabPage()
		tab_FAC.Text = "Reduction factors"
		tab_FAC.Controls.Add(inputGroup_FAC)
		tab_FAC.Enabled = not isFrozen
		inputTabs.Controls.Add(tab_FAC)
		
		return inputTabs

class InputView(View):
	
	def __init__(self, inputData):
		View.__init__(self)
		self.InputData = inputData
		self.Text = "Breakwater Input"
		
		group_MAP = GroupBox()
		group_MAP.Text = "Breakwater alignment"
		group_MAP.Font = s.Font(group_MAP.Font.FontFamily, 10)
		group_MAP.Dock = DockStyle.Fill
		group_MAP.Controls.Add(inputData.mapview)
		
		group_INTABS = GroupBox()
		group_INTABS.Text = "Input"
		group_INTABS.Font = s.Font(group_INTABS.Font.FontFamily, 10)
		group_INTABS.Dock = DockStyle.Left
		group_INTABS.Width = 2*label_width+4*spacer_width
		inputTabs = make_InputTabs(self.InputData,group_MAP,False)
		group_INTABS.Controls.Add(inputTabs)
		
		B1 = Button()
		B1.Dock = DockStyle.Bottom
		B1.Text = "Calculate"
		B1.Height = label_width/5
		B1.Width = label_width*0.5
		B1.Click += lambda s,e : START(s,e,self.InputData)
		
		group_INTABS.Controls.Add(B1)
		#
		self.ChildViews.Add(inputData.mapview)
		self.Controls.Add(group_MAP)
		self.Controls.Add(group_INTABS)

def CreateInputLabelAndTextBox(containerControl, labelName, dataobject, propertyName, verticalOffset):
	label = Label()
	label.Text = labelName
	label.Location = s.Point(sp_loc,verticalOffset)
	label.Width = label_width
	containerControl.Controls.Add(label)
	
	textbox = TextBox()
	textbox.Text = GetValue(dataobject,propertyName)
	textbox.Location = s.Point(label_width+spacer_width,verticalOffset)
	textbox.Width = label_width
	textbox.TextChanged += lambda s,e : SetValue(dataobject,propertyName, textbox.Text)
	containerControl.Controls.Add(textbox)
	
	return label,textbox
	
def CreateInputLabelAndNumeric(containerControl, labelName, dataobject, propertyName, verticalOffset,min,max,decimal,increment):
	label = Label()
	label.Text = labelName
	label.Location = s.Point(sp_loc,verticalOffset)
	label.Width = label_width
	containerControl.Controls.Add(label)
	
	numbox = NumericUpDown()
	numbox.Maximum = max
	numbox.Minimum = min
	numbox.Value = GetValue(dataobject,propertyName)
	numbox.Location = s.Point(label_width+spacer_width,verticalOffset)
	numbox.Increment = increment
	numbox.DecimalPlaces = decimal
	numbox.Width = label_width

	numbox.ValueChanged += lambda s,e : SetValue(dataobject,propertyName, numbox.Value)
	containerControl.Controls.Add(numbox)
	
	return label,numbox

def CreateInputDataGroupBox_GENERAL(group_MAP,inputData):
	
	def check_for_1D(sender,group_MAP,group_IN,inputData): # Checks if user checked 1D or 2D
		if sender.Text == "1D":
			inputData.is2D = False
			group_MAP.Visible = False
			if not group_IN.Controls.Contains(Lab_z):
				group_IN.Controls.Add(Lab_z)
				group_IN.Controls.Add(Tb_z)
		if sender.Text == "2D":
			inputData.is2D = True
			group_MAP.Visible = True
			if group_IN.Controls.Contains(Lab_z):
				group_IN.Controls.Remove(Lab_z)
				group_IN.Controls.Remove(Tb_z)
	
	def check_for_autocrest(group_IN,sender,inputData): # Checks for autocrest and removes labels
		if sender.Checked:
			inputData.autocrest = True
			if group_IN.Controls.Contains(Lab_Ch):
				group_IN.Controls.Remove(Lab_Ch)
				group_IN.Controls.Remove(Tb_Ch)
			if not group_IN.Controls.Contains(safetylevelCombo):
				group_IN.Controls.Add(safetylevelCombo)
				group_IN.Controls.Add(safetylevelLabel)
				group_IN.Controls.Add(QthresLabel)
		else:
			inputData.autocrest = False
			if not group_IN.Controls.Contains(Lab_Ch):
				group_IN.Controls.Add(Lab_Ch)
				group_IN.Controls.Add(Tb_Ch)
			if group_IN.Controls.Contains(safetylevelCombo):
				group_IN.Controls.Remove(safetylevelCombo)
				group_IN.Controls.Remove(safetylevelLabel)
				group_IN.Controls.Remove(QthresLabel)
	
	def change_qthres(sender,inputData):
		inputData.qthres = bw.get_Qthres_Index(sender.SelectedIndex)
		inputData.situation = sender.SelectedItem
		inputData.situationIndex = sender.SelectedIndex
		alowovertop = ("%.4f" % inputData.qthres).rstrip('0').rstrip('.')
		QthresLabel.Text = "Allowable overtopping = " + alowovertop + " l/s/m" 
	
	
	group_IN = Panel()
	#group_IN.Text = "Input"
	group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
	#group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
	group_IN.Dock = DockStyle.Fill
	
	counter = 0
	radiobuttonLabel = Label()
	radiobuttonLabel.Text = "Method:"
	radiobuttonLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
	radiobuttonLabel.Width = label_width
	group_IN.Controls.Add(radiobuttonLabel)
	
	radiobutton2D = RadioButton()
	radiobutton2D.Text = "2D"
	radiobutton2D.Location = s.Point(sp_loc+label_width+spacer_width,vert_spacing * counter+vert_sp)
	radiobutton2D.Width = 0.4*label_width
	if inputData.is2D:
		radiobutton2D.Checked = True
	if (group_MAP != None):
		radiobutton2D.CheckedChanged += lambda s,e : check_for_1D(s,group_MAP,group_IN,inputData)
	group_IN.Controls.Add(radiobutton2D)
	
	radiobutton1D = RadioButton()
	radiobutton1D.Text = "1D"
	radiobutton1D.Location = s.Point(sp_loc+1.5*label_width,vert_spacing * counter+vert_sp)
	if not inputData.is2D:
		radiobutton1D.Checked = False
	if (group_MAP != None):
		radiobutton1D.CheckedChanged += lambda s,e : check_for_1D(s,group_MAP,group_IN,inputData)
	group_IN.Controls.Add(radiobutton1D)
	
	counter = counter + 1
	checkboxAutoCrest = CheckBox()
	checkboxAutoCrest.Text = "Automated crestheight calculation"
	checkboxAutoCrest.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
	checkboxAutoCrest.AutoSize = True
	if inputData.autocrest:
		checkboxAutoCrest.Checked = True
	else:
		checkboxAutoCrest.Checked = False
	
	checkboxAutoCrest.CheckedChanged += lambda s,e : check_for_autocrest(group_IN,s,inputData)
	group_IN.Controls.Add(checkboxAutoCrest)
	
	counter = counter + 1
	[Lab_cota,Tb_cota] = CreateInputLabelAndNumeric(group_IN, "Slope 1:", inputData,"cota", vert_spacing * counter+vert_sp,1,8,1,1)
	counter = counter + 1
	[Lab_Cw,Tb_Cw] = CreateInputLabelAndNumeric(group_IN, "Crestwidth (m)", inputData,"crestwidth", vert_spacing * counter+vert_sp,1,100,2,0.25)
	counter = counter + 1
	[Lab_Ch,Tb_Ch] = CreateInputLabelAndNumeric(group_IN, "Crestheight (m+MSL)", inputData,"crestheight", vert_spacing * counter+vert_sp,0,100,2,0.25)
	counter = counter + 1
	[Lab_z,Tb_z] = CreateInputLabelAndNumeric(group_IN, "Local depth (m)", inputData,"z", vert_spacing * counter+vert_sp,0,1000000,1,0.5)
	
	if radiobutton2D.Checked:
		group_IN.Controls.Remove(Lab_z)
		group_IN.Controls.Remove(Tb_z)
	if checkboxAutoCrest.Checked:
		group_IN.Controls.Remove(Lab_Ch)
		group_IN.Controls.Remove(Tb_Ch)
	
	counter = counter + 1
	safetylevelCombo = ComboBox()
	safetyLevelCombo = bw.get_situation_list(safetylevelCombo)
	safetylevelCombo.Location = s.Point(sp_loc+0.75*label_width,vert_spacing * counter+vert_sp)
	safetylevelCombo.Width = 1.25*label_width
	safetylevelCombo.SelectedIndex = inputData.situationIndex
	inputData.qthres = bw.get_Qthres_Index(safetylevelCombo.SelectedIndex)
	inputData.situation = safetylevelCombo.SelectedItem
	safetylevelCombo.SelectionChangeCommitted += lambda s,e : change_qthres(s,inputData)
	
	safetylevelLabel = Label()
	safetylevelLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
	safetylevelLabel.Text = "Safety level"
	safetylevelLabel.Width = 0.75*label_width
	
	counter = counter + 1
	QthresLabel = Label()
	alowovertop = ("%.4f" % float(inputData.qthres)).rstrip('0').rstrip('.')
	QthresLabel.Text = "Allowable overtopping = " + alowovertop + " l/s/m" 
	QthresLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
	QthresLabel.AutoSize = True
	
	if checkboxAutoCrest.Checked:
		group_IN.Controls.Add(safetylevelCombo)
		group_IN.Controls.Add(safetylevelLabel)
		group_IN.Controls.Add(QthresLabel)
		group_IN.Controls.Remove(Lab_Ch)
		group_IN.Controls.Remove(Tb_Ch)
	
	return group_IN

def CreateInputDataGroupBox_WAVES(inputData):
	
	#Check for Nearshore
	def check_if_NS(group_IN,sender,inputData):
		if sender.Text == "Nearshore":
			inputData.isOffshore = False
			if group_IN.Controls.Contains(Lab_OD):
				group_IN.Controls.Remove(Lab_OD)
				group_IN.Controls.Remove(Tb_OD)
		if sender.Text == "Offshore":
			inputData.isOffshore = True
			if not group_IN.Controls.Contains(Lab_OD):
				group_IN.Controls.Add(Lab_OD)
				group_IN.Controls.Add(Tb_OD)
	
	
	group_IN = Panel()
	#group_IN.Text = "Input"
	group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
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
	if inputData.isOffshore: 
		radiobutton1.Checked = True
	radiobutton1.Location = s.Point(sp_loc+label_width,vert_spacing * counter+vert_sp)
	
	#if (group_MAP != None):
	radiobutton1.CheckedChanged += lambda s,e : check_if_NS(group_IN,s,inputData)
	group_IN.Controls.Add(radiobutton1)
	
	counter = counter +1
	radiobutton2 = RadioButton()
	radiobutton2.Text = "Nearshore"
	if not inputData.isOffshore:
		radiobutton2.Checked = True
	radiobutton2.Location = s.Point(sp_loc+label_width,vert_spacing * counter+vert_sp)
	radiobutton2.CheckedChanged += lambda s,e : check_if_NS(group_IN,s,inputData)
	group_IN.Controls.Add(radiobutton2)
	
	counter = counter + 1
	[Lab_Hs,Tb_Hs] = CreateInputLabelAndNumeric(group_IN, "Hs (m)", inputData,"Hs0", vert_spacing * counter+vert_sp,0.1,20,2,0.25)
	counter = counter + 1
	[Lab_Tp,Tb_Tp] = CreateInputLabelAndNumeric(group_IN, "Tp (s)", inputData,"Tp0", vert_spacing * counter+vert_sp,0,50,1,0.2)
	counter = counter + 1
	[Lab_Dir,Tb_Dir] = CreateInputLabelAndNumeric(group_IN, "Dir (degSN)", inputData,"theta0", vert_spacing * counter+vert_sp,0,90,0,5)
	counter = counter + 1
	[Lab_SWL,Tb_SWL] = CreateInputLabelAndNumeric(group_IN, "SWL (m+MSL)", inputData,"SWL", vert_spacing * counter+vert_sp,-20,20,2,0.25)
	counter = counter + 1
	[Lab_SD,Tb_SD] = CreateInputLabelAndNumeric(group_IN, "Stormduration (h)", inputData,"stormdur", vert_spacing * counter+vert_sp,1,20000,1,1)
	counter = counter + 1
	[Lab_GBr,Tb_GBr] = CreateInputLabelAndNumeric(group_IN, "Breaker parameter", inputData,"gammabreak", vert_spacing * counter+vert_sp,0.4,1,2,0.01)
	counter = counter + 1
	[Lab_OD,Tb_OD] = CreateInputLabelAndNumeric(group_IN, "Offshore Depth (m)", inputData,"z0", vert_spacing * counter+vert_sp,0.1,10000000,1,0.1)
	
	
	if not inputData.isOffshore:
		group_IN.Controls.Remove(Lab_OD)
		group_IN.Controls.Remove(Tb_OD)
	
	
	return group_IN

def CreateInputDataGroupBox_STONE(inputData):
	
	def change_armourtype(sender,inputData):
		inputData.Armour_Type = sender.SelectedItem
		inputData.Armour_TypeIndex = sender.SelectedIndex
	
	group_IN = Panel()
	group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
	group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
	group_IN.Dock = DockStyle.Fill
	
	counter = 0
	armourtypeCombo = ComboBox()
	armourtypeCombo = bw.get_armour_types(armourtypeCombo)
	
	armourtypeCombo.Location = s.Point(sp_loc+label_width,vert_spacing * counter+vert_sp)
	armourtypeCombo.Width = label_width
	armourtypeCombo.SelectedIndex = inputData.Armour_TypeIndex
	inputData.Armour_Type = armourtypeCombo.SelectedItem
	armourtypeCombo.SelectionChangeCommitted += lambda s,e : change_armourtype(s,inputData)
	group_IN.Controls.Add(armourtypeCombo)
	
	armourtypeLabel = Label()
	armourtypeLabel.Location = s.Point(sp_loc,vert_spacing * counter+vert_sp)
	armourtypeLabel.Text = "Armour type"
	armourtypeLabel.Width = label_width
	group_IN.Controls.Add(armourtypeLabel)
	
	
	
	counter = counter + 1
	[Lab_RD,Tb_RD] = CreateInputLabelAndNumeric(group_IN, "Rock Density (kg/m3)", inputData,"rhos", vert_spacing * counter+vert_sp,100,10000,0,10)
	counter = counter + 1
	[Lab_WD,Tb_WD] = CreateInputLabelAndNumeric(group_IN, "Water Density (kg/m3)", inputData,"rhow", vert_spacing * counter+vert_sp,100,10000,0,10)
	counter = counter + 1
	[Lab_LC,Tb_LC] = CreateInputLabelAndNumeric(group_IN, "Layer coefficient (kt)", inputData,"kt", vert_spacing * counter+vert_sp,0,1,2,.01)
	counter = counter + 1
	[Lab_P,Tb_P] = CreateInputLabelAndNumeric(group_IN, "Notional permeability (P)", inputData,"P", vert_spacing * counter+vert_sp,0.1,0.6,1,0.1)
	counter = counter + 1
	[Lab_S,Tb_S] = CreateInputLabelAndNumeric(group_IN, "Damage number (S)", inputData,"S", vert_spacing * counter+vert_sp,1,17,0,1)
	
	
	return group_IN
	
def CreateInputDataGroupBox_FAC(inputData):
	
	group_IN = Panel()
	group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
	group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
	group_IN.Dock = DockStyle.Fill
	
	counter = 0
	[Lab_GBe,Tb_GBe] = CreateInputLabelAndNumeric(group_IN, "Berm reduction", inputData,"gammab", vert_spacing * counter+vert_sp,0.1,1,2,0.1)
	counter = counter + 1
	[Lab_GF,Tb_GF] = CreateInputLabelAndNumeric(group_IN, "Roughness reduction", inputData,"gammaf", vert_spacing * counter+vert_sp,0.1,1,2,0.1)
	counter = counter + 1
	[Lab_AI,Tb_AI] = CreateInputLabelAndNumeric(group_IN, "Angle of incidence (deg)", inputData,"angleinc", vert_spacing * counter+vert_sp,0,90,0,1)
	
	return group_IN
	
class OutputView(View):
	
	def __init__(self, inputdata, outputdata,BWlineClone,MapEnvelope):
		View.__init__(self)
		self.InputData = inputdata
		self.OutputData = outputdata
		self.Text = "Breakwater Output"
		
		group_OUT = GroupBox()
		group_OUT.Dock = DockStyle.Fill
		group_OUT.Text = "Output"
		
		tabs_FROZEN = make_InputTabs(self.InputData,None,True)
		
		group_FROZEN = GroupBox()
		group_FROZEN.Text = "Selected Input"
		group_FROZEN.Dock = DockStyle.Left
		group_FROZEN.Width = 2.5*label_width+4*spacer_width
		group_FROZEN.Controls.Add(tabs_FROZEN)
		
		outputTabs = TabControl()
		outputTabs.Dock = DockStyle.Fill
		outputTabs.Width = 2*label_width+3*spacer_width
		
		plot1 =  bw.Plot_Crossection(self.InputData,self.OutputData)
		tab_PLOT1 = TabPage() #for the plot
		tab_PLOT1.Text = "Cross-section"
		tab_PLOT1.Controls.Add(plot1)
		
		def Slider_changed(sender,tab_PLOT1,plot3,InputData,OutputData):
			# Re-create plot for cross-section
			InputData.cross_ind = sender.Value-1
			for ind in range(0,len(tab_PLOT1.Controls)):
				if tab_PLOT1.Controls[ind].Text == "Plot1":
					ind_to_rem = ind
			tab_PLOT1.Controls.Remove(tab_PLOT1.Controls[ind_to_rem])
			plot2 =  bw.Plot_Crossection(InputData,OutputData)
			tab_PLOT1.Controls.Add(plot2)
			plot2.BringToFront()
			
			# Re-create volume text
			Volumes_Text = bw.Create_VolumesText(InputData,OutputData)
			Outputlabel3.Text = Volumes_Text
			
			# Re-create profile figure
			lw.addBreakwaterDashes_ind(plot3, InputData.profile, InputData)
			
			
		if self.InputData.is2D:
			chart2 = lw.plotProfile(self.InputData.profile,self.InputData.crestheight,self.OutputData.layer) # Chart Profile
			#chart2 = lw.addBreakWaterDashes(chart2,self.InputData.profile)
			plot3 = ChartView()
			plot3.Chart = chart2
			plot3.Dock = DockStyle.Fill
			lw.addBreakwaterDashes_ind(plot3, self.InputData.profile, self.InputData)
			tab_PLOT2 = TabPage()
			tab_PLOT2.Text = "Profile"
			tab_PLOT2.Controls.Add(plot3)
			
		if self.InputData.is2D:
			Slider = TrackBar()
			#Slider.Size = Size(150, 30)
			Slider.Dock = DockStyle.Bottom
			Slider.Minimum = 1
			Slider.Maximum = len(self.InputData.profile['mean_z'])
			Slider.TickFrequency = 1
			Slider.LargeChange = 1
			Slider.SmallChange = 1
			Slider.Text = "Cross-section number"
			Slider.Value = self.InputData.cross_ind+1
			Slider.ValueChanged += lambda s,e : Slider_changed(s,tab_PLOT1,plot3,self.InputData,self.OutputData)
			tab_PLOT1.Controls.Add(Slider)
		
		if self.InputData.is2D:
			tab_MAP1 = TabPage()
			tab_MAP1.Text = "Map"
			MapOut1 = MapView()
			mapout1 = Map()
			OSMLlayer = OSML()
			OSMLlayer.Name = "Open Street Maps"
			BWfeature = []
			BWfeature.append(Feature(Geometry = BWlineClone))
			BWlayer1 = CreateLayerForFeatures("Breakwater", BWfeature,None)
			BWlayer1.Style.Line.Color = Color.Black
			BWlayer1.Style.Line.Width = 3
			mapout1.Layers.Add(BWlayer1)
			mapout1.Layers.Add(OSMLlayer)
			
			Rasterlaag = _RegularGridRasterLayer()
			Rasterlaag.Name = "Bathymetry"
			Rasterlaag.DataSource.Path = self.InputData.RasterPath
			SetGradientTheme(Rasterlaag, Rasterlaag.ThemeAttributeName, 15)
			
			mapout1.Layers.Add(Rasterlaag)
			mapout1.BringToFront(Rasterlaag)
			mapout1.BringToFront(BWlayer1)
			
			MapOut1.Map = mapout1
			MapOut1.Dock = DockStyle.Fill
			MapOut1.Map.ZoomToFit(MapEnvelope)
			MapOut1.Dock = DockStyle.Fill
			tab_MAP1.Controls.Add(MapOut1)
		
		Dimensions_Text = bw.Create_DimensionsText(self.InputData,self.OutputData)
		Conditions_Text = bw.Create_ConditionsText(self.InputData,self.OutputData)
		Volumes_Text = bw.Create_VolumesText(self.InputData,self.OutputData)
		Overtopping_Text = bw.Create_OvertoppingText(self.InputData,self.OutputData)
		
		tab_TEXT1 = TabPage()
		tab_TEXT2 = TabPage()
		tab_TEXT3 = TabPage()
		tab_TEXT4 = TabPage()
		
		Outputlabel1 = RichTextBox()
		Outputlabel1.Dock = DockStyle.Fill
		Outputlabel1.Font = s.Font(Outputlabel1.Font.FontFamily, 10)
		Outputlabel1.BackColor = Color.FromArgb(249,249,249)
		Outputlabel1.BorderStyle = BorderStyle.None
		Outputlabel1.ReadOnly = True
		Outputlabel1.Text = Dimensions_Text
		tab_TEXT1.Controls.Add(Outputlabel1)
		tab_TEXT1.Text = "Dimensions"
		
		Outputlabel2 = RichTextBox()
		Outputlabel2.Dock = DockStyle.Fill
		Outputlabel2.Font = s.Font(Outputlabel2.Font.FontFamily, 10)
		Outputlabel2.BackColor = Color.FromArgb(249,249,249)
		Outputlabel2.BorderStyle = BorderStyle.None
		Outputlabel2.ReadOnly = True
		Outputlabel2.Text = Conditions_Text
		tab_TEXT2.Controls.Add(Outputlabel2)
		tab_TEXT2.Text = "Conditions"
		
		Outputlabel3 = RichTextBox()
		Outputlabel3.Font = s.Font(Outputlabel3.Font.FontFamily, 10)
		Outputlabel3.Dock = DockStyle.Fill
		Outputlabel3.BackColor = Color.FromArgb(249,249,249)
		Outputlabel3.BorderStyle = BorderStyle.None
		Outputlabel3.ReadOnly = True
		Outputlabel3.Text = Volumes_Text
		tab_TEXT3.Controls.Add(Outputlabel3)
		tab_TEXT3.Text = "Volumes"
		
		Outputlabel4 = RichTextBox()
		Outputlabel4.Dock = DockStyle.Fill
		Outputlabel4.Font = s.Font(Outputlabel4.Font.FontFamily, 10)
		Outputlabel4.BackColor = Color.FromArgb(249,249,249)
		Outputlabel4.BorderStyle = BorderStyle.None
		Outputlabel4.ReadOnly = True
		Outputlabel4.Text = Overtopping_Text
		tab_TEXT4.Controls.Add(Outputlabel4)
		tab_TEXT4.Text = "Overtopping"
		
		outputTabs.Controls.Add(tab_PLOT1)
		if self.InputData.is2D:
			outputTabs.Controls.Add(tab_PLOT2)
		if self.InputData.is2D:
			outputTabs.Controls.Add(tab_MAP1)
			self.ChildViews.Add(MapOut1)
		
		outputTabs.Controls.Add(tab_TEXT1)
		outputTabs.Controls.Add(tab_TEXT2)
		outputTabs.Controls.Add(tab_TEXT3)
		outputTabs.Controls.Add(tab_TEXT4)
		
		
		group_OUT.Controls.Add(outputTabs)
		
		
		self.Controls.Add(group_OUT)
		self.Controls.Add(group_FROZEN)
	
def START(sender,e,inputData):
	
	# Check if Breakwater is clicked
	if inputData.BWlayer.LastRenderedFeaturesCount<1 and inputData.is2D:
		MessageBox.Show("Please click breakwater in map","No breakwater defined!")
		return
	
	# Check if crestheight is above SWL
	
	if not inputData.autocrest and inputData.crestheight <= inputData.SWL:
		MessageBox.Show("Please increase the crest height","Crestheight is lower than SWL")
		return
		
	if inputData.is2D:
				
		# Check if grid exists
		ValidPath = os.path.exists(inputData.RasterPath)
		
		if ValidPath == False:			
			MessageBox.Show("Please select a valid path to a bathymetry grid","No bathymetry found!")
			return
		
		# Get bathy grid from path
		grid = bw.get_bathygrid(inputData.RasterPath)		
		
		# Check if the depth values need to be multiplied by -1 to make them positive
		
		Multiplication = 1
		
		if inputData.MakePositive == True:			
			Multiplication = -1	
						
		
		# Get lineGeometry
		LineGeometry = bw.get_LineGeometry(inputData.BWlayer)
		
		# Get profile
		Profile = GridFunctions.GetProfileFromGrid(LineGeometry,grid,3857)
		BWlineClone = LineGeometry.Clone()
		inputData.profile['dist'] = np.array(Profile["dist_UTM"])
		inputData.profile['z'] = np.array(Profile["Z"]) * Multiplication
		inputData.profile['x'] = np.array(Profile["UTM_X"])
		inputData.profile['y'] = np.array(Profile["UTM_Y"])
	else:
		BWlineClone = []
		LineGeometry = []
	
	
	inputData.counterTAB = inputData.counterTAB + 1
	
	inputClone = inputData.Clone()
	MapEnvelope = inputData.mapview.Map.Envelope.Clone()
	
	if inputClone.is2D:
		# Check if all depths are positive
		if np.all(inputClone.profile['z'] < 0):
			inputClone.IsNegative = True

	if inputClone.IsNegative:
		MessageBox.Show("No bathymetry data found or you defined your breakwater on land. \nPlease redefine breakwater","No data or land data")
		return
	
	
	[inputClone,outputData] = bw.ENGINE(inputClone)
	[inputClone,outputData] = bw.get_AllDims(inputClone,outputData)
	
	outputView = OutputView(inputClone,outputData,BWlineClone,MapEnvelope)
	
	outputView.Text = "Breakwater Output (%0.2d)" %inputClone.counterTAB
	outputView.Show()


def Start_BreakwaterTool():
	inputData = BuildInput()
	inputData = bw.get_BW_Alignment(inputData)
	inputView = InputView(inputData)
	inputView.Show()


Start_BreakwaterTool()



