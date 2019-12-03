#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Josh Friedman
#
#       josh.friedman@deltares.nl
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
#JFriedman Mar. 18, 2015
#========================

#========================
#load necessary libraries
#========================

#region load libraries
import os
import clr
import System.Drawing as _sd
import Scripts.TidalData as td
from Scripts.GeneralData.Utilities import *
from Scripts.GeneralData.Entities.Tide import *
from Scripts.UI_Examples.View import *

clr.AddReference("System.Windows.Forms")
#Illegal: all modules are directly available for all main-routines when this submodule is called. All modules should remain private, and with NameSpace.
#from System.Windows.Forms import 
#DateTimePickerFormat, MessageBox, HorizontalAlignment, TabPage, MessageBox
#DataGridView, FolderBrowserDialog, DialogResult, Padding
import System.Windows.Forms as _swf

from Libraries.MapFunctions import *
from Libraries.Wps import *


#endregion

#=============================
#define input + clone function
#=============================



#class containing all inputs for Tide Analysis
class BuildInput:
	def __init__(self):
		for i in Application.Plugins:
			if i.Name == "Toolbox":
				toolbox_dir = i.Toolbox.ScriptingRootDirectory
				
		self.ProjectName = "JJJ"
		self.WorkDir = toolbox_dir + r"\Scripts\TidalData\WORKING_DIR" # BJ: Adjusted to new map structure #JB: again
		self.DataSource = ""
		self.Filename = "WL_input.txt"
		self.Latitude = "Click Map!"
		self.Longitude = "Click Map!"
		self.StartTime = "2015-01-01"
		self.EndTime = "2015-02-01"
		self.OutputNum = 0
		self.Scenario = None
	
	def Clone(self):
		newInput = BuildInput()
		newInput.ProjectName = self.ProjectName
		newInput.WorkDir = self.WorkDir
		newInput.DataSource = self.DataSource
		newInput.Filename = self.Filename
		newInput.Latitude = self.Latitude
		newInput.Longitude = self.Longitude
		newInput.StartTime = self.StartTime
		newInput.EndTime = self.EndTime
		newInput.OutputNum = self.OutputNum
		
		#The clone should not have acces to scenario-data, since scenario can be updated, while OUTPUT should remain frozen.
		newInput.Scenario = None
		return newInput

#=======================
#define GLOBAL variables
#=======================
sp_loc = 5 #start point/location for labels (from left edge)
label_width = 150 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 40 #vertical spacing between labels (from previous)

#===================================
#define the TABCONTROL (output view)
#===================================

#add PLOT/STATS tabs
def BuildTabs(plot,B2,STATS,B3):
	tab_holder = TabControl() #overview "holder"
	tab_holder.Dock = DockStyle.Fill #fill the space

	tab_PLOT = _swf.TabPage() #for the plot
	tab_PLOT.Text = "Timeseries Plot"
	tab_PLOT.Controls.Add(plot)
	tab_PLOT.Controls.Add(B2)

	tab_STATS = _swf.TabPage() #for the output stats
	tab_STATS.Text = "Tide Statistics"
	tab_STATS.Controls.Add(STATS)
	tab_STATS.Controls.Add(B3)

	#add the tabs to the "holder"
	tab_holder.Controls.Add(tab_PLOT)
	tab_holder.Controls.Add(tab_STATS)
	return tab_holder

#====================================================
#define INPUT (i.e. group boxes + labels + textboxes)
#====================================================

#"folder directory" function
def GetFileDir(sender, e):
	NewDialog = _swf.FolderBrowserDialog()

	if NewDialog.ShowDialog() == _swf.DialogResult.OK:
		INPUT.WorkDir = NewDialog.SelectedPath;

