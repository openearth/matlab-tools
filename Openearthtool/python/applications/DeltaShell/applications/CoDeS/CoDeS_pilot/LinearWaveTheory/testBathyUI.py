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
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import numpy as np
import math

import os, inspect

#print(os.path.realpath(__file__))

#print(inspect.getfile(inspect.currentframe()))

#Importing all modules of collegues
import Scripts.LinearWaveTheory as lwt
import Scripts.WaveWindData as wwd
import Scripts.TidalData as td
import Scripts.BathymetryData as bmd
import Scripts.BreakwaterDesign as bwd
#import Scripts.CoastlineDevelopment as cd



import Scripts.BathymetryData.Conversion_UI as UItest

UItest.initializeView()

#Wave-climate offshore (3 arrays) (+ occurence?)
Hs = np.array([3.25, 1.01, 10, 5.2, 2.2, 1, 5.5, 5, 4]);              #Wave-heigth [m]
Tp = np.array([8, 7, 15, 15, 5, 9, 12, 1, 2]);                        #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130]);      #Wave direction [deg]
n1 = wwd.classifyWaves(Hs, Tp, dirWave)


Hs = np.array([0.69,1.02,1.05,0.99, 1])
Tp = np.array([8.1,6.95,8.2,7.78, 7.67])
dirWave = np.array([121,130,137,148, 101])
n2 = wwd.classifyWaves(Hs, Tp, dirWave)


Hs = np.array([0.69,float('NaN'),float('NaN'),1.05,0.99, 1])
Tp = np.array([8.1,float('NaN'),6.95,8.2,7.78, 7.67])
dirWave = np.array([121,130,137,148, 101, 516])
n3 = wwd.classifyWaves(Hs, Tp, dirWave)


