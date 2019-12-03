#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
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
import Scripts.BreakwaterDesign.ENGINEv2 as bw

class BuildInput(object):
	def __init__(self):
		self._observers = []
		self.counterTAB = 0
		self.Hs = 3
		self.Hs0 = 3
		self.Tp = 12
		self.Tp0 = 12
		self.SWL = 1
		self._cota = 3
		self.z = 10
		self.z0 = 100
		self.angleinc = 0
		self.theta = 0
		self.theta0 = 0
		self.Armour_Type = "Rock"
		self.Armour_TypeIndex = 0
		self.rhos = 2650
		self.rhow = 1000
		self.P = 0.4
		self.S = 2
		self.stormdur = 6
		self.autocrest = True
		self.crestheight = 0
		self.crestwidth = 5
		self.situation = "n"
		self.situationIndex = 0
		self.gammab = 1
		self.gammabreak = 0.73
		self.gammaf = 0.4
		self.kt = 1
		self.g = 9.81
		self.cpl = 6.2
		self.cs = 1.0
		self.qthres = 0.1
		self.length = 1000
		self.cross_ind = 0
		self.profile = {}
		self.is2D = False
		self.isOffshore = True
		self.IsNegative = False
		self.BWlayer = None
		self.mapview = None
		self.RasterPath = ""
		self.MakePositive = False
		self.unitCostArmour = 20
		self.unitCostFilter = 15
		self.unitCostCore = 10
	
	def get_cota(self):
		return self._cota
	
	def set_cota(self, value):
		print 'value setted'
		self._cota = value
		
		for callback in self._observers:
			print 'anouncing change'
			callback(self)
	
	cota = property(get_cota, set_cota)
	
	def bind_to(self, callback):
		print 'bound'
		self._observers.append(callback)
	
	
	def Clone(self):
		newInput = BuildInput()
		newInput.counterTAB = self.counterTAB
		newInput.Hs = self.Hs
		newInput.Hs0 = self.Hs0
		newInput.Tp = self.Tp
		newInput.Tp0 = self.Tp0
		newInput.SWL = self.SWL
		newInput.theta = self.theta
		newInput.theta0 = self.theta0
		newInput.cota = self.cota
		newInput.z = self.z
		newInput.z0 = self.z0
		newInput.angleinc = self.angleinc
		newInput.Armour_Type = self.Armour_Type
		newInput.Armour_TypeIndex = self.Armour_TypeIndex
		newInput.rhos = self.rhos
		newInput.rhow = self.rhow
		newInput.P = self.P
		newInput.S = self.S
		newInput.stormdur = self.stormdur
		newInput.autocrest = self.autocrest
		newInput.crestheight = self.crestheight
		newInput.crestwidth = self.crestwidth
		newInput.situation = self.situation
		newInput.situationIndex = self.situationIndex
		newInput.gammab = self.gammab
		newInput.gammaf = self.gammaf
		newInput.gammabreak = self.gammabreak 
		newInput.kt = self.kt
		newInput.g = self.g
		newInput.cpl = self.cpl 
		newInput.cs = self.cs
		newInput.qthres = self.qthres
		newInput.length = self.length
		newInput.cross_ind = self.cross_ind
		newInput.profile = self.profile
		newInput.is2D = self.is2D
		newInput.isOffshore = self.isOffshore
		newInput.IsNegative = self.IsNegative
		newInput.BWlayer = self.BWlayer
		newInput.mapview = self.mapview
		newInput.RasterPath = self.RasterPath
		newInput.MakePositive = self.MakePositive
		newInput.unitCostArmour = self.unitCostArmour
		newInput.unitCostFilter = self.unitCostFilter
		newInput.unitCostCore = self.unitCostCore
		return newInput
		
class BuildOutput(object):
	def __init__(self,InputData):
		self.Inputdata = InputData
		self.Inputdata.bind_to(self.updateOutput)
		self.Outputdata = bw.ENGINE(self.Inputdata)
	
	def updateOutput(self,inputData):
		self.Outputdata = bw.ENGINE(inputData)
		print inputData.cota

data = BuildInput()
Out = BuildOutput(data)

print Out.Outputdata.irri

data.cota = 2

print Out.Outputdata.irri



