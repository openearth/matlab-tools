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

from Scripts.WavePenetration.Utilities import applyWavePen as _wp
from Scripts.WavePenetration.Utilities import WavePenUtils as _wpU

import math
import numpy as _np

polygon = [[1, 4.], [2, 2], [4, 1], [8,2], [7,4], [5,6], [3.,6]]
coordX = _np.array([coord[0] for coord in polygon])
coordY = _np.array([coord[1] for coord in polygon])
harborEntry = [(coordX[0] + coordX[-1])/2, (coordY[0] + coordY[-1])/2 ]

deltaRad = _np.arctan2(coordY[-1] - coordY[0], coordX[-1] - coordX[0])
#print(deltaRad/math.pi)


xLocal, yLocal = _wpU.RotateToLocalHarbor(coordX, coordY, harborEntry, deltaRad)
print(xLocal)
print(yLocal)

xMin, xMax, yMin, yMax = _wpU.GetLocalHarborExtend(polygon,harborEntry, deltaRad)
print([xMin, xMax, yMin, yMax])


globX = harborEntry[0] + (coordX * _np.cos(math.pi - deltaRad)) + (coordY * _np.sin(deltaRad))
globY = harborEntry[1] - (coordX * _np.sin(math.pi - deltaRad)) + (coordY * _np.cos(deltaRad))

print(min(polygon[1]))

"""
#Put after Start routines.
dataView = _GeneralDataView.GeneralDataView(NewScenario)
dataView.Show()

wavePenView = _WavePenetrationView(NewScenario)
wavePenView.Show()

print(NewScenario.GenericData.CivilStructures.keys())

if not (NewScenario.GenericData.Coastline == None):
	print("kustlijn present")
else:
	print("geen kustlijn")


from Scripts.WavePenetration.Utilities import WavePenUtils as _wpU


wavePenView.Coastline = NewScenario.GenericData.Coastline.CoastlineGeometry
wavePenView.BreakwaterL = NewScenario.GenericData.CivilStructures['gr'].StructureGeometry
wavePenView.BreakwaterR = NewScenario.GenericData.CivilStructures['WER'].StructureGeometry

polygoon = _wpU.createHarborPolygon(wavePenView.BreakwaterL, wavePenView.Coastline, wavePenView.BreakwaterR)

print(polygoon)
"""


