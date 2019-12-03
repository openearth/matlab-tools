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


from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import Scripts.WavePenetration as wp
import Scripts.LinearWaveTheory as lwt

from Scripts.WavePenetration.Utilities.CornuSpiralLight import CornuSpiral as _CornuSpiral
print(np.shape(_CornuSpiral))


from Scripts.WavePenetration.Utilities.CornuSpiralDense import CornuSpiral as _CornuSpiral
print(np.shape(_CornuSpiral))


from Scripts.WavePenetration.Utilities.CornuSpiral import CornuSpiral as _CornuSpiral
print(np.shape(_CornuSpiral))
