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


## Daarnaast, om te testen de CornuSpiraal
#from Scripts.WavePenetration.CornuSpiral import CornuSpiral as _CornuSpiral

from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import Scripts.WavePenetration as wp


""" TEST PhaseShift
beta = 185;
waveLength = 9;
B = 65;

phaseShift = np.exp(1j * (0.5*B*np.cos(beta)/waveLength) * 2*math.pi)

print phaseShift
"""
#DONE 
#region init

#Setup for harbor coordinates:
xRange = np.arange(0., 300., 20.)
yRange = np.arange(0., 400., 20.)
xx, yy = np.meshgrid(xRange, yRange)

bwWidth = 100.
harborDepth = 100000.;
reflectionFactorRight = 1.
reflectionFactorLeft = 1.

#Setup for spectral inputs
waveDir = 90.
waveLength = 100.
Hs = 1.
Smax = 75.
beta0 = waveDir * (math.pi/180.)


#Get waveperiod
k = 2*math.pi / waveLength						#WaveNumber 								[1/m]
omega = np.sqrt(9.81*k*np.tanh(k*harborDepth)) 		#Angular frequency							[rad/s] 
Tp = 2*math.pi/omega			 #Significant wave period T(1/3) of incident wave 			[s] 

#Setup a 'polar'-grid, to have domain of waveFrequencies and waveDirections
fmin = 1/80.
fmax = 10./Tp

resFreq = 100.
resDir = 200.
waveFreqRange = np.linspace(fmin, fmax, resFreq)
waveDirRange = np.linspace(-math.pi, +math.pi, resDir)
f, theta = np.meshgrid(waveFreqRange, waveDirRange)
dFreq = (fmax - fmin)/resFreq

"""
print(np.argmin((yy-150.) ** 2))
myY = np.argmin((yy-150.) ** 2)
[ind1, ind2] = np.unravel_index(myY, np.shape(yy))
print(yy[ind1, ind2])
print(yy[myY])
"""


#dirmin and dirmax are always -pi and +pi
#CHECK DONE! print(Tp)


#local location of breakwater-heads
xR =  0.5*bwWidth 
yR = 0.				 #Location of right breakwater head				[m]
xL = -0.5*bwWidth 
yL = 0.				 #Location of left breakwater head				[m]

#endregion


Sf = wp.getMitsayasuFreqSpectrum(Hs, Tp, f)
D = wp.calcSpreadingFunction(Smax, Tp, f, theta)
#Intermediate result
D0 = np.trapz(D.T, x=waveDirRange, axis=1)/(2*math.pi)
DNorm = wp.normalizeSpreadingFunction(D, waveDirRange)
E_incid = Sf * DNorm


#print(DNorm - D)

#print(D0)


"""
for indR in range(np.size(xx, 0)):
	for indC in range(np.size(xx, 1)):
		#print([xx[indR, indC], yy[indR, indC]])
		pass
	print(xx[indR, 0])
"""



"""
#region test Sf
x = np.arange(0, np.size(Sf[0,:]))
Sftest = np.vstack((x, Sf[0,:])).T
Sftest2 = np.vstack((x, Sf[15,:])).T
lineSeries = CreateLineSeries(Sftest)
lineSeries2 = CreateLineSeries(Sftest2)
chart = CreateChart([lineSeries, lineSeries2])
chart.Title = "Sf chart"
OpenView(chart)
#Klopt niet helemaal. Karakter wel. FACTOR 2PI!! verholpen
#endregion
"""


"""
#region test D0
x = np.arange(0, np.size(D0))
D0test = np.vstack((x, D0)).T
lineSeries = CreateLineSeries(D0test)
chart = CreateChart([lineSeries])
chart.Title = "D0 chart"
OpenView(chart)
#Klopt! 
#endregion
"""


"""
#region test D
x = np.arange(0, np.size(D[74,:]))
Dtest = np.vstack((x, D[74,:])).T
Dtest2 = np.vstack((x, D[169,:])).T
lineSeries = CreateLineSeries(Dtest)
lineSeries2 = CreateLineSeries(Dtest2)
chart = CreateChart([lineSeries, lineSeries2])
chart.Title = "D not normalized chart"
OpenView(chart)
#Klopt.
#endregion
"""



"""
#region test D normalized
x = np.arange(0, np.size(DNorm[74,:]))
DtestN = np.vstack((x, DNorm[74,:])).T
DtestN2 = np.vstack((x, DNorm[169,:])).T
lineSeries = CreateLineSeries(DtestN)
lineSeries2 = CreateLineSeries(DtestN2)
chart = CreateChart([lineSeries, lineSeries2])
chart.Title = "D NORMALIZEDchart"
OpenView(chart)
#Klopt.
#endregion
"""

"""
#region test E_incid
x = np.arange(0, np.size(E_incid[74,:]))
Etest = np.vstack((x, E_incid[74,:])).T
Etest2 = np.vstack((x, E_incid[169,:])).T
Etest3 = np.vstack((x, E_incid[99,:])).T
lineSeries = CreateLineSeries(Etest)
lineSeries2 = CreateLineSeries(Etest2)
lineSeries3 = CreateLineSeries(Etest3)
chart.Title = "E_incid chart"
chart = CreateChart([lineSeries, lineSeries2, lineSeries3])
OpenView(chart)
#Klopt.
#endregion
"""
