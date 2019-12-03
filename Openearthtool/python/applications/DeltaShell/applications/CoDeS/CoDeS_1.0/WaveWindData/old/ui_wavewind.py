#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Jaap de Rue
#
#       jaap.de.rue@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
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
import time
from System import *
from System.Collections.Generic import *
from System.Windows.Forms import OpenFileDialog, Cursor
from System.Windows.Forms import DialogResult
from System.Windows.Forms import MessageBox
from Scripts.UI_Examples.View import *
from System.Drawing import Font as f
from System.Drawing import FontStyle as fs
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
from SharpMap.UI.Tools import MapTool
from GisSharpBlog.NetTopologySuite.Geometries import Envelope
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
import Libraries.FlowFlexibleMeshFunctions as FMFunctions
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from Scripts.WaveWindData.ui_dateformat import *

from Scripts.WaveWindData.input.read_csv import *
from Scripts.WaveWindData.output.write_series import *
from Scripts.WaveWindData.engine.classifyWaves import *
from Scripts.WaveWindData.engine.utils import *

from System.Windows.Forms import TabPage, FormStartPosition
from System.Windows.Forms import DataGridView
#from Scripts.WaveWindData.ui_inspect import *

activeTab = 0
xCoordinate = None
yCoordinate = None
zCoordinate = None

#region functions
def btnSelectedFile_Click(sender, e):
	ofdSelectedFile = OpenFileDialog()
	ofdSelectedFile.Filter = "Comma Seperated Files (*.csv)|*.csv"
	#ofdSelectedFile.Filter = "Text Files (*.txt)|*.txt"
	
	if ofdSelectedFile.ShowDialog() == DialogResult.OK:
		tbSelectedFile.Text = ofdSelectedFile.FileName

def grid_remove_rows_G():
	
	#dgvManual.Rows.Clear()
	for i in range(0,dgvManual.Rows.Count - 1):
		dgvManual.Rows.RemoveAt(0)

def inspect_data(data, type):

	tpManual.Text = "Inspect and edit"
	grid_remove_rows_G()
	if (str(type) == "time series"):
		dgvManual.Columns[0].Name = "Date time"
		dgvManual.Columns[1].Name = "Height"
		dgvManual.Columns[2].Name = "Period"
		dgvManual.Columns[3].Name = "Direction"
		dgvManual.Columns[0].Width = 117
		dgvManual.Columns[1].Width = 117
		dgvManual.Columns[2].Width = 117
		dgvManual.Columns[3].Width = 116
		#=============
		#JOSH ADDITION
		#=============
		#example for "Timeseries Input"
		#import datetime
		#import numpy as np
		#data = [[datetime.datetime(2010,1,1),np.NumpyDotNet.ScalarFloat64(1),2,3],[datetime.datetime(2010,1,2),2,3,4]]
		for row in data:
			row = convert_list(row)
			dgvManual.Rows.Add(row[0],row[1],row[2],row[3])
		
	if (str(type) == "class"):
		dgvManual.Columns[0].Name = "Height"
		dgvManual.Columns[1].Name = "Period"
		dgvManual.Columns[2].Name = "Direction"
		dgvManual.Columns[3].Name = "Occurence"
		dgvManual.Columns[0].Width = 117
		dgvManual.Columns[1].Width = 117
		dgvManual.Columns[2].Width = 117
		dgvManual.Columns[3].Width = 116
		#=============
		#JOSH ADDITION
		#=============
		#example for "Class Input"
		#data = [[1,2,3,4],[2,4,6,8],[3,6,9,12]]
		#temp = [row[:-1] + [round(row[-1],2)] for row in data]
		for row in data:
			row = convert_list(row)
			dgvManual.Rows.Add(row[0],row[1],row[2],round(row[3],2))
			
	tcWaveData.SelectedIndex = 1

def validate(text):
	"""returns T/F whether """
	if(text == ""):
		return False
	else:
		return True