#"pick data source" function
def PickDataSource(group_IN, SelectedItem, WPScontrols, TScontrols, INPUT):
	INPUT.DataSource = SelectedItem
	if INPUT.DataSource == "WPS": #add/delete the right boxes
		if group_IN.Controls.Contains(TScontrols[0]): #check to see if boxes exist, if so - remove them
			group_IN.Controls.Remove(TScontrols[0])
			group_IN.Controls.Remove(TScontrols[1])
			group_IN.Controls.Remove(TScontrols[2])
			group_IN.Controls.Remove(TScontrols[3])
			group_IN.Controls.Remove(TScontrols[4])
			group_IN.Controls.Remove(TScontrols[5])
		group_IN.Controls.Add(WPScontrols[0])
		group_IN.Controls.Add(WPScontrols[1])
		group_IN.Controls.Add(WPScontrols[2])
		group_IN.Controls.Add(WPScontrols[3])
		group_IN.Controls.Add(WPScontrols[4])
		group_IN.Controls.Add(WPScontrols[5])
		group_IN.Controls.Add(WPScontrols[6])
		group_IN.Controls.Add(WPScontrols[7])
	if INPUT.DataSource == "Timeseries": #add/delete the right boxes
		if group_IN.Controls.Contains(WPScontrols[0]): #check to see if boxes exist, if so - remove them
			group_IN.Controls.Remove(WPScontrols[0])
			group_IN.Controls.Remove(WPScontrols[1])
			group_IN.Controls.Remove(WPScontrols[2])
			group_IN.Controls.Remove(WPScontrols[3])
			group_IN.Controls.Remove(WPScontrols[4])
			group_IN.Controls.Remove(WPScontrols[5])
			group_IN.Controls.Remove(WPScontrols[6])
			group_IN.Controls.Remove(WPScontrols[7])
		group_IN.Controls.Add(TScontrols[0])
		group_IN.Controls.Add(TScontrols[1])
		group_IN.Controls.Add(TScontrols[2])
		group_IN.Controls.Add(TScontrols[3])
		group_IN.Controls.Add(TScontrols[4])
		group_IN.Controls.Add(TScontrols[5])

#get handle to INPUT
def GetProjectName(Change, INPUT):
	INPUT.ProjectName = Change

def GetWorkDir(Change, INPUT):
	INPUT.WorkDir = Change

def GetFilename(Change, INPUT):
	INPUT.Filename = Change

def GetLatitude(Change, INPUT):
	INPUT.Latitude = Change
	
def GetLongitude(Change, INPUT):
	INPUT.Longitude = Change

def GetStartTime(Change, INPUT):
	INPUT.StartTime = Change

def GetEndTime(Change):
	INPUT.EndTime = Change

