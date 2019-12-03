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

#========================
#define the label SPACING
#========================
sp_loc = 5 #start point/location for labels (from left edge)
label_width = 170 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 30 #vertical spacing between labels (from previous)
vert_sp = 10 # start point/location for labels (from top edge)


def make_OutputTabs(InputData,OutputData,BWlineClone,MapEnvelope):
	outputTabs = TabControl()
	outputTabs.Dock = DockStyle.Fill
	outputTabs.Width = 2*label_width+3*spacer_width
	
	plot1 =  bw.Plot_Crossection(InputData,OutputData)
	tab_PLOT1 = TabPage() #for the plot
	tab_PLOT1.Text = "Cross-section"
	tab_PLOT1.Controls.Add(plot1)
	
	def Slider_changed(sender,tab_PLOT1,plot3,InputData,OutputData):
		# Re-create plot for cross-section
		OutputData.cross_ind = sender.Value-1
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
		lw.addBreakwaterDashes_ind(plot3, OutputData.profile, OutputData.cross_ind)
		
	if InputData.is2D:
		chart2 = lw.plotProfile(OutputData.profile,OutputData.crestheight,OutputData.layer) # Chart Profile
		#chart2 = lw.addBreakWaterDashes(chart2,self.InputData.profile)
		plot3 = ChartView()
		plot3.Chart = chart2
		plot3.Dock = DockStyle.Fill
		lw.addBreakwaterDashes_ind(plot3, OutputData.profile, OutputData.cross_ind)
		tab_PLOT2 = TabPage()
		tab_PLOT2.Text = "Profile"
		tab_PLOT2.Controls.Add(plot3)
		
	if InputData.is2D:
		Slider = TrackBar()
		#Slider.Size = Size(150, 30)
		Slider.Dock = DockStyle.Bottom
		Slider.Minimum = 1
		Slider.Maximum = len(OutputData.profile['mean_z'])
		Slider.TickFrequency = 1
		Slider.LargeChange = 1
		Slider.SmallChange = 1
		Slider.Text = "Cross-section number"
		Slider.Value = OutputData.cross_ind+1
		Slider.ValueChanged += lambda s,e : Slider_changed(s,tab_PLOT1,plot3,InputData,OutputData)
		tab_PLOT1.Controls.Add(Slider)
	
	if InputData.is2D:
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
		Rasterlaag.DataSource.Path = InputData.RasterPath
		SetGradientTheme(Rasterlaag, Rasterlaag.ThemeAttributeName, 15)
		
		mapout1.Layers.Add(Rasterlaag)
		mapout1.BringToFront(Rasterlaag)
		mapout1.BringToFront(BWlayer1)
		
		MapOut1.Map = mapout1
		MapOut1.Dock = DockStyle.Fill
		MapOut1.Map.ZoomToFit(MapEnvelope)
		MapOut1.Dock = DockStyle.Fill
		tab_MAP1.Controls.Add(MapOut1)
	else:
		MapOut1 = []
			
	
	Dimensions_Text = bw.Create_DimensionsText(InputData,OutputData)
	Conditions_Text = bw.Create_ConditionsText(InputData,OutputData)
	Volumes_Text = bw.Create_VolumesText(InputData,OutputData)
	Overtopping_Text = bw.Create_OvertoppingText(InputData,OutputData)
	
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
	if InputData.is2D:
		outputTabs.Controls.Add(tab_PLOT2)
	if InputData.is2D:
		outputTabs.Controls.Add(tab_MAP1)
		#ChildViews.Add(MapOut1)
	
	outputTabs.Controls.Add(tab_TEXT1)
	outputTabs.Controls.Add(tab_TEXT2)
	outputTabs.Controls.Add(tab_TEXT3)
	outputTabs.Controls.Add(tab_TEXT4)
	
	return outputTabs, MapOut1