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


from SharpMap.Layers import PointCloudLayer
from SharpMap.Data.Providers import PointCloudFeatureProvider
from SharpMap.Rendering.Thematics import GradientTheme
from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView
from NetTopologySuite.Extensions.Coverages import PointValue, PointCloud
import Scripts.GeneralData.Views.View as _View
import Scripts.GeneralData.Utilities.GridFunctions as GridFunc
import Scripts.GeneralData.Entities.Scenario as _Scenario

from Scripts.GeneralData.Views import GeneralDataView as _GeneralDataView
from Scripts.WavePenetration.Views import WavePenetrationView as _WavePenetrationView


scenario = _Scenario()

#Creating some breakwaters for fast testing
#scenario.GenericData.CivilStructures 
#scenario.GenericData.Coastline

#Put after Start routines.
dataView = _GeneralDataView.GeneralDataView(scenario)
dataView.Show()

wavePenView = _WavePenetrationView(scenario)
wavePenView.Show()

#The left breakwater is the one which Startpoint is closest towards StartPoint of Coastline
#So test must be based on Start- and Endpoint of coastline.

#Store text entries
textBWL = wavePenView.dropdownBreakWaterL.Text
textBWR = wavePenView.dropdownBreakWaterR.Text

#Swap text
wavePenView.dropdownBreakWaterL.Text = textBWR
wavePenView.dropdownBreakWaterR.Text = textBWL


"""
print(wavePenView.Coastline.StartPoint.Distance(wavePenView.BreakwaterL.StartPoint))

distStartCToLeftBW = _np.hypot(xLDiff, yLDiff)
distStartCToRightBW = _np.hypot(xRDiff, yRDiff)

if distStartCToLeftBW < distStartCToRightBW:
	print("LINKS!")
else:
	print("RECHTS!")
	


wavePenView.dropdownBreakWaterL.D
"""