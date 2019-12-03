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
import os
import clr
clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf
import System.Drawing as _sd
from System import Type
from GeoAPI.Geometries import IPoint
from Scripts.UI_Examples.View import *
from SharpMap.Editors.Interactors import Feature2DEditor as _Feature2DEditor

from NetTopologySuite.Extensions.Features import PointFeature as _PointFeature

from Libraries import MapFunctions as _MapFunctions
from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Entities.Tide as _Tide
import Scripts.TidalData.Entities.TideInput as _TideInput
import Scripts.TidalData.Utilities.TideMapTools as _TideMapTools
import Scripts.TidalData.Utilities.TideEngine as _TideEngine
import Scripts.TidalData.Utilities.TidePlotFunctions as _TidePlotFunctions
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools

# Try to import Wps server
try:
	import Libraries.Wps as _Wps
	WPS = True
except:
	print "No WPS server connection"
	WPS = False

class TideView(BaseView):
	
	def __init__(self, scenario):
		BaseView.__init__(self)
		
		self.INPUT = _TideInput.BuildInput()
		self.__scenario = scenario
		self.Text = "Tide"
		
		self.TideLocationLayer = None
		
		# Check for Wps server
		self.WPS = WPS
		if not self.WPS:
			self.lblMessage.Text = "WPS server couldn't be loaded"
		
		#	Default control dimensions
		self.sp_loc = 5 #start point/location for labels (from left edge)
		self.label_width = 180 #width for labels + textboxes...
		self.spacer_width = 5 #horizontal spacing between label + textboxes
		self.vert_spacing = 40 #vertical spacing between labels (from previous)
		
		# Build Input Controls
		self.BuildInputBox()
		self.leftPanel.Controls.Add(self.group_IN)
		
		# Build Output (right) Controls
		self.RightOutTabs = _swf.TabControl()
		self.RightOutTabs.Dock = DockStyle.Fill
		
		#	Set anchoring
		self.SetAnchoring()
		
		#Get General Map
		self.mapView = MapView()
		self.mapView.Dock = DockStyle.Fill
		_CoDesMapTools.ShowLegend(self.mapView)
		
		self.group_MAP = _swf.TabPage()
		self.group_MAP.Text = "Map"
		self.RightOutTabs.Controls.Add(self.group_MAP)
		
		self.group_MAP.Dock = DockStyle.Fill
		self.group_MAP.Controls.Add(self.mapView)
		
		self.rightPanel.Controls.Add(self.RightOutTabs)
		self.ChildViews.Add(self.mapView)
		
		self.ClickTool = _TideMapTools.AddPointMapTool()
		self.mapView.MapControl.Tools.Add(self.ClickTool)
		
		#	Set Scrollbars
		self.SetScrollBarsLeftPanel(20)
		
		self.InitializeForScenario()
	
	def InitializeForScenario(self):
		self.mapView.Map = self.__scenario.GeneralMap
		
		self.GroupLayer = self.__scenario.GroupLayerTide
		self.GroupLayer.Layers.Clear()

		#if (self.TideLocationLayer != None):
		#	self.TideLocationLayer.DataSource.FeaturesChanged -= self.FeaturesChanges
			
		self.TideLocationLayer = self.CreateTideLocationLayer()
		self.TideLocationLayer.DataSource.FeaturesChanged += self.FeaturesChanges
		self.TideLocationLayer.ShowInLegend = False
		self.TideLocationLayer.ShowInTreeView = False
		
		self.GroupLayer.Layers.Add(self.TideLocationLayer)
		self.mapView.Map.BringToFront(self.TideLocationLayer)
		
		self.ClickTool.SetLayer(self.TideLocationLayer)
		
		self.INPUT.SetToDefaults()

		tide = self.__scenario.GenericData.Tide
		if tide == None: return
		
		self.cons = tide.cons
		self.data = tide.data
		self.stats = tide.stats
		
		if (tide.Location != None):
			feature = _PointFeature(Geometry = tide.Location)
			self.TideLocationLayer.DataSource.Features.Add(feature)
			self.TideLocationLayer.ShowInLegend = True
			self.TideLocationLayer.ShowInTreeView = True
		
		self.run_plot()
		self.BuildTabs()
		self.RightOutTabs.Controls.Add(self.tab_PLOT)
		self.RightOutTabs.Controls.Add(self.tab_STATS)
		self.btn_ClickPoint.Enabled = True
		
	def FeaturesChanges(self, s,e):
		locationFeatures = self.TideLocationLayer.DataSource.Features
		hasLocationFeatures = len(locationFeatures) > 0
		
		self.TideLocationLayer.ShowInLegend = hasLocationFeatures
		
		if hasLocationFeatures:
			# convert to lat/lon
			PT = _MapFunctions.TransformGeometry(locationFeatures[0].Geometry, self.__scenario.GenericData.SR_EPSGCode, 4326)
			
			self.L5b.Text = "%.4f" %(PT.Coordinate.Y) #assign value to textbox
			self.L6b.Text = "%.4f" %(PT.Coordinate.X) #assign value to textbox
		else:
			self.L5b.Text = "Click Location!"
			self.L6b.Text = "Click Location!"
		
		self.ClickTool.IsActive = False
		self.btn_ClickPoint.Enabled = True

	def CreateTideLocationLayer(self):
		cs = _MapFunctions.Map.CoordinateSystemFactory.CreateFromEPSG(self.__scenario.GenericData.SR_EPSGCode)
		layer = _MapFunctions.CreateLayerForFeatures("Tide Location",[],cs)
		layer.FeatureEditor = _Feature2DEditor(None)
		layer.Style.GeometryType = Type.GetType("GeoAPI.Geometries.IPoint, GeoAPI")
		layer.Style.Fill.Color = Color.Green
		layer.Style.Outline = layer.Style.Outline
		
		return layer
		 
	def StartClickLocation(self):
		self.ClickTool.IsActive = True
		self.btn_ClickPoint.Enabled = False
		self.TideLocationLayer.ShowInLegend = True
		self.TideLocationLayer.ShowInTreeView = True
		
	def UpdateInput(self,object,propertyName,value):
		script = "object." + propertyName + "=value"
		exec(script)
	
	def BuildInputBox(self):

		#define the groupbox
		self.group_IN = _swf.Panel()
		self.group_IN.Text = "Input"
		
		#self.group_IN.Width = 2*self.label_width+3*self.spacer_width #width of entire group box (needs to be big!)
		self.group_IN.Dock = DockStyle.Fill
		self.group_IN.Padding = _swf.Padding(self.vert_spacing/1.5)
	
		#region get project name
		self.L1a = _swf.Label()
		self.L1a.Text = "Project Location:"
		self.L1a.Location = _sd.Point(self.sp_loc,self.vert_spacing)
		self.L1a.Width = self.label_width
	
		self.L1b = _swf.TextBox()
		self.L1b.Text = self.INPUT.ProjectName #default name
		self.L1b.Location = _sd.Point(self.label_width+self.spacer_width,self.vert_spacing)
		self.L1b.Width = self.label_width
		self.L1b.TextChanged += lambda s,e : self.UpdateInput(self.INPUT,"ProjectName",self.L1b.Text)
		#endregion
	
		#region get working directory
		self.L2a = _swf.Label()
		self.L2a.Text = "Working Directory:"
		self.L2a.Location = _sd.Point(self.sp_loc,2*self.vert_spacing)
		self.L2a.Width = self.label_width
	
		button_size = 25
		self.L2b = _swf.TextBox()
		self.L2b.Text =  self.INPUT.WorkDir #default name
		self.L2b.Location = _sd.Point(self.label_width+self.spacer_width,2*self.vert_spacing)
		self.L2b.Width = self.label_width - button_size
		self.L2b.TextChanged += lambda s,e : self.UpdateInput(self.INPUT,"WorkDir",self.L2b.Text)
	
		self.L2c = _swf.Button()
		self.L2c.BackColor = Color.DarkGray
		self.L2c.Text = "..."
		self.L2c.Location = _sd.Point(self.label_width+self.spacer_width + self.label_width - button_size,2*self.vert_spacing)
		self.L2c.Width = button_size
		self.L2c.Click += lambda s,e : self.GetFileDir()
		#endregion
	
		#region pick data source
		self.L3a = _swf.Label()
		self.L3a.Text = "Data Source:"
		self.L3a.Location = _sd.Point(self.sp_loc,3*self.vert_spacing)
		self.L3a.Width = self.label_width
	
		self.L3b = _swf.ListBox()
		self.L3b.Items.Add("Timeseries")
		if self.WPS:
			self.L3b.Items.Add("WPS")
	
		self.L3b.Height = 50
		self.L3b.Location = _sd.Point(self.label_width+self.spacer_width,3*self.vert_spacing)
		self.L3b.Width = self.label_width
		#get choice at end!
		#endregion
	
		#region pick filename (CONDITIONAL!)
		self.L4a = _swf.Label()
		self.L4a.Text = "Input File [ascii]:"
		self.L4a.Location = _sd.Point(self.sp_loc,7.5*self.vert_spacing)
		self.L4a.Width = self.label_width
	
		self.L4b = _swf.TextBox()
		self.L4b.Text = self.INPUT.Filename #default name
		self.L4b.Location = _sd.Point(self.label_width+self.spacer_width,7.5*self.vert_spacing)
		self.L4b.Width = self.label_width
		self.L4b.TextChanged += lambda s,e : self.UpdateInput(self.INPUT,"Filename",self.L4b.Text)
		#get choice at end!
		#endregion
		
		self.btn_ClickPoint = _swf.Button()
		self.btn_ClickPoint.Location = _sd.Point((self.label_width+self.spacer_width),4.5*self.vert_spacing)
		self.btn_ClickPoint.Text = "Click Location"
		self.btn_ClickPoint.Width = self.label_width
		self.btn_ClickPoint.Click += lambda s,e : self.StartClickLocation()
		
		#region pick latitude (CONDITIONAL!)
		self.L5a = _swf.Label()
		self.L5a.Text = "Latitude [deg]:"
		self.L5a.Location = _sd.Point(self.sp_loc,5.5*self.vert_spacing)
		self.L5a.Width = self.label_width
		
		self.L5b = _swf.TextBox()
		self.L5b.Enabled = False
		self.L5b.Text = self.INPUT.Latitude #default longitude
		self.L5b.Location = _sd.Point(self.label_width+self.spacer_width,5.5*self.vert_spacing)
		self.L5b.Width = self.label_width
		self.L5b.TextChanged += lambda s,e : self.UpdateInput(self.INPUT,"Latitude",self.L5b.Text)
	
		#region pick longitude (CONDITIONAL!)
		self.L6a = _swf.Label()
		self.L6a.Text = "Longitude [deg]:"
		self.L6a.Location = _sd.Point(self.sp_loc,6.5*self.vert_spacing)
		self.L6a.Width = self.label_width
	
		self.L6b = _swf.TextBox()
		self.L6b.Enabled = False
		self.L6b.Text = self.INPUT.Longitude #default longitude
		self.L6b.Location = _sd.Point(self.label_width+self.spacer_width,6.5*self.vert_spacing)
		self.L6b.Width = self.label_width
		self.L6b.TextChanged += lambda s,e : self.UpdateInput(self.INPUT,"Longitude",self.L6b.Text)
		
		#region pick start time (CONDITIONAL!)
		self.L7a = _swf.Label()
		self.L7a.Text = "Start Time:"
		self.L7a.Location = _sd.Point(self.sp_loc,7.5*self.vert_spacing)
		self.L7a.Width = self.label_width
	
		self.L7b = _swf.DateTimePicker()
		self.L7b.Location = _sd.Point(self.label_width+self.spacer_width,7.5*self.vert_spacing)
		self.L7b.Width = self.label_width
		self.L7b.Format = _swf.DateTimePickerFormat.Custom
		self.L7b.CustomFormat = "yyyy-MM-dd"
		self.L7b.Text = self.INPUT.StartTime #default start date
		self.L7b.TextChanged += lambda s,e : self.UpdateInput(self.INPUT,"StartTime",self.L7b.Text)
		#get choice at end!
		#endregion
	
		#region pick end time (CONDITIONAL!)
		self.L8a = _swf.Label()
		self.L8a.Text = "End Time:"
		self.L8a.Location = _sd.Point(self.sp_loc,8.5*self.vert_spacing)
		self.L8a.Width = self.label_width
	
		self.L8b = _swf.DateTimePicker()
		self.L8b.Location = _sd.Point(self.label_width+self.spacer_width,8.5*self.vert_spacing)
		self.L8b.Width = self.label_width
		self.L8b.Format = _swf.DateTimePickerFormat.Custom
		self.L8b.CustomFormat = "yyyy-MM-dd"
		self.L8b.Text = self.INPUT.EndTime #default start date
		self.L8b.TextChanged += lambda s,e : self.UpdateInput(self.INPUT,"EndTime",self.L8b.Text)
		#get choice at end!
		#endregion
	
		#region build "trigger" button
		self.B1 = _swf.Button()
		self.B1.Location = _sd.Point((self.label_width+self.spacer_width)/2,14*self.vert_spacing)
		self.B1.Text = "Confirm Selection"
		self.B1.Dock = DockStyle.Bottom
		self.B1.Height = self.label_width/5
		self.B1.Width = self.label_width*0.5
		self.B1.Click += lambda s,e : self.OutputTrigger()
		
		#only add the necessary initial functions
		self.group_IN.Controls.Add(self.L1a)
		self.group_IN.Controls.Add(self.L1b)
		self.group_IN.Controls.Add(self.L2a)
		self.group_IN.Controls.Add(self.L2b)
		self.group_IN.Controls.Add(self.L2c)
		self.group_IN.Controls.Add(self.L3a)
		self.group_IN.Controls.Add(self.L3b)
		self.group_IN.Controls.Add(self.B1)
		self.group_IN.Controls.Add(self.btn_ClickPoint)
	
		#define controls for changing
		self.WPScontrols = [self.L5a,self.L5b,self.L6a,self.L6b,self.L7a,self.L7b,self.L8a,self.L8b]
		self.TScontrols = [self.L4a,self.L4b,self.L5a,self.L5b,self.L6a,self.L6b]
		self.L3b.SelectedIndexChanged += lambda s,e : self.PickDataSource()
		if self.INPUT.DataSource == "WPS":
			self.L3b.SelectedIndex = 1
		else:
			self.L3b.SelectedIndex = 0
		
	def PickDataSource(self):
		self.INPUT.DataSource = self.L3b.SelectedItem
		if self.INPUT.DataSource == "WPS": #add/delete the right boxes
			if self.group_IN.Controls.Contains(self.TScontrols[0]): #check to see if boxes exist, if so - remove them
				self.group_IN.Controls.Remove(self.TScontrols[0])
				self.group_IN.Controls.Remove(self.TScontrols[1])
				self.group_IN.Controls.Remove(self.TScontrols[2])
				self.group_IN.Controls.Remove(self.TScontrols[3])
				self.group_IN.Controls.Remove(self.TScontrols[4])
				self.group_IN.Controls.Remove(self.TScontrols[5])
			self.group_IN.Controls.Add(self.WPScontrols[0])
			self.group_IN.Controls.Add(self.WPScontrols[1])
			self.group_IN.Controls.Add(self.WPScontrols[2])
			self.group_IN.Controls.Add(self.WPScontrols[3])
			self.group_IN.Controls.Add(self.WPScontrols[4])
			self.group_IN.Controls.Add(self.WPScontrols[5])
			self.group_IN.Controls.Add(self.WPScontrols[6])
			self.group_IN.Controls.Add(self.WPScontrols[7])
		if self.INPUT.DataSource == "Timeseries": #add/delete the right boxes
			if self.group_IN.Controls.Contains(self.WPScontrols[0]): #check to see if boxes exist, if so - remove them
				self.group_IN.Controls.Remove(self.WPScontrols[0])
				self.group_IN.Controls.Remove(self.WPScontrols[1])
				self.group_IN.Controls.Remove(self.WPScontrols[2])
				self.group_IN.Controls.Remove(self.WPScontrols[3])
				self.group_IN.Controls.Remove(self.WPScontrols[4])
				self.group_IN.Controls.Remove(self.WPScontrols[5])
				self.group_IN.Controls.Remove(self.WPScontrols[6])
				self.group_IN.Controls.Remove(self.WPScontrols[7])
			self.group_IN.Controls.Add(self.TScontrols[0])
			self.group_IN.Controls.Add(self.TScontrols[1])
			self.group_IN.Controls.Add(self.TScontrols[2])
			self.group_IN.Controls.Add(self.TScontrols[3])
			self.group_IN.Controls.Add(self.TScontrols[4])
			self.group_IN.Controls.Add(self.TScontrols[5])
	
	def GetFileDir(self):
		NewDialog = _swf.FolderBrowserDialog()

		if NewDialog.ShowDialog() == _swf.DialogResult.OK:
			self.INPUT.WorkDir = NewDialog.SelectedPath;
	
	def OutputTrigger(self):
		self.lblMessage.ForeColor = Color.Black
		self.lblMessage.Text = "Processing..."
		self.Refresh()
		INPUT = self.INPUT
		
		if self.TideLocationLayer != None:
			self.TideSucces = True
			if self.INPUT.DataSource == "WPS":
				try:
					self.run_WPS()
				except:
					self.TideSucces = False
					_swf.MessageBox.Show("No data found, did you click on land?")
			elif self.INPUT.DataSource == "Timeseries":
				self.run_TS()
			
			if self.TideSucces:
				if hasattr(self, "tab_PLOT"):
					if self.RightOutTabs.Controls.Contains(self.tab_PLOT):
						self.RightOutTabs.Controls.Remove(self.tab_PLOT)
						self.RightOutTabs.Controls.Remove(self.tab_STATS)		
				
				self.BuildTabs()
				
				#add the tabs to the "holder"
		
				self.RightOutTabs.Controls.Add(self.tab_PLOT)
				if self.INPUT.DataSource == "WPS":
					self.RightOutTabs.Controls.Add(self.tab_STATS)
				self.RightOutTabs.SelectedIndex = 1
				self.ClickTool.IsActive = False
				self.btn_ClickPoint.Enabled = True
				
				# Save in Generic Data
				self.__scenario.GenericData.Tide = _Tide(self.cons,self.data,self.stats)
				
				if (len(self.TideLocationLayer.DataSource.Features) > 0):
					self.__scenario.GenericData.Tide.Location = self.TideLocationLayer.DataSource.Features[0].Geometry
			
			self.lblMessage.Text = ""
		else:
			self.lblMessage.ForeColor = Color.Red
			self.lblMessage.Text = "Required information missing!"

	def run_plot(self):
		
		location = self.INPUT.ProjectName
		#define the chart view
		self.plot = ChartView() #empty chart view
		self.plot.Dock = DockStyle.Fill #fill the space
	
		#plot the entire timeseries
		titler = 'Entire Tidal Record at %s' %location
		ylabel = 'Water Level [m]'
		xlabel = 'Date/Time'
		chart_all = _TidePlotFunctions.plot_tide(self.data,titler,xlabel,ylabel) #initialize the plot with the first dataset
		_TidePlotFunctions.add_series(chart_all,self.data,self.data) #add the tide statistics on top of plot
	
		# Create a chartview
		self.plot.Chart = chart_all
	
		#for button clicking!
		self.B2 = _swf.Button()
		self.B2.Dock = DockStyle.Bottom
		self.B2.Text = "Print Plots"
		self.B2.Height = self.vert_spacing
		self.B2.Click += lambda s,e : self.PrintPlot()
	
		#add stats
		self.build_output_stats()
	
	def build_output_stats(self):

		#build "export" button
		self.B3 = _swf.Button()
		self.B3.Dock = DockStyle.Bottom
		self.B3.Text = "Export Statistics"
		self.B3.Height = self.vert_spacing
		self.B3.Click += lambda s,e : self.ExportTideData()
	
		#build constituents table
		choice = self.INPUT.DataSource
		if choice == "WPS":
			self.STATS = _swf.DataGridView()
			self.STATS.Dock = DockStyle.Fill
			self.STATS.RowCount = 1
			self.STATS.ColumnCount = 3
			self.STATS.Columns[0].Name = "Constituent Name"
			self.STATS.Columns[1].Name = "Amplitude [m]"
			self.STATS.Columns[2].Name = "Phase [deg]"	
			self.STATS.ColumnHeadersHeight = 50
			self.STATS.ReadOnly = True
			self.STATS.Enabled = False #don't allow the user to touch the table
			self.STATS.AllowUserToAddRows = False
			self.STATS.RowHeadersVisible = False
			self.STATS.ForeColor = Color.Red
			self.STATS.Font = _sd.Font(self.STATS.Font,_sd.FontStyle.Bold)
			
			for key in self.cons.keys():
				self.STATS.Rows.Add(key,"%.4f" %self.cons[key][0],"%.2f" %self.cons[key][1])
		else:
			self.STATS = _swf.Label()
			self.STATS.Text = "No Information Available"
			self.STATS.Location = _sd.Point(25,25)
			self.STATS.Font = _sd.Font(self.STATS.Font,_sd.FontStyle.Bold)
			
			self.STATS.Width = 400
			self.STATS.Height = 50
	
	def run_WPS(self):
		
		INPUT = self.INPUT
		SourcePath = INPUT.WorkDir + os.sep + '..' + os.sep + 'DATA' + os.sep + 'h_tpxo7.2.nc'
		
		self.cons = _TideEngine.extract_TOPEX(SourcePath, float(INPUT.Latitude),float(INPUT.Longitude))
		
		
		#required input
		epsgCode = 4326
		self.data = _Wps.GetTidalPredictForCoordinate(float(INPUT.Longitude), float(INPUT.Latitude), epsgCode, INPUT.StartTime, INPUT.EndTime, _Wps.Frequency.Hourly)
	
		#get stats
		self.stats = dict([('LAT', _TideEngine.getLAT(self.data)),('MLWS', _TideEngine.getMLWS(self.data)),\
		('MLWN', _TideEngine.getMLWN(self.data)),('MSL', _TideEngine.getMSL(self.data)),('MHWN', _TideEngine.getMHWN(self.data)),\
		('MHWS', _TideEngine.getMHWS(self.data)),('HAT', _TideEngine.getHAT(self.data))])
		
		#INPUT.Scenario.GenericData.Tide = createGenericTide(data, 'TopexWPS', self.stats, INPUT)
		
		self.run_plot()
	
	def run_TS(self):

		#required input
		hdr = '*'
		delimiterChar = '\t'
		dateTimeFormat = '%Y/%m/%d %H:%M:%S'
		
		SourcePath = self.INPUT.WorkDir + os.sep + '..' + os.sep + 'DATA' + os.sep + self.INPUT.Filename
		self.data = _TideEngine.load_ascii(SourcePath, hdr, delimiterChar, dateTimeFormat)
		
		#get stats, a
		self.cons = 0
		self.stats = dict([('LAT', _TideEngine.getLAT(self.data)),('MLWS', _TideEngine.getMLWS(self.data)),\
		('MLWN', _TideEngine.getMLWN(self.data)),('MSL', _TideEngine.getMSL(self.data)),('MHWN', _TideEngine.getMHWN(self.data)),\
		('MHWS', _TideEngine.getMHWS(self.data)),('HAT', _TideEngine.getHAT(self.data))])
		
		#self.INPUT.Scenario.GenericData.Tide = createGenericTide(data, SourcePath, stats, INPUT)
		
		#DebugLine:
		#INPUT.ProjectName = "Overwrite JJJ"
		
		self.run_plot()
	
	def BuildTabs(self):
		self.tab_PLOT = _swf.TabPage() #for the plot
		if self.INPUT.DataSource == "WPS":
			self.tab_PLOT.Text = "Timeseries Plot (WPS)"
		else:
			self.tab_PLOT.Text = "Timeseries Plot"
		self.tab_PLOT.Controls.Add(self.plot)
		self.tab_PLOT.Controls.Add(self.B2)
	
		self.tab_STATS = _swf.TabPage() #for the output stats
		self.tab_STATS.Text = "Tide Statistics (TPXO)"
		self.tab_STATS.Controls.Add(self.STATS)
		self.tab_STATS.Controls.Add(self.B3)

	def PrintPlot(self):
		#_swf.MessageBox.Show(self.INPUT.Scenario.GenericData.Tide.SourcePath)
		
		
		img_name = 'Tidal_Record_%s.png' % self.INPUT.ProjectName.replace(' ','_')
		self.plot.Chart.ExportAsImage(self.INPUT.WorkDir + os.sep + img_name,1200,900) # Export the chart as an image
		_swf.MessageBox.Show("Tide Plot Exported!","Confirmation") #alert the user
	
	def ExportTideData(self):
		file_name = 'Tidal_Analysis_%s.txt' %self.INPUT.ProjectName.replace(' ','_')
		_TideEngine.export_stats(self.INPUT.WorkDir + os.sep + file_name,self.stats,self.cons)
		_swf.MessageBox.Show("Tide Statistics Exported!","Confirmation") #alert the user
	
	def SetAnchoring(self):
		self.L2b.Anchor = _swf.AnchorStyles.Top | _swf.AnchorStyles.Left | _swf.AnchorStyles.Right
		self.L2c.Anchor = _swf.AnchorStyles.Top | _swf.AnchorStyles.Right


"""from Scripts.GeneralData.Utilities.ScenarioPersister import *
path = "D:\\temp\\newScenario.dat"
scenarioPersister = ScenarioPersister()
newScenario = scenarioPersister.LoadScenario(path) 
structView = TideView(newScenario)

structView.Show()"""