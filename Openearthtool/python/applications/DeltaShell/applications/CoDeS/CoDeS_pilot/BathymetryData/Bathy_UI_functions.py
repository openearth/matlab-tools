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
from Libraries.ChartFunctions import *
from Libraries.MapFunctions import *

from SharpMap.Styles import VectorStyle
from SharpMap.Layers import PointCloudLayer
from SharpMap.Extensions.Data.Providers import GdalFeatureProvider
from SharpMap.Layers import RegularGridCoverageLayer
from SharpMap.Extensions.Layers import DelftDashboardTileLayer as _DelftDashboardTileLayer
from SharpMap.Extensions.Layers import GdalRasterLayer as _RasterLayer
from NetTopologySuite.Extensions.Coverages import PointValue


from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from SharpMap.Rendering.Thematics import ThemeFactory, ColorBlend

from System.Windows.Forms import *

from System.Windows.Forms import RadioButton
from System.Windows.Forms import DialogResult
from System.Windows.Forms import MessageBox
from System.Windows.Forms import OpenFileDialog
from System.Windows.Forms import SaveFileDialog

from Scripts.BathymetryData import GridFunctions

import Libraries.FlowFlexibleMeshFunctions as FMFunctions

import math
import numpy

#from Scripts.CoastlineDevelopment import *




