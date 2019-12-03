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
#Tide Tool SHELL (run me!)
#========================
#JFriedman Mar. 11, 2015
#========================

#========================
#load necessary libraries
#========================

#region load libraries
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
from Scripts.UI_Examples.View import *
from datetime import datetime
import System.Drawing as s
import Scripts.TidalData as td
from Libraries.MapFunctions import *
#endregion

#========================
#define the label SPACING
#========================

sp_loc = 5 #start point/location for labels (from left edge)
label_width = 150 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 40 #vertical spacing between labels (from previous)

#================================================
#define VARIABLES that are needed in subfunctions
#================================================
stats = {}
cons = {}
counter = 0 #dynamic name of new windows

#==================
#first define VIEWS
#==================

def SetValue(object, propertyName, value):
	script = "object." + propertyName + "=value"
	exec(script)

def GetValue(object, propertyName):
	script = "object." + propertyName
	return eval(script)

class InputData(object):
	def __init__(self):
		self.ProjectName = ""
		self.WorkingDir = ""
		self.SourceType = "WPS"
		self.Lat = 0.0
		self.Long = 0.0
		
	def Clone(self):
		clone = InputData()
		clone.ProjectName = self.ProjectName
		clone.WorkingDir = self.WorkingDir
		clone.SourceType = self.SourceType
		clone.Lat = self.Lat
		clone.Long = self.Long
		
		return clone

class OutputView(View):
	
	def __init__(self, inputData):
		View.__init__(self)
		self.InputData = inputData
		self.Text = "Output"
		
		inputGroup = CreateInputDataGroupBox(self.InputData)
		self.Controls.Add(inputGroup)

class InputView(View):
	
	def __init__(self, inputdata):
		View.__init__(self)
		self.InputData = inputdata
		self.Text = "Tide Input"
		
		map = MapView() #empty map view
		map.Dock = DockStyle.Fill #fill the space
		map.Map.Layers.Add(CreateSatelliteImageLayer())
		
		group_MAP = GroupBox()
		group_MAP.Text = "Map View"
		group_MAP.Font = s.Font(group_MAP.Font.FontFamily, 10)
		group_MAP.Dock = DockStyle.Fill
		
		inputGroup = CreateInputDataGroupBox(self.InputData)
		self.Controls.Add(inputGroup)

def CreateInputLabelAndTextBox(containerControl, labelName, dataobject, propertyName, verticalOffset):
	label = Label()
	label.Text = labelName
	label.Location = s.Point(sp_loc,verticalOffset)
	label.Width = label_width
	containerControl.Controls.Add(label)
	
	textbox = TextBox()
	textbox.Text = GetValue(dataobject,propertyName)
	textbox.Location = s.Point(label_width+spacer_width,verticalOffset)
	textbox.Width = label_width
	textbox.TextChanged += lambda s,e : SetValue(dataobject,propertyName, textbox.Text)
	
	containerControl.Controls.Add(textbox)

def CreateInputDataGroupBox(inputData):
	group_IN = GroupBox()
	group_IN.Text = "Input"
	group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
	group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
	group_IN.Dock = DockStyle.Left
		
	CreateInputLabelAndTextBox(group_IN, "Project Location:", inputData, "ProjectName", vert_spacing)
	CreateInputLabelAndTextBox(group_IN, "Working Directory:", inputData, "WorkingDir", vert_spacing * 2)
	
	return group_IN
	
inputData = InputData()
inputData.ProjectName = "JJJ2"
inputData.WorkingDir = r"d:\friedman\Desktop\Current Work\CoDeS\DeltaShell\plugins\DeltaShell.Plugins.Toolbox\Scripts\TidalData\WORKING_DIR"

inputView = InputView(inputData)
inputView.Show()

inputDataClone = inputData.Clone()
outputView = OutputView(inputDataClone)
outputView.Show()

#region add global INPUT
view_IN = View() #build INPUT view window
view_IN.Text = "Tide Input"
#endregion

#region add MAP/CHART views
plot = ChartView() #empty chart view
plot.Dock = DockStyle.Fill #fill the space

map = MapView() #empty map view
map.Dock = DockStyle.Fill #fill the space
map.Map.Layers.Add(CreateSatelliteImageLayer())
#endregion

#===================================
#define the TABCONTROL (output view)
#===================================

