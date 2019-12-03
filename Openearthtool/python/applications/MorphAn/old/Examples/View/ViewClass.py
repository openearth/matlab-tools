from Libraries.MorphAn.MorphAnData import *
from Libraries.Utils.Project import *
from Libraries.Utils.View import *
from DeltaShell.Plugins.MorphAn.Data import MorphAnWorkSpace as _MorphAnWorkSpace
from DeltaShell.Plugins.MorphAn.Data import MorphAnDataExtensions as _MorphAnDataExtensions
from DeltaShell.Plugins.MorphAn.MapLayers.MorphAnData import MorphAnDataLayer as _MorphAnDataLayer

class ReportView(View):
	def __init__(self):
		super(ReportView,self).__init__()
		
		self.__InitializeComponents()
		self.Text = "Test tool"
		
	def __InitializeComponents(self):
				
		#region Map
		self.mapView = MapView(Dock = DockStyle.Fill)
		""" Add MapView to childviews to allow default backgroundlayers and manipulation in the "Map" toolwindow """
		self.mapView.MapControl.SelectedFeaturesChanged += self.__SelectedFeaturesChanged
		self.ChildViews.Add(self.mapView)
		#endregion

		#region Options
		self.jrkChoice = ComboBox(
			Dock = DockStyle.Top,
			DropDownStyle = ComboBoxStyle.DropDownList)
		self.jrkChoice.SelectedIndexChanged += self.__JrkSelectedIndexChanged
		
		self.optionsBox = GroupBox(
			Dock = DockStyle.Top,
			Text = "Options",
			Height = 200)
		self.optionsBox.Controls.Add(self.jrkChoice)
		#endregion
		
		#region Report box
		self.reportTextBox = RichTextBox(
			Dock = DockStyle.Fill,
			ReadOnly = True)
		self.reportTextBox.Margin.All = 10
			
		self.reportBox = GroupBox(
			Dock = DockStyle.Fill,
			Text = "Report")
		self.reportBox.Controls.Add(self.reportTextBox)
		#endregion
		
		#region Add controls to view
		self.splitPanel = SplitContainer(
			Orientation = Orientation.Vertical, 
			FixedPanel = FixedPanel.Panel2,
			Dock = DockStyle.Fill,
			Width = 700,
			SplitterDistance = 200,
			Panel1MinSize = 200,
			Panel2MinSize = 400)
		
		self.splitPanel.Panel1.Controls.Add(self.mapView)
		self.splitPanel.Panel2.Controls.Add(self.reportBox)
		self.splitPanel.Panel2.Controls.Add(self.optionsBox)
		self.morphAnDataLayer = None
		
		self.Controls.Add(self.splitPanel)
		#endregion
		
		self.__InitializeJrkBox()
		self.__FillMapView()
	
	def __SelectedFeaturesChanged(self,o,e):
		txt = "Selected locations:\n"
		for feature in self.mapView.MapControl.SelectedFeatures:
			txt += "%s\n" % (feature.TransectLocation.Name)
		
		self.reportTextBox.Text = txt
		
	def __FillMapView(self):
		workspace = None
		for item in RootFolder.Items:
			if (isinstance(item,_MorphAnWorkSpace)):
				workspace = item
				break
		
		if workspace == None:
			return
		
		locations = _MorphAnDataExtensions.GetFilteredTransectLocations(workspace.MorphAnData)
		
		self.morphAnDataLayer = _MorphAnDataLayer(True, False, False,
				MorphAnData = workspace.MorphAnData,
				JarkusMeasurements = GetJarkusMeasurementsSet(self.jrkChoice.SelectedItem))
		self.mapView.Map.Layers.Add(self.morphAnDataLayer)
				
		if (self.mapView.Times.Length > 0):
			startTime = None
			if not(self.mapView.TimeSelectionStart == None):
				startTime = max(self.mapView.Times)
				
			self.mapView.SetCurrentTimeSelection(startTime,None)
				
	def __InitializeJrkBox(self):
		workspace = None
		for item in RootFolder.Items:
			if (isinstance(item,_MorphAnWorkSpace)):
				workspace = item
				break
		
		if workspace == None:
			return
			
		for jrk in workspace.MorphAnData.JarkusMeasurementsList:
			self.jrkChoice.Items.Add(jrk.Name)
			
		self.jrkChoice.SelectedIndex = 0
	
	def __JrkSelectedIndexChanged(self,comboBox,eventargs):
		PrintMessage("Selected: %s" % (self.jrkChoice.SelectedItem))
		if (self.morphAnDataLayer == None):
			return
		self.morphAnDataLayer.JarkusMeasurements = GetJarkusMeasurementsSet(self.jrkChoice.SelectedItem)
		
v = ReportView()
v.Show()
