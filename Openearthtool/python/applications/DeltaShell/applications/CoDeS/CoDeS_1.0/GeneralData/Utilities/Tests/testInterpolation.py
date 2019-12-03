#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Hidde Elzinga
#
#       hidde.elzinga@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
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
from Scripts.GeneralData.Utilities.Interpolation import *
from Scripts.WavePenetration.Utilities.CornuSpiral import CornuSpiral as _CornuSpiral
import numpy as np
import numpy as _np
import math

import time

henk = np.array([1, 2, 2.4, 3.4])
toos = np.array([8, 6, 8, 10]);
meertoos = np.array([8, 10, 11, 1, 98]); 
compl = np.array([8+1j, 10+34j, 8+54j, 10+114j]);

"""
x = _np.array([3., 3.3, 3.2, 2.8, 3.15, 2.14])
x = x.reshape((3,2))
y = np.zeros(x.shape, dtype=x.dtype)
print(y)
"""

"""
print(compl.dtype)
print(henk.dtype)
print(_np.zeros_like(henk, dtype=compl.dtype))
np.zero
"""
"""
#Scalar input
print(Interp(_np.array([3.]), henk, toos))
print(Interp(_np.array([3.]), henk, compl))
a = Interp(_np.array([3.]), henk, compl.Real)
b = Interp(_np.array([3.]), henk, compl.Imag)
print(a + b*1j)
"""

"""
#Multiple inputs (1D)
print(Interp(_np.array([3., 3.3]), henk, toos))
print(Interp(_np.array([3., 3.2]), henk, compl))
a = Interp(_np.array([3., 3.2]), henk, compl.Real)
b = Interp(_np.array([3., 3.2]), henk, compl.Imag)
print(a + b*1j)
"""

"""
#This fails:
print(Interp(_np.array([3, 3.2, 2.5, 2.8]), henk, compl))
#Split up will do the job:
a = Interp(_np.array([3, 3.2, 2.5, 2.8]), henk, compl.Real)
b = Interp(_np.array([3, 3.2, 2.5, 2.8]), henk, compl.Imag)
print(a + b*1j)
"""

"""
#Multiple inputs (2D)
gridvb = _np.array([[3, 3.2], [2.5, 2.8]])

check2D = Interp(gridvb, henk, meertoos)
print(check2D)
#This fails:
check2Dcompl = Interp(gridvb, henk, compl)
print(check2Dcompl)

#Split up will do the job:
a2 = Interp(gridvb, henk, compl.Real)
b2 = Interp(gridvb, henk, compl.Imag)
print(a2 + b2*1j)
"""

#generate meshgrid
xRange = np.arange(-400., 400., 20.)
yRange = np.arange(0., 400., 2.)
xx, yy = np.meshgrid(xRange, yRange)

print(_np.size(xx))

theta0 = 0.2*math.pi
k = 4.5
r = np.hypot(xx, yy);																			#[XxY meshgrid]
theta = np.arctan2(yy, xx) % (2*math.pi);														#[XxY meshgrid]
sigmaI =  2*np.sqrt(k*r/math.pi) * np.sin(0.5*(theta-theta0)) * np.sign(np.cos(0.5*(theta0))); #Incident wave field 
sigmaR = -2*np.sqrt(k*r/math.pi) * np.sin(0.5*(theta+theta0)) * np.sign(np.cos(0.5*(theta0))); #Reflected wave field 

t0 = time.time()
"""
GiR = 0.5 + Interp(sigmaI, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Real)			#Incident wave field (real part)
GiI = Interp(sigmaI, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Imag)				#Incident wave field (complex part)
Gi = GiR + GiI * 1j

GrR = 0.5 + Interp(sigmaR, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Real)			#Reflected wave field (real part)
GrI = Interp(sigmaR, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Imag)				#Reflected wave field (complex part)
Gr = GrR + GrI * 1j
"""
t1 = time.time()

Gi = 0.5 + Interp(sigmaI, _CornuSpiral[:,0].Real, _CornuSpiral[:,1])				#Incident wave field
Gr = 0.5 + Interp(sigmaR, _CornuSpiral[:,0].Real, _CornuSpiral[:,1])				#Reflected wave field

t2 = time.time()



print('Timing of interpolations with medium CornuSiral')
print(t2-t1)
print('In matlab approx 0.008 sec')