#build INPUT group box
def BuildInputBox(INPUT):

	#define the groupbox
	group_IN = GroupBox()
	group_IN.Text = "Input"
	group_IN.Font = _sd.Font(group_IN.Font.FontFamily, 10)
	group_IN.Width = 2*label_width+3*spacer_width #width of entire group box (needs to be big!)
	group_IN.Dock = DockStyle.Left
	group_IN.Padding = _swf.Padding(vert_spacing/1.5)

	#region get project name
	L1a = Label()
	L1a.Text = "Project Location:"
	L1a.Location = _sd.Point(sp_loc,vert_spacing)
	L1a.Width = label_width

	L1b = TextBox()
	L1b.Text = INPUT.ProjectName #default name
	L1b.Location = _sd.Point(label_width+spacer_width,vert_spacing)
	L1b.Width = label_width
	L1b.TextChanged += lambda s,e : GetProjectName(L1b.Text, INPUT)
	#endregion

	#region get working directory
	L2a = Label()
	L2a.Text = "Working Directory:"
	L2a.Location = _sd.Point(sp_loc,2*vert_spacing)
	L2a.Width = label_width

	button_size = 25
	L2b = TextBox()
	L2b.Text =  INPUT.WorkDir #default name
	L2b.Location = _sd.Point(label_width+spacer_width,2*vert_spacing)
	L2b.Width = label_width - button_size
	L2b.TextChanged += lambda s,e : GetWorkDir(L2b.Text, INPUT)

	L2c = Button()
	L2c.BackColor = Color.DarkGray
	L2c.Text = "..."
	L2c.Location = _sd.Point(label_width+spacer_width + label_width - button_size,2*vert_spacing)
	L2c.Width = button_size
	L2c.Click += GetFileDir
	#endregion

	#region pick data source
	L3a = Label()
	L3a.Text = "Data Source:"
	L3a.Location = _sd.Point(sp_loc,3*vert_spacing)
	L3a.Width = label_width

	L3b = ListBox()
	L3b.Items.Add("Timeseries")
	L3b.Items.Add("WPS")
	L3b.Height = 50
	L3b.Location = _sd.Point(label_width+spacer_width,3*vert_spacing)
	L3b.Width = label_width
	#get choice at end!
	#endregion

	#region pick filename (CONDITIONAL!)
	L4a = Label()
	L4a.Text = "Input File [ascii]:"
	L4a.Location = _sd.Point(sp_loc,6.5*vert_spacing)
	L4a.Width = label_width

	L4b = TextBox()
	L4b.Text = INPUT.Filename #default name
	L4b.Location = _sd.Point(label_width+spacer_width,6.5*vert_spacing)
	L4b.Width = label_width
	L4b.TextChanged += lambda s,e : GetFilename(L4b.Text, INPUT)
	#get choice at end!
	#endregion

	#region pick latitude (CONDITIONAL!)
	L5a = Label()
	L5a.Text = "Latitude [deg]:"
	L5a.Location = _sd.Point(sp_loc,4.5*vert_spacing)
	L5a.Width = label_width
	
	L5b = TextBox()
	L5b.Enabled = False
	L5b.Text = INPUT.Latitude #default longitude
	L5b.Location = _sd.Point(label_width+spacer_width,4.5*vert_spacing)
	L5b.Width = label_width
	L5b.TextChanged += lambda s,e : GetLatitude(L5b.Text, INPUT)

	#L5b = NumericUpDown()
	#L5b.DecimalPlaces = 2 #for textbox
	#L5b.TextAlign = _swf.HorizontalAlignment.Right
	#L5b.Increment = 0.1 #for increment with dir keys
	#L5b.Maximum = 90 #max bounds
	#L5b.Minimum = -90 #min bounds
	#L5b.Location = _sd.Point(label_width+spacer_width,4.5*vert_spacing)
	#L5b.Width = label_width
	#L5b.Value = INPUT.Latitude #default number
	#L5b.ValueChanged += lambda s,e : GetLatitude(L5b.Value)
	#get choice at end!
	#endregion

	#region pick longitude (CONDITIONAL!)
	L6a = Label()
	L6a.Text = "Longitude [deg]:"
	L6a.Location = _sd.Point(sp_loc,5.5*vert_spacing)
	L6a.Width = label_width

	L6b = TextBox()
	L6b.Enabled = False
	L6b.Text = INPUT.Longitude #default longitude
	L6b.Location = _sd.Point(label_width+spacer_width,5.5*vert_spacing)
	L6b.Width = label_width
	L6b.TextChanged += lambda s,e : GetLongitude(L6b.Text, INPUT)

	#L6b = NumericUpDown()
	#L6b.DecimalPlaces = 2
	#L6b.TextAlign = _swf.HorizontalAlignment.Right
	#L6b.Increment = 0.1 #for increment with dir keys
	#L6b.Maximum = 180 #max bounds
	#L6b.Minimum = -180 #min bounds
	#L6b.Location = _sd.Point(label_width+spacer_width,5.5*vert_spacing)
	#L6b.Width = label_width
	#L6b.Value = INPUT.Longitude #default number
	#L6b.ValueChanged += lambda s,e : GetLongitude(L6b.Value)"""
	#get choice at end!
	#endregion

	#region pick start time (CONDITIONAL!)
	L7a = Label()
	L7a.Text = "Start Time:"
	L7a.Location = _sd.Point(sp_loc,6.5*vert_spacing)
	L7a.Width = label_width

	L7b = DateTimePicker()
	L7b.Location = _sd.Point(label_width+spacer_width,6.5*vert_spacing)
	L7b.Width = label_width
	L7b.Format = _swf.DateTimePickerFormat.Custom
	L7b.CustomFormat = "yyyy-MM-dd"
	L7b.Text = INPUT.StartTime #default start date
	L7b.TextChanged += lambda s,e : GetStartTime(L7b.Text, INPUT)
	#get choice at end!
	#endregion

	#region pick end time (CONDITIONAL!)
	L8a = Label()
	L8a.Text = "End Time:"
	L8a.Location = _sd.Point(sp_loc,7.5*vert_spacing)
	L8a.Width = label_width

	L8b = DateTimePicker()
	L8b.Location = _sd.Point(label_width+spacer_width,7.5*vert_spacing)
	L8b.Width = label_width
	L8b.Format = _swf.DateTimePickerFormat.Custom
	L8b.CustomFormat = "yyyy-MM-dd"
	L8b.Text = INPUT.EndTime #default start date
	L8b.TextChanged += lambda s,e : GetEndTime(L8b.Text, INPUT)
	#get choice at end!
	#endregion

	#region build "trigger" button
	B1 = Button()
	B1.Location = _sd.Point((label_width+spacer_width)/2,14*vert_spacing)
	B1.Text = "Confirm Selection"
	B1.Dock = DockStyle.Bottom
	B1.Height = label_width/2
	B1.Width = label_width*1.1

	#only add the necessary initial functions
	group_IN.Controls.Add(L1a)
	group_IN.Controls.Add(L1b)
	group_IN.Controls.Add(L2a)
	group_IN.Controls.Add(L2b)
	group_IN.Controls.Add(L2c)
	group_IN.Controls.Add(L3a)
	group_IN.Controls.Add(L3b)
	group_IN.Controls.Add(B1)

	#define controls for changing
	WPScontrols = [L5a,L5b,L6a,L6b,L7a,L7b,L8a,L8b]
	TScontrols = [L4a,L4b,L5a,L5b,L6a,L6b]
	L3b.SelectedIndexChanged += lambda s,e : PickDataSource(group_IN,L3b.SelectedItem,WPScontrols,TScontrols, INPUT)
	if INPUT.DataSource == "WPS":
		L3b.SelectedIndex = 1
	else:
		L3b.SelectedIndex = 0

	return B1,group_IN,L5b,L6b

