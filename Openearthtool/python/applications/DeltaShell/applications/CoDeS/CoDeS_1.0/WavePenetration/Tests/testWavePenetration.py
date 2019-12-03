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
import numpy as np
import time
import math

from SharpMap import XyzFile
from SharpMap.Layers import PointCloudLayer
from SharpMap.Data.Providers import PointCloudFeatureProvider
from SharpMap.Rendering.Thematics import GradientTheme
from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView
from NetTopologySuite.Extensions.Coverages import PointValue, PointCloud
import Scripts.GeneralData.Views.View as _View
import Scripts.GeneralData.Utilities.GridFunctions as GridFunc
import Scripts.WavePenetration as wp


#GENERATE WAVE-SPECS
Hs = 3.
Tp = 6.
waveDir = 90. #Coming from east
waveDir = 270. #Coming from west
Smax = 30.

#generate harbor specs
harborDepth = 15.
xRange = np.linspace(-200., 200., 41)
yRange = np.linspace(0.1, 600., 61)
xLocal, yLocal = np.meshgrid(xRange, yRange)


#BW-heads
xLbw = 2.
yLbw = 2.

xRbw = 100.
yRbw = 120.

#Center of harbor entry
x0 = (xRbw+xLbw)/2
y0 = (yRbw+yLbw)/2
xbwDiff = (xRbw-xLbw)
ybwDiff = (yRbw-yLbw)

#Get width and angle of the BW head coordinates
harborWidth = np.hypot(xbwDiff, ybwDiff)						#[m] 
deltaRad = np.arctan2(ybwDiff, xbwDiff) % (2*math.pi)			#[rad] angle of breakwaters, with harbor as positive y]
delta = deltaRad * (180/math.pi)								#[deg]

relDir = (90 - delta - waveDir) % 360

t0 = time.time()
value = wp.calcGodaDiagram(xLocal, yLocal, harborWidth, harborDepth, Hs, Tp, relDir, Smax, 1, 3)
t1 = time.time()

value = value * Hs
print(t1-t0)

#ROTATING TOWARDS BREAKWATERS
xGlob = x0 + (xLocal * np.cos(math.pi-deltaRad)) + (yLocal * np.sin(math.pi-deltaRad))		#[XxY meshgrid]
yGlob = y0 - (xLocal * np.sin(math.pi-deltaRad)) + (yLocal * np.cos(math.pi-deltaRad))		#[XxY meshgrid]


xVec = np.ravel(xGlob)
yVec = np.ravel(yGlob)
vVec = np.ravel(value)

puntenWolk = PointCloud()
for ind in range(np.size(xVec)):
	punt = PointValue()
	punt.X = xVec[ind]
	punt.Y = yVec[ind]
	punt.Value = vVec[ind]
	puntenWolk.PointValues.Add(punt)

#print(value.shape)

# create layer for points
pointCloudFeatureProvider = PointCloudFeatureProvider()
pointCloudFeatureProvider.PointCloud = puntenWolk


XYZlayer = PointCloudLayer()
XYZlayer.DataSource = pointCloudFeatureProvider
XYZlayer.Name = 'gekke henkie'
GridFunc.SetGradientTheme(XYZlayer, 'Value', 9, XYZlayer.MinDataValue, XYZlayer.MaxDataValue)

#XYZlayer.Theme = 

mapView = MapView()
mapView.Map.Layers.Add(XYZlayer)


view = _View()
view.Controls.Add(mapView)
view.ChildViews.Add(mapView)
view.Show()
