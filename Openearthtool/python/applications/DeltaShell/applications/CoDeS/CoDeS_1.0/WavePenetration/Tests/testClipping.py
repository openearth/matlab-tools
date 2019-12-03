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
import numpy as _np
import math
from Scripts.WavePenetration.Utilities import applyWavePen as _wp
from Scripts.WavePenetration.Utilities import WavePenUtils as _wpU
from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Views.View as _View
import Scripts.GeneralData.Utilities.GridFunctions as GridFunc
import Scripts.GeneralData.Utilities.Conversions as _Conversions
import Scripts.GeneralData.Entities.Scenario as _Scenario
import Scripts.GeneralData.Entities.CivilStructure as _CivilStructure
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools

import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions

import DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapView as _MapView
from SharpMap.Rendering.Thematics import GradientTheme
from SharpMap.Layers import PointCloudLayer
from SharpMap.Data.Providers import PointCloudFeatureProvider
from NetTopologySuite.Extensions.Coverages import PointValue, PointCloud

import Scripts.WavePenetration as _wp


#Generate my view
scenario = _Scenario()
wavePenView = _wp.WavePenetrationView(scenario)



xLbw = 25.
yLbw = 25.

xRbw = 30.
yRbw = 50.


harborPolygon = [[xLbw, yLbw], [xLbw, 0], [xRbw, 0], [xRbw, yRbw]]


#Center of harbor entry (i.e. the base of the point layer) 
x0 = (xRbw+xLbw)/2
y0 = (yRbw+yLbw)/2
xbwDiff = (xRbw-xLbw)
ybwDiff = (yRbw-yLbw)

#Get width and angle of the BW head coordinates
harborWidth = _np.hypot(xbwDiff, ybwDiff)						#[m] 
deltaRad = _np.arctan2(ybwDiff, xbwDiff) % (2*math.pi)			#[rad] angle of breakwaters, with harbor as positive y]


xMin = -30.
xMax = 30.
yMin = 0.	#Always zero, since the harborentry is defined as y = 0
yMax = 40.

#Defining local grid (with default value)
gridSize = 41.
xRange = _np.linspace(xMin, xMax, gridSize)
yRange = _np.linspace(yMin, yMax, gridSize)
xLocal, yLocal = _np.meshgrid(xRange, yRange)

xLocVec = _np.ravel(xLocal)
yLocVec = _np.ravel(yLocal)


xGlob = x0 + (xLocal * _np.cos(math.pi-deltaRad)) + (yLocal * _np.sin(math.pi-deltaRad))		#[XxY meshgrid]
yGlob = y0 - (xLocal * _np.sin(math.pi-deltaRad)) + (yLocal * _np.cos(math.pi-deltaRad))		#[XxY meshgrid]

xVec = _np.ravel(xGlob)
yVec = _np.ravel(yGlob)
vVec = xVec + yVec



puntenWolk = PointCloud()
puntenWolkO = PointCloud()
for ind in range(_np.size(xVec)):
	#Check whether the point is inside the polygon of he harbor.
	
	if _wp.pointInPolygon(xVec[ind], yVec[ind], harborPolygon):
		punt = PointValue()
		punt.X = xVec[ind]
		punt.Y = yVec[ind]
		punt.Value = vVec[ind]
		puntenWolk.PointValues.Add(punt)
	
	if _wp.pointInPolygon(xLocVec[ind], yLocVec[ind], harborPolygon):
		puntO = PointValue()
		puntO.X = xLocVec[ind]
		puntO.Y = yLocVec[ind]
		puntO.Value = vVec[ind]
		puntenWolkO.PointValues.Add(puntO)
	




#Showing the new map
# create layer for points
pointCloudFeatureProvider = PointCloudFeatureProvider()
pointCloudFeatureProvider.PointCloud = puntenWolk
pointCloudFeatureProvider2 = PointCloudFeatureProvider()
pointCloudFeatureProvider2.PointCloud = puntenWolkO



GolfHoogteLayer = PointCloudLayer()
GolfHoogteLayer.DataSource = pointCloudFeatureProvider
GolfHoogteLayer.Name = 'WaveHeight'
GridFunc.SetGradientTheme(GolfHoogteLayer, 'Value', 9)

GolfHoogteLayer2 = PointCloudLayer()
GolfHoogteLayer2.DataSource = pointCloudFeatureProvider2
GolfHoogteLayer2.Name = 'WaveHeight Local'
GridFunc.SetGradientTheme(GolfHoogteLayer2, 'Value', 9)


wavePenView.GroupLayer = scenario.GroupLayerWavePenetration
#Voeg de laag toe aan de groupLayer
wavePenView.GroupLayer.Layers.Add(GolfHoogteLayer)
wavePenView.GroupLayer.Layers.Add(GolfHoogteLayer2)
#scenario.GroupLayerWavePenetration.Layers.Add(GolfHoogteLayer)
wavePenView.mapView.Map.BringToFront(GolfHoogteLayer2)
wavePenView.mapView.Map.BringToFront(GolfHoogteLayer)

#Zoom to extend of harbor:
wavePenView.mapView.Map.ZoomToFit(GolfHoogteLayer.Envelope, True)



wavePenView.Show()