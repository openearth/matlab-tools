#region Imports and includes
from operator import itemgetter, attrgetter
from Libraries.Utils.Charting import *
from Libraries.Utils.TransectOperations import *
from Libraries.MorphAn.MorphAnData import *
from Libraries.Utils.List import *

from DeltaShell.Plugins.MorphAn.Domain.Utils import *
from DelftTools.Utils import *
"""
from System.Drawing import Color
from System.Drawing.Drawing2D import DashStyle
"""
from Examples.Functions.BeachCharacteristics import *
#region

#region Initiate variables
waterLevel = 3.2
lowWaterLevel = -1.2
year = 2010
printto = 3; #0 : textDocuemtn in project,1 : file on system, opened in a text document,2: messages, 3: Graph
jarkusMeasurementsName = "Texel"
outputName = "Beach slopes"
outputFileName = "C:/Users/geer/Documents/testourput.txt"
#region

#region Open report (files) if needed
if printto == 1 :
	file = open(outputFileName,"w+")
	textDocument = TextDocument()
	textDocument.Name = outputName
	textDocument.Content = ""
if printto == 0 : 
	textDocument = TextDocument()
	textDocument.Name = outputName
	textDocument.Content = ""
if printto == 3 :
	alongshore = []
	beachSlopes = []
	beachWidths = []
	xLows = []
	xHighs = []
#region

for (transect) in sorted(GetJarkusMeasurements(jarkusMeasurementsName),key=attrgetter('TransectLocation')):
#region Calculation
	if not(transect.Time.Year == year) :
		continue
		
	xWaterLine, xLowWaterLine, beachWidth, beachSlope = CalculateBeachSlope(transect,waterLevel,lowWaterLevel)
	
	if (xWaterLine == None):
		continue
#region

#region Print/store result
	if printto == 0:
		textDocument.Content = textDocument.Content + "\n" + "Location {0}:".format(transect.Name)
		textDocument.Content = textDocument.Content + "\n" + "   Beach width              = {0:0.2f} [m]".format(beachWidth,"%0.2f")
		textDocument.Content = textDocument.Content + "\n" + "   Beach slope              = {0:0.5f} [-]".format(beachSlope,"%0.2f")
		textDocument.Content = textDocument.Content + "\n" + "   Position water level     = {0:0.2f} [m]".format(xWaterLine,"%0.2f")
		textDocument.Content = textDocument.Content + "\n" + "   Position low water level = {0:0.2f} [m]".format(xLowWaterLine,"%0.2f")
	if printto == 1 :
		file.write("Location {0}:\n".format(transect.Name))
		file.write("   Beach width              = {0:0.2f} [m]\n".format(beachWidth,"%0.2f"))
		file.write("   Beach slope              = {0:0.5f} [-]\n".format(beachSlope,"%0.2f"))
		file.write("   Position water level     = {0:0.2f} [m]\n".format(xWaterLine,"%0.2f"))
		file.write("   Position low water level = {0:0.2f} [m]\n".format(xLowWaterLine,"%0.2f"))
	if printto == 2 :
		print "Location {0}:".format(transect.Name)
		print "   Beach width              = {0:0.2f} [m]".format(beachWidth,"%0.2f")
		print "   Beach slope              = {0:0.5f} [-]".format(beachSlope,"%0.2f")
		print "   Position water level     = {0:0.2f} [m]".format(xWaterLine,"%0.2f")
		print "   Position low water level = {0:0.2f} [m]".format(xLowWaterLine,"%0.2f")
	if printto == 3 :
		alongshore.append(transect.TransectLocation.Offset)
		beachSlopes.append(beachSlope)
		beachWidths.append(beachWidth)
		xLows.append(xLowWaterLine)
		xHighs.append(xWaterLine)
#region

#region Open output
if printto == 0 : 
	Gui.CommandHandler.AddItemToProject(textDocument)
	Gui.DocumentViewsResolver.OpenViewForData(textDocument)
if printto == 1 :
	file.close()
	file2 = open(outputFileName,"r")
	lines = file2.readlines()
	
	for line in lines:
		textDocument.Content = textDocument.Content + line
	Gui.CommandHandler.AddItemToProject(textDocument)
	Gui.DocumentViewsResolver.OpenViewForData(textDocument)
if printto == 3:
	chart = CreateChart()
	chart.Title = "Beach characteristics"
	chart.Name = "Beach characteristics"
	chart.Legend.Visible = 1
	chart.Legend.Alignment = LegendAlignment.Right
	chart.BottomAxis.Title = "Alongshore position"
	chart.LeftAxis.Title = "Value"
	
	series = AddToChartAsBar(chart,alongshore,beachWidths,"Beach width")
	series.Color = Color.ForestGreen
	series = AddToChartAsLine(chart,alongshore,xLows,"x Position low water")
	series.Color = Color.BlueViolet
	series.Width = 2
	series.PointerVisible = 0
	series = AddToChartAsLine(chart,alongshore,xHighs,"x Position high water")
	series.Color = Color.OrangeRed
	series.Width = 2
	series.PointerVisible = 0
	series = AddToChartAsLine(chart,alongshore,beachSlopes,"Beach slope")
	series.Color = Color.SandyBrown
	series.Width = 2
	series.PointerVisible = 0
	series.Visible = False
		
	ShowChart(chart)
#region