#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Witteveen+Bos
#       Jaap de Rue
#
#       jaap.de.rue@witteveenbos.com
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



#Example wave-class dictionary (waveHeigth, wavePeriod, direction and occurence
wave_classes = {'class1': [1,8,120,20], 'class2': [1,8,150,20]}

from Scripts.WaveWindData.engine.classifyWaves import *


# Or load wave classes, and convert to separate arrays:
H_s,T_p,dir,occ,names = get_wave_classes(wave_classes)




#Example timeseries
H_s = np.array([1,1.02,1.05,0.99])
T_p = np.array([8.1,7.95,8.2,7.78])
dir = np.array([121,130,137,148])
#and add an (trivial) occ array:
occ   = np.ones(np.alen(H_s))/np.alen(H_s)
"""for i in range(int(np.alen(H_s))):
    names[i] = "t" + str(i+1)"""




Hs = np.array([3.25, 1.01, 13, 13.2, 2.2, 1, 5.5, 5, 4]);            #Wave-heigth [m]
Tp = np.array([8, 7, 15, 15, 5, 9, 12, 1, 32]);                     #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130]); 

waveHeight = Hs
wavePeriod = Tp
direction = dirWave

wave_classes = classifyWaves(waveHeight,wavePeriod,direction)