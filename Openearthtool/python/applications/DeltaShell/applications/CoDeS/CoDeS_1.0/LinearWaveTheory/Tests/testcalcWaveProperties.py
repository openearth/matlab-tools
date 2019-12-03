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


## =============================================================
def testisDeepWater():
	#FORMAT: TF = isDeepWater(waveLength, waterDepth)
	henk = isDeepWater(np.array([23.]),np.array([2451])) 		#Should be deep (returns true)
	henk2 = isDeepWater(np.array([29.]),np.array([24]))			#Should be deep (returns true)
	henk3 = isDeepWater(np.array([29.]),np.array([13]))			#Should be undeep (returns false)
	#Different waveLengths (single depth)
	toos = isDeepWater(np.array([1, 13, 97]), np.array([24])) #One undeep, so returns false
	toos2 = isDeepWater(np.array([1, 13, 34]), np.array([24])) #All deep, so returns true
	#Empty sets should return false
	fien = isDeepWater(np.array([]),np.array([]))
	
	print([henk, henk2, henk3])
	print([toos, toos2])
	print(fien)
	return




## =============================================================
def testcalcWaveLength():	
	#offshZ = getdepth(offshLat, offshLon)
	offshZ = -500.0
	#nearshZ = getdepth(nearshLat, nearshLon)
	nearshZ = -2.0
	
	#Get absolute depths
	offshoreWaterDepth = abs(offshZ)
	nearshoreWaterDepth = abs(offshZ)
	
	#Get an array of wave periods
	wavePeriod = np.array([8, 7, 15, 5, 9]).astype('float');     			#Wave-period [s]
	
	waveLength = calcWaveLength(wavePeriod, offshoreWaterDepth)
	
	#With this wavelength, the following equation should hold approximately
	waveLengthTest = ((9.81*wavePeriod**2) / (2*math.pi)) * np.tanh(2*math.pi * offshoreWaterDepth / waveLength)
	waveLengthDeep = (9.81*wavePeriod**2) / (2*math.pi)
	
	print(str(waveLengthTest - waveLength))
	
	#Other equation should hold (p.26):
	wavePeriodTest = ((9.81 / (2*math.pi * waveLength)) * np.tanh(2*math.pi * offshoreWaterDepth / waveLength))**(-0.5)
	
	print(str(wavePeriodTest - wavePeriod))
	
	return


"""
def testcalcWaveVelocity():
	
	waveLength = 23
	waterDepth = 27
	
	
	print(str(waveVelocityTest - waveVelocity))
	return"""