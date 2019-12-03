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
#from Scripts.CoastlineDevelopment.Utilities.general_functions import *
from Scripts.CoastlineDevelopment.Utilities.CoastlineEvolution import *
from Scripts.CoastlineDevelopment.Entities.CoastlineInput import *
from Scripts.CoastlineDevelopment.Entities.CoastlineOutput import *
from Scripts.CoastlineDevelopment.Views.OutputCoastlineEvolution import *


from Scripts.UI_Examples.Shortcuts import *

import Scripts.BathymetryData as bmd
import Scripts.BreakwaterDesign as bwd
import Scripts.LinearWaveTheory as lwt
import Scripts.TidalData as td
import Scripts.WaveWindData as wwd

import os
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import DateTimePickerFormat
from System.Windows.Forms import MessageBox
from System.Windows.Forms import HorizontalAlignment
from SharpMap.Api.Enums import VerticalAlignmentEnum
from System.Drawing import ContentAlignment
from System.Windows.Forms import TabPage
from System.Windows.Forms import DataGridView
from System.Windows.Forms import FolderBrowserDialog
from System.Windows.Forms import DialogResult
from Scripts.UI_Examples.View import *
from datetime import datetime
import System.Drawing as s
import Scripts.TidalData as td
from Libraries.MapFunctions import *

from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection

from System.Security.Policy import Url
import System.Windows.Forms.BorderStyle as BorderStyle

from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.UI.Tools import NewLineTool
from NetTopologySuite.Extensions.Features import Feature

from System.Windows.Forms import Button, DockStyle, AnchorStyles, Padding

from Libraries.StandardFunctions import *
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
from DelftTools.Utils import Url

import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env

InputValues = InputData()
OutputValues = OutputData()
DemoVersion = True

