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
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import numpy as np
import os

from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.UI.Tools import NewLineTool
from SharpMap.Extensions.Data.Providers import GdalFeatureProvider
from Scripts.BathymetryData import GridFunctions

from Scripts.UI_Examples.View import *
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import Button, DockStyle
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env
from SharpMap.Extensions.Layers import GdalRegularGridRasterLayer as _RegularGridRasterLayer
from System.Collections.Generic import *
from System import *

from Scripts.BathymetryData.Bathy_UI_functions import *

"""
class make_RasterPath:
	def __init__(self):
		self.path = ""
		self.MakePositive = False

global RasterPath
RasterPath = make_RasterPath()"""


def get_BW_Alignment(inputData):
	# Create layer for the polygons
	inputData.BWlayer = CreateLayerForFeatures("Breakwater", [], None)
	inputData.BWlayer.Style.Line.Color = Color.Black
	inputData.BWlayer.Style.Line.Width = 3
	inputData.BWlayer.FeatureEditor = Feature2DEditor(None)
	inputData.BWlayer.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(3857)
	#BWlayer.DataSource.Features[0].Geometry.Coordinates[0].X
	
	def FeaturesChanges(s,e):
		if len(inputData.BWlayer.DataSource.Features)>=1:
			newLineTool.IsActive = False
			buttonActivate.Enabled = False
			buttonDelete.Enabled = True
	
	inputData.BWlayer.DataSource.FeaturesChanged += FeaturesChanges
	
	# Create new line tool for line (CloseLine = False)
	newLineTool = NewLineTool(None, "New polygon tool", CloseLine = False)
	
	
	# Define layer filter for newLineTool (layer to add the new features to)
	newLineTool.LayerFilter = lambda l : l == inputData.BWlayer
	newLineTool.DrawLineDistanceHints = True
	map = Map()
	#satLayer = CreateSatelliteImageLayer()
	OSMLlayer = OSML()
	OSMLlayer.Name = "Open Street Maps"
	map.Layers.Add(inputData.BWlayer)
	#map.Layers.Add(satLayer)
	map.Layers.Add(OSMLlayer)
	map.ZoomToExtents()
	inputData.mapview = MapView()
	inputData.mapview.Map = map
	inputData.mapview.Dock = DockStyle.Fill
	inputData.mapview.Map.ZoomToFit(Env(350000.0,800000.0,6700000.0,7100000.0))
	
	# Add tool
	inputData.mapview.MapControl.Tools.Add(newLineTool)
	
	def Activate_BW(s,e):
		newLineTool.IsActive = True
		inputData.mapview.MapControl.ActivateTool(newLineTool)
		map.BringToFront(inputData.BWlayer)
	
	# Add button to reactivate tool
	buttonActivate = Button(Text = "Click Breakwater")
	buttonActivate.Dock = DockStyle.Top
	buttonActivate.Click += Activate_BW
	
	def Delete_BW(s,e):
		inputData.BWlayer.RenderRequired = True
		inputData.BWlayer.DataSource.Features.Clear()
		inputData.mapview.MapControl.SelectTool.Clear()
		newLineTool.IsActive = False
		buttonActivate.Enabled = True
		buttonDelete.Enabled = False
	
	buttonDelete = Button(Text = "Delete Breakwater")
	buttonDelete.Dock = DockStyle.Top
	buttonDelete.Click += Delete_BW
	buttonDelete.AutoSize = False
	buttonDelete.Enabled = False
	
	def Load_Bathymetry(s,e):
		Bathy = ShowBathymetryUI(map.Envelope)
		Bathy.ShowDialog()
		#print Bathy.AsciiPath
		#global RasterPath
		#MessageBox.Show("Bathymetry loaded")
		inputData.RasterPath = Bathy.AsciiPath
		#MessageBox.Show("Positive or negative " + str(Bathy.ConvertToPositive))
		inputData.MakePositive = Bathy.ConvertToPositive

		# Check if a valid path is selected
		
		ValidPath = os.path.exists(inputData.RasterPath)
		
		if ValidPath == True:		
			#RasterPath = r"C:\Users\905252\Documents\CoDeS\plugins\DeltaShell.Plugins.Toolbox\Scripts\BathymetryData\Testdata\NorthSea\rws_testdata_grid_positive.asc"
			Rasterlaag = _RegularGridRasterLayer()
			Rasterlaag.Name = "Bathymetry"
			Rasterlaag.DataSource.Path = inputData.RasterPath
			SetGradientTheme(Rasterlaag, Rasterlaag.ThemeAttributeName, 15)
			
			map.Layers.Add(Rasterlaag)
			map.BringToFront(Rasterlaag)
			inputData.mapview.Map.ZoomToFit(Rasterlaag.Envelope)
			buttonBathy.Enabled = False
			buttonDelBathy.Enabled = True
		else:
			MessageBox.Show("Please select a valid path to a bathymetry grid")
		
	def Delete_Bathymetry(s,e):
		inputData.RasterPath = ""
		map.Layers.Remove(map.GetLayerByName("Bathymetry"))
		buttonBathy.Enabled = True
		buttonDelBathy.Enabled = False
	
	
	# Add load bathymetry button
	buttonBathy = Button(Text = "Load Bathymetry")
	buttonBathy.Dock = DockStyle.Top
	buttonBathy.Click += Load_Bathymetry
	
	# Add delete bathymetry button
	buttonDelBathy = Button(Text = "Delete Bathymetry")
	buttonDelBathy.Dock = DockStyle.Top
	buttonDelBathy.Click += Delete_Bathymetry
	buttonDelBathy.Enabled = False
	
	#mapview.MapControl.
	
	inputData.mapview.Controls.Add(buttonDelete)
	inputData.mapview.Controls.Add(buttonActivate)
	inputData.mapview.Controls.Add(buttonDelBathy)
	inputData.mapview.Controls.Add(buttonBathy)
	
	
	
	return inputData

