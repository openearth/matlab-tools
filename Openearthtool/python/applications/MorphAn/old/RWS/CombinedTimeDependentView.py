from Libraries.Utils.View import *
from Libraries.Utils.Project import *
from collections import namedtuple
from Libraries.Utils.Charting import *
from System import Double as _Double
from DelftTools.Utils import DateTimeExtensions as _DateTimeExtensions
from Libraries.MorphAn.Models import *
from System.Drawing import *

class TableObject():
	Location = None

volumeColor = Color.DarkRed
mklColor = Color.DodgerBlue
markers = [PointerStyles.Circle,
	PointerStyles.Diamond,
	PointerStyles.DownTriangle,
	PointerStyles.Hexagon,
	PointerStyles.LeftTriangle,
	PointerStyles.PolishedSphere,
	PointerStyles.Rectangle,
	PointerStyles.RightTriangle,
	PointerStyles.Sphere,
	PointerStyles.Triangle]
	
def TableSelectionChanged(o,e,view,table,chartView, results, modelNames, allSeries):
	# retrieve selection (selected location)
	selectedLocation = table.CurrentFocusedRowObject.Location
	
	# Clear what is currently in the figure
	chartView.Chart.Series.Clear()
	chartView.Title = selectedLocation.Name
	
	#region Add all results
	for iModel,name in enumerate(modelNames):
		# Find series corresponding to the selected model
		series = allSeries[name]
		
		# replace data points in series
		series.Clear()
		result = results[selectedLocation][iModel]
		if hasattr(result,'InputMklResults'):
			# This is an expected coastline location (TKL)
			for mkl in result.InputMklResults:
				if _Double.IsNaN(mkl.OutputXMkl):
					continue
				
				series.Add(_DateTimeExtensions.ToDecimalYear(mkl.Time), mkl.OutputXMkl);

		if hasattr(result,'InputVolumes'):
			# This is a Volume Trend
			for volume in result.InputVolumes:
				if _Double.IsNaN(volume.Volume):
					continue

				series.Add(_DateTimeExtensions.ToDecimalYear(volume.Time),volume.Volume)
				series.VertAxis = VerticalAxis.Right
		
		# Add the series to chart
		chartView.Chart.Series.Add(series)
	#endregion
	
def GetFont():
	font = Font(FontFamily('Arial'), 18.0, FontStyle.Regular, GraphicsUnit.Pixel)
	return font

def ShowView(results,modelNames):
	v = View()
	v.Image = Bitmap(GetToolboxDir() + r"\RWS\QL.jpg")
	v.Text = "Model vergelijking"
	font = GetFont()
	
	#region ChartView
	chartView = ChartView(Dock = DockStyle.Fill)
	v.ChildViews.Add(chartView) 
	
	chartView.Chart.LeftAxis.Title = "MKL positie [m + R.S.P.]"
	chartView.Chart.RightAxis.Title = "Volume [m3/m]"
	chartView.Chart.BottomAxis.Title = "Tijd [jaren]"
	chartView.Chart.Legend.Visible = True
	chartView.Chart.Font = GetFont()
	chartView.Chart.Legend.Font = GetFont()
	chartView.Chart.LeftAxis.LabelsFont = GetFont()
	chartView.Chart.LeftAxis.TitleFont = GetFont()
	chartView.Chart.BottomAxis.LabelsFont = GetFont()
	chartView.Chart.BottomAxis.TitleFont = GetFont()
	chartView.Chart.RightAxis.LabelsFont = GetFont()
	chartView.Chart.RightAxis.TitleFont = GetFont()
	chartView.Controls[0].Header.Font.Color = Color.Black
	chartView.Controls[0].Axes.Right.Grid.Color = volumeColor
	chartView.Controls[0].Axes.Right.Title.Font.Color = volumeColor
	chartView.Controls[0].Axes.Right.Labels.Font.Color = volumeColor
	
	iVolumeMarker = 0
	iMklMarker = 0
	
	allSeries = dict()
	for modelName in modelNames:
		series = PointChartSeries()
		series.Title = modelName
		series.Size = 6
		model = GetModel(modelName)
		if hasattr(model,'VolumeTrendModel'):
			series.VertAxis = VerticalAxis.Right
			series.Color = volumeColor
			series.Style = markers[iVolumeMarker]
			iVolumeMarker = iVolumeMarker + 1
		else:
			series.Style = markers[iMklMarker]
			series.Color = mklColor
			iMklMarker = iMklMarker + 1
			
		allSeries[modelName] = series
	#endregion
	
	#region Table
	table = TableView(Dock = DockStyle.Fill)
	
	TableSelectionChangedCallback = lambda o, eventargs: TableSelectionChanged(o, eventargs, v, table, chartView, results, modelNames, allSeries)
	table.FocusedRowChanged += TableSelectionChangedCallback
	table.Columns.Clear();
	table.AutoGenerateColumns = False
	table.ColumnAutoWidth = True
	table.AddColumn("Location","Locatie",120,True)
	for name in modelNames:
		table.AddColumn(name.replace(' ','_'),name,200,True)
	
	resultlist = []
	for result in results:
		obj = TableObject()
		obj.Location = result
		for idx,name in enumerate(modelNames):
			setattr(obj,name.replace(' ','_'),not(results[result][idx] == None))
		resultlist.append(obj)
	
	table.Data = resultlist
	v.ChildViews.Add(table)
	#endRegion
	
	#region Add controls to view
	splitPanel = SplitContainer(
		Orientation = Orientation.Horizontal, 
		FixedPanel = FixedPanel.Panel2,
		Dock = DockStyle.Fill,
		Width = 700,
		SplitterDistance = 300,
		Panel1MinSize = 200,
		Panel2MinSize = 200)
	
	splitPanel.Panel1.Controls.Add(chartView)
	splitPanel.Panel2.Controls.Add(table)
	
	v.Controls.Add(splitPanel)
	
	table.FocusedRowIndex = 0
	#endregion
	
	v.Show()