def createInputControl():
	
	sp_loc = 5 #start point/location for labels (from left edge)
	label_width  = 140 #width for labels + textboxes...
	spacer_width = 20 #horizontal spacing between label + textboxes
	vert_spacing = 40 #vertical spacing between labels (from previous)
	window_width = 2*label_width+2*spacer_width
	isFrozen = False
	
	def make_InputTabs():
		inputTabs = TabControl()
		inputTabs.Dock = DockStyle.Fill
		
		inputGroup_LT = CreateInputDataGroupBox_LT()
		L1, L2, L3, L4, L5, L6, L7 = CreateButtons_LT(inputGroup_LT)
		
		inputGroup_CE = CreateInputDataGroupBox_CE()
		C1, C2, C3, C4, C5, C6, C7 = CreateButtons_CE(inputGroup_CE)
		
		tab_LT = TabPage()
		tab_LT.Controls.Add(inputGroup_LT)
		tab_LT.Text = "LT"
		tab_LT.Enabled = not isFrozen
		inputTabs.Controls.Add(tab_LT)
		
		tab_CE = TabPage()
		tab_CE.Controls.Add(inputGroup_CE)
		tab_CE.Text = "CE"
		tab_CE.Enabled = not isFrozen
		inputTabs.Controls.Add(tab_CE)
		
		return inputTabs, L1, L2, L3, L4, L5, L6, L7, C1, C2, C3, C4, C5, C6, C7
		
	def CreateInputDataGroupBox_LT():
		group_IN = Panel()
		group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
		group_IN.Dock = DockStyle.Fill
		
		### 1 Define Variables
		
		# 1.1 Gamma input
		text_gamma = Label()
		text_gamma.Text = "Breaker index:"
		text_gamma.Location = s.Point(window_width/2 - 1.05*label_width,3.6*vert_spacing)
		text_gamma.Width = 0.8*label_width
		text_gamma.TextAlign = ContentAlignment.MiddleRight
		group_IN.Controls.Add(text_gamma)
		
		def set_gamma():
			InputValues.gamma = float(nud_gamma.Value)

		nud_gamma = NumericUpDown()
		nud_gamma.DecimalPlaces = 2
		nud_gamma.TextAlign = HorizontalAlignment.Right
		nud_gamma.Increment = 0.01 #for increment with dir keys
		nud_gamma.Maximum = 0.99 #max bounds
		nud_gamma.Minimum = 0.01 #min bounds
		nud_gamma.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,3.6*vert_spacing)
		nud_gamma.Width = 0.5*label_width
		nud_gamma.Value = InputValues.gamma #default number
		nud_gamma.ValueChanged += lambda s,e : set_gamma()
		group_IN.Controls.Add(nud_gamma)
		
		text_gamma_unit = Label()
		text_gamma_unit.Text = "[-]"
		text_gamma_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,3.6*vert_spacing)
		text_gamma_unit.Width = 0.5*label_width
		text_gamma_unit.TextAlign = ContentAlignment.MiddleLeft
		group_IN.Controls.Add(text_gamma_unit)
		
		# 1.2 DOC input
		
		text_doc = Label()
		text_doc.Text = "Depth of closure:"
		text_doc.Location = s.Point(window_width/2 - 1.05*label_width,4.3*vert_spacing)
		text_doc.Width = 0.8*label_width
		text_doc.TextAlign = ContentAlignment.MiddleRight
		group_IN.Controls.Add(text_doc)
		
		def set_doc():
			InputValues.doc = float(nud_doc.Value)
		
		nud_doc = NumericUpDown()
		nud_doc.DecimalPlaces = 2
		nud_doc.TextAlign = HorizontalAlignment.Right
		nud_doc.Increment = 0.1 #for increment with dir keys
		nud_doc.Maximum = 10 #max bounds
		nud_doc.Minimum = 0.5 #min bounds
		nud_doc.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,4.3*vert_spacing)
		nud_doc.Width = 0.5*label_width
		nud_doc.Value = InputValues.doc #default number
		nud_doc.ValueChanged += lambda s,e : set_doc()
		group_IN.Controls.Add(nud_doc)
		
		text_doc_unit = Label()
		text_doc_unit.Text = "[mtr.]"
		text_doc_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,4.3*vert_spacing)
		text_doc_unit.Width = 0.5*label_width
		text_doc_unit.TextAlign = ContentAlignment.MiddleLeft
		group_IN.Controls.Add(text_doc_unit)
		
		# 1.3 d50 input:
		
		text_d50 = Label()
		text_d50.Text = "d50:"
		text_d50.Location = s.Point(window_width/2 - 1.05*label_width,5.0*vert_spacing)
		text_d50.Width = 0.8*label_width
		text_d50.TextAlign = ContentAlignment.MiddleRight
		group_IN.Controls.Add(text_d50)
		
		def set_d50():
			InputValues.d50 = float(nud_d50.Value / 1000000)
		
		nud_d50 = NumericUpDown()
		nud_d50.DecimalPlaces = 1
		nud_d50.TextAlign = HorizontalAlignment.Right
		nud_d50.Increment = 10 #for increment with dir keys
		nud_d50.Maximum = 10000 #max bounds
		nud_d50.Minimum = 1 #min bounds
		nud_d50.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,5.0*vert_spacing)
		nud_d50.Width = 0.5*label_width
		nud_d50.Value = InputValues.d50 * 1000000 #default number
		nud_d50.ValueChanged += lambda s,e : set_d50()
		group_IN.Controls.Add(nud_d50)
		
		text_d50_unit = Label()
		text_d50_unit.Text = "[micrometer]"
		text_d50_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,5.0*vert_spacing)
		text_d50_unit.Width = 0.70*label_width
		text_d50_unit.TextAlign = ContentAlignment.MiddleLeft
		group_IN.Controls.Add(text_d50_unit)
		
		# 1.4 Beach slope input:
		
		text_slope = Label()
		text_slope.Text = "Beach slope:"
		text_slope.Location = s.Point(window_width/2 - 1.05*label_width,5.7*vert_spacing)
		text_slope.Width = 0.8*label_width
		text_slope.TextAlign = ContentAlignment.MiddleRight
		group_IN.Controls.Add(text_slope)
		
		def set_slope():
			InputValues.beach_slope = float(nud_slope.Value)
		
		nud_slope = NumericUpDown()
		nud_slope.DecimalPlaces = 3
		nud_slope.TextAlign = HorizontalAlignment.Right
		nud_slope.Increment = 0.001 #for increment with dir keys
		nud_slope.Maximum = 1 #max bounds
		nud_slope.Minimum = 0.000001 #min bounds
		nud_slope.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,5.7*vert_spacing)
		nud_slope.Width = 0.5*label_width
		nud_slope.Value = InputValues.beach_slope #default number
		nud_slope.ValueChanged += lambda s,e : set_slope()
		group_IN.Controls.Add(nud_slope)
		
		text_slope_unit = Label()
		text_slope_unit.Text = "[-]"
		text_slope_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,5.7*vert_spacing)
		text_slope_unit.Width = 0.5*label_width
		text_slope_unit.TextAlign = ContentAlignment.MiddleLeft
		group_IN.Controls.Add(text_slope_unit)
		
		# 1.5 Rho_s input
		
		text_rho_s = Label()
		text_rho_s.Text = "Rho_s:"
		text_rho_s.Location = s.Point(window_width/2 - 1.05*label_width,6.4*vert_spacing)
		text_rho_s.Width = 0.8*label_width
		text_rho_s.TextAlign = ContentAlignment.MiddleRight
		group_IN.Controls.Add(text_rho_s)
		
		def set_rho_s():
			InputValues.rho_s = float(nud_rho_s.Value)
		
		nud_rho_s = NumericUpDown()
		nud_rho_s.DecimalPlaces = 0
		nud_rho_s.TextAlign = HorizontalAlignment.Right
		nud_rho_s.Increment = 5 #for increment with dir keys
		nud_rho_s.Maximum = 3000 #max bounds
		nud_rho_s.Minimum = 1000 #min bounds
		nud_rho_s.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,6.4*vert_spacing)
		nud_rho_s.Width = 0.5*label_width
		nud_rho_s.Value = InputValues.rho_s #default number
		nud_rho_s.ValueChanged += lambda s,e : set_rho_s()
		group_IN.Controls.Add(nud_rho_s)
		
		text_rho_s_unit = Label()
		text_rho_s_unit.Text = "[kg/m3]"
		text_rho_s_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,6.4*vert_spacing)
		text_rho_s_unit.Width = 0.5*label_width
		text_rho_s_unit.TextAlign = ContentAlignment.MiddleLeft
		group_IN.Controls.Add(text_rho_s_unit)
		
		# 1.6 Rho_w input
		
		text_rho_w = Label()
		text_rho_w.Text = "Rho_w:"
		text_rho_w.Location = s.Point(window_width/2 - 1.05*label_width,7.1*vert_spacing)
		text_rho_w.Width = 0.8*label_width
		text_rho_w.TextAlign = ContentAlignment.MiddleRight
		group_IN.Controls.Add(text_rho_w)
		
		def set_rho_w():
			InputValues.rho_w = float(nud_rho_w.Value)
		
		nud_rho_w = NumericUpDown()
		nud_rho_w.DecimalPlaces = 0
		nud_rho_w.TextAlign = HorizontalAlignment.Right
		nud_rho_w.Increment = 5 #for increment with dir keys
		nud_rho_w.Maximum = 1250 #max bounds
		nud_rho_w.Minimum = 995 #min bounds
		nud_rho_w.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,7.1*vert_spacing)
		nud_rho_w.Width = 0.5*label_width
		nud_rho_w.Value = InputValues.rho_w #default number
		nud_rho_w.ValueChanged += lambda s,e : set_rho_w()
		group_IN.Controls.Add(nud_rho_w)
		
		text_rho_w_unit = Label()
		text_rho_w_unit.Text = "[kg/m3]"
		text_rho_w_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,7.1*vert_spacing)
		text_rho_w_unit.Width = 0.5*label_width
		text_rho_w_unit.TextAlign = ContentAlignment.MiddleLeft
		group_IN.Controls.Add(text_rho_w_unit)
		
		# 1.7 porosity input
		
		text_por = Label()
		text_por.Text = "Porosity:"
		text_por.Location = s.Point(window_width/2 - 1.05*label_width,7.8*vert_spacing)
		text_por.Width = 0.8*label_width
		text_por.TextAlign = ContentAlignment.MiddleRight
		group_IN.Controls.Add(text_por)
		
		def set_por():
			InputValues.porosity = float(nud_por.Value)
		
		nud_por = NumericUpDown()
		nud_por.DecimalPlaces = 2
		nud_por.TextAlign = HorizontalAlignment.Right
		nud_por.Increment = 0.01 #for increment with dir keys
		nud_por.Maximum = 0.99 #max bounds
		nud_por.Minimum = 0.01 #min bounds
		nud_por.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,7.8*vert_spacing)
		nud_por.Width = 0.5*label_width
		nud_por.Value = InputValues.porosity #default number
		nud_por.ValueChanged += lambda s,e : set_por()
		group_IN.Controls.Add(nud_por)
		
		text_por_unit = Label()
		text_por_unit.Text = "[-]"
		text_por_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,7.8*vert_spacing)
		text_por_unit.Width = 0.5*label_width
		text_por_unit.TextAlign = ContentAlignment.MiddleLeft
		group_IN.Controls.Add(text_por_unit)
		
		return group_IN
		
	def CreateButtons_LT(group_IN):
		
		# 1. Cross-shore transect
		L1 = Button()
		L1.BackColor = Color.LightGray
		L1.Text = "Add a cross-shore transect"
		L1.Location = s.Point(window_width/2 - label_width,0.8*vert_spacing)
		L1.Width = 2*label_width
		group_IN.Controls.Add(L1)
		
		# 2. Wave conditions
		L2 = Button()
		L2.BackColor = Color.LightGray
		L2.Text = "Get and set wave conditions"
		L2.Location = s.Point(window_width/2 - label_width,2*vert_spacing)
		L2.Width = 2*label_width
		group_IN.Controls.Add(L2)
		
		# 3. Wave transformation
		L3 = CheckBox()
		L3.Enabled=False
		L3.Text = "Transform these waves to nearshore"
		L3.Location = s.Point(window_width/2 - 0.8*label_width,2.6*vert_spacing)
		L3.Width = 2*label_width
		group_IN.Controls.Add(L3)
		
		# 4. Select Function
		L4 = Label()
		L4.Text = "Select a function:"
		L4.Location = s.Point(window_width/2 - 1.0*label_width,9.0*vert_spacing)
		L4.Width = 1.5*label_width
		group_IN.Controls.Add(L4)
		
		def change_function(s,e):
			if s.SelectedIndex==2:
				s.SelectedIndex=0
			InputValues.formula_name = s.Items[s.SelectedIndex]
			
		L7 = ComboBox()
		L7.Items.Add('Kamphuis')
		L7.Items.Add('CERC')
		L7.Items.Add('van Rijn (not implemented yet)')
		L7.SelectedIndex = 0
		L7.Location = s.Point(window_width/2 - label_width,9.6*vert_spacing)
		L7.Width = 2*label_width
		L7.SelectionChangeCommitted += change_function
		group_IN.Controls.Add(L7)
		
		# 5. Compute button
		L5 = Button()
		L5.Enabled = True
		L5.BackColor = Color.LightGray
		L5.Text = "Compute alongshore transports"
		L5.Location = s.Point(window_width/2 - label_width,10.4*vert_spacing)
		L5.Width = 2*label_width
		group_IN.Controls.Add(L5)
		
		# 6. Check boxes
		L6 = CheckBox()
		L6.Text = "Open results in a new window"
		L6.Location = s.Point(window_width/2 - 0.75*label_width,11.1*vert_spacing)
		L6.Width = 1.5*label_width
		group_IN.Controls.Add(L6)
		
		return L1, L2, L3, L4, L5, L6, L7
		
	def CreateInputDataGroupBox_CE():
		group_CE = Panel()
		group_CE.Font = s.Font(group_CE.Font.FontFamily, 10)
		group_CE.Dock = DockStyle.Fill
		
		# 1. Active height

		text_active_height = Label()
		text_active_height.Text = "Active height:"
		text_active_height.Location = s.Point(window_width/2 - 1.05*label_width,3.6*vert_spacing)
		text_active_height.Width = 0.8*label_width
		text_active_height.TextAlign = ContentAlignment.MiddleRight
		group_CE.Controls.Add(text_active_height)
		
		def set_active_height():
			InputValues.active_height = float(nud_active_height.Value)
		
		nud_active_height = NumericUpDown()
		nud_active_height.DecimalPlaces = 1
		nud_active_height.TextAlign = HorizontalAlignment.Right
		nud_active_height.Increment = 0.1 #for increment with dir keys
		nud_active_height.Maximum = 100 #max bounds
		nud_active_height.Minimum = 1 #min bounds
		nud_active_height.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,3.6*vert_spacing)
		nud_active_height.Width = 0.5*label_width
		nud_active_height.Value = InputValues.active_height #default number
		nud_active_height.ValueChanged += lambda s,e : set_active_height()
		group_CE.Controls.Add(nud_active_height)
		
		text_active_height_unit = Label()
		text_active_height_unit.Text = "[m]"
		text_active_height_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,3.6*vert_spacing)
		text_active_height_unit.Width = 0.5*label_width
		text_active_height_unit.TextAlign = ContentAlignment.MiddleLeft
		group_CE.Controls.Add(text_active_height_unit)
		
		# 2. Number of coastline points 
		
		text_npoints = Label()
		text_npoints.Text = "N points:"
		text_npoints.Location = s.Point(window_width/2 - 1.05*label_width,4.3*vert_spacing)
		text_npoints.Width = 0.8*label_width
		text_npoints.TextAlign = ContentAlignment.MiddleRight
		group_CE.Controls.Add(text_npoints)
		
		def set_npoints():
			InputValues.npoints = int(nud_npoints.Value)
		
		nud_npoints = NumericUpDown()
		nud_npoints.DecimalPlaces = 0
		nud_npoints.TextAlign = HorizontalAlignment.Right
		nud_npoints.Increment = 1 #for increment with dir keys
		nud_npoints.Maximum = 1000 #max bounds
		nud_npoints.Minimum = 1 #min bounds
		nud_npoints.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,4.3*vert_spacing)
		nud_npoints.Width = 0.5*label_width
		nud_npoints.Value = InputValues.npoints #default number
		nud_npoints.ValueChanged += lambda s,e : set_npoints()
		group_CE.Controls.Add(nud_npoints)
		
		text_npoints_unit = Label()
		text_npoints_unit.Text = "[-]"
		text_npoints_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,4.3*vert_spacing)
		text_npoints_unit.Width = 0.5*label_width
		text_npoints_unit.TextAlign = ContentAlignment.MiddleLeft
		group_CE.Controls.Add(text_npoints_unit)
		
		# 3. Time to compute:
		
		text_time = Label()
		text_time.Text = "Total time:"
		text_time.Location = s.Point(window_width/2 - 1.05*label_width,5.0*vert_spacing)
		text_time.Width = 0.8*label_width
		text_time.TextAlign = ContentAlignment.MiddleRight
		group_CE.Controls.Add(text_time)
		
		def set_time():
			InputValues.time = int(nud_time.Value)
		
		nud_time = NumericUpDown()
		nud_time.DecimalPlaces = 0
		nud_time.TextAlign = HorizontalAlignment.Right
		nud_time.Increment = 1 #for increment with dir keys
		nud_time.Maximum = 10000 #max bounds
		nud_time.Minimum = 1 #min bounds
		nud_time.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,5.0*vert_spacing)
		nud_time.Width = 0.5*label_width
		nud_time.Value = InputValues.time #default number
		nud_time.ValueChanged += lambda s,e : set_time()
		group_CE.Controls.Add(nud_time)
		
		text_time_unit = Label()
		text_time_unit.Text = "[years]"
		text_time_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,5.0*vert_spacing)
		text_time_unit.Width = 0.70*label_width
		text_time_unit.TextAlign = ContentAlignment.MiddleLeft
		group_CE.Controls.Add(text_time_unit)
		
		# 4. Time step:
		
		text_time_step = Label()
		text_time_step.Text = "Time step:"
		text_time_step.Location = s.Point(window_width/2 - 1.05*label_width,5.7*vert_spacing)
		text_time_step.Width = 0.8*label_width
		text_time_step.TextAlign = ContentAlignment.MiddleRight
		group_CE.Controls.Add(text_time_step)
		
		def set_time_step():
			InputValues.time_step = float(nud_time_step.Value)
		
		nud_time_step = NumericUpDown()
		nud_time_step.DecimalPlaces = 1
		nud_time_step.TextAlign = HorizontalAlignment.Right
		nud_time_step.Increment = 0.1 #for increment with dir keys
		nud_time_step.Maximum = 100 #max bounds
		nud_time_step.Minimum = 0.1 #min bounds
		nud_time_step.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,5.7*vert_spacing)
		nud_time_step.Width = 0.5*label_width
		nud_time_step.Value = InputValues.time_step #default number
		nud_time_step.ValueChanged += lambda s,e : set_time_step()
		group_CE.Controls.Add(nud_time_step)
		
		text_time_step_unit = Label()
		text_time_step_unit.Text = "[years]"
		text_time_step_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,5.7*vert_spacing)
		text_time_step_unit.Width = 0.5*label_width
		text_time_step_unit.TextAlign = ContentAlignment.MiddleLeft
		group_CE.Controls.Add(text_time_step_unit)
		
		# Select Boundary conditions (Left)
		B4a = Label()
		B4a.Text = "Left boundary:"
		B4a.Location = s.Point(window_width/2 - label_width,10.4*vert_spacing)
		B4a.Width = label_width
		group_CE.Controls.Add(B4a)
		
		def change_leftbnd(s,e):
			if s.SelectedIndex==2:
				s.SelectedIndex=0
			InputValues.leftbnd = s.SelectedIndex#s.Items[s.SelectedIndex]
			
		B4b = ComboBox()
		B4b.Items.Add('S = 0')
		B4b.Items.Add('dS = 0')
		B4b.Items.Add('S = x (not implemented)')
		B4b.SelectedIndex = 0
		B4b.Location = s.Point(window_width/2 - label_width,11*vert_spacing)
		B4b.Width = label_width
		B4b.SelectionChangeCommitted += change_leftbnd
		group_CE.Controls.Add(B4b)
		
		# Select Boundary conditions (Right)
		B4a = Label()
		B4a.Text = "Right boundary:"
		B4a.Location = s.Point(window_width/2,10.4*vert_spacing)
		B4a.Width = 0.9*label_width
		group_CE.Controls.Add(B4a)
		
		def change_RightBND(s,e):
			if s.SelectedIndex==2:
				s.SelectedIndex=0
			InputValues.rightbnd = s.SelectedIndex#s.Items[s.SelectedIndex]
		B4b = ComboBox()
		B4b.Items.Add('S = 0')
		B4b.Items.Add('dS = 0')
		B4b.Items.Add('S = x (not implemented)')
		B4b.SelectedIndex = 1
		B4b.Location = s.Point(window_width/2,11*vert_spacing)
		B4b.Width = 0.9*label_width
		B4b.SelectionChangeCommitted += change_RightBND
		group_CE.Controls.Add(B4b)
		
		return group_CE
	
	def CreateButtons_CE(group_CE):
		
		# 1. Cross-shore transect
		C1 = Button()
		C1.BackColor = Color.LightGray
		C1.Text = "Add a coastline"
		C1.Location = s.Point(window_width/2 - label_width,0.8*vert_spacing)
		C1.Width = 2*label_width
		group_CE.Controls.Add(C1)
		
		# 2. Wave conditions
		C2 = Button()
		C2.BackColor = Color.LightGray
		C2.Text = "Get and set wave conditions"
		C2.Location = s.Point(window_width/2 - label_width,2*vert_spacing)
		C2.Width = 2*label_width
		group_CE.Controls.Add(C2)
		
		# 3. Wave transformation
		C3 = CheckBox()
		C3.Enabled=False
		C3.Text = "Transform these waves to nearshore"
		C3.Location = s.Point(window_width/2 - 0.8*label_width,2.6*vert_spacing)
		C3.Width = 2*label_width
		group_CE.Controls.Add(C3)
		
		# 4. Select Function
		C4 = Label()
		C4.Text = "Select a function:"
		C4.Location = s.Point(window_width/2 - 1.0*label_width,9.0*vert_spacing)
		C4.Width = 1.5*label_width
		group_CE.Controls.Add(C4)
		
		def change_function(s,e):
			if s.SelectedIndex==2:
				s.SelectedIndex=0
			InputValues.formula_name = s.Items[s.SelectedIndex]
			
		C7 = ComboBox()
		C7.Items.Add('Kamphuis')
		C7.Items.Add('CERC')
		C7.Items.Add('van Rijn (not implemented yet)')
		C7.SelectedIndex = 0
		C7.Location = s.Point(window_width/2 - label_width,9.6*vert_spacing)
		C7.Width = 2*label_width
		C7.SelectionChangeCommitted += change_function
		group_CE.Controls.Add(C7)
		
		# 5. Compute button
		C5 = Button()
		C5.Enabled = True
		C5.BackColor = Color.LightGray
		C5.Text = "Compute coastline evolution"
		C5.Location = s.Point(window_width/2 - label_width,11.8*vert_spacing)
		C5.Width = 2*label_width
		group_CE.Controls.Add(C5)
		
		# 6. Check boxes
		C6 = CheckBox()
		C6.Text = "Open results in a new window"
		C6.Location = s.Point(window_width/2 - 0.75*label_width,12.4*vert_spacing)
		C6.Width = 1.5*label_width
		group_CE.Controls.Add(C6)
		
		return C1, C2, C3, C4, C5, C6, C7
		
	
	group_INTABS = GroupBox()
	group_INTABS.Text = "Input"
	group_INTABS.Font = s.Font(group_INTABS.Font.FontFamily, 10)
	group_INTABS.Dock = DockStyle.Left
	group_INTABS.Width = 2*label_width+4*spacer_width
	
	inputTabs, L1, L2, L3, L4, L5, L6, L7, C1, C2, C3, C4, C5, C6, C7 = make_InputTabs()
	
	group_INTABS.Controls.Add(inputTabs)
		
	return group_INTABS, L1, L2, L3, L4, L5, L6, L7, C1, C2, C3, C4, C5, C6, C7
	
