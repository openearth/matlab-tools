#region import
from DelftTools.Controls.Swf.Charting import *
from DelftTools.Controls.Swf.Charting.Series import *
from System.Drawing import Color
from System.Drawing.Drawing2D import DashStyle
#endregion

#region CreateChart
def CreateChart():
	"""
	Returns a new Delta Shell Chart object
	"""
	return Chart()
	
#endregion

#region CreateChartView
def CreateChartView():
	"""
	Creates a Delta Shell ChartView object used to visualize a chart in the GUI
	"""
	return ChartView()
	
#endregion
	
#region Add series to a Delta Shell Chart

def AddToChartAsLine(chart,x,y,name):
	"""
	Adds a Line to a Chart
	@param x: X values of the series to create
	@param y: Y values of the series to create
	#param name: Name/Title of the series that appears in the Chart toolwindow and legend
	"""
	
	series = LineChartSeries()
	series.Title = name
	for idx,xValue in enumerate(x):
		series.Add(xValue,y[idx])
	chart.Series.Add(series)
	return series
		
def AddToChartAsArea(chart,x,y,name):
	"""
	Adds an AreaSeries to a Chart
	@param x: X values of the series to create
	@param y: Y values of the series to create
	#param name: Name/Title of the series that appears in the Chart toolwindow and legend
	"""
	
	series = AreaChartSeries()
	series.Title = name
	for idx,xValue in enumerate(x):
		series.Add(xValue,y[idx])
	chart.Series.Add(series)
	return series
	
def AddToChartAsPolygon(chart,x,y,name):
	"""
	Adds a Polygon to a Chart
	@param x: X values of the series to create
	@param y: Y values of the series to create
	#param name: Name/Title of the series that appears in the Chart toolwindow and legend
	"""
	
	series = PolygonChartSeries()
	series.Title = name
	for idx,xValue in enumerate(x):
		series.Add(xValue,y[idx])
	chart.Series.Add(series)
	return series

def AddToChartAsBar(chart,x,y,name):
	"""
	Adds a Bar series to a Chart
	@param x: X values of the series to create
	@param y: Y values of the series to create
	#param name: Name/Title of the series that appears in the Chart toolwindow and legend
	"""
	
	series = BarSeries()
	series.Title = name
	for idx,xValue in enumerate(x):
		series.Add(xValue,y[idx])
	chart.Series.Add(series)
	return series

def AddToChartAsPoint(chart,x,y,name):
	"""
	Adds a Point series to a Chart
	@param x: X values of the series to create
	@param y: Y values of the series to create
	#param name: Name/Title of the series that appears in the Chart toolwindow and legend
	"""
	
	series = PointChartSeries()
	series.Title = name
	for idx,xValue in enumerate(x):
		series.Add(xValue,y[idx])
	chart.Series.Add(series)
	return series

#endregion

#region Undocumented
def FindTeeChart(chartView):
	import clr
	clr.AddReference('TeeChart')
	from Steema.TeeChart import TChart as _TChart

	teeChart = None
	for control in chartView.Controls:
		if (isinstance(control,_TChart)):
			teeChart = control
	
	return teeChart

def InvertBottomAxes(chartView):
	teeChart = FindTeeChart(chartView)
	if (teeChart != None):
		teeChart.Chart.Axes.Bottom.Inverted = True
	
def InvertLeftAxes(chartView):
	teeChart = FindTeeChart(chartView)
	if (teeChart != None):
		teeChart.Chart.Axes.Left.Inverted = True
	
#endregion

#region ShowChart
def ShowChart(chart):
	"""
	Opens a view in the interface that shows the specified chart
	@param chart: The chart to present in the GUI
	"""
	
	# Do not add the chart as item to the project yet. Opening the chart twice will clear all data in it. This should be fixed in the coming release
	# Gui.CommandHandler.AddItemToProject(chart)
	Gui.DocumentViewsResolver.OpenViewForData(chart)

#endregion