#build OUTPUT group box
def BuildOutputBox(plot,B2,STATS,B3):
	group_OUTPUT = GroupBox()
	group_OUTPUT.Text = "Output"
	group_OUTPUT.Font = _sd.Font(group_OUTPUT.Font.FontFamily, 10)
	group_OUTPUT.Dock = DockStyle.Fill
	tab_holder = BuildTabs(plot,B2,STATS,B3)
	group_OUTPUT.Controls.Add(tab_holder)
	return group_OUTPUT

#=============
#GUI functions
#=============

#"trigger" output function
def OutputTrigger(INPUT):
	
	#get final choice for input
	INPUT.OutputNum += 1
	OUTPUT = INPUT.Clone() #clone all values including Scenarioit
	
	if OUTPUT.DataSource == "WPS":
		plot,B2,STATS,B3 = run_WPS(INPUT, OUTPUT)
	elif OUTPUT.DataSource == "Timeseries":
		plot,B2,STATS,B3 = run_TS(INPUT, OUTPUT)
	
	#build the output view
	view_OUT = View()
	view_OUT.Text = "Tide Output (%02d)" %OUTPUT.OutputNum
	
	#Debugline:
	#view_OUT.Text = "Lat uit GenData = " + str(INPUT.Scenario.GenericData.Tide.Location.Coordinate.X) 
	
	
	#build OUTPUT screen
	B1,group_FROZEN_IN,L5b,L6b = BuildInputBox(OUTPUT)
	group_FROZEN_IN.Text = "Selected Input"
	group_FROZEN_IN.Enabled = False
	
	group_OUTPUT = BuildOutputBox(plot,B2,STATS,B3)
	view_OUT.Controls.Add(group_OUTPUT)
	view_OUT.Controls.Add(group_FROZEN_IN)
	view_OUT.Show()