def btnOKAuto_Click(frm):
	
	#By default, the data type is time series
	type = "time series"
	
	if(not validate(tbSelectedFile.Text) or not validate(tbHeader.Text) or not validate(tbDelimiter.Text) or not validate(tbDateFormat.Text)):
		#Some message if no text is given
		lblMessage.ForeColor = Color.Red
		lblMessage.Text = "Required information is missing."
		
	else:
		#Some message while processing data
		lblMessage.ForeColor = Color.Black
		lblMessage.Text = "PROCESSING ... "
		frmWaveData.Refresh()

		# retrieve values as filled in by user (using label name)
		fileName = tbSelectedFile.Text
		headerRow = int(tbHeader.Text)
		delimiter = tbDelimiter.Text
		dtFormat = tbDateFormat.Text
		classify = cbClassify.Checked
		inspect = cbInspect.Checked
		
		#Read the actual data
		data = read_csv(fileName, headerRow, delimiter, dtFormat)
		
		if classify:
			#If the data should be classified: call classifyWaves, 
			#and overwrite the original data with waveclass-data 
			type = "class"			#Flag to know which type of data is present
			Hs = np.array(column(data, 1))			#Wave-heigth [m]
			Tp = np.array(column(data, 2))			#Wave-period [s]
			dirWave = np.array(column(data, 3))		#Wave direction [deg]
			data = classifyWaves(Hs, Tp, dirWave)
		
		
		#Return some message after processing data
		lblMessage.ForeColor = Color.Green
		lblMessage.Text = "DONE!"
		frmWaveData.Refresh()
		
		#Store the data (and type) into the from object.
		frm.Data = data
		frm.Type = type
		
		if inspect:
			inspect_data(data, type)
		else:
			time.sleep(0.5)
			frmWaveData.Close()
			frmWaveData.DialogResult = DialogResult.OK

def is_valid_input(input):
	""" If the input is convertible to float, than in is valid. """
	try:
		float(input)
	except:
		return 1
	return 0

def btnOKManual_Click(frm):
	
	data = []
	nrOfErrors = 0

	if (dgvManual.Rows.Count > 1):
	
		lblMessage.ForeColor = Color.Green
		lblMessage.Text = "PROCESSING .. "
		frmWaveData.Refresh()

		if (dgvManual.Columns[0].Name == "Date time"):
			type = "time series"
			for i in range(0,dgvManual.Rows.Count - 1):
				#check if hs, hl and dir are valid
				nrOfErrors += is_valid_input(dgvManual.Rows[i].Cells[1].Value) + is_valid_input(dgvManual.Rows[i].Cells[2].Value) + is_valid_input(dgvManual.Rows[i].Cells[3].Value)
				if (nrOfErrors == 0):
					dt = dgvManual.Rows[i].Cells[0].Value
					wh = float(dgvManual.Rows[i].Cells[1].Value)
					wl = float(dgvManual.Rows[i].Cells[2].Value)
					dir = float(dgvManual.Rows[i].Cells[3].Value)
					data.append([dt, wh, wl, dir])
			
		else:
			type = "class"
			for i in range(0,dgvManual.Rows.Count - 1):
				#check if hs, hl, dir and occ are valid
				nrOfErrors += is_valid_input(dgvManual.Rows[i].Cells[0].Value) + is_valid_input(dgvManual.Rows[i].Cells[1].Value) + is_valid_input(dgvManual.Rows[i].Cells[2].Value) + is_valid_input(dgvManual.Rows[i].Cells[3].Value)
				if (nrOfErrors == 0):
					wh = float(dgvManual.Rows[i].Cells[0].Value)
					wl = float(dgvManual.Rows[i].Cells[1].Value)
					dir = float(dgvManual.Rows[i].Cells[2].Value)
					occ = float(dgvManual.Rows[i].Cells[3].Value)
					data.append([wh, wl, dir, occ])

		if (nrOfErrors == 0):
			lblMessage.ForeColor = Color.Green
			lblMessage.Text = "DONE!"
			frmWaveData.Refresh()
			time.sleep(0.5)
			frmWaveData.Close()
			frmWaveData.DialogResult = DialogResult.OK
	
			frm.Data = data
			frm.Type = type
			
		else:
		
			lblMessage.ForeColor = Color.Red
			lblMessage.Text = "Data incomplete or invalid."
			frmWaveData.Refresh()		

	else:
		
		lblMessage.ForeColor = Color.Red
		lblMessage.Text = "No data entered."
		frmWaveData.Refresh()		

def btnCancel_Click(sender, e):
	
	frmWaveData.Visible = False

class AddPointMapTool(MapTool):
	def __init__(self):
		self.Layer = None
		self.x = None
		self.y = None
		self.FunctionToExecute = None
	
	def OnMouseDown(self, worldPosition, e):
		if (self.Layer == None):
			return
		
		self.x = worldPosition.X
		self.y = worldPosition.Y
		self.FunctionToExecute(self.x, self.y)
		self.Layer.DataSource.Features.Clear()
		self.Layer.DataSource.Add(Feature(Geometry = CreatePointGeometry(worldPosition.X, worldPosition.Y)))
		self.Layer.RenderRequired = True