class BathyForm(Form):
	def StepToPage2(self):
		# Read raster properties and display them on page 2 of the tab control
		
		provider = GdalFeatureProvider()
		provider.Open(self.AsciiPath)	
		grid = provider.Grid
		
		Text = ""
		Text += "X origin: " + str(grid.Origin.X) + "\n"
		Text += "Y origin: " + str(grid.Origin.Y) + "\n"
		Text += "Number of rows: " + str(grid.SizeX) + "\n"
		Text += "Number of columns: " + str(grid.SizeY) + "\n"
		Text += "Cell size X: " + str(grid.DeltaX) + "\n"
		Text += "Cell size Y: " + str(grid.DeltaY) + "\n"
				
		self.BathyMetaData.Text = Text
		
		self.TabSteps.SelectedIndex = 1
		self.txtSelectedGrid.Text = self.AsciiPath
	
	def FinishImport(self):
		
		# Set conversion to positive numbers to true of false		
			
		self.ConvertToPositive = self.CheckPositiveNumbers.Checked
		self.Close()	
		
	
	
	def BrowseSave_Click(self,sender, e):
		NewDialog = SaveFileDialog()
		NewDialog.Filter = "ascii-files (*.asc)|*.asc"
		
		if NewDialog.ShowDialog() == DialogResult.OK:
			self.newTextbox2.Text = NewDialog.FileName

	def btnBrowseAscii_Click(self,sender,e):
		NewDialog = OpenFileDialog()
		NewDialog.Filter = "Ascii-grid (*.asc)|*.asc"
		
		if NewDialog.ShowDialog() == DialogResult.OK:
			self.txtAsciiPath.Text = NewDialog.FileName	
			
	def Conversion_Click(self,sender, e):
		XYZbestand = self.newTextbox.Text
		ascGrid = self.newTextbox2.Text
			
		GridFunctions.Convert_XYZ_to_grid(XYZbestand,ascGrid)
		
		# Add xyz-file to map
		
		XYZLayerName = path.split(XYZbestand)[1]	
		
		# read points from XYZ file
		file = XyzFile()
		points = [feature for feature in file.Read(XYZbestand)]
		
		"""# create layer for points
		#XYZlayer = PointCloudLayer()
		XYZlayer.DataSource = FeatureCollection(points, PointValue)
		XYZlayer.Name = XYZLayerName
		SetGradientTheme(XYZlayer,"Value",10)
		
		# create layer for grid
		
		RasterLayer = _RasterLayer()	
		RasterLayerName = path.split(ascGrid)[1]
		RasterLayer.DataSource.Path = ascGrid
		RasterLayer.Name = RasterLayerName
		SetGradientTheme(RasterLayer,"Raster1",10)"""
		
		self.AsciiPath = ascGrid
		self.StepToPage2()
		
		Answer = MessageBox.Show("Conversion from XYZ to Ascii is ready.")	
	
	def btnImportAscii_Click(self,sender,e):
		# Ascii grid can be directly imported
		
		self.AsciiPath = self.txtAsciiPath.Text		
		self.StepToPage2()
		
	
	def btnFinalizeImport_Click(self,sender,e):
		
		
		self.FinishImport()
	


	def btnExtractGEBCO_Click(self,sender, e):
		
		# Get current map extent
		CurrentExtent = self.MapExtent	
			
		# Extract GEBCO-data for current map extent
		
		diffX = CurrentExtent.MaxX - CurrentExtent.MinX
		diffY = CurrentExtent.MaxY - CurrentExtent.MinY
		
		if diffX > 500000 or diffY > 500000:
			MessageBox.Show("Please select an area of max 300 x 300 km")
			return
		
		if diffX < 10000 or diffY < 10000:
			MessageBox.Show("Please select an area of at least 10 x 10 km")
			return
		
		NewDialog = SaveFileDialog()
		NewDialog.Filter = "ascii-files (*.asc)|*.asc"
		
		if NewDialog.ShowDialog() == DialogResult.OK:
			GridFunctions.GetAscGridFromGebco(CurrentExtent,NewDialog.FileName)			
			
			self.AsciiPath = NewDialog.FileName
			self.StepToPage2()
				
	
	def Browse_Click(self, sender, e):
		NewDialog = OpenFileDialog()
		NewDialog.Filter = "XYZ-files (*.xyz)|*.xyz"
		
		if NewDialog.ShowDialog() == DialogResult.OK:
			self.newTextbox.Text = NewDialog.FileName
	
	
	def radioButtonChooseFile_Click(self, sender,e):
		
		self.TabPage1.Controls.Remove(self.labelExtent)		
	
		self.TabPage1.Controls.Remove(self.txtMinX)
		self.TabPage1.Controls.Remove(self.txtMaxX)
		self.TabPage1.Controls.Remove(self.txtMinY)
		self.TabPage1.Controls.Remove(self.txtMaxY)	
				
		self.TabPage1.Controls.Remove(self.labelMinX)
		self.TabPage1.Controls.Remove(self.labelMaxX)
		self.TabPage1.Controls.Remove(self.labelMinY)
		self.TabPage1.Controls.Remove(self.labelMaxY)
		
		self.TabPage1.Controls.Remove(self.btnExtractGEBCO)
		self.TabPage1.Controls.Remove(self.btnImportAscii)
		
		
		self.TabPage1.Controls.Remove(self.txtAsciiPath)
		self.TabPage1.Controls.Remove(self.labelAscii)
		self.TabPage1.Controls.Remove(self.btnBrowseAscii)
			
		# Show controls which are relevant for this choice
		
		# Create labels
		
		self.label.Left = 10
		self.label.Top = 130
		self.label.Width = 160
		self.label.Text = "Select input XYZ-file:"	
		
		self.label2.Left = 10
		self.label2.Top = 180
		self.label2.Width = 160
		self.label2.Text = "Select output path:"
		
		# Create Browse buttons
		
		self.newButton.BackColor = Color.DarkGray
		self.newButton.Text = "Browse"
		self.newButton.Left = 750
		self.newButton.Top = 130
		self.newButton.Click += lambda s,e : self.Browse_Click(s,e)
			
		self.newButton2.BackColor = Color.DarkGray
		self.newButton2.Text = "Browse"
		self.newButton2.Left = 750
		self.newButton2.Top = 180
		self.newButton2.Click += lambda s,e : self.BrowseSave_Click(s,e)
		
		# Conversion button
		
		self.ConversionButton.BackColor = Color.DarkGray
		self.ConversionButton.Text = "Convert XYZ to ascii grid"
		self.ConversionButton.Left = 600
		self.ConversionButton.Top = 240
		self.ConversionButton.Width = 200
		self.ConversionButton.Height = 35
		self.ConversionButton.Click += lambda s,e : self.Conversion_Click(s,e)
		
		self.newTextbox.Name = "txt_XYZPath"
		self.newTextbox.Left = 200
		self.newTextbox.Top = 130
		self.newTextbox.Width = 520	
		
		self.newTextbox2.Name = "txt_asciigrid"
		self.newTextbox2.Left = 200
		self.newTextbox2.Top = 180
		self.newTextbox2.Width = 520
		
		self.TabPage1.Controls.Add(self.label)
		self.TabPage1.Controls.Add(self.label2)
		self.TabPage1.Controls.Add(self.newButton)
		self.TabPage1.Controls.Add(self.newButton2)
		self.TabPage1.Controls.Add(self.ConversionButton)
		self.TabPage1.Controls.Add(self.newTextbox)
		self.TabPage1.Controls.Add(self.newTextbox2)	
	
	def radioButtonChooseAscii_Click(self,sender,e):

		# Remove other controls
		
		self.TabPage1.Controls.Remove(self.labelExtent)
		
		self.TabPage1.Controls.Remove(self.txtMinX)
		self.TabPage1.Controls.Remove(self.txtMaxX)
		self.TabPage1.Controls.Remove(self.txtMinY)
		self.TabPage1.Controls.Remove(self.txtMaxY)	
				
		self.TabPage1.Controls.Remove(self.labelMinX)
		self.TabPage1.Controls.Remove(self.labelMaxX)
		self.TabPage1.Controls.Remove(self.labelMinY)
		self.TabPage1.Controls.Remove(self.labelMaxY)
		
		self.TabPage1.Controls.Remove(self.btnExtractGEBCO)
		
		self.TabPage1.Controls.Remove(self.label)
		self.TabPage1.Controls.Remove(self.label2)
		self.TabPage1.Controls.Remove(self.newButton)
		self.TabPage1.Controls.Remove(self.newButton2)
		self.TabPage1.Controls.Remove(self.ConversionButton)
		self.TabPage1.Controls.Remove(self.newTextbox)
		self.TabPage1.Controls.Remove(self.newTextbox2)
		
		print ("Controls removed")
			
		self.txtAsciiPath.Name = "txt_AsciiPath"
		self.txtAsciiPath.Left = 150
		self.txtAsciiPath.Top = 130
		self.txtAsciiPath.Width = 520	
		
		self.labelAscii.Text = "Select ascii grid:"
		self.labelAscii.Left = 10
		self.labelAscii.Top = 130	
		
		self.btnBrowseAscii.BackColor = Color.DarkGray
		self.btnBrowseAscii.Text = "Browse"
		self.btnBrowseAscii.Left = 750
		self.btnBrowseAscii.Top = 130
		self.btnBrowseAscii.Click += lambda s,e : self.btnBrowseAscii_Click(s,e)
				
		self.btnImportAscii.Text = "Import ascii grid"
		self.btnImportAscii.Left = 600
		self.btnImportAscii.Top = 240
		self.btnImportAscii.Width = 200
		self.btnImportAscii.Height = 35
		self.btnImportAscii.BackColor = Color.DarkGray
		self.btnImportAscii.Click += lambda s,e :self.btnImportAscii_Click(s,e)	
		
		self.TabPage1.Controls.Add(self.txtAsciiPath)
		self.TabPage1.Controls.Add(self.labelAscii)
		self.TabPage1.Controls.Add(self.btnBrowseAscii)
		self.TabPage1.Controls.Add(self.btnImportAscii)
	
	def radioButtonGlobal_Click(self,sender,e):
		self.TabPage1.Controls.Remove(self.label)
		self.TabPage1.Controls.Remove(self.label2)
		self.TabPage1.Controls.Remove(self.newButton)
		self.TabPage1.Controls.Remove(self.newButton2)
		self.TabPage1.Controls.Remove(self.ConversionButton)
		self.TabPage1.Controls.Remove(self.newTextbox)
		self.TabPage1.Controls.Remove(self.newTextbox2)
		
		self.TabPage1.Controls.Remove(self.txtAsciiPath)
		self.TabPage1.Controls.Remove(self.labelAscii)
		self.TabPage1.Controls.Remove(self.btnBrowseAscii)
		self.TabPage1.Controls.Remove(self.btnImportAscii)
		
		# Get current map extent
		CurrentExtent = self.MapExtent
		
		# Show buttons for minX, maxX, minY and maxY
		
		self.labelExtent.Text = "Current map extent:"
		self.labelExtent.Left = 210
		self.labelExtent.Top = 86
		self.labelExtent.Width = 160
		
		self.txtMinX.Text = str(CurrentExtent.MinX)
		self.txtMinX.Left = 150
		self.txtMinX.Top = 190	
		
		self.labelMinX.Text = "MinX"
		self.labelMinX.Left = 110
		self.labelMinX.Top = 190
			
		self.txtMaxX.Text = str(CurrentExtent.MaxX)
		self.txtMaxX.Left = 350
		self.txtMaxX.Top = 190
		
		self.labelMaxX.Text = "MaxX"
		self.labelMaxX.Left = 310
		self.labelMaxX.Top = 190
			
		self.txtMinY.Text = str(CurrentExtent.MinY)
		self.txtMinY.Left = 250
		self.txtMinY.Top = 240
		
		self.labelMinY.Text = "MinY"
		self.labelMinY.Left = 210
		self.labelMinY.Top = 240
		
		self.txtMaxY.Text = str(CurrentExtent.MaxY)
		self.txtMaxY.Left = 250
		self.txtMaxY.Top = 140
		
		self.labelMaxY.Text = "MaxY"
		self.labelMaxY.Left = 210
		self.labelMaxY.Top = 140
		
		self.btnExtractGEBCO.Text = "Extract GEBCO elevation data"
		self.btnExtractGEBCO.Left = 600
		self.btnExtractGEBCO.Top = 240
		self.btnExtractGEBCO.Width = 200
		self.btnExtractGEBCO.Height = 35
		self.btnExtractGEBCO.BackColor = Color.DarkGray
		self.btnExtractGEBCO.Click += lambda s,e :self.btnExtractGEBCO_Click(s,e)
		
		self.TabPage1.Controls.Add(self.labelExtent)
		
		self.TabPage1.Controls.Add(self.txtMinX)
		self.TabPage1.Controls.Add(self.txtMaxX)
		self.TabPage1.Controls.Add(self.txtMinY)
		self.TabPage1.Controls.Add(self.txtMaxY)	
		
		self.TabPage1.Controls.Add(self.labelMinX)
		self.TabPage1.Controls.Add(self.labelMaxX)
		self.TabPage1.Controls.Add(self.labelMinY)
		self.TabPage1.Controls.Add(self.labelMaxY)
		
		self.TabPage1.Controls.Add(self.btnExtractGEBCO)
	
	
	
	def __init__(self):
		self.AsciiPath = ""
		self.MapExtent = None
		
		# Controls for tabpage 1 
				
		# Global variables for reference to controls	
	
		self.TabSteps = TabControl()
		self.TabSteps.Dock = DockStyle.Fill
		#self.TabSteps.Left = 10
		#self.TabSteps.Top = 10
		
		
		
		# For option 'Choose file'
		
		self.label = Label()
		self.label2 = Label()
		self.newButton = Button()
		self.newButton2 = Button()
		self.ConversionButton = Button()
		self.newTextbox = TextBox()
		self.newTextbox2 = TextBox()
		
		# For option 'Global'
		
		self.txtMinX = TextBox()
		self.txtMaxX = TextBox()
		self.txtMinY = TextBox()
		self.txtMaxY = TextBox()
	
		self.labelMinX = Label()
		self.labelMaxX = Label()
		self.labelMinY = Label()
		self.labelMaxY = Label()
		self.labelExtent = Label()		
	
		self.btnExtractGEBCO = Button()
		
		# For option 'Select ascii grid'
		
		self.txtAsciiPath = TextBox()
		self.btnBrowseAscii = Button()
		
		self.labelAscii = Label()		
		self.btnImportAscii = Button()		
		
					
				
	
		# Create radio button for choice of data on disk or globally available data (select by extent)
		
		self.radioButtonChooseAscii = RadioButton()
		self.radioButtonChooseAscii.Text = "Add ascii grid (*.asc)"
		self.radioButtonChooseAscii.Left = 10
		self.radioButtonChooseAscii.Width = 200
		self.radioButtonChooseAscii.Top = 20
		self.radioButtonChooseAscii.Click += lambda s,e : self.radioButtonChooseAscii_Click(s,e)
				
		self.radioButtonChooseFile = RadioButton()
		self.radioButtonChooseFile.Text = "Add bathymetry from xyz-file"
		self.radioButtonChooseFile.Left = 10
		self.radioButtonChooseFile.Width = 200
		self.radioButtonChooseFile.Top = 50
		self.radioButtonChooseFile.Click += lambda s,e : self.radioButtonChooseFile_Click(s,e)
		self.radioButtonChooseFile.Enabled = False
		
		self.radioButtonGlobal = RadioButton()
		self.radioButtonGlobal.Text = "Select from global dataset"
		self.radioButtonGlobal.Left = 10
		self.radioButtonGlobal.Width = 200
		self.radioButtonGlobal.Top = 80
		self.radioButtonGlobal.Click += lambda s,e : self.radioButtonGlobal_Click(s,e)
				
		self.Text="Import bathymetry data"
				
		# Controls for tabpage 2
		
		self.labelSelectedGrid = Label()
		self.labelSelectedGrid.Text = "Grid to be imported: "
		self.labelSelectedGrid.Top = 20
		self.labelSelectedGrid.Left = 20
		self.labelSelectedGrid.Width = 120
		
		self.txtSelectedGrid = TextBox()
		self.txtSelectedGrid.Enabled = False
		self.txtSelectedGrid.Top = 20 
		self.txtSelectedGrid.Left = 180
		self.txtSelectedGrid.Width = 240
		
		self.btnFinalizeImport = Button()
		self.btnFinalizeImport.Text = "Import bathymetry grid"
		self.btnFinalizeImport.Left = 600
		self.btnFinalizeImport.Top = 240
		self.btnFinalizeImport.Width = 200
		self.btnFinalizeImport.Height = 35
		self.btnFinalizeImport.Click += lambda s,e : self.btnFinalizeImport_Click(s,e)
		
		self.BathyMetaData = RichTextBox()
		self.BathyMetaData.Enabled = False
		self.BathyMetaData.Text = "Grid metadata"
		self.BathyMetaData.Top = 55
		self.BathyMetaData.Left = 20			
		self.BathyMetaData.Width = 400
		self.BathyMetaData.Height = 240
		
		self.CheckPositiveNumbers = CheckBox()
		self.CheckPositiveNumbers.Text = "Multiply by -1 to create positive depth values"
		self.CheckPositiveNumbers.Top = 20
		self.CheckPositiveNumbers.Left = 460
		self.CheckPositiveNumbers.Width = 320
		
		
		# Compose Tabcontrol
		
		self.TabPage1 = TabPage()
		self.TabPage1.Text = "Choose bathymetry input" 		
		self.TabPage2 = TabPage()
		self.TabPage2.Text = "Bathymetry metadata" 		
		
		self.TabPage1.Controls.Add(self.radioButtonChooseAscii)
		self.TabPage1.Controls.Add(self.radioButtonChooseFile)
		self.TabPage1.Controls.Add(self.radioButtonGlobal)
		
		self.TabPage2.Controls.Add(self.labelSelectedGrid)	
		self.TabPage2.Controls.Add(self.txtSelectedGrid)
		self.TabPage2.Controls.Add(self.btnFinalizeImport)	
		self.TabPage2.Controls.Add(self.BathyMetaData)	
		self.TabPage2.Controls.Add(self.CheckPositiveNumbers)
		
		self.TabSteps.TabPages.Add(self.TabPage1)
		self.TabSteps.TabPages.Add(self.TabPage2)			
		self.Controls.Add(self.TabSteps)
				
		
		# 	Add controls to form
		
		#self.Controls.Add(self.BathyMetaData)		
		#self.Controls.Add(self.radioButtonChooseAscii)
		#self.Controls.Add(self.radioButtonChooseFile)
		#self.Controls.Add(self.radioButtonGlobal)
				
		
		
		# 	Form properties
		self.SetAutoSizeMode(AutoSizeMode.GrowOnly) 
		self.Width = 950
		self.Height = 400
		self.MaximumSize.Width = 1024
		self.MaximumSize.Height = 400
		
		#self.AsciiPath = r"C:\Users\905252\Documents\CoDeS\plugins\DeltaShell.Plugins.Toolbox\Scripts\BathymetryData\Testdata\NorthSea\rws_testdata_grid.asc"
		self.ConvertToPositive = False		
		
		
	
		
