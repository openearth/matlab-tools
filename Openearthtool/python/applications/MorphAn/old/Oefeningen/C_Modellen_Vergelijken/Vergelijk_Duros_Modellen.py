from Libraries.Utils.Charting import *
from Libraries.Duros.Duros import *

#region 1. Definieer invoer
x = [ -250.0, -24.375, 5.625, 55.725, 230.625, 2780.625 ]
z = [ 15.0, 15.0, 3.0, 0.0, -3.0, -20.0 ]
waterLevel = 5.0
dWaterLevelValues = [-2, -1, -0.5, -0.25, -0.1, 0, 0.1, 0.25, 0.5, 1, 2]
colors = [ Color.PowderBlue, Color.RosyBrown, Color.BlueViolet, Color.DeepSkyBlue, 
		Color.Purple, Color.DarkOliveGreen, Color.Chocolate, Color.CornflowerBlue,
		Color.Firebrick, Color.DarkTurquoise, Color.DeepPink ]
Hs = 9
Tp = 16
D50 = 0.000250

#endregion

#region 2. Bereken Duros profiel
resultaten = []

for dWaterLevel in dWaterLevelValues :
	resultaten.append(Duros(x,z,waterLevel + dWaterLevel,Hs,Tp,D50))

#endregion

#region 4. Toon de berekende eindprofiel in de interface
chartView = CreateChartView()

# Waterstanden
xValues = [-250, 2780.625, 2780.625, -250, -250]
zMax = max(dWaterLevelValues) + waterLevel
zMin = min(dWaterLevelValues) + waterLevel
zValues = [zMax, zMax, zMin, zMin, zMax]
polygon = AddToChartAsPolygon(chartView.Chart,xValues,zValues,"Waterstand")
polygon.Color = Color.LightBlue

# Initieel profiel
area = AddToChartAsArea(chartView.Chart,x,z,"Initieel profiel")
area.LineVisible = True
area.LineColor = Color.SaddleBrown
area.LineWidth = 3
area.Color = Color.SandyBrown

# Berekende profielen
xP = []
waterLevels = []
for index,resultaat in enumerate(resultaten) :
	xP.append(resultaat.OutputPointPDuros.X)
	waterLevels.append(resultaat.Input.MaximumStormSurgeLevel)
	xEind = resultaat.OutputDurosProfile.XCoordinates
	zEind = resultaat.OutputDurosProfile.ZCoordinates
	title = "DUROS+ (waterstand %0.2f [m + NAP])" % (resultaat.Input.MaximumStormSurgeLevel)
	line = AddToChartAsLine(chartView.Chart,xEind,zEind,title)
	line.Color = colors[index]
	line.Width = 2
	line.PointerVisible = False

lineVerloop = AddToChartAsLine(chartView.Chart,xP,waterLevels,"Verloop afslagpunt op MSLL")
lineVerloop.PointerVisible = True
lineVerloop.Color = Color.Gray
lineVerloop.PointerStyle = PointerStyles.Circle
lineVerloop.PointerColor = Color.Purple
lineVerloop.PointerLineColor = Color.Black
lineVerloop.PointerSize = 4
lineVerloop.Width = 3

chartView.Chart.Legend.Visible = True
chartView.Chart.Legend.Alignment = LegendAlignment.Bottom
chartView.Chart.BottomAxis.Title = "Afstand kustdwars [m]"
chartView.Chart.LeftAxis.Title = "Hoogte [m + NAP]"
chartView.Chart.Name = "Duros vergelijking"
chartView.Title = "Duros vergelijking"
chartView.Chart.BottomAxis.Automatic = False
chartView.Chart.BottomAxis.Minimum = -200
chartView.Chart.BottomAxis.Maximum = 600
chartView.Chart.LeftAxis.Automatic = False
chartView.Chart.LeftAxis.Minimum = -10
chartView.Chart.LeftAxis.Maximum = 17

Gui.DocumentViews.Add(chartView)
Gui.DocumentViews.ActiveView = chartView

#endregion

#region 5. Sla de geopende figuur op 
chartView.Chart.ExportAsImage("D:\Test\Duros vergelijking.png",1200,500)

#endregion