#initiate GUI layout function
def build_gui(scenario):
	
	
	INPUT = BuildInput() #get default
	
	#INPUT is alreay global. Set the 'function-given'-scenario-parameter towards the global INPUT
	INPUT.Scenario = scenario
	
	#define main view
	view_IN = View() #build INPUT view window
	view_IN.Text = "Tide Input"
	
	#Debugline:
	#view_IN.Text = "Tide Input ( = " + str(scenario.GenericData.Tide) + ")"
	
	#build MAP group box
	group_MAP = GroupBox()
	group_MAP.Text = "Map View"
	group_MAP.Font = _sd.Font(group_MAP.Font.FontFamily, 10)
	group_MAP.Dock = DockStyle.Fill
	group_MAP.Padding = _swf.Padding(10)
	
	#build INPUT screen 
	B1,group_IN,L5b,L6b = BuildInputBox(INPUT)

	# Create a mapview
	mapview = td.ClickMap(L5b,L6b)
	group_MAP.Controls.Add(mapview)
	view_IN.ChildViews.Add(mapview)

	#get selected index from list -> call function (CONDITIONAL!)
	B1.Click += lambda s,e : OutputTrigger(INPUT)
	

	#add the controls (INPUT VIEW)
	view_IN.Controls.Add(group_MAP)
	view_IN.Controls.Add(group_IN)

	#show the view
	view_IN.Show()

#"print plots" button click function
def PrintPlot(plot, location):
	_swf.MessageBox.Show(INPUT.Scenario.GenericData.Tide.SourcePath)
	
	
	img_name = 'Tidal_Record_%s.png' % location.replace(' ','_')
	plot.Chart.ExportAsImage(INPUT.WorkDir + os.sep + img_name,1200,900) # Export the chart as an image
	_swf.MessageBox.Show("Tide Plot Exported!","Confirmation") #alert the user

#"export stats" button click function
def ExportTideData(location,stats,cons):
	file_name = 'Tidal_Analysis_%s.txt' %location.replace(' ','_')
	td.export_stats(INPUT.WorkDir + os.sep + file_name,stats,cons)
	_swf.MessageBox.Show("Tide Statistics Exported!","Confirmation") #alert the user

#=======================
#TIDE ANALYSIS functions
#=======================

#"extract WPS data" function
def run_WPS(INPUT, OUTPUT):
	
	SourcePath = OUTPUT.WorkDir + os.sep + '..' + os.sep + 'DATA' + os.sep + 'h_tpxo7.2.nc'
	cons = td.extract_TOPEX(SourcePath, float(OUTPUT.Latitude),float(OUTPUT.Longitude))
	
	#required input
	epsgCode = 4326
	data = GetTidalPredictForCoordinate(float(OUTPUT.Longitude), float(OUTPUT.Latitude), epsgCode, OUTPUT.StartTime, OUTPUT.EndTime, Frequency.Hourly)

	#get stats
	stats = dict([('LAT', td.getLAT(data)),('MLWS', td.getMLWS(data)),\
	('MLWN', td.getMLWN(data)),('MSL', td.getMSL(data)),('MHWN', td.getMHWN(data)),\
	('MHWS', td.getMHWS(data)),('HAT', td.getHAT(data))])
	
	INPUT.Scenario.GenericData.Tide = createGenericTide(data, 'TopexWPS', stats, INPUT)
	
	plot,B2,STATS,B3 = run_plot(OUTPUT.ProjectName,data,cons,stats, INPUT)
	return plot,B2,STATS,B3

#"read timeseries data" function
def run_TS(INPUT, OUTPUT):

	#required input
	hdr = '*'
	delimiterChar = '\t'
	dateTimeFormat = '%Y/%m/%d %H:%M:%S'
	
	SourcePath = OUTPUT.WorkDir + os.sep + '..' + os.sep + 'DATA' + os.sep + OUTPUT.Filename
	data = td.load_ascii(SourcePath, hdr, delimiterChar, dateTimeFormat)
	
	#get stats, a
	cons = 0
	stats = dict([('LAT', td.getLAT(data)),('MLWS', td.getMLWS(data)),\
	('MLWN', td.getMLWN(data)),('MSL', td.getMSL(data)),('MHWN', td.getMHWN(data)),\
	('MHWS', td.getMHWS(data)),('HAT', td.getHAT(data))])
	
	INPUT.Scenario.GenericData.Tide = createGenericTide(data, SourcePath, stats, INPUT)
	
	#DebugLine:
	#INPUT.ProjectName = "Overwrite JJJ"
	
	plot,B2,STATS,B3 = run_plot(OUTPUT.ProjectName,data,cons,stats, INPUT)
	return plot,B2,STATS,B3

