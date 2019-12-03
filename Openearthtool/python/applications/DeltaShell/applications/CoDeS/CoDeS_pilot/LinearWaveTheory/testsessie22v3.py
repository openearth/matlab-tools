#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Witteveen+Bos
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
from System.Windows.Forms import MessageBox

import Scripts.LinearWaveTheory as lwt
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *

import numpy as np
import math


shoreNormal = -10    #(Nautic) Degrees
dirWave = np.array([-90, 220, 240, 190, 30, -70, 41., 40, 310, 130, 0]);        #Wave direction [deg]

relDirtest = ((dirWave - shoreNormal + 180) % 360 - 180)

[relDir, ixD] = lwt.calcRelativeDirection(dirWave, shoreNormal)


s = None

try:
    float(s)
    print('hoera')
except:
    print('boing')
    



toos = np.NumpyDotNet.ScalarFloat64(34)


lijstje = [1, 21, 3, 5]
erreetje = np.array(lijstje)

truus = np.array([34, 43, 23, 34]).astype('float')
truus2 = erreetje * 1.

test = (truus / 3) > 10

boe = 3 * 32.23


