#region Imports and includes
from operator import itemgetter, attrgetter
from Libraries.MorphAn.TransectOperations import *
from Libraries.MorphAn.MorphAnData import *
from Libraries.Utils.Charting import *
from DeltaShell.Plugins.MorphAn.Domain.Utils import TransectExtensions as _TransectExtensions

#endregion

#region CalculateBeachSlope
def CalculateBeachSlope(transect,zHigh,zLow) :
	"""
	Calculates position of low- and high water, beach width and beach slope.
	@param transect: The input profile used to calculate beach width etc.
	@param waterLevel
	"""
	
	# Bereken kruispunten tussen profiel en hoog / laagwater
	highWaterIntersections = _TransectExtensions.HorizontalIntersections(transect,zHigh)
	lowWaterIntersections = _TransectExtensions.HorizontalIntersections(transect,zLow)
	
	# Indien geen kruispunten -> geen resultaat
	if (lowWaterIntersections.Count == 0 or highWaterIntersections.Count == 0) :
		return None, None, None, None
		
	# Zoek meest zeewaarts hoogwater kruispunt
	xHighWater = highWaterIntersections[0].X
	"""Take most seaward intersection"""
	for coordinate in highWaterIntersections :
		if coordinate.X > xHighWater : 
			xHighWater = coordinate.X
	
	# Zoek meest zeewaarts laagwater kruispunt
	xLowWaterLine = lowWaterIntersections[0].X
	"""Take most seaward intersection"""
	for coordinate in lowWaterIntersections :
		if coordinate.X > xLowWaterLine : 
			xLowWaterLine = coordinate.X
			
	# Bereken strandbreedte
	beachWidth = xLowWaterLine - xHighWater
	
	# Strandbreedte groter dan 800 meter? => Neem niet op in de resultaten
	if (beachWidth == 0 or beachWidth > 800) :
		return None, None, None, None
		
	# Bereken strandhelling
	beachSlope = (zHigh - zLow) / beachWidth
	
	return xHighWater, xLowWaterLine, beachWidth, beachSlope
#endregion

def CalculateBeachChagacteristics(jrkName,lw,hw,year):
	#region Instellingen
	"""	
	hw = 3.2							# Niveau van hoogwater (m + NAP)
	lw = -1.2							# Niveau van laag water (m + NAP)
	year = 2010							# Jaar dat moet worden geanalyzeerd
	jrkName = "Texel"					# Naam van de set met JARKUS metingen
	"""	
	#endregion
	
	#region Initializatie
	alongshore = []
	beachSlopes = []
	beachWidths = []
	xLows = []
	xHighs = []
	
	#endregion
	
	#region "Loop"
	"""
	Ga een voor een door alle metingen in de geselecteerde set en sorteer deze op locatie (TransectLocation)
	"""
	for (transect) in sorted(GetJarkusMeasurements(jrkName),key=attrgetter('TransectLocation')):
		
		""" Sla metingen uit een ander jaar over """
		if not(transect.Time.Year == year) :
			continue
	
		""" 
		Bereken strandbreedte en helling.
		Probeer deze functie te vervangen door een functie die .. berekent
		"""
		xWaterLine, xLowWaterLine, beachWidth, beachSlope = CalculateBeachSlope(transect,hw,lw)
				
		if (xWaterLine == None):
			""" Neem lege resultaten niet op in het plaatje. """
			continue
	
		""" Bewaar de berekende getallen in lijstjes, zodat we ze later kunnen plotten """
		alongshore.append(transect.TransectLocation.Offset)
		beachSlopes.append(beachSlope)
		beachWidths.append(beachWidth)
		xLows.append(xLowWaterLine)
		xHighs.append(xWaterLine)
		
	#endregion
	
	#region Visualiseer resultaat
	""" Maak figuur aan en specificeer titels van de assen """
	chart = CreateChart()
	chart.Name = "Karakteristieken: %s (%d)" % (jrkName,year)
	chart.BottomAxis.Title = "Metrering"
	chart.LeftAxis.Title = "Afstand kustdwars [m + RSP] / Strandbreedte [m]"
	chart.RightAxis.Title = "Strandhelling"
	chart.Legend.Visible = 1
	chart.Legend.Alignment = LegendAlignment.Top
	
	""" Voeg nu lijnen toe met de berekende grootheden """
	# Strandbreedte
	series = AddToChartAsBar(chart,alongshore,beachWidths,"Strandbreedte")
	series.Color = Color.ForestGreen
	# Positie laagwaterlijn (kustdwars)
	series = AddToChartAsLine(chart,alongshore,xLows,"Positie laagwater (m + RSP)")
	series.Color = Color.BlueViolet
	series.Width = 2
	series.PointerVisible = 0
	# Positie hoogwaterlijn (kustdwars)
	series = AddToChartAsLine(chart,alongshore,xHighs,"Positie hoogwater (m + RSP)")
	series.Color = Color.OrangeRed
	series.Width = 2
	series.PointerVisible = 0
	# Strandhelling
	series = AddToChartAsLine(chart,alongshore,beachSlopes,"Strandhelling")
	series.Color = Color.SandyBrown
	series.Width = 2
	series.PointerVisible = 0
	series.VertAxis = VerticalAxis.Right
	
	""" Laat de figuur nu zien """
	ShowChart(chart)
	
	#endregion