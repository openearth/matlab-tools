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


xLbw = 20.
yLbw = 20.

xRbw = 60.
yRbw = 20.

#Center of harbor entry
x0 = (xRbw+xLbw)/2
y0 = (yRbw+yLbw)/2
xbwDiff = (xRbw-xLbw)
ybwDiff = (yRbw-yLbw)


#Get width and angle of the BW head coordinates
harborWidth = _np.hypot(xbwDiff, ybwDiff)						#[m] 
deltaRad = _np.arctan2(ybwDiff, xbwDiff) % (2*math.pi)			#[rad] angle of breakwaters, with harbor as positive y]
delta = deltaRad * (180/math.pi)								#[deg]

#print(harborWidth)
#print(deltaRad/(math.pi/180))
print(delta)



#Global wave Direction (northing) 
waveDir = 30

#Northing
relDir = ((waveDir - (180 - delta) + 90) % 360) - 90

print relDir



"""
#Put after Start routines.
dataView = _GeneralDataView.GeneralDataView(NewScenario)
dataView.Show()

wavePenView = _WavePenetrationView(NewScenario)
wavePenView.Show()

print(NewScenario.GenericData.CivilStructures.keys())
"""