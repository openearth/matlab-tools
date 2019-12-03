from BKL_plus.ProposedBkl import *
from Libraries.Utils.Charting import *
from Libraries.MorphAn.Models import *
from DelftTools.Utils import *
from Libraries.Utils.Project import PrintMessage
from DeltaShell.Plugins.MorphAn.Models.CoastalDevelopment.ExpectedCoastLine import ExpectedCoastLineLocation as _ExpectedCoastLineLocation
from DelftTools.Functions.Binding import FunctionBindingListRow as _FunctionBindingListRow
from DeltaShell.Plugins.MorphAn.Forms.Controls import MorphAnTable as _MorphAnTable
from System.Drawing import Font as _Font
from System import Double as _Double

modelName = "Scheveningen"

def OpenAndInitializeTklPlot(modelName, areaName):
	global newBklLine
	model = GetModel(modelName)
	if (model == None):
		NoViewMessage()
		return
	
	data = model.ExpectedCoastLineModel.ExpectedCoastLineLocations
	Gui.DocumentViewsResolver.OpenViewForData(data)
	view = Gui.DocumentViews.ActiveView

	for series in view.ChildViews[0].Chart.Series:
		if (series.Tag == "NewBklTag"):
			"""Already subscribed and series was already added"""
			return
	
	RegisterCallback(view, areaName)
	newBklLine = AddLineToFigure(view)
	PlotNewBkl(view,areaName)
	
	chart = view.Controls[0].Panel1.Controls[0].ChartView.Chart
	chart.Legend.Font = _Font(chart.Legend.Font.FontFamily, 14)
	chart.Font = _Font(chart.Font.FontFamily, 14)
	chart.LeftAxis.TitleFont = _Font(chart.LeftAxis.TitleFont.FontFamily, 14)
	chart.BottomAxis.Automatic = False
	chart.BottomAxis.Minimum = 2006
	chart.BottomAxis.TitleFont = _Font(chart.BottomAxis.TitleFont.FontFamily, 14)
	
def TklViewSelectionChanged(o,e,view,areaname) : 
	PlotNewBkl(view,areaname)
	
def PlotNewBkl(view,areaname):
	global newBklLine
	tkl,chartView = GetCurrentSelectedTkl(view)
	if (tkl == None):
		return
	
	xBklOld = tkl.InputBklPosition
	xBklNew = None
	bklProposed = ProposedBkl(areaname)
	for idx,val in enumerate(bklProposed[0]):
		if (val == tkl.Location.Offset):
			xBklNew = bklProposed[1][idx]
			break
	
	oldBklLine = GetBklLines(chartView)
	if (oldBklLine != None and not _Double.IsNaN(xBklOld)):
		oldBklLine.Clear()
		oldBklLine.Add(1990,xBklOld)
		oldBklLine.Add(2015,xBklOld)
	
	newBklLine.Clear()
	newBklLine.Add(2015,xBklNew)
	newBklLine.Add(chartView.Chart.BottomAxis.Maximum,xBklNew)
	
def GetBklLines(chartView):
	oldBklLine = None
	for series in chartView.Chart.Series:
		if (series.Tag == "BKLTag"):
			oldBklLine = series
	
	return oldBklLine

def GetCurrentSelectedTkl(view):
	tklChartControl = view.Controls[0].Panel1.Controls[0]
	currentViewTitle = view.Controls[0].Panel1.Controls[0].Controls[0].Title
	
	tkl = None
	for result in view.Data.ResultList:
		if (result.Location.Name == currentViewTitle):
			tkl = result
			break
	return tkl,tklChartControl.ChartView
	
def NoViewMessage():
	PrintMessage("This function needs a filled output view with Expected coastline positions (TKL)",0)
	PrintMessage("Please add a coastal development model, run it and open the output of the expected coastline model")



def RegisterCallback(view, areaName):
	morphAnTable = None
	for control in view.Controls:
		if (hasattr(control,"Panel2")):
			for panelcontrol in control.Panel2.Controls:
				if (isinstance(panelcontrol,_MorphAnTable)):
					morphAnTable = panelcontrol
					break
		if (morphAnTable != None):
			break
			
	TklViewSelectionChangedCallback = lambda o, eventargs, tklView=view, a = areaName: TklViewSelectionChanged(o,eventargs,tklView, a)
	
	morphAnTable.SelectionChanged += TklViewSelectionChangedCallback
	#morphAnTable.SelectionChanged -= TklViewSelectionChangedCallback

def AddLineToFigure(view):
	chartView = view.ChildViews[0]
	line = LineChartSeries(
			Title = "Voorgestelde BKL", 
			Tag = "NewBklTag",
			PointerVisible = False,
			Width = 3,
			Color = Color.DodgerBlue,
			DashStyle = DashStyle.Dash
			)
	chartView.Chart.Series.Add(line)
	return line