#Kaart = None

#for TempObject in CurrentProject.RootFolder.Items:
#	if (str(TempObject) == "Bathymetry"):
#		Kaart = TempObject.Value	
		
"""Tekstvak = TextBox()
#Tekstvak.Top = 50
#Tekstvak.Left = 50
	
TabSteps = TabControl()
TabSteps.Dock = DockStyle.Fill

TabPage1 = TabPage()
TabPage1.Text = "Page 1" 

TabSteps.TabPages.Add(TabPage1)
TabPage2 = TabPage()
TabPage2.Text = "Page 2" 
TabSteps.TabPages.Add(TabPage2)

#TabSteps.Dock = DockStyle.Fill


frmBathy.Controls.Add(TabSteps)
TabSteps.BringToFront()
#print TabPage1.Size.Width
"""

#frmBathy = BathyForm()
#frmBathy.MaximizeBox = False

#frmBathy.MaximumSize.Width = 1024
#frmBathy.MaximumSize.Height = 400
#frmBathy.ShowDialog()

#print "Form created"

"""frmBathy.AsciiPath = "leeg"
frmBathy.Close(
print "Form closed"""



def ShowBathymetryUI(MapExtent):
	frmBathy = BathyForm()
	frmBathy.MapExtent = MapExtent	
	return frmBathy


def SetGradientTheme(layer, attributeName, numClasses):
	"""Sets the theme (coloring) of the layer"""
	
	colorBlend = ColorBlend.Rainbow5
	
	size = 10
	layer.Theme = ThemeFactory.CreateGradientTheme(attributeName, None, colorBlend, layer.MinDataValue, layer.MaxDataValue, size,size,False,True,numClasses)



