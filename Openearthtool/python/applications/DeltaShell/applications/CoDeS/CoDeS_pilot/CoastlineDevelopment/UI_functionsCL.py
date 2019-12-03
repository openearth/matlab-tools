#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Freek Scheel
#
#       freek.scheel@deltares.nl
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
from Scripts.CoastlineDevelopment.general_functions import *
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
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import Button, DockStyle, AnchorStyles, Padding

from Libraries.StandardFunctions import *
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
from DelftTools.Utils import Url

import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env

# import Scripts.WaveWindData.ui_wavewind as get_wave_wind <-- for use in GUI upon clicking

class InputData(object):
	def __init__(self):
		self.Profiles       = np.array([[None,None]])
		self.Wave_data      = None
		self.input_type     = None
		self.formula_name   = 'Kamphuis'
		self.beach_slope    = 1.0/100.0
		self.rho_s          = 2650.0
		self.rho_w          = 1025.0
		self.d50            = 0.000200 # in m
		self.porosity       = 0.4
		self.doc            = 5.0
		self.gamma          = 0.7
		self.wave_loc_xyz   = np.array([None,None,None])
		self.wave_loc_epsg  = 3857
	def Clone(self):
		clone = InputData()
		clone.Profiles      = self.Profiles
		clone.Wave_data     = self.Wave_data
		close.input_type    = self.input_type
		close.formula_name  = self.formula_name
		clone.beach_slope   = self.beach_slope
		clone.rho_s         = self.rho_s
		clone.rho_w         = self.rho_w
		clone.d50           = self.d50    
		clone.porosity      = self.porosity
		clone.doc           = self.doc
		clone.gamma         = self.gamma
		clone.wave_loc_xyz  = self.wave_loc_xyz
		clone.wave_loc_epsg = self.wave_loc_epsg
		return clone

cs_variables = InputData()