def createMapControl():
	map = MapView() #empty map view
	map.Dock = DockStyle.Fill #fill the space
	OSML_layer = OSML()
	OSML_layer.Name = "OpenStreetMaps"
	OSML_layer.ShowInLegend = False
	map.Map.Layers.Add(OSML_layer)
	map.Map.CoordinateSystem = CreateCoordinateSystem(3857)
	
	# Set the extent to the Netherlands:
	map.Map.ZoomToFit(Env(350000.0,800000.0,6700000.0,7100000.0))
	
	group_MAP      = GroupBox()
	group_MAP.Text = "Map View"
	group_MAP.Font = s.Font(group_MAP.Font.FontFamily, 10)
	group_MAP.Dock = DockStyle.Fill # Will be shrinked by the input group
	
	# Add the map to the map group:
	group_MAP.Controls.Add(map)
	
	# Add message box cross-shore profile
	ClickProfile = Label()
	ClickProfile.Text = "Please click the first point at the coastline and the second point offshore You can end with a double click (only the first 2 points are used)"
	ClickProfile.Visible = False
	ClickProfile.BackColor = Color.White
	ClickProfile.BorderStyle = BorderStyle.FixedSingle
	ClickProfile.Location = s.Point(10,25)
	ClickProfile.Width = 450
	ClickProfile.Height = 30
	ClickProfile.TextAlign = ContentAlignment.MiddleCenter
	group_MAP.Controls.Add(ClickProfile)

	# Add layer for cross-shore profile
	LAY_LT = CreateLayerForFeatures("Cross-shore profiles", [], None)
	ShowLayerLabels(LAY_LT, "title")
	LAY_LT.Style.Line.Color = Color.Black
	LAY_LT.Style.Line.Width = 5
	LAY_LT.Style.Line.DashStyle = DashStyle.Dot
	LAY_LT.FeatureEditor = Feature2DEditor(None)
	LAY_LT.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(3857)
	map.Map.Layers.Add(LAY_LT)
	LAY_LT.RenderOrder = 0
	LAY_LT.ShowInLegend = False

	# Add message box coastline
	ClickCoastline = Label()
	ClickCoastline.Text = "Please click the coastline with the sea on the left side. You can end with a double click"
	ClickCoastline.Visible = False
	ClickCoastline.BackColor = Color.White
	ClickCoastline.BorderStyle = BorderStyle.FixedSingle
	ClickCoastline.Location = s.Point(10,25)
	ClickCoastline.Width = 450
	ClickCoastline.Height = 30
	ClickCoastline.TextAlign = ContentAlignment.MiddleCenter
	group_MAP.Controls.Add(ClickCoastline)
	
	
	# Add layer for coastline
	LAY_CE = CreateLayerForFeatures("Coastline", [], None)
	ShowLayerLabels(LAY_CE, "title")
	LAY_CE.Style.Line.Color = Color.Black
	LAY_CE.Style.Line.Width = 5
	LAY_CE.Style.Line.DashStyle = DashStyle.Dot
	LAY_CE.FeatureEditor = Feature2DEditor(None)
	LAY_CE.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(3857)
	map.Map.Layers.Add(LAY_CE)
	LAY_CE.RenderOrder = 0
	LAY_CE.ShowInLegend = False

	newLineTool = NewLineTool(None, "New polygon tool", CloseLine = False)	
	# Define layer filter for newLineTool (layer to add the new features to)
	newLineTool.DrawLineDistanceHints = True
	# Add tool
	map.MapControl.Tools.Add(newLineTool)

	return map, group_MAP, newLineTool, ClickProfile, LAY_LT, ClickCoastline, LAY_CE
	
