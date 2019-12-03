#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
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
import Scripts.BreakwaterDesign.Views.BreakwaterView as _BreakwaterView
import Scripts.BreakwaterDesign.Entities.BreakwaterInput as _BreakwaterInput

from Scripts.GeneralData.Views.View import *
from Scripts.GeneralData.Entities import Scenario as _Scenario
from Scripts.GeneralData.Entities.Bathymetry import *

#import Scripts.BreakwaterDesign.Utilities.CloneBreakwaterInput as _CloneFunction


def OpenBreakwaterView(scenario):
	# Check if Breakwater Design is already open, else open new View
	viewbw = None
	for v in Gui.DocumentViews:
		if v.Text == "Breakwater Design":
			viewbw = v
	
	if viewbw != None:
		Gui.DocumentViews.ActiveView = viewbw
	else:
		inputData = _BreakwaterInput()
		inputView = _BreakwaterView(inputData,scenario)
		inputView.Show()
		#	Set scrollbars
		inputView.SetScrollBarsLeftPanel(20)


def Start_BreakwaterTool():
	inputData = _BreakwaterInput()		
	inputView = _BreakwaterView(inputData)
	inputView.Show()
	
	
#scenario = _Scenario()

#slopeValue = 5
#slopeRatio = 1/slopeValue
#slopeBathymetry = SlopeBathymetry(slopeValue)
#scenario.GenericData.Bathymetry = slopeBathymetry

#OpenBreakwaterView(scenario)

