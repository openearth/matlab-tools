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
import clr
clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf
import System.Drawing as _sd

#from Libraries.MapFunctions import *
#from Libraries.StandardFunctions import *
from SharpMap.UI.Tools import MapTool
from SharpMap.Layers import PointCloudLayer
from SharpMap.Data.Providers import PointCloudFeatureProvider
from SharpMap.Rendering.Thematics import GradientTheme
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
from GisSharpBlog.NetTopologySuite.Geometries import Envelope
import DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapView as _MapView
from NetTopologySuite.Extensions.Coverages import PointValue, PointCloud


from Scripts.GeneralData.Views.BaseView import *
import Scripts.GeneralData.Views.View as _View
import Scripts.GeneralData.Utilities.GridFunctions as GridFunc
import Scripts.GeneralData.Utilities.Conversions as _Conversions
import Scripts.GeneralData.Entities.Scenario as _Scenario
import Scripts.GeneralData.Entities.CivilStructure as _CivilStructure
import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools
from Scripts.WavePenetration.Utilities import applyWavePen as _wp
import Scripts.GeneralData.Utilities.GeometryFunctions as _GeometryFunctions

import numpy as _np
import Scripts.WavePenetration as _wp


#Generate my view
scenario = _Scenario()
wavePenView = _wp.WavePenetrationView(scenario)
wavePenView.Show()

myPol = [[0, 0], [0, 50], [50, 50], [50, 0]]

xVec = _np.array([8.,  4.,  4.,  56., 65., 54., 48.,  47., 13., 12.])
yVec = _np.array([8.,  1.,  2.,  9.,  47., 23., 12.,  17., 19., 11.])
vVec = _np.array([0.2, 0.8, 0.1, 0.5, 0.4, 2.5, 0.12, 0.3, 0.4, 0.4])

puntenWolk = PointCloud()
for ind in range(_np.size(xVec)):
	if _wp.pointInPolygon(xVec[ind],yVec[ind],myPol):
		punt = PointValue()
		punt.X = xVec[ind]
		punt.Y = yVec[ind]
		punt.Value = vVec[ind]
		puntenWolk.PointValues.Add(punt)
	else:
		print("mis")


#Before adding some shizzle: remove the old.
wavePenView.GroupLayer.Layers.Clear()


#Showing the new map
# create layer for points
pointCloudFeatureProvider = PointCloudFeatureProvider()
pointCloudFeatureProvider.PointCloud = puntenWolk

GolfHoogteLayer = PointCloudLayer()
GolfHoogteLayer.DataSource = pointCloudFeatureProvider
GolfHoogteLayer.Name = 'WaveHeight'
GridFunc.SetGradientTheme(GolfHoogteLayer, 'Value', 9)


wavePenView.GroupLayer = scenario.GroupLayerWavePenetration
#Voeg de laag toe aan de groupLayer
wavePenView.GroupLayer.Layers.Add(GolfHoogteLayer)
#scenario.GroupLayerWavePenetration.Layers.Add(GolfHoogteLayer)
wavePenView.mapView.Map.BringToFront(GolfHoogteLayer)

#Zoom to extend of harbor:
wavePenView.mapView.Map.ZoomToFit(GolfHoogteLayer.Envelope, True)