#add PLOT/STATS tabs
def BuildTabs(plot,B2,STATS,B3):
	tab_holder = TabControl() #overview "holder"
	tab_holder.Dock = DockStyle.Fill #fill the space
	
	tab_PLOT = TabPage() #for the plot
	tab_PLOT.Text = "Timeseries Plot"
	tab_PLOT.Controls.Add(plot)
	tab_PLOT.Controls.Add(B2)
	
	tab_STATS = TabPage() #for the output stats
	tab_STATS.Text = "Tide Statistics"
	tab_STATS.Controls.Add(STATS)
	tab_STATS.Controls.Add(B3)
	
	#add the tabs to the "holder"
	tab_holder.Controls.Add(tab_PLOT)
	tab_holder.Controls.Add(tab_STATS)
	return tab_holder

#==============================
#define the general GROUP BOXES
#==============================

#region build INPUT group box
group_IN = GroupBox()
group_IN.Text = "Input"
group_IN.Font = s.Font(group_IN.Font.FontFamily, 10)
group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
group_IN.Dock = DockStyle.Left
#endregion

#build FROZEN INPUT group box
def BuildFrozenInput():
	group_FROZEN_IN = GroupBox()
	group_FROZEN_IN.Text = "Chosen Input"
	group_FROZEN_IN.Font = s.Font(group_FROZEN_IN.Font.FontFamily, 10)
	group_FROZEN_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
	group_FROZEN_IN.Dock = DockStyle.Left
	return group_FROZEN_IN

#region build MAP group box
group_MAP = GroupBox()
group_MAP.Text = "Map View"
group_MAP.Font = s.Font(group_MAP.Font.FontFamily, 10)
group_MAP.Dock = DockStyle.Fill
#endregion

#build OUTPUT group box
def BuildOutput(plot,B2,STATS,B3):
	group_OUTPUT = GroupBox()
	group_OUTPUT.Text = "Output"
	group_OUTPUT.Font = s.Font(group_OUTPUT.Font.FontFamily, 10)
	group_OUTPUT.Dock = DockStyle.Fill
	tab_holder = BuildTabs(plot,B2,STATS,B3)
	group_OUTPUT.Controls.Add(tab_holder)
	return group_OUTPUT

#======================================
#define INPUT (i.e. labels + textboxes)
#======================================

#region get project name
L1a = Label()
L1a.Text = "Project Location:"
L1a.Location = s.Point(sp_loc,vert_spacing)
L1a.Width = label_width

L1b = TextBox()
L1b.Text = "JJJ" #default name
L1b.Location = s.Point(label_width+spacer_width,vert_spacing)
L1b.Width = label_width
#endregion

#region get working directory
L2a = Label()
L2a.Text = "Working Directory:"
L2a.Location = s.Point(sp_loc,2*vert_spacing)
L2a.Width = label_width

button_size = 25
L2b = TextBox()
L2b.Text = r"d:\friedman\Desktop\Current Work\CoDeS\DeltaShell\plugins\DeltaShell.Plugins.Toolbox\Scripts\TidalData\WORKING_DIR" #default name
L2b.Location = s.Point(label_width+spacer_width,2*vert_spacing)
L2b.Width = label_width - button_size

L2c = Button()
L2c.BackColor = Color.DarkGray
L2c.Text = "..."
L2c.Location = s.Point(label_width+spacer_width + label_width - button_size,2*vert_spacing)
L2c.Width = button_size

#endregion

#region pick data source
L3a = Label()
L3a.Text = "Data Source:"
L3a.Location = s.Point(sp_loc,3*vert_spacing)
L3a.Width = label_width

L3b = ListBox()
L3b.Items.Add("WPS")
L3b.Items.Add("Timeseries")
L3b.Height = 50
L3b.Location = s.Point(label_width+spacer_width,3*vert_spacing)
L3b.Width = label_width
#get choice at end!
#endregion

#region pick filename (CONDITIONAL!)
L4a = Label()
L4a.Text = "Input File [ascii]:"
L4a.Location = s.Point(sp_loc,4.5*vert_spacing)
L4a.Width = label_width

L4b = TextBox()
L4b.Text = "WL_input.txt" #default name
L4b.Location = s.Point(label_width+spacer_width,4.5*vert_spacing)
L4b.Width = label_width
#get choice at end!
#endregion

