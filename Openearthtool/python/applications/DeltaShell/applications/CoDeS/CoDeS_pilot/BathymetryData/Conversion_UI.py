#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 RoyalHaskoningDHV
#       Dirk Voesenek
#
#       dirk.voesenek@rhdhv.com
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
import clr
clr.AddReference("System.Windows.Forms")
from os import path
from SharpMap import XyzFile
from SharpMap import Map

from SharpMap.Data.Providers import FeatureCollection
from Scripts.UI_Examples.View import *
from Libraries.ChartFunctions import *
from Libraries.MapFunctions import *

from SharpMap.Styles import VectorStyle
from SharpMap.Layers import PointCloudLayer

from SharpMap.Layers import RegularGridCoverageLayer
from SharpMap.Extensions.Layers import DelftDashboardTileLayer as _DelftDashboardTileLayer
from SharpMap.Extensions.Layers import GdalRasterLayer as _RasterLayer
from NetTopologySuite.Extensions.Coverages import PointValue

from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from SharpMap.Rendering.Thematics import ThemeFactory, ColorBlend

from System.Windows.Forms import RadioButton
from System.Windows.Forms import DialogResult
from System.Windows.Forms import MessageBox
from System.Windows.Forms import OpenFileDialog
from System.Windows.Forms import SaveFileDialog

import Libraries.FlowFlexibleMeshFunctions as FMFunctions
import Scripts.BathymetryData as bmd
import math
import numpy

#from Scripts.CoastlineDevelopment import *



def SetGradientTheme(layer, attributeName, numClasses):
	"""Sets the theme (coloring) of the layer"""
	
	colorBlend = ColorBlend.Rainbow5
	size = 10
	layer.Theme = ThemeFactory.CreateGradientTheme(attributeName, None, colorBlend, layer.MinDataValue, layer.MaxDataValue, size,size,False,True,numClasses)

def Browse_Click(sender, e):
	NewDialog = OpenFileDialog()
	NewDialog.Filter = "XYZ-files (*.xyz)|*.xyz"
	
	if NewDialog.ShowDialog() == DialogResult.OK:
		newTextbox.Text = NewDialog.FileName
				
def BrowseSave_Click(sender, e):
	NewDialog = SaveFileDialog()
	NewDialog.Filter = "ascii-files (*.asc)|*.asc"
	
	if NewDialog.ShowDialog() == DialogResult.OK:
		newTextbox2.Text = NewDialog.FileName
 

def Conversion_Click(sender, e):
	XYZbestand = newTextbox.Text
	ascGrid = newTextbox2.Text
	
	
	bmd.Convert_XYZ_to_grid(XYZbestand,ascGrid)
	
	# Add xyz-file to map
	
	XYZLayerName = path.split(XYZbestand)[1]	
	
	# read points from XYZ file
	file = XyzFile()
	points = [feature for feature in file.Read(XYZbestand)]
	
	# create layer for points
	XYZlayer = PointCloudLayer()
	XYZlayer.DataSource = FeatureCollection(points, PointValue)
	XYZlayer.Name = XYZLayerName
	SetGradientTheme(XYZlayer,"Value",10)
	
	# create layer for grid
	
	RasterLayer = _RasterLayer()	
	RasterLayerName = path.split(ascGrid)[1]
	RasterLayer.DataSource.Path = ascGrid
	RasterLayer.Name = RasterLayerName
	SetGradientTheme(RasterLayer,"Raster1",10)
	
	# open map with layer
	map = mapview.Map
	map.Layers.Add(XYZlayer)
	map.Layers.Add(RasterLayer)
	
	
	MessageBox.Show("Conversion is ready, the input file and the output grid are shown on the map")



