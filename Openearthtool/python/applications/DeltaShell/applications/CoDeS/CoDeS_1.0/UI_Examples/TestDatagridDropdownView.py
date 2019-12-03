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
import os

clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf
from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Utilities.WaveWindUtils as _waveWindUtils

from Scripts.GeneralData.Utilities import CsvUtilities as _CsvUtilities
import numpy as _np

import datetime

#datum = datetime.datetime(year = 2017,month = 3,day = 20,hour = 10)
#print datum

class TestView(BaseView):
	def __init__(self):
		BaseView.__init__(self)


		#self.dataPath = r"C:\Projecten\Coastal Design Toolbox\Develop\ToolboxContent\Scripts\WaveWindData\testdata\Sea.dat"
		self.dataPath = r"C:\Projecten\Coastal Design Toolbox\Develop\ToolboxContent\Scripts\WaveWindData\testdata\Sea2.dat"
		
		self.tbPreview = _swf.RichTextBox()
		self.tbPreview.Top = 5
		self.tbPreview.Left = 5
		self.tbPreview.Width = 500
		self.tbPreview.Height = 250
		self.tbPreview.ReadOnly = True
		self.tbPreview.WordWrap = False
		self.tbPreview.ScrollBars = _swf.RichTextBoxScrollBars.Horizontal
		#self.tbPreview.Dock = _swf.DockStyle.Top
		
		_CsvUtilities.PreviewFileInTextbox(self.dataPath,self.tbPreview)
		
		
		self.dummyRowsInput = _swf.NumericUpDown()
		self.dummyRowsInput.Minimum = 0  
		self.dummyRowsInput.Increment = 1 
		self.dummyRowsInput.Value = 5
		self.dummyRowsInput.Dock = _swf.DockStyle.Bottom
		
		self.dummyRowsInput.ValueChanged += lambda s,e : self.UpdateDataColumnNames()
		
		#	Button
		self.btnOK = _swf.Button()
		self.btnOK.Text = "OK"
		self.btnOK.Top = 200
		self.btnOK.Left = 100
		self.btnOK.Width = 100
		self.btnOK.Click += lambda s,e : self.btnOK_Click()
		self.btnOK.Dock = _swf.DockStyle.Bottom
		
		
		#	 Define column names (which will be linked to properties of the Waveclimate)
				
		self.propertyDict = dict()
		
		self.propertyDict[0] = "Wave height"
		self.propertyDict[1] = "Wave period"
		self.propertyDict[2] = "Wave direction"
		#self.propertyDict[3] = "Year"
		#self.propertyDict[4] = "Month"
		#self.propertyDict[5] = "Day"
		#self.propertyDict[6] = "Hour"
		
		self.dataGridColumnMapping = _swf.DataGridView()
		
		for columnIndex in range(0,len(self.propertyDict)):
			self.dataGridColumnMappingComboColumn = _swf.DataGridViewComboBoxColumn()
			self.dataGridColumnMappingComboColumn.Name = self.propertyDict[columnIndex]	
			self.dataGridColumnMapping.Columns.Add(self.dataGridColumnMappingComboColumn)			
		
		
		self.dataGridColumnMapping.Rows.Add()
		self.dataGridColumnMapping.AllowUserToAddRows = False
		self.dataGridColumnMapping.Dock = _swf.DockStyle.Bottom
		self.dataGridColumnMapping.Height = 50
		
		self.UpdateDataColumnNames()
		
		
		# Add control to left panel
		self.leftPanel.Controls.Add(self.dataGridColumnMapping)
		self.leftPanel.Controls.Add(self.btnOK)
		self.leftPanel.Controls.Add(self.tbPreview)
		self.leftPanel.Controls.Add(self.dummyRowsInput)
		self.SetScrollBarsLeftPanel(20)

	
	
	def UpdateDataColumnNames(self):
		ignoreChars = [ '#','%',"'"]
		self.dataColumnsDict = dict()
		
		headerRowNr = self.dummyRowsInput.Value +1
		# open file
		with open(self.dataPath,'r') as datafile:
			
			regelIndex = 1
			for x in range(0, headerRowNr):
				regel = datafile.readline()			
				regelIndex += 1
			
			#	First try splitting with tab
			columnNames = regel.split('\t')			
			
			#	If no result, split with space
			
			if len(columnNames) == 1:
				columnNames = regel.split(' ')
			print columnNames			
			
			k = 0
			for colIndex in range(0,len(columnNames)):
				if columnNames[colIndex] not in ignoreChars:
					self.dataColumnsDict[columnNames[colIndex]] = k
					k+=1
					
		print self.dataColumnsDict
		
		#	Update the items of the combobox columns
		
		for datagridColumnIndex in range(0,3):
			datagridComboColumn = self.dataGridColumnMapping.Columns[datagridColumnIndex]
			
			datagridComboColumn.Items.Clear()
			
			for columnName in self.dataColumnsDict.keys():
				datagridComboColumn.Items.Add(columnName)
		
	
	def btnOK_Click(self):
		
		
		#_swf.MessageBox.Show("Clicked")
		
		#print self.dataColumnsDict
		#
		#for key in self.dataColumnsDict.keys():
		#	print("Key = " + str(key))
		#	print("Value = " + str(self.dataColumnsDict[key]))
				
				
		hsValues = []
		tpValues = []
		hsdirValues = []
				
		hsColName = self.dataGridColumnMapping.Rows[0].Cells[0].Value
		hsColIndex = self.dataColumnsDict[hsColName]
		tpColName = self.dataGridColumnMapping.Rows[0].Cells[1].Value
		tpColIndex = self.dataColumnsDict[tpColName]
		hsdirColName = self.dataGridColumnMapping.Rows[0].Cells[2].Value
		hsdirColIndex = self.dataColumnsDict[hsdirColName]
		
		numberOfDataColumns = len(self.dataColumnsDict)
		
		with open(self.dataPath,'r') as datafile:
			regelIndex = 1
			
			#	Skip header
			for x in range(0, self.dummyRowsInput.Value):
				regel = datafile.readline()
				
			#	Show some data
			while regel <> None and regel <> "":
				regel = datafile.readline()
				dataEntries = regel.split('\t')
				
				#print dataEntries
				
				if len(dataEntries) == numberOfDataColumns:
					if (dataEntries[hsColIndex] == "NaN" or dataEntries[tpColIndex] == "NaN" or dataEntries[hsdirColIndex] == "NaN") == False: 
						hsValues.append(round(float(dataEntries[hsColIndex]),2))
						tpValues.append(round(float(dataEntries[tpColIndex]),2))
						hsdirValues.append(round(float(dataEntries[hsdirColIndex]),2))	
		
		#_swf.MessageBox.Show(str(hsValues[0:10]))
		
		
		Hs = _np.array(hsValues)			#Wave-heigth [m]
		Tp = _np.array(tpValues)			#Wave-period [s]
		dirWave = _np.array(hsdirValues)		#Wave direction [deg]
		waveClasses = _waveWindUtils.classifyWaves(Hs,Tp,dirWave)
		
		print("Number of waveclasses: " + str(len(waveClasses)))
		
		for waveClass in waveClasses:
			print waveClass
		
		_swf.MessageBox.Show(str("Klaar!"))
	


testView = TestView()
testView.Show()	


_swf.NumericUpDown.ValueChanged