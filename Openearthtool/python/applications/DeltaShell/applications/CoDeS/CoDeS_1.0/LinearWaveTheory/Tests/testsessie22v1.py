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


##Assume a given profile

depth = np.array([30, 25, 19, 19, 19, 18, 17, 15, 20, 20, 21, 26, 18., 12, 14, 10, 13, 12, 9, 8, 4, 3, 2, 2, 2,1]);
dist = np.arange(0, np.alen(depth)) * 1.


profile = dict()
profile['dist'] = dist
profile['z'] = depth
profile['x'] = dist
profile['y'] = dist

meanDist = np.zeros(len(dist)-1)
meanDepth = np.zeros(len(depth)-1)
for i in range(len(meanDist)):
    meanDist[i] = (dist[i] + dist[i+1])/2
    meanDepth[i] = (depth[i] + depth[i+1])/2


profile['mean_dist'] = meanDist
profile['mean_z'] = meanDepth


depthatDist = np.vstack((meanDist,meanDepth)).T

#Generating Series
pointsProfile = CreatePointSeries(depthatDist)
pointsProfile.Color = Color.DarkRed

pointsProfile.Style.Circle
chart = lwt.plotProfile(profile)

OpenView(chart)



chart = lwt.addBreakWaterDashes(chart, profile)

#Wave-climate offshore (3 arrays) (+ occurence?)
Hs = np.array([4.25, 1.01, 13, 13.2, 2.2, 1, 5.5, 5, 4]);            #Wave-heigth [m]
Tp = np.array([8, 7, 15, 15, 5, 9, 12, 1, 32]);                      #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130]);     #Wave direction [deg]

#Initiate
waveHeight = np.zeros(np.alen(depth))
n = 6 # n-th wave-climate will be stored for plotting.
waveHeight[0] = Hs[n]

for i in range(1, len(depth)):
    #for n in range(0,np.alen(Hs)):
    #for test: take 3 wave_classes
    
    (Hsnew, Tpnew, relDirnew) = lwt.calcWaveConditions(Hs[n], Tp[n], dirWave[n], depth[i-1], depth[i])
    waveHeight[i] = Hsnew;


chart = lwt.addWaveHeightPlot(chart, profile, waveHeight)