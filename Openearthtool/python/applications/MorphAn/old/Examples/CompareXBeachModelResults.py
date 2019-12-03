from Libraries.Utils.Charting import *
from Libraries.XBeach.XBeach import *

#modelNames = ["XBeach (1D)","XBeach (1D) - 2"]
modelNames = []
for item in RootFolder.Items[1].Items:
	modelNames.append(item.Name)

chart = Chart()
chart.Name = "XBeach model comparison"
chart.BottomAxis.Title = "Cross-shore position [m]"
chart.LeftAxis.Title = "Height [m]"
chart.Legend.Visible = True
chart.Legend.Alignment = LegendAlignment.Bottom

modelName = modelNames[0]
for modelName in modelNames:
	profile = GetXBeachModelProfile(modelName,0)
	series = LineChartSeries()
	series.Title = modelName + " initial"
	for idx,val in enumerate(profile.XCoordinates):
		series.Add(val,profile.ZCoordinates[idx])
	series.Width = 2
	series.PointerVisible = False
	
	chart.Series.Add(series)
	
	profile = GetXBeachModelProfile(modelName,2000)
	
	series = LineChartSeries()
	series.Title = modelName + " 2000"
	for idx,val in enumerate(profile.XCoordinates):
		series.Add(val,profile.ZCoordinates[idx])
	series.Width = 2
	series.PointerVisible = False
	
	chart.Series.Add(series)

	profile = GetXBeachModelProfile(modelName)
	
	series = LineChartSeries()
	series.Title = modelName + " final"
	for idx,val in enumerate(profile.XCoordinates):
		series.Add(val,profile.ZCoordinates[idx])
	series.Width = 2
	series.PointerVisible = False
	
	chart.Series.Add(series)
	
	waterLevel = GetXBeachModelOutput(modelName,outputName="zs")
	
	series = LineChartSeries()
	series.Title = modelName + " water level"
	for idx,val in enumerate(waterLevel.XCoordinates):
		series.Add(val,waterLevel.ZCoordinates[idx])
	series.Width = 2
	series.PointerVisible = False
	
	chart.Series.Add(series)
	
ShowChart(chart)