def start_CD_GUI():
	# This code starts the GUI opon clicking the the GUI button:
	
	cs_variables.Profiles   = np.array([[None,None]])
	cs_variables.Wave_data  = None
	cs_variables.input_type = None
	
	def n_a(sender, event):
		S1.Text = "Not available yet, but we're working on it!\n" + S1.Text
	
	def FeaturesChanges(newLineTool,message):
		newLineTool.IsActive = False
		added_feature = prof_layer.DataSource.Features[len(prof_layer.DataSource.Features)-1]
		# HIDDE
		"""def test():
			print 'changed'
		prof_layer.DataSource.Features.CollectionChanged
		added_feature.Geometry.GeometryChanged"""
		# print added_feature
		if added_feature.Geometry.NumPoints >= 2:
			start_point = added_feature.Geometry.Coordinates.Get(0)
			end_point   = added_feature.Geometry.Coordinates.Get(1)
			cs_variables.Profiles = np.append(cs_variables.Profiles,[[start_point.X,start_point.Y],[end_point.X,end_point.Y],[None,None]], axis=0)
			if added_feature.Geometry.NumPoints >= 3:
				added_feature.Geometry = CreateLineGeometry([[start_point.X,start_point.Y],[end_point.X,end_point.Y]])
		message.Visible = False
	
	def add_CS_profile(map,cs_variables,prof_layer,newLineTool,message):
		# Create a layer for the polygons if not existing yet:
		
		message.Visible = True
		
		map.MapControl.Focus()
		
		# Create new line tool for line (CloseLine = False)
		
		map.MapControl.ActivateTool(newLineTool)
	
	sp_loc = 5 #start point/location for labels (from left edge)
	label_width  = 140 #width for labels + textboxes...
	spacer_width = 20 #horizontal spacing between label + textboxes
	vert_spacing = 40 #vertical spacing between labels (from previous)
	window_width = 2*label_width+2*spacer_width
	
	input_window      = View() #build INPUT view window
	input_window.Text = "Coastline Development"
	input_window.Show()
	
	# Define the map:
	map = MapView() #empty map view
	map.Dock = DockStyle.Fill #fill the space
	OSML_layer = OSML()
	OSML_layer.Name = "OpenStreetMaps"
	map.Map.Layers.Add(OSML_layer)
	map.Map.CoordinateSystem = CreateCoordinateSystem(3857)
	# Set the extent to the Netherlands:
	map.Map.ZoomToFit(Env(350000.0,800000.0,6700000.0,7100000.0))
	
	# and put in the map group:
	group_MAP      = GroupBox()
	group_MAP.Text = "Map View"
	group_MAP.Font = s.Font(group_MAP.Font.FontFamily, 10)
	group_MAP.Dock = DockStyle.Fill # Will be shrinked by the input group
	
	profile_click_text = Label()
	profile_click_text.Text = "Please click the first point at the coastline and the second point offshore You can end with a double click (only the first 2 points are used)"
	profile_click_text.Visible = False
	profile_click_text.BackColor = Color.White
	profile_click_text.BorderStyle = BorderStyle.FixedSingle
	profile_click_text.Location = s.Point(10,25)
	profile_click_text.Width = 450
	profile_click_text.Height = 30
	profile_click_text.TextAlign = ContentAlignment.MiddleCenter
	group_MAP.Controls.Add(profile_click_text)
	
	# Add the map to the map group:
	group_MAP.Controls.Add(map)
	# And add the map to the active input_window
	input_window.ChildViews.Add(map) # if map is frozen
	input_window.Controls.Add(group_MAP)
	
	# define the input window:
	
	
	# and put it in the groupbox
	group_IN       = GroupBox()
	group_IN.Text  = "Input"
	group_IN.Font  = s.Font(group_IN.Font.FontFamily, 10)
	group_IN.Width = window_width #width of entire group box (needs to be big!)
	group_IN.Dock  = DockStyle.Left # This group will shrink the map view
	group_IN.Padding = Padding(spacer_width)
	
	# And add the map to the active input_window
	input_window.Controls.Add(group_IN)
	
	#L1a = Label()
	#L1a.Text = "Project Location:"
	#L1a.Location = s.Point(sp_loc,vert_spacing)
	#L1a.Width = label_width
	#group_IN.Controls.Add(L1a)
	
	L1abc = Button()
	L1abc.BackColor = Color.LightGray
	L1abc.Text = "Add a cross-shore transect"
	L1abc.Location = s.Point(window_width/2 - label_width,0.8*vert_spacing)
	L1abc.Width = 2*label_width
	L1abc.Click += lambda s,e : add_CS_profile(map,cs_variables,prof_layer,newLineTool,profile_click_text)
	group_IN.Controls.Add(L1abc)
	
	def get_wave_data_from_gui(map,L3a):
		if wwd.ui_wavewind.frmWaveData.ShowDialog() == DialogResult.OK:
			cs_variables.Wave_data     = wwd.ui_wavewind.frmWaveData.Data
			cs_variables.input_type    = wwd.ui_wavewind.frmWaveData.Type
			cs_variables.wave_loc_xyz  = np.array([wwd.ui_wavewind.frmWaveData.X,wwd.ui_wavewind.frmWaveData.Y,wwd.ui_wavewind.frmWaveData.Z])
			cs_variables.wave_loc_epsg = wwd.ui_wavewind.frmWaveData.epsg
			
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
				
				wave_point_layer = CreateLayerForFeatures("Wave data position", wave_point_feature, CreateCoordinateSystem(cs_variables.wave_loc_epsg))
				map.Map.Layers.Insert(0,wave_point_layer)
				
				ShowLayerLabels(wave_point_layer, "title")
				wave_point_layer.LabelLayer.Style.HorizontalAlignment = HorizontalAlignmentEnum.Left
				
				L3a.Enabled = True
			else:
				L3a.Enabled = False
				L3a.Checked = False
	
	L3a = CheckBox()
	L3a.Enabled=False
	L3a.Text = "Transform these waves to nearshore"
	L3a.Location = s.Point(window_width/2 - 0.8*label_width,2.6*vert_spacing)
	L3a.Width = 2*label_width
	group_IN.Controls.Add(L3a)
	
	L2abc = Button()
	L2abc.BackColor = Color.LightGray
	L2abc.Text = "Get and set wave conditions"
	L2abc.Location = s.Point(window_width/2 - label_width,2*vert_spacing)
	L2abc.Width = 2*label_width
	L2abc.Click += lambda s,e : get_wave_data_from_gui(map,L3a)
	group_IN.Controls.Add(L2abc)
	
	# gamma input
	
	text_gamma = Label()
	text_gamma.Text = "Breaker index:"
	text_gamma.Location = s.Point(window_width/2 - 1.05*label_width,3.6*vert_spacing)
	text_gamma.Width = 0.8*label_width
	text_gamma.TextAlign = ContentAlignment.MiddleRight
	group_IN.Controls.Add(text_gamma)
	
	def set_gamma():
		cs_variables.gamma = nud_gamma.Value
	
	nud_gamma = NumericUpDown()
	nud_gamma.DecimalPlaces = 2
	nud_gamma.TextAlign = HorizontalAlignment.Right
	nud_gamma.Increment = 0.01 #for increment with dir keys
	nud_gamma.Maximum = 0.99 #max bounds
	nud_gamma.Minimum = 0.01 #min bounds
	nud_gamma.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,3.6*vert_spacing)
	nud_gamma.Width = 0.5*label_width
	nud_gamma.Value = cs_variables.gamma #default number
	nud_gamma.ValueChanged += lambda s,e : set_gamma()
	group_IN.Controls.Add(nud_gamma)
	
	text_gamma_unit = Label()
	text_gamma_unit.Text = "[-]"
	text_gamma_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,3.6*vert_spacing)
	text_gamma_unit.Width = 0.5*label_width
	text_gamma_unit.TextAlign = ContentAlignment.MiddleLeft
	group_IN.Controls.Add(text_gamma_unit)
	
	# DOC input
	
	text_doc = Label()
	text_doc.Text = "Depth of closure:"
	text_doc.Location = s.Point(window_width/2 - 1.05*label_width,4.3*vert_spacing)
	text_doc.Width = 0.8*label_width
	text_doc.TextAlign = ContentAlignment.MiddleRight
	group_IN.Controls.Add(text_doc)
	
	def set_doc():
		cs_variables.doc = nud_doc.Value
	
	nud_doc = NumericUpDown()
	nud_doc.DecimalPlaces = 2
	nud_doc.TextAlign = HorizontalAlignment.Right
	nud_doc.Increment = 0.1 #for increment with dir keys
	nud_doc.Maximum = 10 #max bounds
	nud_doc.Minimum = 0.5 #min bounds
	nud_doc.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,4.3*vert_spacing)
	nud_doc.Width = 0.5*label_width
	nud_doc.Value = cs_variables.doc #default number
	nud_doc.ValueChanged += lambda s,e : set_doc()
	group_IN.Controls.Add(nud_doc)
	
	text_doc_unit = Label()
	text_doc_unit.Text = "[mtr.]"
	text_doc_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,4.3*vert_spacing)
	text_doc_unit.Width = 0.5*label_width
	text_doc_unit.TextAlign = ContentAlignment.MiddleLeft
	group_IN.Controls.Add(text_doc_unit)
	
	# d50 input:
	
	text_d50 = Label()
	text_d50.Text = "d50:"
	text_d50.Location = s.Point(window_width/2 - 1.05*label_width,5.0*vert_spacing)
	text_d50.Width = 0.8*label_width
	text_d50.TextAlign = ContentAlignment.MiddleRight
	group_IN.Controls.Add(text_d50)
	
	def set_d50():
		cs_variables.d50 = nud_d50.Value / 1000000
	
	nud_d50 = NumericUpDown()
	nud_d50.DecimalPlaces = 1
	nud_d50.TextAlign = HorizontalAlignment.Right
	nud_d50.Increment = 10 #for increment with dir keys
	nud_d50.Maximum = 10000 #max bounds
	nud_d50.Minimum = 1 #min bounds
	nud_d50.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,5.0*vert_spacing)
	nud_d50.Width = 0.5*label_width
	nud_d50.Value = cs_variables.d50 * 1000000 #default number
	nud_d50.ValueChanged += lambda s,e : set_d50()
	group_IN.Controls.Add(nud_d50)
	
	text_d50_unit = Label()
	text_d50_unit.Text = "[micrometer]"
	text_d50_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,5.0*vert_spacing)
	text_d50_unit.Width = 0.70*label_width
	text_d50_unit.TextAlign = ContentAlignment.MiddleLeft
	group_IN.Controls.Add(text_d50_unit)
	
	# beach slope input:
	
	text_slope = Label()
	text_slope.Text = "Beach slope:"
	text_slope.Location = s.Point(window_width/2 - 1.05*label_width,5.7*vert_spacing)
	text_slope.Width = 0.8*label_width
	text_slope.TextAlign = ContentAlignment.MiddleRight
	group_IN.Controls.Add(text_slope)
	
	def set_slope():
		cs_variables.beach_slope = nud_slope.Value
	
	nud_slope = NumericUpDown()
	nud_slope.DecimalPlaces = 3
	nud_slope.TextAlign = HorizontalAlignment.Right
	nud_slope.Increment = 0.001 #for increment with dir keys
	nud_slope.Maximum = 1 #max bounds
	nud_slope.Minimum = 0.000001 #min bounds
	nud_slope.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,5.7*vert_spacing)
	nud_slope.Width = 0.5*label_width
	nud_slope.Value = cs_variables.beach_slope #default number
	nud_slope.ValueChanged += lambda s,e : set_slope()
	group_IN.Controls.Add(nud_slope)
	
	text_slope_unit = Label()
	text_slope_unit.Text = "[-]"
	text_slope_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,5.7*vert_spacing)
	text_slope_unit.Width = 0.5*label_width
	text_slope_unit.TextAlign = ContentAlignment.MiddleLeft
	group_IN.Controls.Add(text_slope_unit)
	
	# Rho_s input
	
	text_rho_s = Label()
	text_rho_s.Text = "Rho_s:"
	text_rho_s.Location = s.Point(window_width/2 - 1.05*label_width,6.4*vert_spacing)
	text_rho_s.Width = 0.8*label_width
	text_rho_s.TextAlign = ContentAlignment.MiddleRight
	group_IN.Controls.Add(text_rho_s)
	
	def set_rho_s():
		cs_variables.rho_s = nud_rho_s.Value
	
	nud_rho_s = NumericUpDown()
	nud_rho_s.DecimalPlaces = 0
	nud_rho_s.TextAlign = HorizontalAlignment.Right
	nud_rho_s.Increment = 5 #for increment with dir keys
	nud_rho_s.Maximum = 3000 #max bounds
	nud_rho_s.Minimum = 1000 #min bounds
	nud_rho_s.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,6.4*vert_spacing)
	nud_rho_s.Width = 0.5*label_width
	nud_rho_s.Value = cs_variables.rho_s #default number
	nud_rho_s.ValueChanged += lambda s,e : set_rho_s()
	group_IN.Controls.Add(nud_rho_s)
	
	text_rho_s_unit = Label()
	text_rho_s_unit.Text = "[kg/m3]"
	text_rho_s_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,6.4*vert_spacing)
	text_rho_s_unit.Width = 0.5*label_width
	text_rho_s_unit.TextAlign = ContentAlignment.MiddleLeft
	group_IN.Controls.Add(text_rho_s_unit)
	
	# Rho_w input
	
	text_rho_w = Label()
	text_rho_w.Text = "Rho_w:"
	text_rho_w.Location = s.Point(window_width/2 - 1.05*label_width,7.1*vert_spacing)
	text_rho_w.Width = 0.8*label_width
	text_rho_w.TextAlign = ContentAlignment.MiddleRight
	group_IN.Controls.Add(text_rho_w)
	
	def set_rho_w():
		cs_variables.rho_w = nud_rho_w.Value
	
	nud_rho_w = NumericUpDown()
	nud_rho_w.DecimalPlaces = 0
	nud_rho_w.TextAlign = HorizontalAlignment.Right
	nud_rho_w.Increment = 5 #for increment with dir keys
	nud_rho_w.Maximum = 1250 #max bounds
	nud_rho_w.Minimum = 995 #min bounds
	nud_rho_w.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,7.1*vert_spacing)
	nud_rho_w.Width = 0.5*label_width
	nud_rho_w.Value = cs_variables.rho_w #default number
	nud_rho_w.ValueChanged += lambda s,e : set_rho_w()
	group_IN.Controls.Add(nud_rho_w)
	
	text_rho_w_unit = Label()
	text_rho_w_unit.Text = "[kg/m3]"
	text_rho_w_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,7.1*vert_spacing)
	text_rho_w_unit.Width = 0.5*label_width
	text_rho_w_unit.TextAlign = ContentAlignment.MiddleLeft
	group_IN.Controls.Add(text_rho_w_unit)
	
	# porosity input
	
	text_por = Label()
	text_por.Text = "Porosity:"
	text_por.Location = s.Point(window_width/2 - 1.05*label_width,7.8*vert_spacing)
	text_por.Width = 0.8*label_width
	text_por.TextAlign = ContentAlignment.MiddleRight
	group_IN.Controls.Add(text_por)
	
	def set_por():
		cs_variables.porosity = nud_por.Value
	
	nud_por = NumericUpDown()
	nud_por.DecimalPlaces = 2
	nud_por.TextAlign = HorizontalAlignment.Right
	nud_por.Increment = 0.01 #for increment with dir keys
	nud_por.Maximum = 0.99 #max bounds
	nud_por.Minimum = 0.01 #min bounds
	nud_por.Location = s.Point(window_width/2 - 0.25*label_width+spacer_width/2,7.8*vert_spacing)
	nud_por.Width = 0.5*label_width
	nud_por.Value = cs_variables.porosity #default number
	nud_por.ValueChanged += lambda s,e : set_por()
	group_IN.Controls.Add(nud_por)
	
	text_por_unit = Label()
	text_por_unit.Text = "[-]"
	text_por_unit.Location = s.Point(window_width/2 + 0.25*label_width+2*spacer_width/2,7.8*vert_spacing)
	text_por_unit.Width = 0.5*label_width
	text_por_unit.TextAlign = ContentAlignment.MiddleLeft
	group_IN.Controls.Add(text_por_unit)
	
	# function part:
	
	L4a = Label()
	L4a.Text = "Select a function:"
	L4a.Location = s.Point(window_width/2 - 1.0*label_width,9.0*vert_spacing)
	L4a.Width = 1.5*label_width
	group_IN.Controls.Add(L4a)
	
	def change_function(s,e):
		if s.SelectedIndex==2:
			s.SelectedIndex=0
		cs_variables.formula_name = s.Items[s.SelectedIndex]
	L4abc = ComboBox()
	L4abc.Items.Add('Kamphuis')
	L4abc.Items.Add('CERC')
	L4abc.Items.Add('van Rijn (not implemented yet)')
	L4abc.SelectedIndex = 0
	# L4abc.BackColor = Color.LightGray
	L4abc.Location = s.Point(window_width/2 - label_width,9.6*vert_spacing)
	L4abc.Width = 2*label_width
	L4abc.SelectionChangeCommitted += change_function
	group_IN.Controls.Add(L4abc)
	
	L5abc = Button()
	L5abc.Enabled = True
	L5abc.BackColor = Color.LightGray
	L5abc.Text = "Compute alongshore transports"
	L5abc.Location = s.Point(window_width/2 - label_width,10.4*vert_spacing)
	L5abc.Width = 2*label_width
	L5abc.Click += lambda s,e : main_function(map.Map,cs_variables,L6a,L3a)
	group_IN.Controls.Add(L5abc)
	
	L6a = CheckBox()
	L6a.Text = "Open results in a new window"
	L6a.Location = s.Point(window_width/2 - 0.75*label_width,11.1*vert_spacing)
	L6a.Width = 1.5*label_width
	group_IN.Controls.Add(L6a)
	new_window_switch = L6a # for debugging
	
	"""S1 = RichTextBox()
	S1.Text = "Awaiting User Input..."
	S1.Dock = DockStyle.Bottom
	S1.Height = 3*vert_spacing
	S1.Width = 2*label_width
	S1.BackColor = Color.LightGray
	S1.ForeColor = Color.Black
	S1.Font = s.Font(S1.Font,s.FontStyle.Italic)
	group_IN.Controls.Add(S1)"""
	
	newLineTool = NewLineTool(None, "New polygon tool", CloseLine = False)	
	# Define layer filter for newLineTool (layer to add the new features to)
	newLineTool.DrawLineDistanceHints = True
	# Add tool
	map.MapControl.Tools.Add(newLineTool)
	
	prof_layer = CreateLayerForFeatures("Cross-shore profiles", [], None)
	prof_layer.Style.Line.Color = Color.Black
	prof_layer.Style.Line.Width = 5
	prof_layer.Style.Line.DashStyle = DashStyle.Dot
	prof_layer.FeatureEditor = Feature2DEditor(None)
	prof_layer.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(3857)
	map.Map.Layers.Add(prof_layer)
	prof_layer.RenderOrder = 0
	prof_layer.DataSource.FeaturesChanged += lambda s,e: FeaturesChanges(newLineTool,profile_click_text)
	
	newLineTool.LayerFilter = lambda l : l == prof_layer
	






