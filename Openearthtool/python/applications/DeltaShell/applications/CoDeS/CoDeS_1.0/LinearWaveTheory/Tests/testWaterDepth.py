#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Jochem Boersma
#
#       jochem.boersma@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *

import numpy as np
import math


#Importing all modules of collegues
import Scripts.LinearWaveTheory as lwt
import Scripts.BathymetryData as bmd
import Scripts.BreakwaterDesign as bwd
import Scripts.TidalData as td
import Scripts.CoastlineDevelopment as cd
import Scripts.WaveWindData as wwd

import Scripts.BathymetryData.GridFunctions as grdF


(X,Y,dist,depth) = grdF.GetProfile("Bathymetry","elevation_luanda_5m", 298906, 9017957, 300000, 9018633, 100)
depthatDist = np.vstack((dist,depth)).T


#henk = bmd.GridFunctions.ReadGridValue("Bathymetry","elevation_luanda_5m", 300000, 9018000)    #Depth [m]
#truus = bmd.GridFunctions.ReadGridValue("Bathymetry","elevation_luanda_5m", 299000, 9017000)    #Depth [m]
lineSeriesDepth = CreateLineSeries(depthatDist)



#lineSeriesWaveHeigth = CreateLineSeries(heigthatDist)

# Configure the line series
lineSeriesDepth.Color = Color.Red
lineSeriesDepth.Width = 3
#lineSeries.PointerVisible = True
#lineSeries.PointerSize = 5
#lineSeries.PointerColor = Color.Red
#lineSeries.PointerLineVisible = True
#lineSeries.PointerLineColor = Color.DarkRed
lineSeriesDepth.Transparency = 50

chart = CreateChart([lineSeriesDepth])


# Configure the chart
chart.TitleVisible = True
chart.Title = "Depth Profile"
chart.BackGroundColor = Color.White
chart.Legend.Visible = False

# Configure the bottom axis
#chart.BottomAxis.Automatic = False
#chart.BottomAxis.Minimum = 1
#chart.BottomAxis.Maximum = 6
chart.BottomAxis.Title = "distance from offshore point"

# Configure the left axis
chart.LeftAxis.Title = "Depth [m]"

# Show the chart
OpenView(chart)