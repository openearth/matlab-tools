from Libraries.Utils.View import *
from Libraries.Utils.Project import *
from collections import namedtuple
from Libraries.Utils.Charting import *
from System import Double as _Double
from DelftTools.Utils import DateTimeExtensions as _DateTimeExtensions
from Libraries.MorphAn.Models import *
from System.Drawing import *
from operator import itemgetter, attrgetter
from DeltaShell.Plugins.MorphAn.Models.CoastalDevelopment.ExpectedCoastLine import ExpectedCoastLineModel as _ExpectedCoastLineModel

volumeColor = Color.DarkRed
mklColor = Color.DodgerBlue
markers = [PointerStyles.Circle,
	PointerStyles.Diamond,
	PointerStyles.DownTriangle,
	PointerStyles.LeftTriangle,
	PointerStyles.Hexagon,
	PointerStyles.PolishedSphere,
	PointerStyles.Rectangle,
	PointerStyles.RightTriangle,
	PointerStyles.Sphere,
	PointerStyles.Triangle]
colors = [Color.DodgerBlue,
	Color.SeaGreen,
	Color.PaleVioletRed,
	Color.LightGoldenrodYellow,
	Color.MediumOrchid,
	Color.Purple,
	Color.BurlyWood]

def GetFont():
	font = Font(FontFamily('Arial'), 18.0, FontStyle.Regular, GraphicsUnit.Pixel)
	return font

def ShowBklTklView():
	models = Application.GetAllModelsInProject()
	tklModel = None
	for model in models:
		if isinstance(model,_ExpectedCoastLineModel):
			tklModel = model
			break
	
	if tklModel == None:
		return
		
	v = View()
	v.Image = Bitmap(GetToolboxDir() + r"\RWS\Gemma.jpg")
	v.Text = "Trend vergelijking"
	font = GetFont()
	
	#region ChartView
	chartView = ChartView(Dock = DockStyle.Fill)
	v.ChildViews.Add(chartView) 
	
	chartView.Chart.LeftAxis.Title = "TKL - BKL [m]"
	chartView.Chart.BottomAxis.Title = "Raainummer"
	chartView.Chart.Legend.Visible = True
	chartView.Chart.Font = GetFont()
	chartView.Chart.Legend.Font = GetFont()
	chartView.Chart.LeftAxis.LabelsFont = GetFont()
	chartView.Chart.LeftAxis.TitleFont = GetFont()
	chartView.Chart.BottomAxis.LabelsFont = GetFont()
	chartView.Chart.BottomAxis.TitleFont = GetFont()
	chartView.Controls[0].Header.Font.Color = Color.Black
	
	firstTkl = model.ExpectedCoastLineLocations.ResultList[0]
	for idx in [0,2,4]:
		if (firstTkl.OutputDatesToExtrapolateTo.Count-1 < idx):
			break
		
		series = LineChartSeries()
		series.Title = "TKL - BLK " + firstTkl.OutputDatesToExtrapolateTo[idx].Year.ToString()
		series.PointerSize = 6
		series.PointerVisible = True
		series.PointerLineColor = Color.Black
		series.PointerLineVisible = True
		series.Width = 2
		series.Color = colors[idx]
		series.PointerColor = colors[idx]
		series.PointerStyle = markers[idx]
		
		for tkl in model.ExpectedCoastLineLocations.ResultList:
			if (_Double.IsNaN(tkl.OutputXLocationTkl[idx]) or _Double.IsNaN(tkl.InputBklPosition)):
				continue
			series.Add(tkl.Location.Offset,tkl.OutputXLocationTkl[idx] - tkl.InputBklPosition)
		
		chartView.Chart.Series.Add(series)
	#endregion
	v.Controls.Add(chartView)
	v.Show()