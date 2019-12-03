#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Hidde Elzinga
#
#       hidde.elzinga@deltares.nl
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
#	External libraries

import clr
clr.AddReference("System.Windows.Forms")

import os
import System.Windows.Forms as _swf
import System.Drawing as _drawing

from SharpMap.Extensions.Layers import GdalRegularGridRasterLayer as _RegularGridRasterLayer 
from SharpMap.Extensions.Data.Providers import GdalFeatureProvider as _GdalFeatureProvider
from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView
from SharpMap.Extensions.Layers import OpenStreetMapLayer as _OSML
import numpy as np
import Libraries.MapFunctions as _mapFunctions

#	Views
from Scripts.GeneralData.Views.BaseView import *
#from Scripts.GeneralData.Views.View import *

#	Enities
import Scripts.GeneralData.Entities.Scenario as _Scenario
from Scripts.GeneralData.Entities.Bathymetry import *

# 	Utilities
from Scripts.GeneralData.Utilities import Conversions as _Conversions
import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions
import Scripts.GeneralData.Utilities.GridFunctions as _GridFunctions
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools


class BathymetryView(BaseView):
	def __init__(self,scenario):
		BaseView.__init__(self)
		
			#	Variables for storage and selection of data
		
		self._currentScenario = scenario
		self.ConvertToPositive = False
		self.AsciiPath = ""
		
		self.Text = "Bathymetry import"
		self.InitializeControls()
		
		self.InitializeForScenario()
	
	def InitializeForScenario(self):
		self.mapPreview.Map = self._currentScenario.GeneralMap
		self.GroupLayer = self._currentScenario.GroupLayerBathymetry
		
		currentBathymetry = self._currentScenario.GenericData.Bathymetry
		if (currentBathymetry == None): return
		
		self.DisableImportControls()
		isSlope = currentBathymetry.BathymetryType == BathymetryType.Slope
		
		self.radioButtonSlope.Checked = isSlope
		self.radioButtonChooseAscii.Checked = not isSlope
		self.SetVisibilityControlsSlope(isSlope)
		self.SetVisibilityControlsAscii(not isSlope)
		self.btnCreateSlopeBathy.Enabled = isSlope
		self.btnImportAscii.Enabled = isSlope
		
		if isSlope :
			self.txtSlopeValue.Text = str(currentBathymetry.SlopeValue)

		elif currentBathymetry.BathymetryType == BathymetryType.Ascii :
			self.txtAsciiPath.Text = currentBathymetry.SourcePath
			self.AsciiPath = currentBathymetry.SourcePath
			
		self.CheckPositiveNumbers.Checked = currentBathymetry.IsDepth
		
		self.AddBathyLayer(currentBathymetry.BathymetryType)
	
	def InitializeControls(self):
		
		#	Create tabcontrol with two pages
		
		self.TabSteps = _swf.TabControl()
		self.TabSteps.Dock = _swf.DockStyle.Fill
		
		self.TabPage1 = _swf.TabPage()
		self.TabPage1.Text = "Bathymetry input" 
		
		self.TabPage2 = _swf.TabPage()
		self.TabPage2.Text = "Bathymetry metadata" 	


		self.TabSteps.TabPages.Add(self.TabPage1)
		#self.TabSteps.TabPages.Add(self.TabPage2)
		
		#	Add tabcontrol to left panel of the view
		self.leftPanel.Controls.Add(self.TabSteps)
		
		# Global variables for reference to controls	
		
		# Controls for tabpage 1
		
		# For option 'Choose file'
		
		self.label = _swf.Label()
		self.label2 = _swf.Label()
		self.newButton = _swf.Button()
		self.newButton2 = _swf.Button()
		self.ConversionButton = _swf.Button()
		self.newTextbox = _swf.TextBox()
		self.newTextbox2 = _swf.TextBox()
		
		# For option 'Global'
		
		self.txtMinX = _swf.TextBox()
		self.txtMaxX = _swf.TextBox()
		self.txtMinY = _swf.TextBox()
		self.txtMaxY = _swf.TextBox()
	
		self.labelMinX = _swf.Label()
		self.labelMaxX = _swf.Label()
		self.labelMinY = _swf.Label()
		self.labelMaxY = _swf.Label()
		self.labelExtent = _swf.Label()		
	
		self.btnExtractGEBCO = _swf.Button()
		
		# For option 'Select ascii grid'
		
		self.txtAsciiPath = _swf.TextBox()
		self.btnBrowseAscii = _swf.Button()
		
		self.labelAscii = _swf.Label()		
		self.btnImportAscii = _swf.Button()		
		
		# For option 'From slope'
		
		self.labelSlope = _swf.Label()
		self.txtSlopeValue = _swf.TextBox()
		self.btnCreateSlopeBathy = _swf.Button()
		
		# Create radio button for choice of data on disk or globally available data (select by extent)
		
		self.radioButtonChooseAscii = _swf.RadioButton()
		self.radioButtonChooseAscii.Text = "Add ascii grid (*.asc)"
		self.radioButtonChooseAscii.Left = 10
		self.radioButtonChooseAscii.Width = 200
		self.radioButtonChooseAscii.Top = 20
		self.radioButtonChooseAscii.Click += lambda s,e : self.radioButtonChooseAscii_Click(s,e)
				
		self.radioButtonChooseFile = _swf.RadioButton()
		self.radioButtonChooseFile.Text = "Create bathymetry from xyz-file"
		self.radioButtonChooseFile.Left = 10
		self.radioButtonChooseFile.Width = 200
		self.radioButtonChooseFile.Top = 50
		self.radioButtonChooseFile.Click += lambda s,e : self.radioButtonChooseFile_Click(s,e)
		self.radioButtonChooseFile.Enabled = False
			
		self.radioButtonGlobal = _swf.RadioButton()
		self.radioButtonGlobal.Text = "Select from global dataset"
		self.radioButtonGlobal.Left = 10
		self.radioButtonGlobal.Width = 200
		self.radioButtonGlobal.Top = 80
		self.radioButtonGlobal.Click += lambda s,e : self.radioButtonGlobal_Click(s,e)
		self.radioButtonGlobal.Enabled = False
		
		self.radioButtonSlope = _swf.RadioButton()
		self.radioButtonSlope.Text = "Create bathymetry from slope"
		self.radioButtonSlope.Left = 10
		self.radioButtonSlope.Width = 200
		self.radioButtonSlope.Top = 110
		self.radioButtonSlope.Click += lambda s,e : self.radioButtonSlope_Click(s,e)		
		
				
		self.Text="Import bathymetry data"
		
		#	GroupBox for radiobuttons		
		
		self.groupChoice = _swf.GroupBox()
		self.groupChoice.AutoSize = 1		
		self.groupChoice.Text = "Type of source data"
		self.groupChoice.Dock = _swf.DockStyle.Top
		self.groupChoice.Controls.Add(self.radioButtonChooseAscii)
		self.groupChoice.Controls.Add(self.radioButtonChooseFile)
		self.groupChoice.Controls.Add(self.radioButtonGlobal)
		self.groupChoice.Controls.Add(self.radioButtonSlope)
		
		#	Groupbox for other controls
		
		self.groupInput = _swf.GroupBox()		
		self.groupInput.Text = "Bathymetry input"
		self.groupInput.Dock = _swf.DockStyle.Fill
		
		
		# Add delete bathymetry button to Groupbox 
		self.btnDeleteBathy = _swf.Button()
		self.btnDeleteBathy.Text = "Delete Bathymetry"
		self.btnDeleteBathy.Left = 60
		self.btnDeleteBathy.Top = 140
		self.btnDeleteBathy.Width = 160
		#self.btnDeleteBathy.Anchor = _swf.AnchorStyles.Top | _swf.AnchorStyles.Right				
		self.btnDeleteBathy.Click += lambda s,e :self.btnDeleteBathy_Click(s,e)			
		self.btnDeleteBathy.Enabled = False		
		self.btnDeleteBathy.Visible = False
		self.groupInput.Controls.Add(self.btnDeleteBathy)
		
		#	Add GroupBoxes to page 1			
				
		self.TabPage1.Controls.Add(self.groupChoice)
		self.TabPage1.Controls.Add(self.groupInput)		
		self.groupInput.BringToFront()
		
		#	Create controls on page 2	
		
		self.CreateControlsPage2()		
		
		# 	Mapview for previewing data 
		self.mapPreview = MapView() 			
		self.mapPreview.Dock = _swf.DockStyle.Fill
		
		_CoDesMapTools.ShowLegend(self.mapPreview)
		
		self.ChildViews.Add(self.mapPreview)
		self.rightPanel.Controls.Add(self.mapPreview)
		
		#	Create controls for ascii and slope bathymetry and set visibility
		
		self.CreateControlsAscii()
		self.CreateControlsSlope()
		
		self.SetVisibilityControlsAscii(True)
		self.SetVisibilityControlsSlope(False)

		#	Activate import of ascii grid by default
		self.radioButtonChooseAscii.Checked = True

	def StepToPage2(self):
		
		#self.CreateControlsPage2()
		self.TabSteps.TabPages.Add(self.TabPage2)
		# Read raster properties and display them on page 2 of the tab control
		
		provider = _GdalFeatureProvider()
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
		
		#self.SetScrollBarsLeftPanel(20)
	
	def CreateControlsPage2(self):
		
		# Controls for tabpage 2
		
		self.labelSelectedGrid = _swf.Label()
		self.labelSelectedGrid.Text = "Grid to be imported: "
		self.labelSelectedGrid.Top = 30
		self.labelSelectedGrid.Left = 10
		self.labelSelectedGrid.Width = 200
		self.labelSelectedGrid.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Top
		
		self.txtSelectedGrid = _swf.TextBox()
		self.txtSelectedGrid.Enabled = False
		self.txtSelectedGrid.Top = 60
		self.txtSelectedGrid.Left = 10
		self.txtSelectedGrid.Width = self.TabPage2.Width - 20
		self.txtSelectedGrid.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Right | _swf.AnchorStyles.Top	
		
		self.BathyMetaData = _swf.RichTextBox()
		self.BathyMetaData.Left = 10
		self.BathyMetaData.Top = 120
		self.BathyMetaData.Height = 180
		
		self.BathyMetaData.Width = self.TabPage2.Width
		self.txtSelectedGrid.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Right | _swf.AnchorStyles.Top
		self.BathyMetaData.Enabled = False
		self.BathyMetaData.Text = "Grid metadata"

		self.CheckPositiveNumbers = _swf.CheckBox()
		self.CheckPositiveNumbers.Text = "Multiply by -1 to create positive depth values"
		self.CheckPositiveNumbers.Top = 420
		self.CheckPositiveNumbers.Left = 10
		self.CheckPositiveNumbers.Width = 320
		self.labelSelectedGrid.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Top
		
		self.btnFinalizeImport = _swf.Button()
		self.btnFinalizeImport.Text = "Import bathymetry grid"
		self.btnFinalizeImport.Left = 10
		self.btnFinalizeImport.Top = 450
		self.btnFinalizeImport.Width = 200
		self.btnFinalizeImport.Height = 35
		self.btnFinalizeImport.Click += lambda s,e : self.btnFinalizeImport_Click(s,e)
		
		
		self.TabPage2.Controls.Add(self.labelSelectedGrid)			
		self.TabPage2.Controls.Add(self.txtSelectedGrid)
		self.TabPage2.Controls.Add(self.BathyMetaData)	
		
		self.TabPage2.Controls.Add(self.CheckPositiveNumbers)		
		self.TabPage2.Controls.Add(self.btnFinalizeImport)			

	def BrowseSave_Click(self,sender, e):
		NewDialog = _swf.SaveFileDialog()
		NewDialog.Filter = "ascii-files (*.asc)|*.asc"
		
		if NewDialog.ShowDialog() == _swf.DialogResult.OK:
			self.newTextbox2.Text = NewDialog.FileName

	def btnBrowseAscii_Click(self,sender,e):
		NewDialog = _swf.OpenFileDialog()
		NewDialog.Filter = "Ascii-grid (*.asc)|*.asc"
		
		if NewDialog.ShowDialog() == _swf.DialogResult.OK:
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
		
		if os.path.isfile(self.txtAsciiPath.Text) == False:
			_swf.MessageBox.Show("Please select a valid path for the ascii grid")
			return
				
		self.AsciiPath = self.txtAsciiPath.Text
		self.StepToPage2()

	def btnFinalizeImport_Click(self,sender,e):	
		self.FinishImport("Asciigrid")

	def btnCreateSlopeBathy_Click(self,sender,e):
		self.FinishImport("Slope")

	def btnExtractGEBCO_Click(self,sender, e):
		
		# Get current map extent
		CurrentExtent = self._currentScenario.GenericData.GetDataExtent()
			
		# Extract GEBCO-data for current map extent
		
		diffX = CurrentExtent.MaxX - CurrentExtent.MinX
		diffY = CurrentExtent.MaxY - CurrentExtent.MinY
		
		if diffX > 500000 or diffY > 500000:
			MessageBox.Show("Please select an area of max 300 x 300 km")
			return
		
		if diffX < 10000 or diffY < 10000:
			MessageBox.Show("Please select an area of at least 10 x 10 km")
			return
		
		NewDialog = _swf.SaveFileDialog()
		NewDialog.Filter = "ascii-files (*.asc)|*.asc"
		
		if NewDialog.ShowDialog() == _swf.DialogResult.OK:
			GridFunctions.GetAscGridFromGebco(CurrentExtent,NewDialog.FileName)			
			
			self.AsciiPath = NewDialog.FileName
			self.StepToPage2()

	def Browse_Click(self, sender, e):
		NewDialog = OpenFileDialog()
		NewDialog.Filter = "XYZ-files (*.xyz)|*.xyz"
		
		if NewDialog.ShowDialog() == _swf.DialogResult.OK:
			self.newTextbox.Text = NewDialog.FileName

	def RemoveControlsXYZ(self):
		self.groupInput.Controls.Remove(self.label)
		self.groupInput.Controls.Remove(self.label2)
		self.groupInput.Controls.Remove(self.newButton)
		self.groupInput.Controls.Remove(self.newButton2)
		self.groupInput.Controls.Remove(self.ConversionButton)
		self.groupInput.Controls.Remove(self.newTextbox)
		self.groupInput.Controls.Remove(self.newTextbox2)
	
	def SetVisibilityControlsAscii(self,isVisible):
		
		self.btnImportAscii.Visible = isVisible
		self.txtAsciiPath.Visible = isVisible
		self.labelAscii.Visible = isVisible
		self.btnBrowseAscii.Visible = isVisible

	def RemoveControlsGebco(self):
		self.groupInput.Controls.Remove(self.labelExtent)		
			
		self.groupInput.Controls.Remove(self.txtMinX)
		self.groupInput.Controls.Remove(self.txtMaxX)
		self.groupInput.Controls.Remove(self.txtMinY)
		self.groupInput.Controls.Remove(self.txtMaxY)	
			
		self.groupInput.Controls.Remove(self.labelMinX)
		self.groupInput.Controls.Remove(self.labelMaxX)
		self.groupInput.Controls.Remove(self.labelMinY)
		self.groupInput.Controls.Remove(self.labelMaxY)
			 
		self.groupInput.Controls.Remove(self.btnExtractGEBCO)
	
	def SetVisibilityControlsSlope(self, isVisible):
		
		self.labelSlope.Visible = isVisible
		self.txtSlopeValue.Visible = isVisible
		self.btnCreateSlopeBathy.Visible = isVisible

	def CreateControlsAscii(self):
		
		self.labelAscii.Text = "Select ascii grid:"
		self.labelAscii.Left = 10
		self.labelAscii.Top = 30
		self.labelAscii.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Top
				
		self.txtAsciiPath.Name = "txt_AsciiPath"
		self.txtAsciiPath.Left = 10
		self.txtAsciiPath.Top = 50
		self.txtAsciiPath.Width = self.groupInput.Width - 20
		self.txtAsciiPath.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Top | _swf.AnchorStyles.Right
		
		
		#_swf.MessageBox.Show("Current width of group is " + str(self.groupInput.Width))
				
		self.btnBrowseAscii.Text = "Browse"
		self.btnBrowseAscii.Width = 80
		self.btnBrowseAscii.Left = self.groupInput.Width - 90
		self.btnBrowseAscii.Top = 20
		self.btnBrowseAscii.Anchor = _swf.AnchorStyles.Top | _swf.AnchorStyles.Right
		
		
		self.btnBrowseAscii.Click += lambda s,e : self.btnBrowseAscii_Click(s,e)
				
		self.btnImportAscii.Text = "Import ascii grid"
		self.btnImportAscii.Left = 60
		self.btnImportAscii.Top = 110
		self.btnImportAscii.Width = 160
		#self.btnImportAscii.Anchor = _swf.AnchorStyles.Top | _swf.AnchorStyles.Right

		
		self.btnImportAscii.Click += lambda s,e :self.btnImportAscii_Click(s,e)	
		
		self.groupInput.Controls.Add(self.txtAsciiPath)
		self.groupInput.Controls.Add(self.labelAscii)
		self.groupInput.Controls.Add(self.btnBrowseAscii)
		self.groupInput.Controls.Add(self.btnImportAscii)
		
		self.SetScrollBarsLeftPanel(0)
	
	def CreateControlsXYZ(self):
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
		
		self.groupInput.Controls.Add(self.label)
		self.groupInput.Controls.Add(self.label2)
		self.groupInput.Controls.Add(self.newButton)
		self.groupInput.Controls.Add(self.newButton2)
		self.groupInput.Controls.Add(self.ConversionButton)
		self.groupInput.Controls.Add(self.newTextbox)
		self.groupInput.Controls.Add(self.newTextbox2)
		
		#self.SetScrollBarsLeftPanel(20)
	
	def CreateControlsGebco(self):
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
		
		self.groupInput.Controls.Add(self.labelExtent)
			 
		self.groupInput.Controls.Add(self.txtMinX)
		self.groupInput.Controls.Add(self.txtMaxX)
		self.groupInput.Controls.Add(self.txtMinY)
		self.groupInput.Controls.Add(self.txtMaxY)	
			 
		self.groupInput.Controls.Add(self.labelMinX)
		self.groupInput.Controls.Add(self.labelMaxX)
		self.groupInput.Controls.Add(self.labelMinY)
		self.groupInput.Controls.Add(self.labelMaxY)
			 
		self.groupInput.Controls.Add(self.btnExtractGEBCO)
	
	def CreateControlsSlope(self):
				
		self.labelSlope = _swf.Label()
		self.txtSlopeValue = _swf.TextBox()
		
		self.labelSlope.Text = "Fill in slope (1:...)"
		self.labelSlope.Left = 10
		self.labelSlope.Top = 30
		self.labelSlope.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Top
				
		
		self.txtSlopeValue.Left = 120
		self.txtSlopeValue.Top = 30
		self.txtSlopeValue.Width = 40
		self.txtSlopeValue.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Top
		
		
		self.btnCreateSlopeBathy.Text = "Create bathymetry"
		self.btnCreateSlopeBathy.Left = 60
		self.btnCreateSlopeBathy.Top = 110
		self.btnCreateSlopeBathy.Width = 160
		self.btnCreateSlopeBathy.Click += lambda s,e :self.btnCreateSlopeBathy_Click(s,e)
		
	
		self.groupInput.Controls.Add(self.labelSlope)
		self.groupInput.Controls.Add(self.txtSlopeValue)
		self.groupInput.Controls.Add(self.btnCreateSlopeBathy)
		
		self.SetScrollBarsLeftPanel(0)
	
	def radioButtonChooseFile_Click(self, sender,e):
		
		#	Remove controls which are not necessary 
		self.RemoveControlsGebco()
		self.SetVisibilityControlsAscii()
		self.SetVisibilityControlsSlope()
		
		self.CreateControlsXYZ()
		self.lblMessage.Text = ""
		
	def btnDeleteBathy_Click(self,sender,e):
		self._currentScenario.GenericData.Bathymetry = None
		self.GroupLayer.Layers.Clear()
		
		self.ConvertToPositive = False
		self.AsciiPath = ""
		self.txtAsciiPath.Text = ""
		self.newTextbox2.Text = ""
		self.txtSlopeValue.Text = ""
		
		self.groupChoice.Enabled = True
		for control in self.groupInput.Controls:
			control.Enabled = True
			self.btnDeleteBathy.Enabled = False
		
		if self.TabSteps.TabPages.Contains(self.TabPage2):
			self.TabSteps.TabPages.Remove(self.TabPage2)
			self.CheckPositiveNumbers.Enabled = True
			self.btnFinalizeImport.Enabled = True
		
		self.lblMessage.Text = ""
		
	def radioButtonChooseAscii_Click(self,sender,e):
		
		self.RemoveControlsGebco()
		self.RemoveControlsXYZ()
		self.SetVisibilityControlsSlope(False)
		self.SetVisibilityControlsAscii(True)
		
		self.lblMessage.Text = ""
		
		self.SetScrollBarsLeftPanel(20)
	
	def radioButtonGlobal_Click(self,sender,e):
		#	Update exten of map which is displayed
		
		self.MapExtent = self.mapPreview.Map.Envelope
		
		#self.RemoveControlsXYZ()
		self.SetVisibilityControlsAscii(False)
		self.SetVisibilityControlsSlope(False)
		
		self.CreateControlsGebco()
		self.lblMessage.Text = ""
	
	def radioButtonSlope_Click(self,sender,e):
		
		
		#self.RemoveControlsXYZ()
		#self.RemoveControlsGebco()
		
		self.SetVisibilityControlsAscii(False)
		self.SetVisibilityControlsSlope(True)
		
		
		if self._currentScenario.GenericData.Coastline == None:
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = "Coastline required!"
		else:
			self.lblMessage.Text = ""
		
		self.SetScrollBarsLeftPanel(0)

	def CreateGridFromPath(self,asciiPath):		
		gdalProvider = _GdalFeatureProvider()
		gdalProvider.Open(asciiPath)
		
		regularGrid = gdalProvider.Grid
		return regularGrid

	def CreateGridLayerFromPath(self,asciiPath):
		rasterLayer = _RegularGridRasterLayer()
		rasterLayer.Name = "Ascii-Grid (m)"
		rasterLayer.DataSource.Path = asciiPath
		
		maxColor = np.ceil(rasterLayer.MaxDataValue).Value
		minColor = np.floor(rasterLayer.MinDataValue).Value
		numClass = 10
		maxColor = minColor+(numClass-1)*np.ceil((maxColor-minColor)/(numClass-1)).Value
		
		_GridFunctions.SetGradientTheme(rasterLayer,rasterLayer.ThemeAttributeName, numClass,minColor,maxColor)
		
		return rasterLayer
	
	def CreateSlopeBathymetryLayer(self):
		geometry = self._currentScenario.GenericData.Coastline.CoastlineGeometry
		tot_length = geometry.Length
		numsteps = 30
		ds = tot_length/numsteps
		segmentID = 0
		lengthInSegment = 0
		totalLength = 0
		numberP = 0
		
		cs = _mapFunctions.Map.CoordinateSystemFactory.CreateFromEPSG(self._currentScenario.GenericData.SR_EPSGCode)
		slopeBathymetryLayer = _mapFunctions.CreateLayerForFeatures(("Slope 1:"+self.txtSlopeValue.Text), [], cs)
		
		slopeLayerStyle = slopeBathymetryLayer.Style
		slopeLayerStyle.Line.Width = 2
		slopeLayerStyle.Line.Color = _mapFunctions.Color.SlateGray
		slopeLayerStyle.Line = slopeLayerStyle.Line 

		while (segmentID+1)<geometry.NumPoints:
			numberP = numberP + 1
			start_point = geometry.Coordinates.Get(segmentID)
			end_point   = geometry.Coordinates.Get(segmentID+1)
			dY = (end_point.Y - start_point.Y)
			dX = (end_point.X - start_point.X)
			DirectionCrosshore = -(np.arctan2(dY,dX))
			
			segment_length     = np.sqrt((dX**2) + (dY**2)).Value
			if numberP % 2 == 0:
				dist = tot_length*0.05
			else:
				dist = tot_length*0.025
			
			X = start_point.X + dX * (lengthInSegment/segment_length)
			Y = start_point.Y + dY * (lengthInSegment/segment_length)
			
			endpoints_slope = np.array([X+np.sin(DirectionCrosshore)*dist,Y+np.cos(DirectionCrosshore)*dist])
			SlopeFeature = _mapFunctions.Feature(Geometry = _mapFunctions.CreateLineGeometry([np.array([X,Y]),np.array([endpoints_slope[0].Value,endpoints_slope[1].Value])]))
			slopeBathymetryLayer.DataSource.Features.Add(SlopeFeature)
			totalLength = totalLength + ds
			lengthInSegment = lengthInSegment+ds
			if lengthInSegment>segment_length:
				segmentID = segmentID + 1
				lengthInSegment = lengthInSegment-segment_length
		
		return slopeBathymetryLayer
	
	def AddBathyLayer(self, BathyType, zoomToFit = False):
		self.GroupLayer.Layers.Clear()
		
		if BathyType == BathymetryType.Ascii:
			layer = self.CreateGridLayerFromPath(self.AsciiPath)
			
			self.GroupLayer.Layers.Add(layer)
			self.mapPreview.Map.SendToBack(layer)
			self.mapPreview.Map.SendToBack(self._currentScenario.OSMLlayer)
			
		elif BathyType == BathymetryType.Slope:
			if self._currentScenario.GenericData.Bathymetry == None:
				return
			
			layer =  self.CreateSlopeBathymetryLayer()
			self.GroupLayer.Layers.Add(layer)
			self.mapPreview.Map.BringToFront(layer)
			
		# self.mapPreview.Map.ZoomToFit(layer.Envelope)
	
	def FinishImport(self,BathyType):
		
		if BathyType == BathymetryType.Ascii :
			# 	Set conversion to positive numbers to true of false
			isDepth = not self.CheckPositiveNumbers.Checked
			
			#	Add layer to map
			if os.path.isfile(self.AsciiPath) == False: 
				_swf.MessageBox.Show("Please select a valid path for the ascii grid")
				return
				 
			bathymetryGrid = self.CreateGridFromPath(self.AsciiPath)			
			
			#	Create Bathymetry object and add this to the active Scenario object
			if self._currentScenario.GenericData == None:
				_swf.MessageBox.Show("No data defined")
				return
				
			self._currentScenario.GenericData.Bathymetry = AsciiBathymetry(bathymetryGrid,self.AsciiPath,isDepth)
			self.TabSteps.SelectedIndex = 0
			
		elif BathyType == BathymetryType.Slope :
			#	Check if a numeric value has been filled in
			
			if self._currentScenario.GenericData.Coastline == None:
				_swf.MessageBox.Show("Coastline Required!")
				return
				
			slopeValue = _Conversions.StrToFloat(self.txtSlopeValue.Text)
			
			if slopeValue == None:
				_swf.MessageBox.Show("Please fill in a numeric value for the slope")
				return
				
			# 	Create bathymetry based on slope
			self._currentScenario.GenericData.Bathymetry = SlopeBathymetry(slopeValue)
		else:
			return
		
		
		
		self.AddBathyLayer(BathyType, True)
		
		self.lblMessage.ForeColor = Color.Green
		self.lblMessage.Text = "Bathymetry Imported: " + BathyType
		self.DisableImportControls()
	
	def DisableImportControls(self):
		self.groupChoice.Enabled = False
		for control in self.groupInput.Controls:
			control.Enabled = False
		self.btnDeleteBathy.Visible = True
		self.btnDeleteBathy.Enabled = True
		if self.TabSteps.TabPages.Contains(self.TabPage2):
			for control in self.TabPage2.Controls:
				control.Enabled = False	
			   
		
#from Scripts.GeneralData.Utilities.ScenarioPersister import *
#path = "D:\\temp\\newScenario.dat"
#scenarioPersister = ScenarioPersister()
#newScenario = scenarioPersister.LoadScenario(path) 

#newView = BathymetryView(newScenario)

#newView.Show()
#scenario = _Scenario()

#bathyView = BathymetryView(scenario)
#bathyView.Show()


