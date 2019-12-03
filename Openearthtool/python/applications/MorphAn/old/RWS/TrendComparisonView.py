from Libraries.Utils.View import *
from Libraries.Utils.Project import *
from collections import namedtuple
from Libraries.Utils.Charting import *
from System import Double as _Double
from DelftTools.Utils import DateTimeExtensions as _DateTimeExtensions
from Libraries.MorphAn.Models import *
from System.Drawing import *
from operator import itemgetter, attrgetter

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
colors = [Color.DodgerBlue,
	Color.SeaGreen,
	Color.PaleVioletRed,
	Color.MediumOrchid,
	Color.LightGoldenrodYellow,
	Color.Purple,
	Color.BurlyWood]

def GetFont():
	font = Font(FontFamily('Arial'), 18.0, FontStyle.Regular, GraphicsUnit.Pixel)
	return font

def ShowTrendComparisonView(results,modelNames):
	v = View()
	v.Image = Bitmap(GetToolboxDir() + r"\RWS\Gemma.jpg")
	v.Text = "Trend vergelijking"
	font = GetFont()
	
	#region ChartView
	chartView = ChartView(Dock = DockStyle.Fill)
	v.ChildViews.Add(chartView) 
	
	chartView.Chart.LeftAxis.Title = "MKL trend [m/jaar]"
	chartView.Chart.RightAxis.Title = "Volume trend [m3/m/jaar]"
	chartView.Chart.BottomAxis.Title = "Raainummer"
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
	
	for idx,modelName in enumerate(modelNames):
		series = LineChartSeries()
		series.Title = modelName
		series.PointerSize = 6
		series.PointerVisible = True
		series.PointerLineColor = Color.Black
		series.PointerLineVisible = True
		series.Width = 2

		model = GetModel(modelName)
		if hasattr(model,'VolumeTrendModel'):
			series.VertAxis = VerticalAxis.Right
			series.PointerColor = colors[idx]
			series.PointerStyle = markers[0]
			series.Color = colors[idx]
			for trend in sorted(model.VolumeTrendModel.Trends.ResultList,key=attrgetter('Location')):
				if _Double.IsNaN(trend.OutputTrend):
					continue
				series.Add(trend.Location.Offset,trend.OutputTrend)
			iVolumeMarker = iVolumeMarker + 1
			
		else:
			series.PointerStyle = markers[1]
			series.PointerColor = colors[idx]
			series.Color = colors[idx]
			for tkl in sorted(model.ExpectedCoastLineModel.ExpectedCoastLineLocations.ResultList,key=attrgetter('Location')):
				if _Double.IsNaN(tkl.OutputTrend):
					continue
				series.Add(tkl.Location.Offset,tkl.OutputTrend)
			iMklMarker = iMklMarker + 1
			
		chartView.Chart.Series.Add(series)
	#endregion
	v.Controls.Add(chartView)
	v.Show()