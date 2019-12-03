#region Imports and includes
from operator import itemgetter, attrgetter
from Libraries.MorphAn.TransectOperations import *
from Libraries.MorphAn.MorphAnData import *
from Oefeningen.A_Analyse.Functies.BerekenStrandBreedte import *
from Libraries.Utils.Charting import *

#endregion

"""
Dit script kan worden gebruikt als voorbeeld bij het analyseren van metingen. Het 
script gaat er vanuit dat MorphAn reeds een workspace heeft met een gevulde set met
JARKUS metingen.

In dit voorbeeld worden de positie van de hoog- en laagwaterlijn, strandbreedte, 
en strandhelling berekend en gevisualiseerd. Het is ook mogelijk om de berekening te vervangen 
door een andere functie.
"""

#region Instellingen
waterLevel = 3.2					# Niveau van hoogwater (m + NAP)
lowWaterLevel = -1.2				# Niveau van laag water (m + NAP)
year = 2010							# Jaar dat moet worden geanalyzeerd
jarkusMeasurementsName = "Texel"	# Naam van de set met JARKUS metingen
outputName = "Strandhelling"		# Titel van het uitvoer plaatje

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
for (transect) in sorted(GetJarkusMeasurements(jarkusMeasurementsName),key=attrgetter('TransectLocation')):
	
	""" Sla metingen uit een ander jaar over """
	if not(transect.Time.Year == year) :
		continue

	""" 
	Bereken strandbreedte en helling.
	Probeer deze functie te vervangen door een functie die .. berekent
	"""
	xWaterLine, xLowWaterLine, beachWidth, beachSlope = CalculateBeachSlope(transect,waterLevel,lowWaterLevel)
			
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
chart.Name = "Karakteristieken: %s" % (jarkusMeasurementsName)
chart.BottomAxis.Title = "Alongshore position"
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