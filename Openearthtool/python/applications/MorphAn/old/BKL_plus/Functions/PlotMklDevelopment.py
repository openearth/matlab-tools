from BKL_plus.ProposedBkl import *
from Libraries.Utils.Project import *
from Libraries.Utils.Charting import *
import numpy as _np
import itertools as _iter
from operator import itemgetter, attrgetter
from System import Double as _Double
from System.Drawing import Font as _Font
from System.Drawing import Image as _Image

def CreateMklAlongshorePlot(modelName,areaName):
	mainModel = FindModel(modelName)
	if (mainModel == None):
		PrintMessage("Model not found, please specify a correct model name")
	
	for v in Gui.DocumentViews:
		if v.Text == areaName:
			Gui.DocumentViews.ActiveView = v
			return
	
	mklModel = mainModel.MomentaryCoastLineModel
	
	startColor = Color.GreenYellow
	endColor = Color.DarkBlue
	years = [1980, 1990, 2000, 2007, 2009, 2011, 2013, 2014]
	years = [2000, 2005, 2010, 2014]

	chartView = CreateChartView()
	chartView.Image = _Image.FromFile(GetToolboxDir() + "\\Bkl_plus\\Functions\\graph-lines.png")
	chartView.Text = modelName
	chart = chartView.Chart
	chart.Name = "MKL alongshore"
	
	for key,group in _iter.groupby(sorted(mklModel.MomentaryCoastLineLocations.ResultList,key=attrgetter('Year')), attrgetter('Year')):
		if (key not in years):
			continue
	
		idx = years.index(key)
		prc = float(idx) / (len(years)-1)
		print startColor.R
		color = Color.FromArgb(255,
					int(startColor.R*(1-prc) + prc*endColor.R),
					int(startColor.G*(1-prc) + prc*endColor.G),
					int(startColor.B*(1-prc) + prc*endColor.B))
		line = LineChartSeries(
			Title = "MKL %i" % key,
			PointerColor = color,
			PointerSize = 2,
			Width = 1,
			Color = color,
			PointerLineColor = color,
			DashStyle = DashStyle.Dash,
			Visible = True
			)
			
		for mkl in sorted(group,key=attrgetter('Location')):
			if (_Double.IsNaN(mkl.OutputXMkl)):
				continue
			line.Add(mkl.Location.Offset/100,mkl.OutputXMkl)
		
		chart.Series.Add(line)
	
	tklModel = mainModel.ExpectedCoastLineModel
	bklLine = LineChartSeries(
		Title = "BKL (2001)",
		PointerColor = Color.Red,
		PointerLineColor = Color.Black,
		PointerSize = 4,
		Width = 2,
		Color = Color.Red,
		DashStyle = DashStyle.Solid)
	
	for tkl in sorted(tklModel.ExpectedCoastLineLocations.ResultList,key=attrgetter('Location')):
		if (_Double.IsNaN(tkl.InputBklPosition)):
			continue
		
		bklLine.Add(tkl.Location.Offset/100,tkl.InputBklPosition)
	
	chart.Series.Add(bklLine)
	
	bklProposed = ProposedBkl(areaName)
	bklLineProposed = LineChartSeries(
		Title = "Voorstel nieuwe BKL",
		PointerColor = Color.Yellow,
		PointerLineColor = Color.Black,
		PointerSize = 4,
		Width = 2,
		Color = Color.Black,
		DashStyle = DashStyle.Solid)
	
	for idx,val in enumerate(bklProposed[0]):
		if (val/float(100) > max(list(bklLine.XValues))):
			break
		bklLineProposed.Add(bklProposed[0][idx]/float(100),bklProposed[1][idx])
	
	chart.Series.Add(bklLineProposed)

	
	Gui.DocumentViews.Add(chartView)
	
	InvertBottomAxes(chartView)
		
	#chartView.Controls[0].Chart.Legend.CustomPosition = True
	#chartView.Controls[0].Chart.Legend.Left = 800
	#chartView.Controls[0].Chart.Legend.Top = 100
	#chartView.Controls[0].Chart.Legend.Height = 400
	#chartView.Controls[0].Chart.Legend.MaxNumRows = 10
	#chartView.Controls[0].Chart.Legend.Visible = True
	
	chart.Legend.Visible = True
	chart.Legend.Alignment = LegendAlignment.Right
	
	chart.BottomAxis.Title = "Kustraai (metrering in decameters)"
	chart.LeftAxis.Title = "MKL ligging"
		
	chart.Legend.Font = _Font(chart.Legend.Font.FontFamily, 14)
	chart.Font = _Font(chart.Font.FontFamily, 14)
	chart.LeftAxis.TitleFont = _Font(chart.LeftAxis.TitleFont.FontFamily, 14)
	chart.BottomAxis.TitleFont = _Font(chart.BottomAxis.TitleFont.FontFamily, 14)
	chart.BottomAxis.LabelsFont = _Font(chart.BottomAxis.LabelsFont.FontFamily, 14)
	chart.LeftAxis.LabelsFont = _Font(chart.LeftAxis.LabelsFont.FontFamily, 14)
