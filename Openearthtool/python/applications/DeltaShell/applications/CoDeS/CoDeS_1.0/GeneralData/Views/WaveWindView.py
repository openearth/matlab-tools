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
import clr
clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf
import System.Drawing.Size as _Size
from System.Drawing import Font as _font
from System.Drawing import FontStyle as _fontStyle
from NetTopologySuite.Extensions.Features import Feature
import Libraries.MapFunctions as _MapFunctions
import Libraries.StandardFunctions as _StandardFunctions
import Libraries.FlowFlexibleMeshFunctions as FMFunctions
from SharpMap.UI.Tools import MapTool
from System import Type
from GeoAPI.Geometries import IPoint

from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from GisSharpBlog.NetTopologySuite.Geometries import Point as _Point
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools
import numpy as _np

#Base view as *: iets met over-erven.
from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Entities.Scenario as _Scenario
import Scripts.GeneralData.Entities.Waves as _Waves
import Scripts.GeneralData.Entities.WaveClimate as _WaveClimate
from Scripts.GeneralData.Utilities import CsvUtilities as _CsvUtilities
from Scripts.GeneralData.Utilities import Conversions as _Conversions
from Scripts.GeneralData.Utilities import WaveWindUtils as _wwd
from SharpMap.Layers import GroupLayer

class AddPointMapTool(MapTool):
	def __init__(self):
		self.Layer = None
	
	def OnMouseDown(self, worldPosition, e):
		if (self.Layer == None):
			return
		
		self.Layer.DataSource.Features.Clear()
		self.Layer.DataSource.Add(Feature(Geometry = _MapFunctions.CreatePointGeometry(worldPosition.X, worldPosition.Y)))
		self.Layer.RenderRequired = True

class WaveClimateType:
	Classes = "class"
	TimeSeries = "timeseries"

