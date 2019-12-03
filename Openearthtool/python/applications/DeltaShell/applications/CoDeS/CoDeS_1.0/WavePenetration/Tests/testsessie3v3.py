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
import Scripts.LinearWaveTheory as lwt


## Test of speed Sommerfeld Pennyprice equation

#generate meshgrid
xRange = np.arange(80., 120., 10.)
yRange = np.arange(100., 200., 10.)
xx, yy = np.meshgrid(xRange, yRange)

print(np.shape(xx))

#generate harbor specs
bwWidth = 100.
harborDepth = 100000.
waveLength = 100.

#for beta in np.arange(-0.2, +0.2, 0.01):
#Field, Fi, Fr, Gi, Gr, Hi, Hr = wp.SommerfeldPenneyPrice(xx, yy, -50, 0, math.pi, -15, waveLength)

#print(np.shape(Field))


print(np.linspace(34, 34, 1))
