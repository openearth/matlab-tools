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
import Scripts.LinearWaveTheory as lwt
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *

import numpy as np
import math


Hs = np.array([1.25, 1.01, 13, 13.2, 12.2, 1, 5.5, 5, 4, 84]);              #Wave-heigth [m]
Tp = np.array([8, 7., 15, 15, 5., 9, 12, 1, 32, 45]);                       #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130, 0]);         #Wave direction [deg]
[HsN, TpN, thetaN] = lwt.calcWaveConditions(Hs,Tp, dirWave, 54, 2)


#Next try:
Hs = np.array([1.25, 1.01, 13, 13.2, 12.2, 1, 5.5, 5, 4, 84]);              #Wave-heigth [m]
Tp = np.array([8, 7., 15, 15, 5., 9, 12, 1, 32, 45]);                       #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130, 0]);         #Wave direction [deg]
[HsN, TpN, thetaN] = lwt.transWaveConditions(Hs,Tp, dirWave, [54, 2], 0.78)

#Next try:
Hs = np.array(4)
Tp = np.array(3)
dirWave = np.array(0)
[HsN, TpN, thetaN] = lwt.transWaveConditions(Hs,Tp, dirWave, [100, 3], 0.73)


#Next try:
Hs = np.array([2])
Tp = np.array([12])
dirWave = np.array([12])
[HsN, TpN, thetaN] = lwt.transWaveConditions(Hs,Tp, dirWave, [54, 2], 0.78)


#Next try:
Hs = np.array([2])
Tp = np.array([12])
dirWave = np.array([12])
[HsN2, TpN2, thetaN2] = lwt.transWaveConditions(Hs,Tp, dirWave, [54., 2], 0.78)


#Next try: illegaal, en terecht:
#Hs = [2, 4, 5]
#Tp = [12, 16, 5]
#dirWave = [2, 65, 98]
#[HsN, TpN, thetaN] = lwt.transWaveConditions(Hs,Tp, dirWave, [54, 2], 0.78)


"""
test = np.array([3, 3])
testa = np.array([3])
test1 = np.array(3)
test2 = 4

test3a = np.ndim(testa)
test3 = np.ndim(test1)
test4 = np.ndim(test2)
"""


TF = lwt.willBreak(Hs,3, 0.6)
TF2 = lwt.willBreak(Hs,3., 0.6)