def btnExtractGEBCO_Click(sender, e):
	
	# Get current map extent
	CurrentExtent = mapview.Map.Envelope
	
	# Extract GEBCO-data for current map extent
	
	diffX = CurrentExtent.MaxX - CurrentExtent.MinX
	diffY = CurrentExtent.MaxY - CurrentExtent.MinY
	
	if diffX > 5000000 or diffY > 5000000:
		MessageBox.Show("Please select an area of max 500 x 500 km")
		return
	
	if diffX < 10000 or diffY < 10000:
		MessageBox.Show("Please select an area of at least 10 x 10 km")
		return
	
	NewDialog = SaveFileDialog()
	NewDialog.Filter = "ascii-files (*.asc)|*.asc"
	
	if NewDialog.ShowDialog() == DialogResult.OK:
		bmd.GetAscGridFromGebco(CurrentExtent,NewDialog.FileName)
		MessageBox.Show("Extraction of grid is ready")
		
	
	


def radioButtonChooseFile_Click(sender, e):
	
	newPanel.Controls.Remove(txtMinX)
	newPanel.Controls.Remove(txtMaxX)
	newPanel.Controls.Remove(txtMinY)
	newPanel.Controls.Remove(txtMaxY)	
			
	newPanel.Controls.Remove(labelMinX)
	newPanel.Controls.Remove(labelMaxX)
	newPanel.Controls.Remove(labelMinY)
	newPanel.Controls.Remove(labelMaxY)
	
	newPanel.Controls.Remove(btnExtractGEBCO)
	
	
	#MessageBox.Show("Clicked")
	
	# Show controls which are relevant for this choice
	
	# Create labels
	
	label.Left = 10
	label.Top = 100
	label.Width = 160
	label.Text = "Select input XYZ-file"	
	
	label2.Left = 10
	label2.Top = 150
	label2.Width = 160
	label2.Text = "Select output path"
	
	# Create Browse buttons
	
	newButton.BackColor = Color.DarkGray
	newButton.Text = "Browse"
	newButton.Left = 750
	newButton.Top = 100
	newButton.Click += Browse_Click
		
	newButton2.BackColor = Color.DarkGray
	newButton2.Text = "Browse"
	newButton2.Left = 750
	newButton2.Top = 150
	newButton2.Click += BrowseSave_Click
	
	# Conversion button
	
	ConversionButton.BackColor = Color.DarkGray
	ConversionButton.Text = "Convert XYZ to ascii grid"
	ConversionButton.Left = 200
	ConversionButton.Top = 200
	ConversionButton.Width = 250
	ConversionButton.Height = 40
	ConversionButton.Click += Conversion_Click	
	
	newTextbox.Name = "txt_XYZPath"
	newTextbox.Left = 200
	newTextbox.Top = 100
	newTextbox.Width = 520	
	
	newTextbox2.Name = "txt_asciigrid"
	newTextbox2.Left = 200
	newTextbox2.Top = 150
	newTextbox2.Width = 520
	
	newPanel.Controls.Add(label)
	newPanel.Controls.Add(label2)
	newPanel.Controls.Add(newButton)
	newPanel.Controls.Add(newButton2)
	newPanel.Controls.Add(ConversionButton)
	newPanel.Controls.Add(newTextbox)
	newPanel.Controls.Add(newTextbox2)