def get_situation_list(Critical_type):
	Critical_type.Items.Add('Pedestrians (unaware)')
	Critical_type.Items.Add('Pedestrians (aware)')
	Critical_type.Items.Add('Pedestrians (trained staff)')
	Critical_type.Items.Add('Vehicles (high speed)')
	Critical_type.Items.Add('Vehicles (low speed)')
	Critical_type.Items.Add('Marinas (small boats)')
	Critical_type.Items.Add('Marinas (large yachts)')
	Critical_type.Items.Add('Buildings (no damage)')
	Critical_type.Items.Add('Buildings (moderate damage)')
	Critical_type.Items.Add('Embankment (no damage) ')
	Critical_type.Items.Add('Embankment (crest not protected)')
	Critical_type.Items.Add('Embankment (back slope not protected)')
	return Critical_type

def get_armour_types(Armour_type):
	Armour_type.Items.Add('Rock')
	#armour_types.Items.Add('Cube (1 layer)')
	#armour_types.Items.Add('Cube (2 layers)')
	#armour_types.Items.Add('Tetrapod')
	#armour_types.Items.Add('Dolos')
	#armour_types.Items.Add('Accropode')
	#armour_types.Items.Add('Core-loc')
	#armour_types.Items.Add('Xbloc')
	return Armour_type

