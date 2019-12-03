from Libraries.Utils.TransectOperations import *
from Libraries.Duros.Duros import *
from Libraries.MorphAn.MorphAnData import *
from Libraries.Utils.Charting import *

#region Constants
situatie = "Parkeergarage Egmond"
modelName = "Dune safety model"
raainummer = 3810
jaar = 2003
nwoVoorkant = -148
nwoAchterkant = -210
nwoOnderkant = 2
xSpoor1 = -150
xSpoor2 = -260
nwoName = "Grenzen " + situatie
xmin = -350
xmax = 350
zmin = -6
zmax = 18
exportName = "d:\Test\Test.tiff"
exportSize = [900, 300]
showPlot = False
plotGrensprofiel = True
exportFigure = False

#endregion

#region Retrieve data

boundaryProfile = None
model = GetModel(modelName)

for bp in model.BoundaryProfileModel.ModelResult.ResultList :
	if (bp.Location.Offset == raainummer and bp.Year == jaar):
		boundaryProfile = bp
		break

if (boundaryProfile == None) :
	raise Exception("Could not find result for {0} ({1}) in model '{2}'".format(raainummer,jaar,modelName))

boundaryProfile.Input.XDuneRow = Double.NaN
boundaryProfile.ErosionResult.Input.XDuneRow = Double.NaN

#endregion

#region Create plot
title = "{0} - Steunraai {1} ({2})".format(situatie,raainummer,jaar)

chartView = CreateChartView()
chart = PlotBoundaryProfile(boundaryProfile,title,False,10,chartView)
chart.Title = title
chart.LeftAxis.Title = "Hoogte (m+NAP)"
chart.LeftAxis.Automatic = False
chart.LeftAxis.Minimum = zmin
chart.LeftAxis.Maximum = zmax
chart.BottomAxis.Title = "Afstand (m+RSP)"
chart.BottomAxis.Automatic = False
chart.BottomAxis.Minimum = xmin
chart.BottomAxis.Maximum = xmax
chartView.Title = title

hotelPolygon = CreateTrimmedProfile(boundaryProfile.Input.InputProfile,nwoAchterkant,nwoVoorkant)
xValues = [None]*(hotelPolygon.NumPoints+2)
zValues = [None]*(hotelPolygon.NumPoints+2)
xValues[0] = nwoAchterkant
zValues[0] = nwoOnderkant
xValues[hotelPolygon.NumPoints+1] = nwoVoorkant
zValues[hotelPolygon.NumPoints+1] = nwoOnderkant
for idx,x in enumerate(hotelPolygon.XCoordinates):
	xValues[idx+1] = x
	zValues[idx+1] = hotelPolygon.ZCoordinates[idx]
series = AddToChartAsPolygon(chart,xValues,zValues,nwoName)
series.UseHatch = False
series.Color = Color.BlanchedAlmond
series.LineColor = Color.DarkSlateGray
series.LineStyle = DashStyle.Dash
series.Transparency = 50

zLevelVoorkant = CalculateZLevel(boundaryProfile.Input.InputProfile,nwoVoorkant)
zLevelAchterkant = CalculateZLevel(boundaryProfile.Input.InputProfile,nwoAchterkant)
line = AddToChartAsLine(chart,[nwoAchterkant, nwoAchterkant, nwoAchterkant, nwoVoorkant, nwoVoorkant, nwoVoorkant],[zmin, zLevelAchterkant, nwoOnderkant, nwoOnderkant, zmin, zLevelVoorkant],nwoName)
line.Color = Color.DarkOrchid
line.Width = 3
line.PointerVisible = False

zSpoor1 = CalculateZLevel(boundaryProfile.Input.InputProfile,xSpoor1)
spoor1Series = AddToChartAsPoint(chart,[xSpoor1],[zSpoor1],"Spoor 1")
spoor1Series.Style = PointerStyles.Rectangle
spoor1Series.Size = 5
spoor1Series.LineVisible = True
spoor1Series.LineColor = Color.Black
spoor1Series.Color = Color.Aquamarine

zSpoor2 = CalculateZLevel(boundaryProfile.Input.InputProfile,xSpoor2)
spoor2Series = AddToChartAsPoint(chart,[xSpoor2],[zSpoor2],"Spoor 2")
spoor2Series.Style = PointerStyles.Diamond
spoor2Series.Size = 7
spoor2Series.LineVisible = True
spoor2Series.LineColor = Color.Black
spoor2Series.Color = Color.Yellow

#region Translate series names and toggle visibility
afslagpuntSeries = None

for series in chart.Series :
	series.Title = series.Title.replace("Initial profile","Beginprofiel")
	if (series.Title.startswith("Duros+ Profile change")):
		series.Title = "Afslagberekening Duros+"
	if (series.Title.startswith("R (x =")):
		series.Title = "Afslagpunt R"
		series.Color = Color.GreenYellow
		series.Size = 5
		series.LineVisible = True
		series.LineColor = Color.Black
		afslagpuntSeries = series
	if (series.Title.startswith("T Volume")):
		series.Title = "T Volume"
	if (series.Title.startswith("A Volume")):
		series.Title = "A Volume"
	if (series.Title.startswith("Maximum storm surge level")):
		series.Title = "Rekenpeil"
	if (series.Title.startswith("Boundary profile (")):
		series.Title = "Grensprofiel"
		series.Visible = plotGrensprofiel
	if (series.Title.startswith("Landward boundary of sea defence")):
		series.Title = "Grensprofiel maaiveld"
		series.Color = Color.LightSkyBlue
		series.Visible = plotGrensprofiel	
	
	if (series.Title.startswith("P (x =") or 
	   series.Title.startswith("Precision") or 
	   series.Title.startswith("Extrapolation") or 
	   series.Title.startswith("Boundary")):
		series.Visible = False

	if (series.Title.startswith("Extrapolation of base point to ground level") and plotGrensprofiel):
		series.Visible = True
		series.Color = Color.DimGray

chart.Series.Remove(afslagpuntSeries)
chart.Series.Add(afslagpuntSeries)
#endregion

#endregion

#region Show / export

if (PlotDuros) :
	Gui.DocumentViews.Add(chartView)

#if (exportFigure not None):
	chart.ExportAsImage(exportName,exportSize[0],exportSize[1])

#endregion