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



shoreNormal = 10; #[degrees]

#Start- and endpoint of depths:
offshZ = 30;
nearshZ = 1;
profile = dict();

#profile.append({'z': np.array([offshZ, nearshZ])})
## or whole profile
profile.update({'z': np.array([30, 25, 19, 19, 19, 18, 90, 91, 95, 93, 53, 17, 15, 14, 10, 13, 12, 9, 8, 4, 3, 2, 2, 2, 1])})
profile.update({'dist': np.array(range(0, len(profile['z'])))})

waveHeight = np.zeros(len(profile['z']))
waveHeight2 = np.zeros(len(profile['z']))
waveBreak = np.zeros(len(profile['z']))

## Wavedata:
Hs = np.array([1.25, 1.01, 13, 3.2, 12.2, 1, 5.5, 5, 4]);            #Wave-heigth [m]
Tp = np.array([8, 7., 15, 15, 5., 9, 12, 1, 32]);                      #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130]);     #Wave direction [deg]
dirWave = np.array([20, 40, -89, 30, 10, 41., 40, 10, 30]);         #Wave direction [deg]

(relDir, ixD) = lwt.calcRelativeDirection(dirWave, shoreNormal);



#Initiate values
n = 3; #the entry of the wave-climate-vectors
waveHeight[0] = Hs[n];
waveHeight2[0] = Hs[n];

Hstemp = Hs;
Tptemp = Tp;
relDirtemp = relDir;

for i in range(1, len(profile['z'])):
    #For each dist, calc the waveheigth, based on previous profile-measurement
    (Hstemp, Tptemp, relDirtemp) = lwt.calcWaveConditions(Hstemp, Tptemp, relDirtemp, profile['z'][i-1], profile['z'][i])
    
    #Store the fact whether the waves will break
    waveBreak[i] = lwt.willBreak(Hstemp[n], profile['z'][i], 0.7)
    
    #After calculation: it should be checked if the wave will break, if so: cut height.
    Hstemp = lwt.cutBreakingWaves(Hstemp, profile['z'][i], 0.7)
    waveHeight[i] = Hstemp[n];
    
#end forloop



waveHeightatDist = np.vstack((profile['dist'],waveHeight)).T
depthatDist = np.vstack((profile['dist'],-1*profile['z'])).T
breakatDist = np.vstack((profile['dist'],waveBreak * waveHeight)).T

"""
chart = lwt.plotProfile(profile)

prof = CreateAreaSeries(depthatDist)
prof2 = CreateAreaSeries(waveHeightatDist)
lin = CreateLineSeries(waveHeightatDist)

fig = CreateChart([prof, prof2])
OpenView(fig)
fig.StackSeries = True

fig.Series.Add(lin)
"""
chart = lwt.plotProfile(profile)
OpenView(chart)




chart = lwt.plotProfileWaveHeight(profile, waveHeight)
OpenView(chart)

chart = lwt.addBreakingPlot(chart, profile, waveHeight, waveBreak)

"""
br = CreatePointSeries(breakatDist)
br.Color = Color.LightBlue
br.Size = 5 
#br.Transparency = 30 # %
#br.PointerVisible = False
chart.Series.Add(br)
"""



print('Finish')