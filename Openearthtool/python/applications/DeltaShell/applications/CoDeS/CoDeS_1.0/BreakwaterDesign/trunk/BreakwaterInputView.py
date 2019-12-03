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
#import Scripts.GeneralData.Utilities.PythonObjects as _PythonObjects
from SharpMap.UI.Tools import NewLineTool
from SharpMap.Editors.Interactors import Feature2DEditor
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
#from Libraries.ChartFunctions import *
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
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as _Env
from SharpMap.Extensions.Layers import OpenStreetMapLayer as _OSML

import Scripts.BreakwaterDesign.Utilities.EngineFunctionsBreakwater as bw
from Scripts.BreakwaterDesign.Views.BreakwaterView import *
import Scripts.BreakwaterDesign.Entities.BreakwaterInput as _BreakwaterInput




class BreakwaterInputView(BreakwaterView):	
	def __init__(self,inputData):
		BreakwaterView.__init__(self,inputData)
		
		self.MakeMapView()
		
		
		
	def MakeMapView(self):
		print "Make map"
		# Create layer for the polygons
		self.InputData.BWlayer = CreateLayerForFeatures("Breakwater", [], None)
		self.InputData.BWlayer.Style.Line.Color = Color.Black
		self.InputData.BWlayer.Style.Line.Width = 3
		self.InputData.BWlayer.FeatureEditor = Feature2DEditor(None)
		self.InputData.BWlayer.DataSource.CoordinateSystem = Map.CoordinateSystemFactory.CreateFromEPSG(3857)
		#BWlayer.DataSource.Features[0].Geometry.Coordinates[0].X
		
		def FeaturesChanges(s,e):
			if len(self.InputData.BWlayer.DataSource.Features)>=1:
				newLineTool.IsActive = False
				buttonActivate.Enabled = False
				buttonDelete.Enabled = True
		
		self.InputData.BWlayer.DataSource.FeaturesChanged += FeaturesChanges
		
		# Create new line tool for line (CloseLine = False)
		newLineTool = NewLineTool(None, "New polygon tool", CloseLine = False)
		
		
		# Define layer filter for newLineTool (layer to add the new features to)
		newLineTool.LayerFilter = lambda l : l == self.InputData.BWlayer
		newLineTool.DrawLineDistanceHints = True
		map = Map()
		#satLayer = CreateSatelliteImageLayer()
		OSMLlayer = _OSML()
		OSMLlayer.Name = "Open Street Maps"
		map.Layers.Add(self.InputData.BWlayer)
		#map.Layers.Add(satLayer)
		map.Layers.Add(OSMLlayer)
		map.ZoomToExtents()
		self.InputData.mapview = MapView()
		self.InputData.mapview.Map = map
		self.InputData.mapview.Dock = DockStyle.Fill
		self.InputData.mapview.Map.ZoomToFit(_Env(350000.0,800000.0,6700000.0,7100000.0))
		
		# Add tool
		self.InputData.mapview.MapControl.Tools.Add(newLineTool)
		
		def Activate_BW(s,e):
			newLineTool.IsActive = True
			self.InputData.mapview.MapControl.ActivateTool(newLineTool)
			map.BringToFront(self.InputData.BWlayer)
		
		# Add button to reactivate tool
		buttonActivate = Button(Text = "Click Breakwater")
		buttonActivate.Dock = DockStyle.Top
		buttonActivate.Click += Activate_BW
		
		def Delete_BW(s,e):
			self.InputData.BWlayer.RenderRequired = True
			self.InputData.BWlayer.DataSource.Features.Clear()
			self.InputData.mapview.MapControl.SelectTool.Clear()
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
			self.InputData.RasterPath = Bathy.AsciiPath
			#MessageBox.Show("Positive or negative " + str(Bathy.ConvertToPositive))
			self.InputData.MakePositive = Bathy.ConvertToPositive
	
			# Check if a valid path is selected
			
			ValidPath = os.path.exists(self.InputData.RasterPath)
			
			if ValidPath == True:		
				#RasterPath = r"C:\Users\905252\Documents\CoDeS\plugins\DeltaShell.Plugins.Toolbox\Scripts\BathymetryData\Testdata\NorthSea\rws_testdata_grid_positive.asc"
				Rasterlaag = _RegularGridRasterLayer()
				Rasterlaag.Name = "Bathymetry"
				Rasterlaag.DataSource.Path = self.InputData.RasterPath
				SetGradientTheme(Rasterlaag, Rasterlaag.ThemeAttributeName, 15)
				
				map.Layers.Add(Rasterlaag)
				map.BringToFront(Rasterlaag)
				self.InputData.mapview.Map.ZoomToFit(Rasterlaag.Envelope)
				buttonBathy.Enabled = False
				buttonDelBathy.Enabled = True
			else:
				MessageBox.Show("Please select a valid path to a bathymetry grid")
			
		def Delete_Bathymetry(s,e):
			self.InputData.RasterPath = ""
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
		
		self.InputData.mapview.Controls.Add(buttonDelete)
		self.InputData.mapview.Controls.Add(buttonActivate)
		self.InputData.mapview.Controls.Add(buttonDelBathy)
		self.InputData.mapview.Controls.Add(buttonBathy)
		
		# 	Create panel to contain map
		
		group_MAP = Panel()
		#group_MAP.Text = "Breakwater alignment"
		group_MAP.Font = s.Font(group_MAP.Font.FontFamily, 10)
		group_MAP.Dock = DockStyle.Fill
		group_MAP.Controls.Add(self.InputData.mapview)
		
		#	Make sure map controls are working
		
		self.ChildViews.Add(self.InputData.mapview)
		self.rightPanel.Controls.Add(group_MAP)
		
inputData = _BreakwaterInput()
newView = BreakwaterInputView(inputData)
newView.Show()