def radioButtonGlobal_Click(sender, e):
	newPanel.Controls.Remove(label)
	newPanel.Controls.Remove(label2)
	newPanel.Controls.Remove(newButton)
	newPanel.Controls.Remove(newButton2)
	newPanel.Controls.Remove(ConversionButton)
	newPanel.Controls.Remove(newTextbox)
	newPanel.Controls.Remove(newTextbox2)
	
	# Get current map extent
	CurrentExtent = mapview.Map.Envelope
	
	# Show buttons for minX, maxX, minY and maxY
	
	txtMinX.Text = str(CurrentExtent.MinX)
	txtMinX.Left = 150
	txtMinX.Top = 120	
	
	labelMinX.Text = "MinX"
	labelMinX.Left = 110
	labelMinX.Top = 120
		
	txtMaxX.Text = str(CurrentExtent.MaxX)
	txtMaxX.Left = 350
	txtMaxX.Top = 120
	
	labelMaxX.Text = "MaxX"
	labelMaxX.Left = 310
	labelMaxX.Top = 120
		
	txtMinY.Text = str(CurrentExtent.MinY)
	txtMinY.Left = 250
	txtMinY.Top = 170
	
	labelMinY.Text = "MinY"
	labelMinY.Left = 210
	labelMinY.Top = 170
	
	txtMaxY.Text = str(CurrentExtent.MaxY)
	txtMaxY.Left = 250
	txtMaxY.Top = 70
	
	labelMaxY.Text = "MaxY"
	labelMaxY.Left = 210
	labelMaxY.Top = 70
	
	btnExtractGEBCO.Text = "Extract GEBCO elevation data"
	btnExtractGEBCO.Left = 470
	btnExtractGEBCO.Top = 120
	btnExtractGEBCO.Width = 250
	btnExtractGEBCO.Height = 40
	btnExtractGEBCO.BackColor = Color.DarkGray
	btnExtractGEBCO.Click += btnExtractGEBCO_Click
	
	
	newPanel.Controls.Add(txtMinX)
	newPanel.Controls.Add(txtMaxX)
	newPanel.Controls.Add(txtMinY)
	newPanel.Controls.Add(txtMaxY)	
	
	newPanel.Controls.Add(labelMinX)
	newPanel.Controls.Add(labelMaxX)
	newPanel.Controls.Add(labelMinY)
	newPanel.Controls.Add(labelMaxY)
	
	newPanel.Controls.Add(btnExtractGEBCO)
	
	


	
# Global variables for reference to controls

# For option 'Choose file'
label = Label()
label2 = Label()
newButton = Button()
newButton2 = Button()
ConversionButton = Button()
newTextbox = TextBox()
newTextbox2 = TextBox()

# For option 'Global'

txtMinX = TextBox()
txtMaxX = TextBox()
txtMinY = TextBox()
txtMaxY = TextBox()

labelMinX = Label()
labelMaxX = Label()
labelMinY = Label()
labelMaxY = Label()

btnExtractGEBCO = Button()


# Create an empty view
view = View()
view.Text = "Bathymetry data"

# Create a panel
newPanel = Panel()
newPanel.Dock = DockStyle.Fill
newPanel.BackColor = Color.Aquamarine

# Create a mapview
Kaart = Map()
Kaart.CoordinateSystem = CreateCoordinateSystem(3857)

mapview = MapView()
mapview.Map = Kaart

childViews = view.get_ChildViews()
childViews.Add(mapview)
mapview.Dock = DockStyle.Top
mapview.Map.Layers.Add(CreateSatelliteImageLayer())

# Create radio button for choice of data on disk or globally available data (select by polygon)

radioButtonChooseFile = RadioButton()
radioButtonChooseFile.Text = "Add own bathymetry"
radioButtonChooseFile.Left = 10
radioButtonChooseFile.Width = 200
radioButtonChooseFile.Top = 20
radioButtonChooseFile.Click += radioButtonChooseFile_Click


radioButtonGlobal = RadioButton()
radioButtonGlobal.Text = "Select from global dataset"
radioButtonGlobal.Left = 10
radioButtonGlobal.Width = 200
radioButtonGlobal.Top = 50
radioButtonGlobal.Click += radioButtonGlobal_Click


newPanel.Controls.Add(radioButtonChooseFile)
newPanel.Controls.Add(radioButtonGlobal)


# Add controls to view
view.Controls.Add(newPanel)
view.Controls.Add(mapview)		
#Systeem = mapview.Map.CoordinateSystem



frmBathy = Form()
frmBathy.Width = 580
frmBathy.Height = 370
frmBathy.Text="Import bathymetry data"


frmBathy.Controls.Add(radioButtonChooseFile)
frmBathy.Controls.Add(radioButtonGlobal)


frmBathy.ShowDialog()
#view.Show()





#Locatie = Coordinate(centerX,centerY)
#print Locatie.X
# Show view
def initializeView():
    view.Show()
    return