def get_wave_data_from_gui(map,L3):
	if wwd.ui_wavewind.frmWaveData.ShowDialog() == DialogResult.OK:
		InputValues.Wave_data     = wwd.ui_wavewind.frmWaveData.Data
		InputValues.input_type    = wwd.ui_wavewind.frmWaveData.Type
		InputValues.wave_loc_xyz  = np.array([wwd.ui_wavewind.frmWaveData.X,wwd.ui_wavewind.frmWaveData.Y,wwd.ui_wavewind.frmWaveData.Z])
		InputValues.wave_loc_epsg = wwd.ui_wavewind.frmWaveData.epsg
		
		lay_to_rem = None
		for i in range(0,len(map.Map.Layers)):
			if map.Map.Layers[i].Name == "Wave data position":
				lay_to_rem = i
		if lay_to_rem != None:
			map.Map.Layers.Remove(map.Map.Layers[lay_to_rem])
		
		if wwd.ui_wavewind.frmWaveData.X != None and wwd.ui_wavewind.frmWaveData.Y != None:
			wave_point_feature = []
			wave_point_feature.append(Feature(Geometry = CreatePointGeometry(wwd.ui_wavewind.frmWaveData.X,wwd.ui_wavewind.frmWaveData.Y)))
			
			wave_point_feature[0].Attributes = DictionaryFeatureAttributeCollection()
			wave_point_feature[0].Attributes['title'] = "Wave data position"
			
			LAY_WAVE = CreateLayerForFeatures("Wave data position", wave_point_feature, CreateCoordinateSystem(InputValues.wave_loc_epsg))
			map.Map.Layers.Insert(0,LAY_WAVE)
			
			ShowLayerLabels(LAY_WAVE, "title")
			LAY_WAVE.LabelLayer.Style.HorizontalAlignment = HorizontalAlignmentEnum.Left
			
			L3.Enabled = True
		else:
			L3.Enabled = False
			L3.Checked = False