#region pick latitude (CONDITIONAL!)
L5a = Label()
L5a.Text = "Latitude [deg]:"
L5a.Location = s.Point(sp_loc,4.5*vert_spacing)
L5a.Width = label_width

L5b = NumericUpDown()
L5b.DecimalPlaces = 2 #for textbox
L5b.TextAlign = HorizontalAlignment.Right
L5b.Increment = 0.1 #for increment with dir keys
L5b.Maximum = 90 #max bounds
L5b.Minimum = -90 #min bounds
L5b.Location = s.Point(label_width+spacer_width,4.5*vert_spacing)
L5b.Width = label_width
L5b.Value = 54 #default number
#get choice at end!
#endregion

#region pick longitude (CONDITIONAL!)
L6a = Label()
L6a.Text = "Longitude [deg]:"
L6a.Location = s.Point(sp_loc,5.5*vert_spacing)
L6a.Width = label_width

L6b = NumericUpDown()
L6b.DecimalPlaces = 2
L6b.TextAlign = HorizontalAlignment.Right
L6b.Increment = 0.1 #for increment with dir keys
L6b.Maximum = 180 #max bounds
L6b.Minimum = -180 #min bounds
L6b.Location = s.Point(label_width+spacer_width,5.5*vert_spacing)
L6b.Width = label_width
L6b.Value = 4 #default number
#get choice at end!
#endregion

#region pick start time (CONDITIONAL!)
L7a = Label()
L7a.Text = "Start Time:"
L7a.Location = s.Point(sp_loc,6.5*vert_spacing)
L7a.Width = label_width

L7b = DateTimePicker()
L7b.Location = s.Point(label_width+spacer_width,6.5*vert_spacing)
L7b.Width = label_width
L7b.Format = DateTimePickerFormat.Custom
L7b.CustomFormat = "yyyy-MM-dd"
L7b.Text = "2015-01-01" #default start date
#get choice at end!
#endregion

#region pick end time (CONDITIONAL!)
L8a = Label()
L8a.Text = "End Time:"
L8a.Location = s.Point(sp_loc,7.5*vert_spacing)
L8a.Width = label_width

L8b = DateTimePicker()
L8b.Location = s.Point(label_width+spacer_width,7.5*vert_spacing)
L8b.Width = label_width
L8b.Format = DateTimePickerFormat.Custom
L8b.CustomFormat = "yyyy-MM-dd"
#get choice at end!
#endregion

#=======================
#define required BUTTONS
#=======================

#region build "trigger" button
B1 = Button()
B1.Location = s.Point(label_width/1.75,8.5*vert_spacing)
B1.Text = "Confirm Selection"
B1.Height = label_width/2
B1.Width = label_width*1.1
#endregion

#region build "print" button
B2 = Button()
B2.Dock = DockStyle.Bottom
B2.Text = "Print Plots"
B2.Height = vert_spacing
#endregion

#region build "export" button
B3 = Button()
B3.Dock = DockStyle.Bottom
B3.Text = "Export Statistics"
B3.Height = vert_spacing
#endregion

#=====================
#define STATUS textbox
#=====================

#region build status textbox
S1 = RichTextBox()
S1.Text = "Awaiting User Input..."
S1.Location = s.Point(1.5*spacer_width,11*vert_spacing)
S1.Height = 3*vert_spacing
S1.Width = 2*label_width
S1.BackColor = Color.LightGray
S1.ForeColor = Color.Red
S1.Font = s.Font(S1.Font,s.FontStyle.Italic)
#endregion

#=======================
#define STATISTICS table
#=======================

#region build constituents table
STATS = DataGridView()
STATS.Dock = DockStyle.Fill
STATS.ColumnCount = 3
STATS.RowCount = 1
STATS.ColumnHeadersHeight = 50
STATS.Columns[0].Name = "Constituent Name"
STATS.Columns[1].Name = "Amplitude [m]"
STATS.Columns[2].Name = "Phase [deg]"
"""STATS.CurrentCell = False"""
"""STATS.DefaultCellStyle.SelectionBackColor = Color.White"""
STATS.ForeColor = Color.Red
STATS.Font = s.Font(STATS.Font,s.FontStyle.Bold)
STATS.Font = s.Font(STATS.Font.FontFamily, 10)
STATS.ReadOnly = True
STATS.Enabled = False #don't allow the user to touch the table
STATS.AllowUserToAddRows = False
STATS.RowHeadersVisible = False