def SetTbCoordinatesText(x,y,textbox):
	
	global xCoordinate, yCoordinate, zCoordinate
	
	xCoordinate = x
	yCoordinate = y
	
	Locatie = _Coordinate()
	Locatie.X = xCoordinate
	Locatie.Y = yCoordinate
	GebcoExtract = FMFunctions.GetGebcoBathymetryData(x,y,x,y,3857)

	# Get z from GEBCO
	zCoordinate = FMFunctions.GetGebcoBathymetryValueFor(Locatie,3857,GebcoExtract)
	textbox.Text = "X: " + str(round(xCoordinate,0)) + " Y: " + str(round(yCoordinate,0)) + " Z: " + str(round(zCoordinate,0)) + " MTR."
	textbox.BackColor = Color.Tomato
	
	btnCoordinates.Enabled = True

def setActiveTab(sender, e):
	
	global activeTab
	
	if (tcWaveData.SelectedTab.TabIndex < 2):
		
		activeTab = tcWaveData.SelectedTab.TabIndex
	
	elif (tcWaveData.SelectedTab.TabIndex == 2):
		
		map.MapControl.Focus()
		
def btnCoordinates_Click(frm):
	
	global activeTab, xCoordinate, yCoordinate, zCoordinate
	
	frm.X = xCoordinate
	frm.Y = yCoordinate
	frm.Z = zCoordinate
	tbCoordinates.BackColor = Color.White
	btnCoordinates.Enabled = False

	tcWaveData.SelectedIndex = activeTab

def showDateFormats(sender, e):
	
	frmDateTime.StartPosition = FormStartPosition.Manual
	frmDateTime.Location = Cursor.Position
	frmDateTime.Show()

#endregion

class WaveDataForm(Form):
	def __init__(self):
		self.Data = None
		self.Type = None
		self.X = None
		self.Y = None
		self.Z = None
		self.epsg = 3857

frmWaveData = WaveDataForm()
frmWaveData.Width = 580
frmWaveData.Height = 370
frmWaveData.Text="Import wave data"

lblMessage = Label()
lblMessage.Top = 10
lblMessage.Left = 20
lblMessage.Width = 520
lblMessage.Font = f(lblMessage.Font.FontFamily, lblMessage.Font.Size, fs.Bold)

lblCoordinates = Label()
lblCoordinates.Top = 301
lblCoordinates.Left = 34
lblCoordinates.Width = 115
lblCoordinates.Text = "Selected coordinates:"
lblCoordinates.Visible = True

tbCoordinates = TextBox()
tbCoordinates.Top = 300
tbCoordinates.Left = 160
tbCoordinates.Width = 250
tbCoordinates.Enabled = False

btnCoordinates = Button()
btnCoordinates.Top = 299
btnCoordinates.Left = 419
btnCoordinates.Width = 100
btnCoordinates.Enabled = False
btnCoordinates.Text = "Confirm point"
btnCoordinates.Click += lambda s,e : btnCoordinates_Click(frmWaveData)

tcWaveData = TabControl()
tcWaveData.Top = 30
tcWaveData.Left = 20
tcWaveData.Width = 520
tcWaveData.Height = 260
tcWaveData.SelectedIndexChanged += setActiveTab

#region auto_import
tpAuto = TabPage()
tpAuto.Text = "File import"
tpAuto.Width = 300
tpAuto.Height = 100

lblSelectedFile = Label()
lblSelectedFile.Top = 10
lblSelectedFile.Left = 10
lblSelectedFile.Width = 150
lblSelectedFile.Text = "Select input file"

tbSelectedFile = TextBox()
tbSelectedFile.Top = 10
tbSelectedFile.Left = 180
tbSelectedFile.Width = 150

btnSelectedFile = Button()
btnSelectedFile.Text = "Browse file"
btnSelectedFile.Top = 10
btnSelectedFile.Left = 340
btnSelectedFile.Click += btnSelectedFile_Click

lblHeader = Label()
lblHeader.Top = 40
lblHeader.Left = 10
lblHeader.Width = 150
lblHeader.Text = "Number of rows in header:"

tbHeader = TextBox()
tbHeader.Top = 40
tbHeader.Left = 180
tbHeader.Width = 150
tbHeader.Text = "1"

lblDelimiter = Label()
lblDelimiter.Top = 70
lblDelimiter.Left = 10
lblDelimiter.Width = 150
lblDelimiter.Text = "Field delimiter:"

tbDelimiter = TextBox()
tbDelimiter.Top = 70
tbDelimiter.Left = 180
tbDelimiter.Width = 150
tbDelimiter.Text = ";"

lblDateFormat = Label()
lblDateFormat.Top = 100
lblDateFormat.Left = 10
lblDateFormat.Width = 150
lblDateFormat.Text = "Date-time format:"

tbDateFormat = TextBox()
tbDateFormat.Top = 100
tbDateFormat.Left = 180
tbDateFormat.Width = 150
tbDateFormat.Text = "%Y/%m/%d %H:%M:%S"