def add_CS_profile(map,group_MAP,InputValues,newLineTool,ClickProfile,LAY_LT):
	
	# Create a layer for the polygons if not existing yet:
	ClickProfile.Visible = True
	map.MapControl.Focus()
	
	# Create new line tool for line (CloseLine = False)
	map.MapControl.ActivateTool(newLineTool)
	
	newLineTool.LayerFilter = lambda l : l == LAY_LT
	
	ClickProfile.BringToFront()
	
def add_Coastline(map,group_MAP,InputValues,newLineTool,ClickCoastline,LAY_CE):

	# Create a layer for the polygons if not existing yet:
	ClickCoastline.Visible = True
	ClickCoastline.BringToFront()
	map.MapControl.Focus()
	
	# Create new line tool for line (CloseLine = False)
	map.MapControl.ActivateTool(newLineTool)
	
	newLineTool.LayerFilter = lambda l : l == LAY_CE
	
def plot_Coastline(map,LAY_CE,InputValues):

	LAY_CE.FeatureEditor.AddNewFeatureByGeometry(LAY_CE,CreateLineGeometry(InputValues.Coastline_utm))
	
	LAY_BW = CreateLayerForFeatures("Breakwater", [], None)
	ShowLayerLabels(LAY_BW, "title")
	LAY_BW.Style.Line.Color = Color.Black
	LAY_BW.Style.Line.Width = 6
	LAY_BW.FeatureEditor = Feature2DEditor(None)
	LAY_BW.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(3857)
	map.Map.Layers.Add(LAY_BW)
	LAY_BW.RenderOrder = 0
	LAY_BW.ShowInLegend = False
	LAY_BW.FeatureEditor.AddNewFeatureByGeometry(LAY_BW,CreateLineGeometry([[606900,7023447],[605169,7024503]]))
	
	map.Map.ZoomToFit(Env(596431.0,617840.0,7012619.0,7031693.0))