"""test = View()
test.Controls.Add(STATS)
test.Show()"""
#endregion

#=============
#GUI functions
#=============

#"pick data source" function
def PickDataSource(sender, e):
	
	if L3b.SelectedItem == "WPS": #add/delete the right boxes
		if group_IN.Controls.Contains(L4a): #check to see if boxes exist, if so - remove them
			group_IN.Controls.Remove(L4a)
			group_IN.Controls.Remove(L4b)
		group_IN.Controls.Add(L5a)
		group_IN.Controls.Add(L5b)
		group_IN.Controls.Add(L6a)
		group_IN.Controls.Add(L6b)
		group_IN.Controls.Add(L7a)
		group_IN.Controls.Add(L7b)
		group_IN.Controls.Add(L8a)
		group_IN.Controls.Add(L8b)
	if L3b.SelectedItem == "Timeseries": #add/delete the right boxes
		group_IN.Controls.Add(L4a)
		group_IN.Controls.Add(L4b)
		if group_IN.Controls.Contains(L5a): #check to see if boxes exist, if so - remove them
			group_IN.Controls.Remove(L5a)
			group_IN.Controls.Remove(L5b)
			group_IN.Controls.Remove(L6a)
			group_IN.Controls.Remove(L6b)
			group_IN.Controls.Remove(L7a)
			group_IN.Controls.Remove(L7b)
			group_IN.Controls.Remove(L8a)
			group_IN.Controls.Remove(L8b)

#"trigger" output function
def OutputTrigger(sender, e):
	#get final choice for input
	location = L1b.Text
	work_dir = L2b.Text
	choice = L3b.SelectedItem 
	if choice == "WPS":
		lat = L5b.Value
		lon = L6b.Value
		sdate = L7b.Value.Date
		edate = L8b.Value.Date
		plot,B2,STATS,B3 = run_WPS(lat,lon,sdate,edate,location)
	if choice == "Timeseries":
		fname = L4b.Text
		plot,B2,STATS,B3 = run_TS(fname,work_dir,location)
	
	#build the output view
	view_OUT = View() #build OUTPUT view window
	global counter
	counter += 1
	view_OUT.Text = "Tide Output (%02d)" %counter
	group_OUTPUT = BuildOutput(plot,B2,STATS,B3)
	group_FROZEN_IN = BuildFrozenInput()
	view_OUT.Controls.Add(group_OUTPUT)
	view_OUT.Controls.Add(group_FROZEN_IN)
	view_OUT.Show()

#"folder directory" function
def GetFileDir(sender, e):
    NewDialog = FolderBrowserDialog()

    if NewDialog.ShowDialog() == DialogResult.OK:
        L2b.Text = NewDialog.SelectedPath;

#initiate GUI layout function
def build_gui():
	
	#only add the necessary initial functions
	group_IN.Controls.Add(L1a)
	group_IN.Controls.Add(L1b)
	group_IN.Controls.Add(L2a)
	group_IN.Controls.Add(L2b)
	group_IN.Controls.Add(L2c)
	group_IN.Controls.Add(L3a)
	group_IN.Controls.Add(L3b)
	group_IN.Controls.Add(B1)
	group_IN.Controls.Add(S1)
	
	# Create a mapview
	group_MAP.Controls.Add(map)
	view_IN.ChildViews.Add(map)
	
	#get selected index from list -> call function (CONDITIONAL!)
	B1.Click += OutputTrigger
	L2c.Click += GetFileDir
	L3b.SelectedIndexChanged += PickDataSource
	
	#add the controls (INPUT VIEW)
	view_IN.Controls.Add(group_MAP)
	view_IN.Controls.Add(group_IN)
	
	#show the view
	view_IN.Show()

#"print plots" button click function
def PrintPlot(sender, e):
	S1.Text = S1.Text + "\nBe Patient: Printing Figure..."
	location = L1b.Text
	work_dir = L2b.Text
	img_name = 'Tidal_Record_%s.png' % location.replace(' ','_')
	plot.Chart.ExportAsImage(work_dir + os.sep + img_name,1200,900) # Export the chart as an image
	S1.Text = S1.Text + "\nFinished: Printing Figure..."

