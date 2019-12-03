from Libraries.Utils.Charting import *

# 1 Create a Chart
chart = CreateChart()

# 2 Add line series
lineSeries = AddToChartAsLine(chart, [0,1,2,3], [3,4,5,6], 'line')
barSeries = AddToChartAsBar(chart, [0,1,2,3], [1,1,2,2], 'bar')
pointSeries = AddToChartAsPoint(chart, [0,1,2,3], [4,3,3,4], 'point')
areaSeries = AddToChartAsArea(chart, [0,1,2,3], [0.5,0.5,1,2], 'area')

# Configure the bar series
barSeries.Color = Color.LightBlue
barSeries.LineVisible = True
barSeries.LineColor = Color.BlueViolet
barSeries.LineWidth = 3

# Configure the line series
lineSeries.Color = Color.Red
lineSeries.Width = 3
lineSeries.PointerVisible = True
lineSeries.PointerSize = 5
lineSeries.PointerColor = Color.Red
lineSeries.PointerLineVisible = True
lineSeries.PointerLineColor = Color.DarkRed
lineSeries.Transparency = 50

# Configure the point series
pointSeries.Color = Color.DarkGreen
pointSeries.LineVisible = True
pointSeries.LineColor = Color.Red
pointSeries.Size = 5 

# Configure the area series
areaSeries.Color = Color.Yellow
areaSeries.Transparency = 50 # %
areaSeries.LineColor = Color.Green
areaSeries.LineWidth = 2
areaSeries.PointerVisible = True
areaSeries.PointerSize = 3
areaSeries.PointerColor = Color.Red
areaSeries.PointerLineVisible = False

# Configure the chart
chart.TitleVisible = True
chart.Title = "Test chart"
chart.BackGroundColor = Color.White
chart.Legend.Visible = True

# Configure the bottom axis
chart.BottomAxis.Automatic = False
chart.BottomAxis.Minimum = 1
chart.BottomAxis.Maximum = 6
chart.BottomAxis.Title = "index"

# Configure the left axis
chart.LeftAxis.Title = "Value"

# 3 Show chart
ShowChart(chart)

# Export the chart as an image (width:1000 height: 1000)
chart.ExportAsImage("D:\\testImage.jpg", 1000,1000)