def start_to_compute_LT(newLineTool,message,map,InputValues,LAY_LT,L6,L3):
	InputValues.was_computed_b4 = True
	FeaturesChanges(newLineTool,message,map,InputValues,LAY_LT,L6,L3,True)

def start_to_compute_CE(OutputValues,InputValues,map,L6):
	# Remove previous output layers
	RemLay = map.Map.GetLayerByName("Coastline Development")
	map.Map.Layers.Remove(RemLay)
	
	# Add layer for output
	LayOutput = CreateLayerForFeatures("Coastline Development", [], CreateCoordinateSystem(3857))
	map.Map.Layers.Add(LayOutput)
	
	# Calculate and plot intermediate results
	coastline_engine(OutputValues,InputValues,DemoVersion,map,L6)
	
	# Plot final results
	plot_coastline_evolution(InputValues,OutputValues,map,L6)

def update_map_plot(map,LAY_LT):
	# Delete the old basepoints:
	inds_to_rem = []
	for ind in range(0,len(map.Map.Layers)):
		if map.Map.Layers[ind].Name == "Basepoints":
			inds_to_rem.append(ind)
	inds_to_rem.reverse()
	if len(inds_to_rem)>0:
		for ind in inds_to_rem:
			map.Map.Layers.Remove(map.Map.Layers[ind])
	
	for feature in LAY_LT.DataSource.Features:
		start_point = feature.Geometry.Coordinates.Get(0)
		end_point   = feature.Geometry.Coordinates.Get(1)
		
		basepoint_features = []
		basepoint_features.append(Feature(Geometry = CreatePointGeometry(start_point.X,start_point.Y)))
		basepoint_features[-1].Attributes = DictionaryFeatureAttributeCollection()
		basepoint_features[-1].Attributes['title'] = str(int(np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0)))  + " deg. N"
		
		LAY_BASE = CreateLayerForFeatures("Basepoints", basepoint_features, CreateCoordinateSystem(3857))
		map.Map.Layers.Insert(0,LAY_BASE)
		ShowLayerLabels(LAY_BASE, "title")
		if (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) < 90.0) or (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) > 270.0):
			LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Bottom
		else:
			LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Top