def Plot_Crossection(ip,op):
	
	lineouter=CreateAreaSeries(op.alignment[op.cross_ind]['dims']['xyouter'])
	lineouter.Color = Color.LightGray
	lineouter.LineColor = Color.Black
	lineouter.LineWidth = 2
	lineouter.PointerVisible = False
	lineouter.PointerLineVisible = False
	lineouter.Transparency = 20
	#lineouter.Title="Crestheight: %.1f m+MSL Crestwidth: %.1f m " % (ip.crestheight,ip.crestwidth)
	
	
	linearmour=CreateAreaSeries(op.alignment[op.cross_ind]['dims']['xyarmour'])
	linearmour.Color = Color.DarkGray
	linearmour.LineVisible = False
	linearmour.PointerVisible = False
	linearmour.PointerLineVisible = False
	#linearmour.LineColor = Color.Black
	linearmour.Transparency = 20
	#linearmour.Title="Armour: Grading "+str(gradmin)+" - "+str(gradmax)+" kg"
	
	linefilter=CreateAreaSeries(op.alignment[op.cross_ind]['dims']['xyfilter'])
	linefilter.Color = Color.DimGray
	linefilter.LineVisible = False
	#linefilter.LineColor = Color.Black
	linefilter.PointerVisible = False
	linefilter.PointerLineVisible = False
	linefilter.Transparency = 20
	#linefilter.Title = "Filter: Grading "+str(gradmin_filter)+" - "+str(gradmax_filter)+" kg"
	
	"""xyMSL=np.vstack((xouter,[0,0,0,0])).T
	lineMSL=CreateLineSeries(xyMSL)
	lineMSL.Color = Color.Blue
	lineMSL.Width = 1.5
	lineMSL.PointerVisible = False
	lineMSL.Transparency = 0
	lineMSL.Title="MSL"""
	
	xySWL=np.vstack(([op.alignment[op.cross_ind]['dims']['xouter'][0],op.alignment[op.cross_ind]['dims']['xouter'][-1]],[ip.SWL,ip.SWL])).T
	lineSWL=CreateAreaSeries(xySWL)
	lineSWL.Color = Color.RoyalBlue
	lineSWL.LineVisible = False
	#lineSWL.LineColor = Color.MediumBlue
	lineSWL.PointerVisible = False
	lineSWL.PointerLineVisible = False
	lineSWL.Transparency = 75
	lineSWL.Title="SWL"
	
	chart = CreateChart([lineouter,linearmour,linefilter,lineSWL])
	chart.LeftAxis.Automatic = False
	if ip.is2D:
		chart.LeftAxis.Minimum = -op.profile['mean_z'][op.cross_ind]
	else:
		chart.LeftAxis.Minimum = -op.z
	
	chart.LeftAxis.Maximum = op.crestheight+2
	chart.LeftAxis.Title = "level w.r.t. MSL (m)"
	chart.BottomAxis.Title = "Distance (m)"
	chart.BackGroundColor = Color.White
	chart.Legend.Visible=False
	chart.Legend.Alignment=LegendAlignment.Right
	if ip.is2D:
		chart.Title="Breakwater section %d at %.1f m from coastline" %(op.cross_ind+1,op.profile['mean_dist'][op.cross_ind])
	else:
		chart.Title="Breakwater cross-section"
	
	chart.TitleVisible=True
	chart.Name="Breakwater design"
	
	plot1 = ChartView()
	plot1.Text = "Plot1"
	plot1.Chart = chart
	plot1.Dock = DockStyle.Fill
	
	return plot1
	
def Create_DimensionsText(ip,op):
	
	Sizes_rock = "\nRubble mound:\n" +\
	"Minimum Dn50:\t\t%.2f m\n" % op.Dn50['armour'] + \
	"Set Dn50:\t\t%.2f m\n" % op.Dn50['armour_grad'] + \
	"Armour:\t\t\t%.0f - %.0f kg\n" % (op.grad['min_armour'],op.grad['max_armour']) + \
	"Filter:\t\t\t%.0f - %.0f kg\n" % (op.grad['min_filter'],op.grad['max_filter']) +\
	"Armour thickness:\t%0.2f m\n" % op.layer['armour'] +\
	"Filter thickness:\t\t%0.2f m\n\n" % op.layer['filter']
	
	if op.isTooLarge['armour']:
		Sizes_rock += "Required Stone size is larger than available in grading table!!\n\n"
		
	if ip.autocrest:
		crestheight_text="%0.2f m (Auto)" % float(op.crestheight)
	else:
		crestheight_text="%0.2f m" % float(op.crestheight)
	
	if ip.is2D:
		localdepth = op.profile['mean_z'][op.cross_ind]
		breakwatlength = np.max(op.profile['dist']).Value
	else:
		localdepth = ip.z
		breakwatlength = 1.0
	
	Dimensions2_Text= \
	"Slope:\t\t\t1:%.0f \n" % ip.cota +\
	"Crestheight:\t\t"+crestheight_text+"\n" +\
	"Crestwidth:\t\t%0.2f m\n" % ip.crestwidth +\
	"Breakwater length:\t%.d m\n\n" % breakwatlength
	
	
	DimensionsText = Sizes_rock + Dimensions2_Text #+ Dimensions2_Text
	return DimensionsText
	
	
