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
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import numpy as np
import math


#Importing all modules of collegues
import Scripts.LinearWaveTheory as lwt
#import Scripts.BathymetryData as bmd
#import Scripts.BreakwaterDesign as bwd
import Scripts.TidalData as td
#import Scripts.CoastlineDevelopment as cd
import Scripts.WaveWindData as wwd

from Scripts.BathymetryData.GridFunctions import *


#Get depth- and distance-vectors from origin (offshore) to end (nearshore)
#(X,Y,dist,depth) = bmd.GetProfile("Bathymetry","elevation_luanda_5m", 298906, 9017957, 300000, 9018633, 100)



#henk = bmd.ReadGridValue("Bathymetry","elevation_luanda_5m", 300000, 9018000)    #Depth [m]
#truus = bmd.ReadGridValue("Bathymetry","elevation_luanda_5m", 299000, 9017000)    #Depth [m]

#Two depths: offshore and nearshore (with lat/lon and bathy gives depth in [m + ref])
#offshZ = getDepth(offshLat, offshLon)    #Depth [m]
#offshZ = np.array(-50.0)
#nearshZ = getDepth(nearshLat, nearshLon) #Depth [m]
#nearshZ = np.array(-2.0)

#depth = np.array([30, 25, 19, 19, 19, 18, 17, 15, 14, 10, 13, 12, 9, 8, 4, 3, 2, 2, 2,1]) * -1;
dist = range(0, np.alen(depth))
depthatDist = np.vstack((dist,depth)).T


#Shore normal (with north, in deg) defined by bathy
#(single entry, since one coast per call)
#shoreNormal = getShoreNormal(nearshLat, nearshLon);         #Shore direction [deg]
shoreNormal = np.array(220)


#Convert to absolute depths [m] (only for internal use)
depth = abs(np.array(depth))


#Wave-climate offshore (3 arrays) (+ occurence?)
Hs = np.array([4.25, 1.01, 13, 13.2, 2.2, 1, 5.5, 5, 4]);            #Wave-heigth [m]
Tp = np.array([8, 7, 15, 15, 5, 9, 12, 1, 32]);                      #Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130]);     #Wave direction [deg]


#The angle between shore and wave.
# (in degrees, modulo 360, but between -180 and 180)
# ref: Waves in Oceanic and Coastal Waters p.205, fig 7.7
relDir = (shoreNormal - dirWave + 180) % 360 - 180

#If DirWave == ShoreNormal, then the wave will go 'gerade aus'.
#If DirWave <= ShoreNormal - 90 or 
#    DirWave >  ShoreNormal + 90
#then the wave will never reach the coast.

#These instances should be removed from the table.
ixD = (-90 <= relDir) & (relDir < 90)
#Selecting the values which are in valid range.
Hs = Hs[ixD]
Tp = Tp[ixD]
relDir = relDir[ixD]

print('Due to shore normal and wave direction, %d wave-instances are removed' % (sum(~ixD)))

#Initiate
waveHeight = np.zeros(np.alen(depth))
n = 0 # n-th wave-climate will be stored for plotting.
waveHeight[0] = Hs[n]

for i in range(1, len(depth)):
    #for n in range(0,np.alen(Hs)):
    #for test: take 3 wave_classes
    
    (Hsnew, Tpnew, relDirnew) = lwt.calcWaveConditions(Hs[n], Tp[n], relDir[n], depth[i-1], depth[i])
    waveHeight[i] = Hsnew;

waveHeightatDist = np.vstack((dist,waveHeight)).T

profile = dict()
profile['dist'] = dist
profile['z'] = depth
profile['x'] = X
profile['y'] = Y


chart = lwt.plotProfileWaveHeight(profile, waveHeight)
OpenView(chart)






"""
Ldeep = calcWaveLength(Tp, offshZ)
Lnear = calcWaveLength(Tp, nearshZ)
#print(isDeepWater(Ldeep, offshZ))

Cdeep = calcWaveVelocity(Ldeep, offshZ)
Cnear = calcWaveVelocity(Lnear, nearshZ)

SinThetadeep = np.sin(relDir * (math.pi / 180.))

#All input arrays have same size:
#REMARK: values of sinus should be between -90 and 90 deg,
#otherwise the waves will not enter the coast
SinThetanear = (SinThetadeep / Cdeep) * Cnear
Thetanear = np.arcsin(SinThetanear) * (180. / math.pi)

#Refraction: ref [?]
Kr = (np.cos(relDir) / np.cos(Thetanear)) ** 0.5


#Shoaling coefficient:
Cgroupdeep = calcGroupVelocity(Ldeep, Tp, offshZ)
Cgroupnear = calcGroupVelocity(Lnear, Tp, nearshZ)

Ks = (Cgroupdeep / Cgroupnear) ** 0.5


#test0 = willBreak(np.array([12]), np.array([12]), 0.75)
#test1 = willBreak(np.array([120]), np.array([12]), 0.75)
#test2 = willBreak(np.array([1]), np.array([12]), 0.75)
#test3 = willBreak(np.array([1]), np.array([12]), 0.75)
#print(str([test0, test1, test2, test3]))



#Final output arguments:
#Wave-climate of the near shore climate,
waveHeightnear = Kr * Ks * Hs
wavePeriodnear = Tp
dirWavenear = Thetanear

"""