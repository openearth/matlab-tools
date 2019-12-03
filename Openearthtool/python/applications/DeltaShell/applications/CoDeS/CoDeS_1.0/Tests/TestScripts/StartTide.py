#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#       Dirk Voesenek
#
#       dirk.voesenek@rhdhv.com
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
import Scripts.TidalData.Entities.TideInput as _TideInput
import Scripts.TidalData.Views.TideView as _TideView

from Scripts.GeneralData.Views.View import *
from Scripts.GeneralData.Entities import Scenario as _Scenario
from Scripts.GeneralData.Entities.Bathymetry import *


TideInput = _TideInput.BuildInput()
Scenario = _Scenario()
TideView = _TideView.TideView(TideInput,Scenario)
TideView.Show()