def update_CE_map_plot(map,LAY_CE):
	# Delete the old basepoints:
	inds_to_rem = []
	for ind in range(0,len(map.Map.Layers)):
		if map.Map.Layers[ind].Name == "Basepoints":
			inds_to_rem.append(ind)
	inds_to_rem.reverse()
	if len(inds_to_rem)>0:
		for ind in inds_to_rem:
			map.Map.Layers.Remove(map.Map.Layers[ind])
	
	"""for feature in LAY_CE.DataSource.Features:
		start_point = feature.Geometry.Coordinates.Get(0)
		end_point   = feature.Geometry.Coordinates.Get(1)
		
		basepoint_features = []
		basepoint_features.append(Feature(Geometry = CreatePointGeometry(start_point.X,start_point.Y)))
		basepoint_features[-1].Attributes = DictionaryFeatureAttributeCollection()
		basepoint_features[-1].Attributes['title'] = str(int(np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0)))  + " deg. N"
		
		LAY_BASE = CreateLayerForFeatures("Basepoints", basepoint_features, CreateCoordinateSystem(3857))
		map.Map.Layers.Insert(0,LAY_BASE)
		ShowLayerLabels(LAY_BASE, "title")
		if (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) < 90.0) or (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) > 270.0):
			LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Bottom
		else:
			LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Top"""

def FeaturesChanges(newLineTool,message,map,InputValues,LAY_LT,L6,L3,clicked):
	newLineTool.IsActive = False
	InputValues.Profiles_former = InputValues.Profiles
	
	# Loop through all features and generate the InputValues.Profiles:
	InputValues.Profiles           = np.array([[None,None]])
	InputValues.Profiles_utm       = np.array([[None,None]])
	InputValues.Profiles_utm_codes = np.array([[]])
	CS_code_compute = np.array([])
	utm_error = False
	for feature in LAY_LT.DataSource.Features:
		if feature.Geometry.NumPoints >= 2:
			start_point = feature.Geometry.Coordinates.Get(0)
			end_point   = feature.Geometry.Coordinates.Get(1)
			CS_code_compute_1, start_point_utm  = points_to_utm(np.array([[start_point.X,start_point.Y]]),3857)
			CS_code_compute_2, end_point_utm    = points_to_utm(np.array([[end_point.X,end_point.Y]]),3857)
			InputValues.Profiles_utm_codes     = np.append(InputValues.Profiles_utm_codes,[[CS_code_compute_1]])
			if CS_code_compute_1 != CS_code_compute_2:
				if ((((end_point.X - start_point.X)**2) + ((end_point.Y - start_point.Y)**2))**(1.0/2.0)) < 50000:
					# We can agree on this, though just make sure the points are now both in the same CS_code_compute_1:
					CS_code_compute_1_tmp, start_point_utm  = points_to_utm(np.array([[start_point.X,start_point.Y]]),3857,CS_code_compute_1)
					CS_code_compute_2_tmp, end_point_utm    = points_to_utm(np.array([[end_point.X,end_point.Y]]),3857,CS_code_compute_1)
				else:
					utm_error = True
			InputValues.Profiles     = np.append(InputValues.Profiles,[[start_point.X,start_point.Y],[end_point.X,end_point.Y],[None,None]],axis=0)
			InputValues.Profiles_utm = np.append(InputValues.Profiles_utm,[start_point_utm[0],end_point_utm[0],[None,None]],axis=0)
			if feature.Geometry.NumPoints >= 3:
				feature.Geometry = CreateLineGeometry([[start_point.X,start_point.Y],[end_point.X,end_point.Y]])
	
	message.Visible = False
	
	update_plot     = False
	update_compute  = False
	
	if clicked: # forced plot/compute
		update_plot    = True
		update_compute = True
	
	if (InputValues.Profiles.shape[0] != InputValues.Profiles_former.shape[0]):
		update_plot = True
	else:
		for ind in range(1,InputValues.Profiles.shape[0],3):
			if (InputValues.Profiles[ind][0] != InputValues.Profiles_former[ind][0]) or (InputValues.Profiles[ind][1] != InputValues.Profiles_former[ind][1]) or (InputValues.Profiles[ind+1][0] != InputValues.Profiles_former[ind+1][0]) or (InputValues.Profiles[ind+1][1] != InputValues.Profiles_former[ind+1][1]):
				update_plot = True
				break
	
	if update_plot and utm_error:
		MessageBox.Show("Start and end points of your profiles are defined in different UTM zones (so they are probably very, very big), please change this to make a computation","Too large cross-sections")
		return
	
	if InputValues.Profiles.shape[0]>1 and InputValues.Wave_data != None and InputValues.was_computed_b4 and utm_error==False:
		if InputValues.Profiles.shape[0] != InputValues.Profiles_former.shape[0]:
			# length is different, so transports are updated anyway:
			update_compute = True
		else:
			# Now, if the length is the same, lets see if they are identical, if not, call the compute function again:
			for ind in range(1,InputValues.Profiles.shape[0],3):
				if (InputValues.Profiles[ind][0] != InputValues.Profiles_former[ind][0]) or (InputValues.Profiles[ind][1] != InputValues.Profiles_former[ind][1]) or (InputValues.Profiles[ind+1][0] != InputValues.Profiles_former[ind+1][0]) or (InputValues.Profiles[ind+1][1] != InputValues.Profiles_former[ind+1][1]):
					update_compute = True
					break
	if update_plot:
		update_map_plot(map,LAY_LT)
		
		if update_compute:
			main_function(map,InputValues,L6,L3)
			return