"""

# This code initializeS the ribbon for coastline development
ribbon = None
for child in Gui.MainWindow.Content.Children :
	if (hasattr(child,'Name') and child.Name == "Ribbon"):
		ribbon = child
# Search for existing Shortcuts tab
rm = 1
tab_h = None
while rm == 1:
	for tab in ribbon.Tabs :
		if (tab.Header == "CoDeS"):
			tab_h = tab
	if tab_h != None:
		ribbon.Tabs.Remove(tab_h)
		rm = 1
		tab_h = None
	else:
		rm=0

for i in Application.Plugins:
	if i.Name == "Toolbox":
		toobox_dir = i.Toolbox.ScriptingRootDirectory

AddShortcut("Start User Interface", "Coastal development",start_CD_GUI,toobox_dir + r"\Scripts\CoastlineDevelopment\GUI_icon.png")
AddShortcut("Compute alongshore transports", "Coastal development",main_function,toobox_dir + r"\Scripts\CoastlineDevelopment\transport.png")
AddShortcut("Compute coastline development", "Coastal development",not_available,toobox_dir + r"\Scripts\CoastlineDevelopment\coastline_change.png")

ribbon = None
for child in Gui.MainWindow.Content.Children :
	if (hasattr(child,'Name') and child.Name == "Ribbon"):
		ribbon = child
# Search for existing Shortcuts tab
for tab in ribbon.Tabs :
	if (tab.Header == "Shortcuts") :
		tab_h = tab
tab_h.Header = "CoDeS"
tab_h.IsSelected = True

"""