#"export stats" button click function
def ExportTideData(sender, e):
	S1.Text = S1.Text + "\nBe Patient: Exporting Data..."
	location = L1b.Text
	work_dir = L2b.Text
	file_name = 'Tidal_Analysis_%s.txt' %location.replace(' ','_')
	global stats
	global cons
	td.export_stats(work_dir + os.sep + file_name,stats,cons)
	S1.Text = S1.Text + "\nFinished: Exporting Data..."

#=======================
#TIDE ANALYSIS functions
#=======================

#"extract WPS data" function
def run_WPS(lat,lon,startDateTime,endDateTime,location):
	
	#required library
	from Libraries.Wps import *

	S1.Text = S1.Text + "\nBe Patient: Extracting TOPEX Constituents..."
	global cons
	cons = td.extract_TOPEX(lat,lon)
	S1.Text = S1.Text + "\nFinished: Extracting TOPEX Constituents..."
	
	#required input
	epsgCode = 4326
	
	S1.Text = S1.Text + "\nBe Patient: Downloading WPS Timeseries..."
	data = GetTidalPredictForCoordinate(lon, lat, epsgCode, startDateTime, endDateTime, Frequency.Hourly)
	S1.Text = S1.Text + "\nFinished: Downloading WPS Timeseries..."
	
	#get stats
	global stats
	stats = dict([('LAT', td.getLAT(data)),('MLWS', td.getMLWS(data)),\
	('MLWN', td.getMLWN(data)),('MSL', td.getMSL(data)),('MHWN', td.getMHWN(data)),\
	('MHWS', td.getMHWS(data)),('HAT', td.getHAT(data))])
	
	plot,B2,STATS,B3 = run_plot(location,data,cons,stats)
	return plot,B2,STATS,B3

#"read timeseries data" function
def run_TS(fname,work_dir,location):
	
	#required input
	if fname == "":
		fname = "WL_input.txt"
	if work_dir == "":
		work_dir = r"d:\friedman\Desktop\Current Work\CoDeS\DeltaShell\plugins\DeltaShell.Plugins.Toolbox\Scripts\TidalData\WORKING_DIR"
	hdr = '*'
	delimiterChar = '\t'
	dateTimeFormat = '%Y/%m/%d %H:%M:%S'
	
	S1.Text = S1.Text + "\nBe Patient: Loading ascii Timeseries..."
	data = td.load_ascii(work_dir + os.sep + fname,hdr,delimiterChar,dateTimeFormat)
	S1.Text = S1.Text + "\nFinished: Loading ascii Timeseries..."
	
	#get stats
	global stats
	stats = dict([('LAT', td.getLAT(data)),('MLWS', td.getMLWS(data)),\
	('MLWN', td.getMLWN(data)),('MSL', td.getMSL(data)),('MHWN', td.getMHWN(data)),\
	('MHWS', td.getMHWS(data)),('HAT', td.getHAT(data))])
	
	plot,B2,STATS,B3 = run_plot(location,data,cons,stats)
	return plot,B2,STATS,B3
	
#"read tidal timeseries data" function
def run_plot(location,data,cons,stats):
	
	#plot the entire timeseries
	titler = 'Entire Tidal Record at %s' %location
	ylabel = 'Water Level [m]'
	xlabel = 'Date/Time'
	S1.Text = S1.Text + "\nBe Patient: Building Figure..."
	chart_all = td.plot_tide(data,titler,xlabel,ylabel) #initialize the plot with the first dataset
	chart_all = td.add_series(chart_all,data,data) #add the tide statistics on top of plot
	S1.Text = S1.Text + "\nFinished: Building Figure..."
	
	#for button clicking!
	B2.Click += PrintPlot
	
	# Create a chartview
	plot.Chart = chart_all
	"""tab_PLOT.Controls.Add(plot)
	tab_PLOT.Controls.Add(B2)"""
	
	#add stats
	STATS,B3 = build_output(data,cons,stats)
	return plot,B2,STATS,B3

#"output tidal stats" function
def build_output(data,cons,stats):
	
	#for button clicking!
	B3.Click += ExportTideData
	
	# Create a label
	choice = L3b.SelectedItem
	if choice == "WPS":
		for key in cons.keys():
			STATS.Rows.Add(key,cons[key][0],cons[key][1])
	return STATS,B3
	
#=================
#begins the SHELL!
#=================
build_gui()