class WaveWindView(BaseView):
	def __init__(self,scenario):
		BaseView.__init__(self)
		
		#	Variables for storage and selection of data
		self.__scenario = scenario
		self.Type = None
		self.epsg = 3857
		self.Text = "Wave Wind import"
		
		if self.__scenario.GenericData.Waves == None:
			self.__scenario.GenericData.Waves = _Waves()
			
		self.InitializeControls()
		self.InitializeForScenario()

	def InitializeControls(self):
		
		#region auto_import
		self.rbtnAuto = _swf.RadioButton()
		self.rbtnAuto.Text = "Auto import"
		self.rbtnAuto.Top = 10
		self.rbtnAuto.Left = 10
		self.rbtnAuto.Width = 150
		self.rbtnAuto.Checked = True
		self.rbtnAuto.Click += self.rbtnAuto_Click
		
		self.lblSelectedFile = _swf.Label()
		self.lblSelectedFile.Top = 40
		self.lblSelectedFile.Left = 30
		self.lblSelectedFile.Width = 150
		self.lblSelectedFile.Text = "Select input file"
		
		self.tbSelectedFile = _swf.TextBox()
		self.tbSelectedFile.Top = 40
		self.tbSelectedFile.Left = 200
		self.tbSelectedFile.Width = 150
				
		self.btnSelectedFile = _swf.Button()
		self.btnSelectedFile.Text = "Browse file"
		self.btnSelectedFile.Top = 40
		self.btnSelectedFile.Left = 360		
		self.btnSelectedFile.Click += self.btnSelectedFile_Click
		
		self.lblHeader = _swf.Label()
		self.lblHeader.Top = 70
		self.lblHeader.Left = 30
		self.lblHeader.Width = 150
		self.lblHeader.Text = "Number of rows in header:"
		
		self.tbHeader = _swf.TextBox()
		self.tbHeader.Top = 70
		self.tbHeader.Left = 200
		self.tbHeader.Width = 150
		self.tbHeader.Text = "1"
		
		self.lblDelimiter = _swf.Label()
		self.lblDelimiter.Top = 100
		self.lblDelimiter.Left = 30
		self.lblDelimiter.Width = 150
		self.lblDelimiter.Text = "Field delimiter:"
		
		self.tbDelimiter = _swf.TextBox()
		self.tbDelimiter.Top = 100
		self.tbDelimiter.Left = 200
		self.tbDelimiter.Width = 150
		self.tbDelimiter.Text = ","
		
		self.lblDateFormat = _swf.Label()
		self.lblDateFormat.Top = 130
		self.lblDateFormat.Left = 30
		self.lblDateFormat.Width = 150
		self.lblDateFormat.Text = "Date-time format:"
		
		self.tbDateFormat = _swf.TextBox()
		self.tbDateFormat.Top = 130
		self.tbDateFormat.Left = 200
		self.tbDateFormat.Width = 150
		self.tbDateFormat.Text = "%d-%m-%Y %H:%M"
		
		self.lblShowDateFormats = _swf.Label()
		self.lblShowDateFormats.Top = 130
		self.lblShowDateFormats.Left = 360
		self.lblShowDateFormats.Width = 40
		self.lblShowDateFormats.Text = "?"
		self.lblShowDateFormats.Font = _font(self.lblShowDateFormats.Font.FontFamily, 12, _fontStyle.Bold)
		self.lblShowDateFormats.MouseHover += lambda s,e: self.showDateFormats()
		
		self.lblClassify = _swf.Label()
		self.lblClassify.Top = 160
		self.lblClassify.Left = 30
		self.lblClassify.Width = 150
		self.lblClassify.Text = "Classify data:"
		
		self.cbClassify = _swf.CheckBox()
		self.cbClassify.Top = 160
		self.cbClassify.Left = 200
		
		self.lblInspect = _swf.Label()
		self.lblInspect.Top = 190
		self.lblInspect.Left = 30
		self.lblInspect.Width = 150
		self.lblInspect.Text = "Inspect data after import:"
		
		self.cbInspect = _swf.CheckBox()
		self.cbInspect.Top = 190
		self.cbInspect.Left = 200
		
		self.leftPanel.Controls.Add(self.rbtnAuto)
		self.leftPanel.Controls.Add(self.lblSelectedFile)
		self.leftPanel.Controls.Add(self.tbSelectedFile)
		self.leftPanel.Controls.Add(self.btnSelectedFile)
		self.leftPanel.Controls.Add(self.lblHeader)
		self.leftPanel.Controls.Add(self.tbHeader)
		self.leftPanel.Controls.Add(self.lblDelimiter)
		self.leftPanel.Controls.Add(self.tbDelimiter)
		self.leftPanel.Controls.Add(self.lblDateFormat)
		self.leftPanel.Controls.Add(self.tbDateFormat)
		self.leftPanel.Controls.Add(self.lblShowDateFormats)
		self.leftPanel.Controls.Add(self.lblClassify)
		self.leftPanel.Controls.Add(self.cbClassify)
		#self.leftPanel.Controls.Add(self.lblInspect)
		#self.leftPanel.Controls.Add(self.cbInspect)
		
		#endregion
		
		#region manual_input
		
		self.rbtnManual = _swf.RadioButton()
		self.rbtnManual.Text = "Manual import"
		self.rbtnManual.Top = 230
		self.rbtnManual.Left = 10
		self.rbtnManual.Width = 150
		self.rbtnManual.Click += self.rbtnManual_Click
		
		self.dgvManual = _swf.DataGridView()
		
		#self.dgvManual.AutoGenerateColumns = False
		#such that it fits nicely into the wavewind-GUI
		self.dgvManual.Left = 30
		self.dgvManual.Top = 260
		self.dgvManual.Width = 400
		self.dgvManual.Height = 170
		self.dgvManual.ColumnCount = 4
		self.ConfigureWaveClimateTableFor(WaveClimateType.Classes)
		
		self.dgvManual.Enabled = True
		self.dgvManual.ReadOnly = False
		
		self.leftPanel.Controls.Add(self.rbtnManual)
		self.leftPanel.Controls.Add(self.dgvManual)
		
		#endregion
		
		#region location selection
		
		self.map = MapView()
		self.map.Dock = DockStyle.Fill
		
		_CoDesMapTools.ShowLegend(self.map)
		
		self.ChildViews.Add(self.map)
		self.rightPanel.Controls.Add(self.map)
		
		#endregion
		
		#region general
		
		self.cbOffshore = _swf.CheckBox()
		self.cbOffshore.Text = "Offshore waves"
		self.cbOffshore.Top = 450
		self.cbOffshore.Left = 10
		self.cbOffshore.Width = 150
		self.cbOffshore.Checked = True
		self.cbOffshore.Click += self.cbOffshore_Click

		self.cbNearshore = _swf.CheckBox()
		self.cbNearshore.Text = "Nearshore waves"
		self.cbNearshore.Top = 450
		self.cbNearshore.Left = 160
		self.cbNearshore.Width = 150
		self.cbNearshore.Click += self.cbNearshore_Click
		
		self.btnOK = _swf.Button()
		self.btnOK.Text = "OK"
		self.btnOK.Top = 480
		self.btnOK.Left = 10
		self.btnOK.Width = 100
		self.btnOK.Click += lambda s,e : self.btnOK_Click()
		
		self.btnClear = _swf.Button()
		self.btnClear.Text = "Clear input"
		self.btnClear.Top = 480
		self.btnClear.Left = 120
		self.btnClear.Width = 100
		self.btnClear.Click += self.btnClear_Click
		
		self.lblCoordinates = _swf.Label()
		self.lblCoordinates.Top = 520
		self.lblCoordinates.Left = 10
		self.lblCoordinates.Width = 130
		self.lblCoordinates.Text = "Selected coordinates:"
		
		self.tbCoordinates = _swf.TextBox()
		self.tbCoordinates.Top = 520
		self.tbCoordinates.Left = 140
		self.tbCoordinates.Width = 250
		self.tbCoordinates.Enabled = False
		
		self.btnClickPoint = _swf.Button()
		self.btnClickPoint.Top = 550
		self.btnClickPoint.Left = 10
		self.btnClickPoint.Width = 100
		self.btnClickPoint.Enabled = True
		self.btnClickPoint.Text = "Click Point"
		self.btnClickPoint.Click += lambda s,e : self.btnClickPoint_Click()
		
		self.btnCoordinates = _swf.Button()
		self.btnCoordinates.Top = 550
		self.btnCoordinates.Left = 120
		self.btnCoordinates.Width = 100
		self.btnCoordinates.Enabled = False
		self.btnCoordinates.Text = "Confirm point"
		self.btnCoordinates.Click += lambda s,e : self.btnCoordinates_Click()
		
		self.lblGebco = _swf.Label()
		self.lblGebco.Top = 550
		self.lblGebco.Left = 230
		self.lblGebco.Width = 200
		self.lblGebco.Text = "Depth from GEBCO data" 
		
		
		self.leftPanel.Controls.Add(self.cbOffshore)
		self.leftPanel.Controls.Add(self.cbNearshore)
		self.leftPanel.Controls.Add(self.btnOK)
		self.leftPanel.Controls.Add(self.btnClear)
		self.leftPanel.Controls.Add(self.lblCoordinates)
		self.leftPanel.Controls.Add(self.tbCoordinates)
		self.leftPanel.Controls.Add(self.btnCoordinates)
		self.leftPanel.Controls.Add(self.btnClickPoint)
		self.leftPanel.Controls.Add(self.lblGebco)
		
		
		#endregion

	def InitializeForScenario(self):
		self.map.Map = self.__scenario.GeneralMap
		self.GroupLayer = self.__scenario.GroupLayerWaveWind
		
		self.GroupLayer.Layers.Clear()
		self.OffshoreLocationLayer = self.CreateOffshoreLocationLayer()
		self.OffshoreLocationLayer.DataSource.FeaturesChanged += lambda s,e :self.SetCoordinatesText() 
		self.OffshoreLocationLayer.ShowInLegend = False
		self.OffshoreLocationLayer.ShowInTreeView = False
		
		self.GroupLayer.Layers.Add(self.OffshoreLocationLayer)
		self.map.Map.BringToFront(self.OffshoreLocationLayer)
		
		self.tool = AddPointMapTool()
		self.tool.Layer = self.OffshoreLocationLayer
		self.map.MapControl.Tools.Add(self.tool)
		
		waves = self.__scenario.GenericData.Waves
		
		self.SetControlsForShore(waves.IsOffshore)
		self.inspect_data(self.WaveClimatesToValueList(), waves.Type)
		
		if (waves.Location != None):
			feature = Feature(Geometry = waves.Location)
			self.OffshoreLocationLayer.DataSource.Features.Add(feature)
			self.OffshoreLocationLayer.ShowInLegend = True
			self.OffshoreLocationLayer.ShowInTreeView = True
		
		
		self.btnCoordinates_Click() # confirm location
		
	#region functions
	
	def SetAnchoring(self):
		self.tbSelectedFile.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Right | _swf.AnchorStyles.Top
		self.btnSelectedFile.Anchor = _swf.AnchorStyles.Right | _swf.AnchorStyles.Top
		self.dgvManual.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Right | _swf.AnchorStyles.Top 
		self.cbOffshore.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.cbNearshore.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.btnOK.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.btnClear.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.lblCoordinates.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.tbCoordinates.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.btnClickPoint.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.btnCoordinates.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
		self.lblGebco.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Bottom
	
	def btnClickPoint_Click(self):
		self.map.MapControl.SelectTool.IsActive = False
		self.tool.IsActive = True
		self.btnCoordinates.Enabled = True
		self.btnClickPoint.Enabled = False
		self.OffshoreLocationLayer.ShowInLegend = True
		self.OffshoreLocationLayer.ShowInTreeView = True
	
	def showDateFormats(self):
		frmDateTime = _wwd.frmDateTimeExample()
		frmDateTime.Location = _swf.Cursor.Position
		frmDateTime.Show()
	
	def btnSelectedFile_Click(self, sender, e):
		ofdSelectedFile = _swf.OpenFileDialog()
		ofdSelectedFile.Filter = "Comma Seperated Files (*.csv)|*.csv"
		#ofdSelectedFile.Filter = "Text Files (*.txt)|*.txt"
	
		if ofdSelectedFile.ShowDialog() == _swf.DialogResult.OK:
			self.tbSelectedFile.Text = ofdSelectedFile.FileName
	
	def validate(self, text):
		"""returns T/F whether """
		return not text == "" 
	
	def grid_remove_rows(self):
		self.dgvManual.Rows.Clear()
		self.dgvManual.Refresh()
	
	def ConfigureWaveClimateTableFor(self, waveClimateTableType):
		if (waveClimateTableType == WaveClimateType.Classes):
			self.dgvManual.Columns[0].Name = "Height"
			self.dgvManual.Columns[1].Name = "Period"
			self.dgvManual.Columns[2].Name = "Direction"
			self.dgvManual.Columns[3].Name = "Occurence"
			self.dgvManual.Columns[0].Width = 80
			self.dgvManual.Columns[1].Width = 80
			self.dgvManual.Columns[2].Width = 80
			self.dgvManual.Columns[3].Width = 80			
			
		if (waveClimateTableType == WaveClimateType.TimeSeries):
			self.dgvManual.Columns[0].Name = "Date time"
			self.dgvManual.Columns[1].Name = "Height"
			self.dgvManual.Columns[2].Name = "Period"
			self.dgvManual.Columns[3].Name = "Direction"
			self.dgvManual.Columns[0].Width = 117
			self.dgvManual.Columns[1].Width = 80
			self.dgvManual.Columns[2].Width = 80
			self.dgvManual.Columns[3].Width = 80			

	def WaveClimatesToValueList(self):
		list = []
		for climate in self.__scenario.GenericData.Waves.WaveClimates:
			list.append([climate.Hs, climate.Tp, climate.Dir, climate.Occurences])
			
		return list

	def inspect_data(self, data, type):		
		
		self.grid_remove_rows()
		self.ConfigureWaveClimateTableFor(type)

		if (type == WaveClimateType.TimeSeries):
			for row in data:
				self.dgvManual.Rows.Add(row[0],row[1],row[2],row[3])
		if (type == WaveClimateType.Classes):
			for row in data:
				if (row[3] != None):
					self.dgvManual.Rows.Add(row[0],row[1],row[2],round(row[3],5))
				else:
					self.dgvManual.Rows.Add(row[0],row[1],row[2],row[3])

		self.dgvManual.Refresh()
		
		self.SetConrolsForAutomatic(False)
		

	def is_valid_input(self, input):
		""" If the input is convertible to float, than in is valid. """
		try:
			float(input)
		except:
			return False
		return True

	def CheckInputControls(self):
		waves = self.__scenario.GenericData.Waves

		# Check if coordinates have been filled in
		if waves.IsOffshore and waves.Location == None:
			return "Please click a location in case of offshore waves"
			
		#Some message if no text is given
		if (self.rbtnAuto.Checked and 
			(not self.validate(self.tbSelectedFile.Text) or 
			not self.validate(self.tbHeader.Text) or 
			not self.validate(self.tbDelimiter.Text) or 
			not self.validate(self.tbDateFormat.Text))):
			return "Required information is missing"

		if self.rbtnManual.Checked :
			if self.dgvManual.Rows.Count <= 1 :
				return "Data incomplete or invalid"
			
			if (self.dgvManual.Columns[0].Name == "Date time"):
				#check if hs, hl and dir are valid
				if (self.CheckTableValuesAreFloat([1,2,3])) == False:
					return "No data entered"
			else:
				#check if hs, hl, dir and occ are valid
				if (self.CheckTableValuesAreFloat([0,1,2,3])) == False:
					return "No data entered"
			
		return ""
	
	def CheckTableValuesAreFloat(self, columnIndices):
		
		maxCheckRow = self.dgvManual.Rows.Count
		if self.dgvManual.Enabled == True:
			maxCheckRow = self.dgvManual.Rows.Count - 1
		
		for i in range(0,maxCheckRow):
			row = self.dgvManual.Rows[i]
			for cellIndex in columnIndices:
				celwaarde = str(row.Cells[cellIndex].Value)
				
				if (self.is_valid_input(celwaarde) == False):
					return False
		return True
	
	def btnOK_Click(self):
		
		message = self.CheckInputControls()
		if (message != ""):
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = message
			return
		
		#Some message while processing data
		self.lblMessage.ForeColor = Color.Black
		self.lblMessage.Text = "Processing..."
		self.Refresh()
		
		if self.rbtnAuto.Checked:
			# retrieve values as filled in by user (using label name)
			fileName = self.tbSelectedFile.Text
			headerRow = int(self.tbHeader.Text)
			delimiter = self.tbDelimiter.Text
			dtFormat = self.tbDateFormat.Text
			classify = self.cbClassify.Checked
			
			#Read the actual data
			data = _CsvUtilities.read_csv(fileName, headerRow, delimiter, dtFormat)

			if classify:
				#If the data should be classified: call classifyWaves, 
				#and overwrite the original data with waveclass-data 
				type = WaveClimateType.Classes			#Flag to know which type of data is present
				Hs = _np.array(_Conversions.column(data, 1))			#Wave-heigth [m]
				Tp = _np.array(_Conversions.column(data, 2))			#Wave-period [s]
				dirWave = _np.array(_Conversions.column(data, 3))		#Wave direction [deg]
				data = _wwd.classifyWaves(Hs, Tp, dirWave)
			else:
				#By default, the data type is time series
				type = WaveClimateType.TimeSeries
		else:
			data = []
			
			#	Make sure the last empty row is not read in case the Datagridview is enabled
			maxCheckRow = self.dgvManual.Rows.Count
			if self.dgvManual.Enabled == True:
				maxCheckRow = self.dgvManual.Rows.Count - 1
		
			
			if (self.dgvManual.Columns[0].Name == "Date time"):
				type = WaveClimateType.TimeSeries
				
				for i in range(0,maxCheckRow):			
					row = self.dgvManual.Rows[i]
					dt = row.Cells[0].Value
					wh = float(row.Cells[1].Value)
					wl = float(row.Cells[2].Value)
					dir = float(row.Cells[3].Value)
					data.append([dt, wh, wl, dir])
			else:
				type = WaveClimateType.Classes
				for i in range(0,maxCheckRow):			
					row = self.dgvManual.Rows[i]
					wh = float(row.Cells[0].Value)
					wl = float(row.Cells[1].Value)
					dir = float(row.Cells[2].Value)
					occ = float(row.Cells[3].Value)
					data.append([wh, wl, dir, occ])

		#Return some message after processing data
		self.lblMessage.ForeColor = Color.Green
		self.lblMessage.Text = "Wave data imported"
	
		#Store the data (and type) into the from object.
		waves = self.__scenario.GenericData.Waves
		waves.Type = type
		waves.WaveClimates = []
		
		for datarow in data:
			if (self.rbtnAuto.Checked and type == WaveClimateType.TimeSeries):
				climate = _WaveClimate(datarow[1],datarow[2],datarow[3],None)
			else:
				climate = _WaveClimate(datarow[0],datarow[1],datarow[2],datarow[3])
			
			waves.WaveClimates.append(climate)
		
		self.inspect_data(data, type)

	def btnClear_Click(self, sender, e):
		
		self.tbSelectedFile.Text = ""
		self.tbHeader.Text = "1"
		self.tbDelimiter.Text = ","
		self.tbDateFormat.Text = "%d-%m-%Y %H:%M"
		self.grid_remove_rows()
		self.rbtnAuto.Checked = True
		self.rbtnAuto_Click(sender, e)
		
		self.OffshoreLocationLayer.DataSource.Features.Clear()
		self.OffshoreLocationLayer.ShowInLegend = False
		self.OffshoreLocationLayer.ShowInTreeView = False
		
		self.tool.IsActive = False
		self.btnClickPoint.Enabled = True
		self.btnCoordinates.Enabled = False
		self.tbCoordinates.BackColor = Color.White
		

	def cbOffshore_Click(self, sender, e):
		self.SetControlsForShore(self.cbOffshore.Checked)
		self.__scenario.GenericData.Waves.IsOffshore = True

	def cbNearshore_Click(self, sender, e):
		self.SetControlsForShore(not self.cbNearshore.Checked)
		self.__scenario.GenericData.Waves.IsOffshore = False

	def SetControlsForShore(self, offshore):
		
		self.cbNearshore.Checked = not offshore
		self.cbOffshore.Checked = offshore
		self.btnClickPoint.Enabled = offshore
		
		self.OffshoreLocationLayer.DataSource.Features.Clear()
		
		self.OffshoreLocationLayer.ShowInLegend = False
		self.OffshoreLocationLayer.ShowInTreeView = False
		
		self.tbCoordinates.BackColor = Color.White
		self.tbCoordinates.Text = ""
		self.btnCoordinates.Enabled = False
		
		self.tool.IsActive = False

	def rbtnAuto_Click(self, sender, e):
		if self.rbtnAuto.Checked:
			self.SetConrolsForAutomatic(True)			
	
	def rbtnManual_Click(self, sender, e):
		if self.rbtnManual.Checked:
			self.SetConrolsForAutomatic(False)
			
			

	def SetConrolsForAutomatic(self, automatic):
		self.rbtnAuto.Checked = automatic
		self.rbtnManual.Checked = not automatic
		self.tbSelectedFile.Enabled = automatic
		self.btnSelectedFile.Enabled = automatic
		self.tbHeader.Enabled = automatic
		self.tbDelimiter.Enabled = automatic
		self.tbDateFormat.Enabled = automatic
		self.cbClassify.Enabled = automatic
		self.cbInspect.Enabled = automatic
		#	Manual input is not possible		
		self.dgvManual.Enabled = not automatic
		

	def SetCoordinatesText(self):
		
		waves = self.__scenario.GenericData.Waves
		hasOffshoreLocation = self.OffshoreLocationLayer.DataSource.Features.Count != 0
		self.OffshoreLocationLayer.ShowInLegend = hasOffshoreLocation
		
		if not hasOffshoreLocation:
			self.tbCoordinates.Text = ""
			waves.Z = 0
			waves.Location = None
			return
			
		point = self.OffshoreLocationLayer.DataSource.Features[0].Geometry 
		
		# Get z from GEBCO
		GebcoExtract = FMFunctions.GetGebcoBathymetryData(point.X,point.Y,point.X,point.Y,3857)
		
		waves.Z = FMFunctions.GetGebcoBathymetryValueFor(point.Coordinate,3857,GebcoExtract)
		waves.Location = point
		
		self.tbCoordinates.Text = "X: " + str(round(point.X,0)) + " Y: " + str(round(point.Y,0)) + " Z: " + str(round(waves.Z,0)) + " MTR."
		self.tbCoordinates.BackColor = Color.DarkSalmon
		
		self.btnCoordinates.Enabled = True
	
	def btnCoordinates_Click(self):
		self.tbCoordinates.BackColor = Color.White
		self.btnCoordinates.Enabled = False
		self.btnClickPoint.Enabled = True
		self.tool.IsActive = False
		
	def CreateOffshoreLocationLayer(self):
		cs = self.map.Map.CoordinateSystemFactory.CreateFromEPSG(self.__scenario.GenericData.SR_EPSGCode)
		layer = _MapFunctions.CreateLayerForFeatures("Offshore Location", [], cs)
		layer.Style.GeometryType = Type.GetType("GeoAPI.Geometries.IPoint, GeoAPI")
		layer.Style.Fill.Color = Color.Red
		layer.Style.Outline = layer.Style.Outline
		
		return layer
		
	#endregion

"""from Scripts.GeneralData.Utilities.ScenarioPersister import *
path = "D:\\temp\\newScenario.dat"
scenarioPersister = ScenarioPersister()
newScenario = scenarioPersister.LoadScenario(path) 
waveWindView = WaveWindView(newScenario)
waveWindView.Show()"""



#scenario = _Scenario()
#waveWindView = WaveWindView(scenario)
#waveWindView.Show()