def GetCoastline(OutputValues,newLineTool,message,map,InputValues,LAY_CE,C6,C3,clicked):
	#InputValues.Coastline
	#InputValues.Coastline_utm
	
	newLineTool.IsActive = False
	InputValues.Coastline_former = InputValues.Coastline
	
	# Loop through all features and generate the InputValues.Profiles:
	CS_code_compute = np.array([])
	utm_error = False
	InputValues.Coastline = np.array([None,None])
	InputValues.Coastline_utm = np.array([None,None])
	for feature in LAY_CE.DataSource.Features:
		get_utm_code = True
		for coordinate in feature.Geometry.Coordinates:
			if get_utm_code:
				CS_code_compute, coord_utm = points_to_utm(np.array([[coordinate.X,coordinate.Y]]),3857)
				get_utm_code = False
			else:
				_, coord_utm = points_to_utm(np.array([[coordinate.X,coordinate.Y]]),3857,CS_code_compute)
				
			InputValues.Coastline_utm_codes     = np.array([CS_code_compute])
			InputValues.Coastline     = np.vstack((InputValues.Coastline,[coordinate.X,coordinate.Y]))
			InputValues.Coastline_utm = np.vstack((InputValues.Coastline_utm,[coord_utm[0],coord_utm[0]]))
		
	message.Visible = False
	
	update_plot     = False
	update_compute  = False
	
	if clicked: # forced plot/compute
		update_plot    = True
		update_compute = True
	
	if (InputValues.Coastline.shape[0] != InputValues.Coastline_former.shape[0]):
		update_plot = True
	else:
		for ind in range(1,InputValues.Coastline.shape[0],3):
			if (InputValues.Coastline[ind][0] != InputValues.Coastline_former[ind][0]) or (InputValues.Coastline[ind][1] != InputValues.Coastline_former[ind][1]) or (InputValues.Coastline[ind+1][0] != InputValues.Coastline_former[ind+1][0]) or (InputValues.Coastline[ind+1][1] != InputValues.Coastline_former[ind+1][1]):
				update_plot = True
				break
	
	if InputValues.Coastline.shape[0]>1 and InputValues.Wave_data != None and InputValues.was_computed_b4 and utm_error==False:
		if InputValues.Coastline.shape[0] != InputValues.Coastline_former.shape[0]:
			# length is different, so transports are updated anyway:
			update_compute = True
		else:
			# Now, if the length is the same, lets see if they are identical, if not, call the compute function again:
			for ind in range(1,InputValues.Profiles.shape[0],3):
				if (InputValues.Coastline[ind][0] != InputValues.Coastline_former[ind][0]) or (InputValues.Coastline[ind][1] != InputValues.Coastline_former[ind][1]) or (InputValues.Coastline[ind+1][0] != InputValues.Coastline_former[ind+1][0]) or (InputValues.Coastline[ind+1][1] != InputValues.Coastline_former[ind+1][1]):
					update_compute = True
					break
	if update_plot:
		update_CE_map_plot(map,LAY_CE)
		
		if update_compute:
			coastline_engine(OutputValues,InputValues,DemoVersion)

def createView():
	input_window      = View() #build INPUT view window
	input_window.Text = "Coastline Development"
	
	map, group_MAP, newLineTool, ClickProfile, LAY_LT, ClickCoastline, LAY_CE = createMapControl()
	
	group_TAB, L1, L2, L3, L4, L5, L6, L7, C1, C2, C3, C4, C5, C6, C7 = createInputControl()
	
	L2.Click += lambda s,e : get_wave_data_from_gui(map,L3)
	L1.Click += lambda s,e : add_CS_profile(map,group_MAP,InputValues,newLineTool,ClickProfile,LAY_LT)
	L5.Click += lambda s,e : start_to_compute_LT(newLineTool,ClickProfile,map,InputValues,LAY_LT,L6,L3)
	
	C2.Click += lambda s,e : get_wave_data_from_gui(map,C3)
	if DemoVersion:
		C1.Click += lambda s,e : plot_Coastline(map,LAY_CE,InputValues)
	else:
		C1.Click += lambda s,e : add_Coastline(map,group_MAP,InputValues,newLineTool,ClickCoastline,LAY_CE)
	
	C5.Click += lambda s,e : start_to_compute_CE(OutputValues,InputValues,map,C6)
	
	input_window.Controls.Add(group_MAP)
	input_window.Controls.Add(group_TAB)
	# This function executes whenever a cross-shore profile was added or deleted:
	# We also want this function to run when we change points, but this is not triggered by FeaturesChanges (should be the case!)
	#LAY_LT.DataSource.FeaturesChanged += lambda s,e: FeaturesChanges(newLineTool,ClickProfile,map,InputValues,LAY_LT,L6,L3,False)
	#LAY_CE.DataSource.FeaturesChanged += lambda s,e: GetCoastline(newLineTool,ClickCoastline,map,InputValues,LAY_CE,C6,C3,False)
	# As a workaround, we also call the function whenever the Layer is rendered, using the LayerRendered trigger:
	#LAY_LT.LayerRendered += lambda s,e: FeaturesChanges(newLineTool,ClickProfile,map,InputValues,LAY_LT,L6,L3,False) # Remove this after Delta Shell has a fix for the above!
	#LAY_CE.LayerRendered += lambda s,e: GetCoastline(newLineTool,ClickCoastline,map,InputValues,LAY_CE,C6,C3,False) # Remove this after Delta Shell has a fix for the above!
	
	return input_window, map

#debugging
def start_CD_GUI():
	view, map = createView()
	# 	Make sure the map controls are active
	view.ChildViews.Add(map)
	
	view.Show()

start_CD_GUI()

view.Show()

#OutputValues.Years
#OutputValues.Time
#InputValues.time_step

#map.Map.Layers[3].ShowInLegend


"""x = []
y = []
a = map.Map.GetLayerByName("Coastlin2e")
for feature in a.DataSource.Features:
for coordinate in feature.Geometry.Coordinates:
	x.append([coordinate.X,coordinate.Y])
	x = np.array(x)"""

"""feature1 = Feature()
feature1.Geometry = CreateLineGeometry(OutputValues.Coastline_utm[-1])
a = map.Map.GetLayerByName("Coastline")
a.DataSource.Add(feature1)"""
"""name = []
for t in map.MapControl.Tools:
	name.append(t.Name)
	if t.Name == "NorthArrow":
		t.Execute()
		t.Visible = True

map.Map."""
#LayOutput = map.Map.GetLayerByName("Output")
#feature1 = LayOutput.FeatureEditor.AddNewFeatureByGeometry(LayOutput,CreateLineGeometry(OutputValues.Coastline_utm[-1]))
#map.Map.Layers.Remove(LayOutput)