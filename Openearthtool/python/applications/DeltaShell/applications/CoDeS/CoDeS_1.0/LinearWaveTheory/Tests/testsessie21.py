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
import Scripts.LinearWaveTheory as lwt


from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *


import numpy as np
import math



shoreNormal = 10; #[degrees]

#Start- and endpoint of depths:
offshZ = -30;
nearshZ = -1;
profile = np.array([offshZ, nearshZ])
## or whole profile
profile = np.array([30, 25, 19, 19, 19, 18, 90, 91, 95, 93, 53, 17, 15, 14, 10, 13, 12, 9, 8, 4, 3, 2, 2, 2, 1]);

waveHeight = np.zeros(len(profile))
waveHeight2 = np.zeros(len(profile))

## Wavedata:
Hs = np.array([1.25, 1.01, 13, 13.2, 2.2, 1, 5.5, 5, 4]);            #Wave-heigth [m]
Tp = np.array([8, 7., 15, 15, 5., 9, 12, 1, 32]);                    #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130]);     #Wave direction [deg]
dirWave = np.array([20, 40, -89, 30, -70, 41., 40, 10, 30]);         #Wave direction [deg]

(relDir, ixD) = lwt.calcRelativeDirection(dirWave, shoreNormal);



#Initiate values
n = 3; #the entry of the wave-climate-vectors
waveHeight[0] = Hs[n];
waveHeight2[0] = Hs[n];

Hstemp = Hs;
Tptemp = Tp;
relDirtemp = relDir;

for i in range(1, len(profile)):
    #For each dist, calc the waveheigth, based on previous profile-measurement
    (Hstemp, Tptemp, relDirtemp) = lwt.calcWaveConditions(Hstemp, Tptemp, relDirtemp, abs(profile[i-1]), abs(profile[i]))
    
    #After calculation: it should be checked if the wave will break, if so: cut height.
    Hstemp = lwt.cutBreakingWaves(Hstemp, abs(profile[i]), 0.78)
    waveHeight[i] = Hstemp[n];


print('done')
#(Hsnew, Tpnew, relDirnew) = lwt.calcWaveConditions(Hs, Tp, relDir, abs(profile[0]), abs(profile[-1]))

dist = np.array(range(0, len(profile)))
waveHeightatDist = np.vstack((dist,waveHeight)).T
waveHeightatDist2 = np.vstack((dist,waveHeight2)).T
depthatDist = np.vstack((dist,profile)).T

profileReal = {}
profileReal['dist'] = [dist]
profileReal['z'] = [profile]

chart = lwt.plotProfileWaveHeight(profileReal, waveHeight)


OpenView(chart)



#Next try:
(Hsnew, Tpnew, relDirnew) = lwt.transWaveConditions(Hs, Tp, relDir, profile, 0.78)