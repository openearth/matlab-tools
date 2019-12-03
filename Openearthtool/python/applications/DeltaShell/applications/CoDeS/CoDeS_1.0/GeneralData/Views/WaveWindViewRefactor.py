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
import os



#Base view as *: iets met over-erven.
from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Entities.Scenario as _Scenario
import Scripts.GeneralData.Entities.Waves as _Waves
import Scripts.GeneralData.Entities.WaveClimate as _WaveClimate
from Scripts.GeneralData.Utilities import CsvUtilities as _CsvUtilities
from Scripts.GeneralData.Utilities import Conversions as _Conversions
from Scripts.GeneralData.Utilities import WaveWindUtils as _WaveWindUtils
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
		
		#	For temp storage of waveclimates (which are classified from time series)
		
		

	def InitializeControls(self):
		
		#region auto_import
		self.radioImport = _swf.RadioButton()
		self.radioImport.Text = "Import from time series"
		self.radioImport.Top = 10
		self.radioImport.Left = 10
		self.radioImport.Width = 180
		self.radioImport.Checked = True
		self.radioImport.Click += self.radioImport_Click
		
		self.tbSelectedFile = _swf.TextBox()
		self.tbSelectedFile.Top = 10
		self.tbSelectedFile.Left =  190
		self.tbSelectedFile.Width = 150
				
		self.btnSelectedFile = _swf.Button()
		self.btnSelectedFile.Text = "Browse file"
		self.btnSelectedFile.Top = 10
		self.btnSelectedFile.Left = 350
		self.btnSelectedFile.Width = 80
		self.btnSelectedFile.Click += self.btnSelectedFile_Click

		self.tbPreview = _swf.RichTextBox()
		self.tbPreview.Top = 50
		self.tbPreview.Left = 30
		self.tbPreview.Width = 400
		self.tbPreview.Height = 180
		self.tbPreview.ReadOnly = True
		self.tbPreview.WordWrap = False
		self.tbPreview.ScrollBars = _swf.RichTextBoxScrollBars.ForcedBoth
		
		self.lblDelimiter = _swf.Label()
		self.lblDelimiter.Top = 240
		self.lblDelimiter.Left = 30
		self.lblDelimiter.Width = 150
		self.lblDelimiter.Text = "Field delimiter:"
		
		self.cbDelimiter = _swf.ComboBox()
		self.cbDelimiter.Top = 240
		self.cbDelimiter.Left = 370
		self.cbDelimiter.Width = 60
		self.cbDelimiter.Items.Add("tab")
		self.cbDelimiter.Items.Add("space")
		self.cbDelimiter.Items.Add(",")
		self.cbDelimiter.Items.Add(";")
		self.cbDelimiter.Text = "tab"
		self.cbDelimiter.SelectedValueChanged += lambda s,e : self.UpdateDataColumnNames(True)
		
		self.lblDummyRows = _swf.Label()
		self.lblDummyRows.Text = "Number of dummy rows: "
		self.lblDummyRows.Top = 270
		self.lblDummyRows.Left = 30
		self.lblDummyRows.Width = 160
		
		self.dummyRowsInput = _swf.NumericUpDown()
		self.dummyRowsInput.Minimum = 0  
		self.dummyRowsInput.Increment = 1 
		self.dummyRowsInput.Value = 5
		self.dummyRowsInput.Top = 270
		self.dummyRowsInput.Width = 60
		self.dummyRowsInput.Left = 370
		self.dummyRowsInput.ValueChanged += lambda s,e : self.UpdateDataColumnNames(True)
		
		self.lblIgnoreValue = _swf.Label()
		self.lblIgnoreValue.Text = "Value to ignore (NaN) in data rows: "
		self.lblIgnoreValue.Top = 300
		self.lblIgnoreValue.Left = 30
		self.lblIgnoreValue.Width = 250
		
		self.tbIgnoreValue = _swf.TextBox()
		self.tbIgnoreValue.Top = 300
		self.tbIgnoreValue.Left = 370
		self.tbIgnoreValue.Width = 60
		self.tbIgnoreValue.Text = "NaN"
		
		self.propertyDict = dict()
		self.propertyDict[0] = "Wave height"
		self.propertyDict[1] = "Wave period"
		self.propertyDict[2] = "Wave direction"
		#self.propertyDict[3] = "Year"
		#self.propertyDict[4] = "Month"
		#self.propertyDict[5] = "Day"
		#self.propertyDict[6] = "Hour"
		
		self.dataGridColumnMapping = _swf.DataGridView()
		self.dataGridColumnMapping.Top = 330
		self.dataGridColumnMapping.Left = 30		
		self.dataGridColumnMapping.Width = 400		
		self.dataGridColumnMapping.Height = 45
		
		for columnIndex in range(0,len(self.propertyDict)):
			self.dataGridColumnMappingComboColumn = _swf.DataGridViewComboBoxColumn()
			self.dataGridColumnMappingComboColumn.Name = self.propertyDict[columnIndex]	
			self.dataGridColumnMapping.Columns.Add(self.dataGridColumnMappingComboColumn)	
		
		self.dataGridColumnMapping.AllowUserToAddRows = False
		self.dataGridColumnMapping.Rows.Add()
		
		#self.dataGridColumnMapping.DataError += lambda s,e : self.HandleDatagridError(s,e)
		
		self.btnClassifyWaves = _swf.Button()
		self.btnClassifyWaves.Text = "Classify"
		self.btnClassifyWaves.Top = 380
		self.btnClassifyWaves.Left = 350
		self.btnClassifyWaves.Width = 80	
		self.btnClassifyWaves.Click += self.btnClassifyWaves_Click
		
		
				
		"""self.lblDateFormat = _swf.Label()
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
		self.cbInspect.Left = 200"""
		
		self.leftPanel.Controls.Add(self.radioImport)
		#self.leftPanel.Controls.Add(self.lblSelectedFile)
		self.leftPanel.Controls.Add(self.tbSelectedFile)
		self.leftPanel.Controls.Add(self.btnSelectedFile)
		self.leftPanel.Controls.Add(self.lblDelimiter)
		self.leftPanel.Controls.Add(self.cbDelimiter)
		self.leftPanel.Controls.Add(self.tbPreview)
		self.leftPanel.Controls.Add(self.lblDummyRows)
		self.leftPanel.Controls.Add(self.dummyRowsInput)
		self.leftPanel.Controls.Add(self.dataGridColumnMapping)
		self.leftPanel.Controls.Add(self.lblIgnoreValue)
		self.leftPanel.Controls.Add(self.tbIgnoreValue)
		self.leftPanel.Controls.Add(self.btnClassifyWaves)
		#self.leftPanel.Controls.Add(self.lblDateFormat)
		#self.leftPanel.Controls.Add(self.tbDateFormat)
		#self.leftPanel.Controls.Add(self.lblShowDateFormats)
		#self.leftPanel.Controls.Add(self.lblClassify)
		#self.leftPanel.Controls.Add(self.cbClassify)
		#self.leftPanel.Controls.Add(self.lblInspect)
		#self.leftPanel.Controls.Add(self.cbInspect)
		
		#endregion
		
		#region manual_input
		
		self.radioManual = _swf.RadioButton()
		self.radioManual.Text = "Manual import"
		self.radioManual.Top = 430
		self.radioManual.Left = 10
		self.radioManual.Width = 150
		self.radioManual.Click += self.radioManual_Click
		
		self.datagridWaveClimates = _swf.DataGridView()
		
		#self.datagridWaveClimates.AutoGenerateColumns = False
		#such that it fits nicely into the wavewind-GUI
		self.datagridWaveClimates.Left = 30
		self.datagridWaveClimates.Top = 460
		self.datagridWaveClimates.Width = 400
		self.datagridWaveClimates.Height = 170
		self.datagridWaveClimates.ColumnCount = 4
		self.ConfigureDatagridWaveClimates(WaveClimateType.Classes)
		
		self.datagridWaveClimates.Enabled = True
		self.datagridWaveClimates.ReadOnly = False
		
		self.leftPanel.Controls.Add(self.radioManual)
		self.leftPanel.Controls.Add(self.datagridWaveClimates)
		
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
		self.cbOffshore.Top = 650
		self.cbOffshore.Left = 10
		self.cbOffshore.Width = 150
		self.cbOffshore.Checked = True
		self.cbOffshore.Click += self.cbOffshore_Click

		self.cbNearshore = _swf.CheckBox()
		self.cbNearshore.Text = "Nearshore waves"
		self.cbNearshore.Top = 650
		self.cbNearshore.Left = 160
		self.cbNearshore.Width = 150
		self.cbNearshore.Click += self.cbNearshore_Click
		
		self.btnOK = _swf.Button()
		self.btnOK.Text = "OK"
		self.btnOK.Top = 680
		self.btnOK.Left = 10
		self.btnOK.Width = 100
		self.btnOK.Click += lambda s,e : self.btnOK_Click()
		
		self.btnClear = _swf.Button()
		self.btnClear.Text = "Clear input"
		self.btnClear.Top = 680
		self.btnClear.Left = 120
		self.btnClear.Width = 100
		self.btnClear.Click += self.btnClear_Click
		
		self.lblCoordinates = _swf.Label()
		self.lblCoordinates.Top = 720
		self.lblCoordinates.Left = 10
		self.lblCoordinates.Width = 130
		self.lblCoordinates.Text = "Selected coordinates:"
		
		self.tbCoordinates = _swf.TextBox()
		self.tbCoordinates.Top = 720
		self.tbCoordinates.Left = 140
		self.tbCoordinates.Width = 250
		self.tbCoordinates.Enabled = False
		
		self.btnClickPoint = _swf.Button()
		self.btnClickPoint.Top = 750
		self.btnClickPoint.Left = 10
		self.btnClickPoint.Width = 100
		self.btnClickPoint.Enabled = True
		self.btnClickPoint.Text = "Click Point"
		self.btnClickPoint.Click += lambda s,e : self.btnClickPoint_Click()
		
		self.btnCoordinates = _swf.Button()
		self.btnCoordinates.Top = 750
		self.btnCoordinates.Left = 120
		self.btnCoordinates.Width = 100
		self.btnCoordinates.Enabled = False
		self.btnCoordinates.Text = "Confirm point"
		self.btnCoordinates.Click += lambda s,e : self.btnCoordinates_Click()
		
		self.lblGebco = _swf.Label()
		self.lblGebco.Top = 750
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
		
		self.SetScrollBarsLeftPanel(20)
		
		
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
		
		self.radioManual.Checked = True
		self.SetControlsForShore(waves.IsOffshore)
		self.DisplayWaveClimates()
		
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
		self.datagridWaveClimates.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Right | _swf.AnchorStyles.Top 
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
		frmDateTime = _WaveWindUtils.frmDateTimeExample()
		frmDateTime.Location = _swf.Cursor.Position
		frmDateTime.Show()
	
	def btnSelectedFile_Click(self, sender, e):
		openFileDialog = _swf.OpenFileDialog()
		openFileDialog.Filter = "All files | *.*|Comma Seperated Files (*.csv)|*.csv"
		
		
		
		#openFileDialog.Filter = "Text Files (*.txt)|*.txt"
	
		if openFileDialog.ShowDialog() == _swf.DialogResult.OK:
			self.tbSelectedFile.Text = openFileDialog.FileName
			
			#	Preview file contents in RichTextBox
			
			_CsvUtilities.PreviewFileInTextbox(openFileDialog.FileName,self.tbPreview)
			
			#	Update the columnames in the columnMapping
						
			self.UpdateDataColumnNames(False)
	
	
	def UpdateDataColumnNames(self,checkDelimiter):
		
		
		#	Read column separator
		
		sepChar = self.cbDelimiter.Text
		#_swf.MessageBox.Show("update column names with sepchar " + sepChar)
		
		ignoreChars = [ '#','%',"'"]
		
		if os.path.exists(self.tbSelectedFile.Text):
						
			result = _CsvUtilities.ReadColumnNamesAsDict(self.tbSelectedFile.Text,self.dummyRowsInput.Value,sepChar)
						
			self.dataColumnsDict = result[0]			
			errorMessage = result[1]
			
			datagridRow = self.dataGridColumnMapping.Rows[0]
			
			if errorMessage <> "":
				if checkDelimiter:			
					_swf.MessageBox.Show(errorMessage,"WaveWindView",_swf.MessageBoxButtons.OK,_swf.MessageBoxIcon.Exclamation)			
				
				#	Empty the set of items of the combobox column
				
				for datagridColumnIndex in range(0,3):
					datagridRow.Cells[datagridColumnIndex].Value = None
					
					datagridComboColumn = self.dataGridColumnMapping.Columns[datagridColumnIndex]					
					datagridComboColumn.Items.Clear()					
			else:
						
				#	Update the set of items of the combobox columns
				
				for datagridColumnIndex in range(0,3):
					datagridRow.Cells[datagridColumnIndex].Value = None
					datagridComboColumn = self.dataGridColumnMapping.Columns[datagridColumnIndex]
					
					datagridComboColumn.Items.Clear()
					
					for columnName in self.dataColumnsDict.keys():
						datagridComboColumn.Items.Add(columnName)
			
	
	
	
	def validate(self, text):
		"""returns T/F whether """
		return not text == "" 
	
	def ClearDatagridWaveClimates(self):
		self.datagridWaveClimates.Rows.Clear()
		self.datagridWaveClimates.Refresh()
	
	def ConfigureDatagridWaveClimates(self, waveClimateTableType):
		if (waveClimateTableType == WaveClimateType.Classes):
			self.datagridWaveClimates.Columns[0].Name = "Height"
			self.datagridWaveClimates.Columns[1].Name = "Period"
			self.datagridWaveClimates.Columns[2].Name = "Direction"
			self.datagridWaveClimates.Columns[3].Name = "Occurence"
			self.datagridWaveClimates.Columns[0].Width = 80
			self.datagridWaveClimates.Columns[1].Width = 80
			self.datagridWaveClimates.Columns[2].Width = 80
			self.datagridWaveClimates.Columns[3].Width = 80	
			
		"""	
		if (waveClimateTableType == WaveClimateType.TimeSeries):
			self.datagridWaveClimates.Columns[0].Name = "Date time"
			self.datagridWaveClimates.Columns[1].Name = "Height"
			self.datagridWaveClimates.Columns[2].Name = "Period"
			self.datagridWaveClimates.Columns[3].Name = "Direction"
			self.datagridWaveClimates.Columns[0].Width = 117
			self.datagridWaveClimates.Columns[1].Width = 80
			self.datagridWaveClimates.Columns[2].Width = 80
			self.datagridWaveClimates.Columns[3].Width = 80			
		"""

	def WaveClimatesToValueList(self):
		list = []
		for climate in self.__scenario.GenericData.Waves.WaveClimates:
			list.append([climate.Hs, climate.Tp, climate.Dir, climate.Occurences])
			
		return list

	def DisplayWaveClimates(self):		
		
		self.ClearDatagridWaveClimates()
		waveType = self.__scenario.GenericData.Waves.Type
		
		#	Set column headers based on wave type
		self.ConfigureDatagridWaveClimates(waveType)
		
		#	Show waveclimates
		if self.__scenario.GenericData.Waves <> None:
			for WaveClimate in self.__scenario.GenericData.Waves.WaveClimates:				
				self.datagridWaves.Rows.Add(WaveClimate.Hs,WaveClimate.Tp,WaveClimate.Dir,WaveClimate.Occurences)
		
		self.datagridWaveClimates.Refresh()
		
		#self.SetControlsForAutomatic(False)
		

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
		if (self.radioImport.Checked and (not self.validate(self.tbSelectedFile.Text) or not self.validate(self.cbDelimiter.Text))):
			return "Required information is missing"

		if self.radioManual.Checked :
			if self.datagridWaveClimates.Rows.Count <= 1 :
				return "Please enter data."
		
			else:
				#check if hs, hl, dir and occ are valid
				if (self.CheckTableValuesAreFloat([0,1,2,3])) == False:
					return "Please enter numeric data."
			
		return ""
	
	def CheckTableValuesAreFloat(self, columnIndices):
		
		maxCheckRow = self.datagridWaveClimates.Rows.Count
		if self.datagridWaveClimates.Enabled == True:
			maxCheckRow = self.datagridWaveClimates.Rows.Count - 1
		
		for i in range(0,maxCheckRow):
			row = self.datagridWaveClimates.Rows[i]
			for cellIndex in columnIndices:
				celwaarde = str(row.Cells[cellIndex].Value)
				
				if (self.is_valid_input(celwaarde) == False):
					return False
		return True
	
	
	
	
	
	def btnClassifyWaves_Click(self,sender,e):
		
		#	Check if a file for import has been selected
		
		if self.tbSelectedFile.Text == None or self.tbSelectedFile.Text == "":
			_swf.MessageBox.Show("Please select a time series file for classification","WaveWindView",_swf.MessageBoxButtons.OK,_swf.MessageBoxIcon.Exclamation)
			return
		
		filePath = self.tbSelectedFile.Text
		
		if os.path.exists(filePath) == False:
			_swf.MessageBox.Show("Please select a valid time series file for classification","WaveWindView",_swf.MessageBoxButtons.OK,_swf.MessageBoxIcon.Exclamation)
			return
		
		
		#	Read the indices of the data columns based on the selected column names
			
		hsValues = []
		tpValues = []
		hsdirValues = []
				
		hsColName = self.dataGridColumnMapping.Rows[0].Cells[0].Value
		hsColIndex = self.dataColumnsDict[hsColName]
		tpColName = self.dataGridColumnMapping.Rows[0].Cells[1].Value
		tpColIndex = self.dataColumnsDict[tpColName]
		hsdirColName = self.dataGridColumnMapping.Rows[0].Cells[2].Value
		hsdirColIndex = self.dataColumnsDict[hsdirColName]
		
		columnIndices = [hsColIndex,tpColIndex,hsdirColIndex]
		
		
		numDummyRows = self.dummyRowsInput.Value
		sepCharacter = self.cbDelimiter.Text		
		
		#	Read the actual data
		waveDataTimeSeriesDict = _CsvUtilities.ReadDataColumnsAsLists(filePath,numDummyRows,sepCharacter,columnIndices)[0]			
			
		#	Show message in label
		self.lblMessage.ForeColor = Color.Green
		self.lblMessage.Text = "Wave data read from csv"
		
					
		#	Classify waves based on lists of data
		
		hsDatalist = waveDataTimeSeriesDict[hsColIndex]
		tpDatalist = waveDataTimeSeriesDict[tpColIndex]
		hsdirDatalist = waveDataTimeSeriesDict[hsdirColIndex]
				
		Hs = _np.array(hsDatalist)			#Wave-heigth [m]
		Tp = _np.array(tpDatalist)			#Wave-period [s]
		dirWave = _np.array(hsdirDatalist)		#Wave direction [deg]
				
		#	Message while processing data
		
		self.lblMessage.ForeColor = Color.Black
		self.lblMessage.Text = "Processing..."
		self.Refresh()
		waveClassTuples = _WaveWindUtils.classifyWaves(Hs,Tp,dirWave)
		
		#(self, waveHeight, wavePeriod, direction, occurences)
		
		#	Reset list of wave climates
		self.__scenario.GenericData.Waves.WaveClimates = []		
		self.__scenario.GenericData.Waves.Type = WaveClimateType.Classes
		
		for waveClassTuple in waveClassTuples:
			waveClimate = _WaveClimate(waveClassTuple[0],waveClassTuple[1],waveClassTuple[2],waveClassTuple[3])
			self.__scenario.GenericData.Waves.WaveClimates.append(waveClimate)
		
		#	Show message in label
		self.lblMessage.ForeColor = Color.Green
		self.lblMessage.Text = "Wave data classified, number of waveclasses: " + str(len(self.__scenario.GenericData.Waves.WaveClimates))		
				
		#	Display waveclimates in datagrid
		
		self.DisplayWaveClimates()
		
		
		
	
	def DisplayWaveClimates(self):
		
		#	Display waveclimates in datagrid			
		if self.__scenario.GenericData.Waves <> None and len(self.__scenario.GenericData.Waves.WaveClimates) > 0:
			for waveClimate in self.__scenario.GenericData.Waves.WaveClimates:
				self.datagridWaveClimates.Rows.Add(waveClimate.Hs,waveClimate.Tp,waveClimate.Dir,waveClimate.Occurences)
		
	
	def btnOK_Click(self):
				
		
		message = self.CheckInputControls()
		if (message != ""):
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = message
			return
		
			
		#	Make sure the last empty row is not read in case the Datagridview is enabled
		maxCheckRow = self.datagridWaveClimates.Rows.Count - 1
		if self.datagridWaveClimates.Enabled == True or self.datagridWaveClimates.AllowUserToAddRows == True:
			maxCheckRow = self.datagridWaveClimates.Rows.Count - 2
		
		
	
		#Store the data (and type) into the from object.
		waves = self.__scenario.GenericData.Waves
		waves.Type = WaveClimateType.Classes
		waves.WaveClimates = []
		
		checkRowIndex = 0
		
		while checkRowIndex <= maxCheckRow:
			datarow = self.datagridWaveClimates.Rows[checkRowIndex]
			climate = _WaveClimate(datarow.Cells[0].Value,datarow.Cells[1].Value,datarow.Cells[2].Value,datarow.Cells[3].Value)			
			waves.WaveClimates.append(climate)
			checkRowIndex += 1
		
		
		#	Message while processing data
		
		self.lblMessage.ForeColor = Color.Green
		self.lblMessage.Text = "Wave data stored in scenario."
		
		#self.DisplayWaveClimates(data, type)

	def btnClear_Click(self, sender, e):
		
		self.tbSelectedFile.Text = ""
		#self.tbHeader.Text = "1"
		self.cbDelimiter.Text = ","
		self.tbDateFormat.Text = "%d-%m-%Y %H:%M"
		self.ClearDatagridWaveClimates()
		self.radioImport.Checked = True
		self.radioImport_Click(sender, e)
		
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

	def radioImport_Click(self, sender, e):
		if self.radioImport.Checked:
			self.SetControlsForAutomatic(True)			
	
	def radioManual_Click(self, sender, e):
		if self.radioManual.Checked:
			self.SetControlsForAutomatic(False)
			
			

	def SetControlsForAutomatic(self, automatic):
		self.radioImport.Checked = automatic
		self.radioManual.Checked = not automatic
		self.tbSelectedFile.Enabled = automatic
		self.btnSelectedFile.Enabled = automatic
		self.cbDelimiter.Enabled = automatic
		self.dummyRowsInput.Enabled = automatic
		self.tbIgnoreValue.Enabled = automatic
		self.dataGridColumnMapping.Enabled = automatic
		self.btnClassifyWaves.Enabled = automatic
		
		#self.tbDateFormat.Enabled = automatic
		#self.cbClassify.Enabled = automatic
		#self.cbInspect.Enabled = automatic
		#	Manual input is not possible		
		self.datagridWaveClimates.Enabled = not automatic
		

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


