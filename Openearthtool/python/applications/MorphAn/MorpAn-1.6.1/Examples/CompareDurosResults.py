from Libraries.Utils.Shortcuts import *
from Libraries.Utils.Charting import *
from Libraries.Duros.Duros import *

#region 1. Definieer invoer
x = [ -250.0, -24.375, 5.625, 55.725, 230.625, 2780.625 ]
z = [ 15.0, 15.0, 3.0, 0.0, -3.0, -20.0 ]
waterLevel = 5.0
waterLevel2 = waterLevel + 0.5
Hs = 9
Tp = 16
D50 = 0.000250

#endregion


#region 2. Bereken Duros profiel
result1 = Duros(x,z,waterLevel,Hs,Tp,D50)
result2 = Duros(x,z,waterLevel2,Hs,Tp,D50)

#endregion

#region 4. Toon de berekende eindprofiel in de interface
chartView = CreateChartView()

# Initieel profiel
area = AddToChartAsArea(chartView.Chart,x,z,"Initieel profiel")
area.LineVisible = True
area.LineColor = Color.SaddleBrown
area.Color = Color.SandyBrown

# Eindprofiel 1
x1 = result1.OutputDurosProfile.XCoordinates
z1 = result1.OutputDurosProfile.ZCoordinates
title1 = "Waterstand = %0.2f [m + NAP]" % (waterLevel)
line1 = AddToChartAsLine(chartView.Chart,x1,z1,title1)
line1.Color = Color.DarkGreen
line1.Width = 2
line1.PointerVisible = False

# Eindprofiel 2
x2 = result2.OutputDurosProfile.XCoordinates
z2 = result2.OutputDurosProfile.ZCoordinates
title2 = "Waterstand = %0.2f [m + NAP]" % (waterLevel2)
line2 = AddToChartAsLine(chartView.Chart,x2,z2,title2)
line2.Color = Color.DarkRed
line2.Width = 2
line2.PointerVisible = False

chartView.Chart.Legend.Visible = True
chartView.Chart.Legend.Alignment = LegendAlignment.Bottom
chartView.Chart.BottomAxis.Title = "Afstand kustdwars [m]"
chartView.Chart.LeftAxis.Title = "Hoogte [m + NAP]"
chartView.Chart.Title = "Duros vergelijking"
chartView.Chart.BottomAxis.Automatic = False
chartView.Chart.BottomAxis.Minimum = -200
chartView.Chart.BottomAxis.Maximum = 600
chartView.Chart.LeftAxis.Automatic = False
chartView.Chart.LeftAxis.Minimum = -10
chartView.Chart.LeftAxis.Maximum = 17

Gui.DocumentViews.Add(chartView)
Gui.DocumentViews.ActiveView = chartView
#endregion