def createGenericTide(data, SourcePath, stats, INPUT):
	"""Write Tidal-data towards the GenericData-class"""
	
	#Generate a variable of class Tide
	tidalData = Tide()
	
	#All stats of the tide
	tidalData.LAT = stats['LAT']
	tidalData.HAT = stats['HAT']
	tidalData.MLWS = stats['MLWS']
	tidalData.MLWN = stats['MLWN']
	tidalData.MHWS = stats['MHWS']
	tidalData.MHWN = stats['MHWN']
	tidalData.MSL = stats['MSL']
	
	#Timeseries on its own  (2xN vector)
	tidalData.Series = data
	
	#Datasource: the filepath as string
	tidalData.SourcePath = SourcePath
	
	
	#Latitude and Longitude is always string, it is the content of the textbox.
	#If it is still "Click Map!", then it should be set to None. Otherwise it should be converted to a float
	if INPUT.Latitude is "Click Map!":
		valLat = None
	else:
		valLat = StrToFloat(INPUT.Latitude, -999)
	if INPUT.Longitude is "Click Map!":
		valLon = None
	else:
		valLon = StrToFloat(INPUT.Longitude, -999)
	
	tidalData.Location = CreatePointGeometry(valLat, valLon)
	
	
	return tidalData

#"read tidal timeseries data" function
def run_plot(location,data,cons,stats, INPUT):

	#define the chart view
	plot = ChartView() #empty chart view
	plot.Dock = DockStyle.Fill #fill the space

	#plot the entire timeseries
	titler = 'Entire Tidal Record at %s' %location
	ylabel = 'Water Level [m]'
	xlabel = 'Date/Time'
	chart_all = td.plot_tide(data,titler,xlabel,ylabel) #initialize the plot with the first dataset
	td.add_series(chart_all,data,data) #add the tide statistics on top of plot

	# Create a chartview
	plot.Chart = chart_all

	#for button clicking!
	B2 = Button()
	B2.Dock = DockStyle.Bottom
	B2.Text = "Print Plots"
	B2.Height = vert_spacing
	B2.Click += lambda s,e : PrintPlot(plot, location)

	#add stats
	STATS,B3 = build_output(location,data,cons,stats, INPUT)
	return plot,B2,STATS,B3

#"output tidal stats" function
def build_output(location,data,cons,stats, INPUT):

	#build "export" button
	B3 = Button()
	B3.Dock = DockStyle.Bottom
	B3.Text = "Export Statistics"
	B3.Height = vert_spacing
	B3.Click += lambda s,e : ExportTideData(location,stats,cons)

	#build constituents table
	choice = INPUT.DataSource
	if choice == "WPS":
		STATS = _swf.DataGridView()
		STATS.Dock = DockStyle.Fill
		STATS.RowCount = 1
		STATS.ColumnCount = 3
		STATS.Columns[0].Name = "Constituent Name"
		STATS.Columns[1].Name = "Amplitude [m]"
		STATS.Columns[2].Name = "Phase [deg]"	
		STATS.ColumnHeadersHeight = 50
		STATS.ReadOnly = True
		STATS.Enabled = False #don't allow the user to touch the table
		STATS.AllowUserToAddRows = False
		STATS.RowHeadersVisible = False
		STATS.ForeColor = Color.Red
		STATS.Font = _sd.Font(STATS.Font,_sd.FontStyle.Bold)
		STATS.Font = _sd.Font(STATS.Font.FontFamily, 10)
		for key in cons.keys():
			STATS.Rows.Add(key,"%.4f" %cons[key][0],"%.2f" %cons[key][1])
	else:
		STATS = Label()
		STATS.Text = "No Information Available"
		STATS.Location = _sd.Point(25,25)
		STATS.Font = _sd.Font(STATS.Font,_sd.FontStyle.Bold)
		STATS.Font = _sd.Font(STATS.Font.FontFamily, 10)
		STATS.Width = 400
		STATS.Height = 50
		
	return STATS,B3



#=================
#begins the SHELL!
#=================
from Scripts.GeneralData.Entities import Scenario
build_gui(Scenario())
