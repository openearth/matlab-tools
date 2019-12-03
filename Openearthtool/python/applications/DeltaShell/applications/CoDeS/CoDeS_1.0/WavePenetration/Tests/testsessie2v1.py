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

import Scripts.WavePenetration as wp
import Scripts.GeneralData as gd
import Scripts.LinearWaveTheory as lwt

from Scripts.GeneralData.Entities import Scenario
from Scripts.GeneralData.Entities import Waves
from Scripts.GeneralData.Entities import WaveClimate
import Scripts.GeneralData.Utilities as myUtils 


## Daarnaast, om te testen de CornuSpiraal
#from Scripts.WavePenetration.Utilities.CornuSpiral import CornuSpiral
#print(CornuSpiral[4,:])


#Maak de variabelen voor berekenen van WaveFields

#Setup for harbor coordinates:
xRange = np.arange(-5, 5, 2.5);
yRange = np.arange(0, 10, 5);
xx, yy = np.meshgrid(xRange, yRange);

print(xRange)

#Overrule: a single value. 
#xx = np.array([2, 4., 8])# 9, -4, -6]);
#yy = np.array([3, 5, 3])#, 5, -9, -3]);
harborDepth = 15.;

#Waveconditions
Tp = 8.;
dir = 270.;
waveLength = lwt.calcWaveLength(Tp, harborDepth) 

"""
xBW = np.array([100, 3]);
yBW = np.array([1, 2]);
print( - np.arctan2(yBW[0]-yBW[1], xBW[0]-xBW[1])* (180/math.pi))

xBW = np.array([1, 3]);
yBW = np.array([1, 3]);
print( - np.arctan2(yBW[0]-yBW[1], xBW[0]-xBW[1])* (180/math.pi))
"""


#BreakwaterHeads
xBWright = np.array([1.]);
yBWright = np.array([0.5]);
xBWleft = np.array([2.]);
yBWleft = np.array([3.]);
#Northing, with nose to harbor and first BWhead at right, second BWhead at left.
#harborEntryNormal = (-np.arctan2(yBWright-yBWleft, xBWright-xBWleft)* (180/math.pi) % 360)
#print(harborEntryNormal)

#delta = np.arctan2(yBWright-yBWleft, xBWright-xBWleft)* (180/math.pi) % 360
#print(delta)

#Angle of breakwater towards shalow-line of waves (p5, fig1).
#theta0 = (harborEntryNormal + dir) % 360
#print(theta0)

#overrule
delta = math.pi*(1./8)
beta = math.pi*(3./8)

#Based on the right field
Field = wp.SommerfeldPenneyPrice(xx, yy, xBWright, yBWright, delta, beta, waveLength)
print(Field)


