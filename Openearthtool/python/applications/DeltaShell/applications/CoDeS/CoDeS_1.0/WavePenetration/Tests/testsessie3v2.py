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
import math


from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import Scripts.WavePenetration as wp

import time

#generate meshgrid
xRange = np.arange(-8., 8., .1)
yRange = np.arange(-4., 40., 1.)
xx, yy = np.meshgrid(xRange, yRange)

#overwrite xx and yy to get a scalar coordinate
#xx = np.array([[20]])
#yy = np.array([[-20]])

"""
for indC in range(np.size(xx,1)):
	
	print(xx[3, indC] == xx[-1, indC])
	
	for indR in range(np.size(xx,0)):
		pass
"""


#generate harbor specs
bwWidth = 12.
harborDepth = 150.

print(xx)

Hs = 6.
Tp = 8.
relDir = 0.
Smax = 10.


t0 = time.time()
Kdiffr = wp.calcGodaDiagram(xx, yy, bwWidth, harborDepth, Hs, Tp, relDir, Smax)
t1 = time.time()

print(t1-t0)

print(np.shape(Kdiffr))

print(Kdiffr)