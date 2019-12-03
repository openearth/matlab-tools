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
from Scripts.GeneralData.Views.BaseView import *
from Scripts.GeneralData.Utilities.PythonObjects import *
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
import Scripts.BreakwaterDesign as bw
from NetTopologySuite.Extensions.Features import Feature
import System.Drawing as s


#========================
#define the label SPACING
#========================
sp_loc = 5 #start point/location for labels (from left edge)
label_width = 170 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 30 #vertical spacing between labels (from previous)
vert_sp = 10 # start point/location for labels (from top edge)


def make_InputTabs(inputData,group_MAP,isFrozen):

		
		inputTabs = TabControl()
		inputTabs.Dock = DockStyle.Fill
		#inputTabs.Width = 2*label_width+3*spacer_width
		
		inputGroup_GENERAL = CreateInputDataGroupBox_GENERAL(group_MAP,inputData)
		inputGroup_WAVES = CreateInputDataGroupBox_WAVES(inputData)
		inputGroup_STONE = CreateInputDataGroupBox_STONE(inputData)
		inputGroup_FAC = CreateInputDataGroupBox_FAC(inputData)
		inputGroup_UNITCOST = CreateInputDataGroupBox_UNITCOST(inputData)
		
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
		
		tab_UNIT = TabPage()
		tab_UNIT.Text = "Unit rates"
		tab_UNIT.Controls.Add(inputGroup_UNITCOST)
		tab_UNIT.Enabled = not isFrozen
		inputTabs.Controls.Add(tab_UNIT)
		
		return inputTabs

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

def CreateInputDataGroupBox_UNITCOST(inputData):
	
	group_IN = Panel()
	group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
	group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
	group_IN.Dock = DockStyle.Fill
	
	counter = 0
	[Lab_GBe,Tb_GBe] = CreateInputLabelAndNumeric(group_IN, "Unitrate Armour (E/m3)", inputData,"unitCostArmour", vert_spacing * counter+vert_sp,1,1000000,1,1)
	counter = counter + 1
	[Lab_GF,Tb_GF] = CreateInputLabelAndNumeric(group_IN, "Unitrate Filter (E/m3)", inputData,"unitCostFilter", vert_spacing * counter+vert_sp,1,1000000,1,1)
	counter = counter + 1
	[Lab_AI,Tb_AI] = CreateInputLabelAndNumeric(group_IN, "Unitrate Core (E/m3)", inputData,"unitCostCore", vert_spacing * counter+vert_sp,1,1000000,1,1)
	
	return group_IN