def Create_ConditionsText(ip,op):
	
	#defaultHeader = r"{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}"
	#colorsUsed = r"{\colortbl ;\red0\green0\blue255;\red0\green255\blue0;}"
	
	WaveOFF = \
	"\nOffshore:\n" +\
	"Hs:\t\t%.2f m \n"  % ip.Hs0 +\
	"Tp:\t\t%.1f s \n" % ip.Tp0 +\
	"Dir:\t\t%0.0f deg North \n" % ip.theta0 +\
	"Depth:\t\t%.2f m \n\n" % ip.z0 
	
	WaveNEAR = \
	"Nearshore: \n" +\
	"Hs:\t\t%.2f m \n"  % op.Hs +\
	"Tp:\t\t%.1f s \n" % op.Tp +\
	"Dir:\t\t%0.0f deg North \n" % op.theta +\
	"Depth:\t\t%.2f m \n\n" % op.z 
	
	if op.isPlunging:
		BreakerType="Plunging"
	else:
		BreakerType="Surging"
	
	Conditions_extra= \
	"Irribarren:\t\t%.2f\n" % op.irri +\
	"Breakertype:\t\t"+BreakerType+ "\n" +\
	"Wave steepness:\t%.2f\n" % op.stp +\
	"Number of waves:\t%.0f \n" % op.N +\
	"Rel. density:\t\t%.2f" % op.delta
	
	Conditions_Text = WaveOFF + WaveNEAR + Conditions_extra
	return Conditions_Text
	

def Create_VolumesText(ip,op):
	
	VolumesText1 = \
	"\nCross-sectional area at section %d :\n" % (op.cross_ind+1) +\
	"Armour:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['armour'] +\
	"Filter:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['filter'] +\
	"Core:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['core'] +\
	"Total:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['outer'] 
	
	VolumesText2 = \
	"\nTotal volumes:\n" +\
	"Armour:\t\t" + "{:,.0f}".format(float(op.totalvolumes['armour'])) + " m3\n"  +\
	"Filter:\t\t" + "{:,.0f}".format(float(op.totalvolumes['filter'])) + " m3\n" +\
	"Core:\t\t" + "{:,.0f}".format(float(op.totalvolumes['core'])) + " m3\n" +\
	"Total:\t\t" + "{:,.0f}".format(float(op.totalvolumes['outer'])) + " m3\n\n" 
	
	VolumesText = VolumesText1
	
	if ip.is2D:
		VolumesText += VolumesText2
	
	return VolumesText


def Create_OvertoppingText(ip,op):
	
	if ip.autocrest:
		OvertoppingText = \
		"\nSafety level:\t\t " + ip.situation + "\n" +\
		"Allowable overtopping:\t%0.3f l/s/m\n" % ip.qthres +\
		"Current overtopping:\t%0.3f l/s/m\n" % op.qovertopping_crest +\
		"Required crestheight:\t%0.2f m+MSL\n" %  op.crestheight_required +\
		"Set crestheight:\t\t%0.2f m+MSL\n\n" % float(op.crestheight) 
	else:
		OvertoppingText = \
		"\nOvertopping: %0.3f l/s/m\n\n" % float(op.qovertopping_crest) 
		
	return OvertoppingText


def get_bathygrid(ElevationPath):
	#ElevationPath = r"C:\Users\905252\Documents\CoDeS\plugins\DeltaShell.Plugins.Toolbox\Scripts\BathymetryData\Testdata\NorthSea\rws_testdata_grid_positive.asc"

	provider = GdalFeatureProvider()
	provider.Open(ElevationPath)	
	grid = provider.Grid
	return grid

def get_LineGeometry(LineLayer):
	"""Get line geometry from feature layer, by default take first feature"""
	LineFeatures = LineLayer.GetFeatures(LineLayer.Envelope)
	ResultFeature = None
	
	for LineFeature in LineFeatures:
		ResultFeature = LineFeature
		
		
	return ResultFeature.Geometry