lblShowDateFormats = Label()
lblShowDateFormats.Top = 100
lblShowDateFormats.Left = 340
lblShowDateFormats.Width = 40
lblShowDateFormats.Text = "?"
lblShowDateFormats.Font = f(lblMessage.Font.FontFamily, 12, fs.Bold)
lblShowDateFormats.MouseHover += showDateFormats

lblClassify = Label()
lblClassify.Top = 130
lblClassify.Left = 10
lblClassify.Width = 150
lblClassify.Text = "Classify data:"

cbClassify = CheckBox()
cbClassify.Top = 130
cbClassify.Left = 180

lblInspect = Label()
lblInspect.Top = 160
lblInspect.Left = 10
lblInspect.Width = 150
lblInspect.Text = "Inspect data after import:"

cbInspect = CheckBox()
cbInspect.Top = 160
cbInspect.Left = 180

btnOK = Button()
btnOK.Text = "OK"
btnOK.Top = 190
btnOK.Left = 340
btnOK.Click += lambda s,e : btnOKAuto_Click(frmWaveData)

btnCancel = Button()
btnCancel.Text = "Cancel"
btnCancel.Top = 190
btnCancel.Left = 420
btnCancel.Click += btnCancel_Click

tpAuto.Controls.Add(lblSelectedFile)
tpAuto.Controls.Add(tbSelectedFile)
tpAuto.Controls.Add(btnSelectedFile)
tpAuto.Controls.Add(lblHeader)
tpAuto.Controls.Add(tbHeader)
tpAuto.Controls.Add(lblDelimiter)
tpAuto.Controls.Add(tbDelimiter)
tpAuto.Controls.Add(lblDateFormat)
tpAuto.Controls.Add(tbDateFormat)
tpAuto.Controls.Add(lblShowDateFormats)
tpAuto.Controls.Add(lblClassify)
tpAuto.Controls.Add(cbClassify)
tpAuto.Controls.Add(lblInspect)
tpAuto.Controls.Add(cbInspect)
tpAuto.Controls.Add(btnOK)
tpAuto.Controls.Add(btnCancel)
#endregion

#region manual_input
tpManual = TabPage()
tpManual.Text = "Manual input"

dgvManual = DataGridView()
dgvManual.AutoGenerateColumns = False
#such that it fits nicely into the wavewind-GUI
dgvManual.Width = 510
dgvManual.Height = 170
dgvManual.ColumnCount = 4
dgvManual.Columns[0].Name = "Height"
dgvManual.Columns[0].Width = 117
dgvManual.Columns[1].Name = "Period"
dgvManual.Columns[1].Width = 117
dgvManual.Columns[2].Name = "Direction"
dgvManual.Columns[2].Width = 117
dgvManual.Columns[3].Name = "Occurence"
dgvManual.Columns[3].Width = 116

btnOKManual = Button()
btnOKManual.Text = "OK"
btnOKManual.Top = 190
btnOKManual.Left = 340
btnOKManual.Click +=  lambda s,e : btnOKManual_Click(frmWaveData)

btnCancelManual = Button()
btnCancelManual.Text = "Cancel"
btnCancelManual.Top = 190
btnCancelManual.Left = 420
btnCancelManual.Click += btnCancel_Click

tpManual.Controls.Add(dgvManual)
tpManual.Controls.Add(btnOKManual)
tpManual.Controls.Add(btnCancelManual)
#endregion

#region location selection
tpLocation = TabPage()
tpLocation.Text = "Location selection"
tpLocation.Width = 300
tpLocation.Height = 130

tool = AddPointMapTool()
tool.FunctionToExecute = lambda x,y : SetTbCoordinatesText(x,y,tbCoordinates)

featureLayer = CreateLayerForFeatures("Points",[],None)
tool.Layer = featureLayer

map = MapView()
map.Dock = DockStyle.Fill
osmlLayer = OSML()
map.Map.Layers.AddRange([featureLayer, osmlLayer])
map.Map.ZoomToFit(Envelope(-31756.2409618447, 1453795.19199705, 6574369.24871948, 7166268.64778904))

map.MapControl.SelectTool.IsActive = False
map.MapControl.Tools.Add(tool)
tool.IsActive = True

tpLocation.Controls.Add(map)

#endregion

tcWaveData.TabPages.Add(tpAuto)
tcWaveData.TabPages.Add(tpManual)
tcWaveData.TabPages.Add(tpLocation)

frmWaveData.Controls.Add(tcWaveData)
frmWaveData.Controls.Add(lblMessage)
frmWaveData.Controls.Add(lblCoordinates)
frmWaveData.Controls.Add(tbCoordinates)
frmWaveData.Controls.Add(btnCoordinates)

#=============
#JOSH TESTING!
#=============

#frmWaveData.ShowDialog()