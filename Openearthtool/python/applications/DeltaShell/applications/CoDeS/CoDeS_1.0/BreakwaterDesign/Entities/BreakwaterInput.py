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
import Scripts.GeneralData.Utilities.PythonObjects as _PythonObjects

		
class BreakwaterInput(object):
	def __init__(self):
		self._observers = []
		self.cross_ind = 0
		self._Hs0 = 3
		self._Tp0 = 12
		self.SWL = 1
		self._cota = 3
		self._z = 10.0
		self._z0 = 100
		self._angleinc = 0
		self._theta0 = 0
		self.Armour_Type = "Rock"
		self.Armour_TypeIndex = 0
		self._rhos = 2650
		self._rhow = 1000
		self._P = 0.4
		self._S = 2
		self._stormdur = 6
		self._autocrest = True
		self._crestheight = 0
		self._crestwidth = 5
		self._situation = "n"
		self.situationIndex = 0
		self._gammab = 1
		self._gammabreak = 0.73
		self._gammaf = 0.4
		self._kt = 1
		self._g = 9.81
		self._cpl = 6.2
		self._cs = 1.0
		self.qthres = 0.1
		self.profile = {}
		self.is2D = True
		self._isOffshore = True
		self.MakePositive = False
		self._unitCostArmour = 20
		self._unitCostFilter = 15
		self._unitCostCore = 10
		self.ProfileSteps = 50
		self.IsNegative = False
		
		
	def CreatePropertyFor(fieldName):
		return property(lambda s : _PythonObjects.GetValue(s,fieldName),lambda s,v : _PythonObjects.SetValueAndNotifyObs(s,v,fieldName))
		
	def bind_to(self, callback):
		self._observers.append(callback)
	
	def unbind_to(self, callback):
		self._observers.remove(callback)
	
	def unbindall(self):
		self._observers = []
	
	
	#Hs = 				CreatePropertyFor("_Hs")
	Hs0 = 				CreatePropertyFor("_Hs0")
	#Tp = 				CreatePropertyFor("_Tp")
	Tp0 = 				CreatePropertyFor("_Tp0")
	#SWL = 				CreatePropertyFor("_SWL")
	cota = 				CreatePropertyFor("_cota")
	z = 				CreatePropertyFor("_z")
	z0 = 				CreatePropertyFor("_z0")
	angleinc = 			CreatePropertyFor("_angleinc")
	#theta = 			CreatePropertyFor("_theta")
	theta0 = 			CreatePropertyFor("_theta0")
	#Armour_Type = 		CreatePropertyFor("_Armour_Type")
	#Armour_TypeIndex = 	CreatePropertyFor("_Armour_TypeIndex")
	rhos = 				CreatePropertyFor("_rhos")
	rhow = 				CreatePropertyFor("_rhow")
	P = 				CreatePropertyFor("_P")
	S = 				CreatePropertyFor("_S")
	stormdur = 			CreatePropertyFor("_stormdur")
	autocrest = 		CreatePropertyFor("_autocrest")
	crestheight = 		CreatePropertyFor("_crestheight")
	crestwidth = 		CreatePropertyFor("_crestwidth")
	situation = 		CreatePropertyFor("_situation")
	#situationIndex = 	CreatePropertyFor("_situationIndex")
	gammab = 			CreatePropertyFor("_gammab")
	gammabreak = 		CreatePropertyFor("_gammabreak")
	gammaf = 			CreatePropertyFor("_gammaf")
	kt = 				CreatePropertyFor("_kt")
	g = 				CreatePropertyFor("_g")
	cpl = 				CreatePropertyFor("_cpl")
	cs = 				CreatePropertyFor("_cs")
	isOffshore = 		CreatePropertyFor("_isOffshore")
	unitCostArmour = 	CreatePropertyFor("_unitCostArmour")
	unitCostFilter = 	CreatePropertyFor("_unitCostFilter")
	unitCostCore = 		CreatePropertyFor("_unitCostCore")
	
	
	
	def Clone(self):
		newInput = BreakwaterInput()
		newInput.IsNegative = self.IsNegative
		newInput.Hs0 = self.Hs0
		newInput.Tp0 = self.Tp0
		newInput.SWL = self.SWL
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
		newInput.profile = self.profile
		newInput.is2D = self.is2D
		newInput.isOffshore = self.isOffshore
		newInput.MakePositive = self.MakePositive
		newInput.unitCostArmour = self.unitCostArmour
		newInput.unitCostFilter = self.unitCostFilter
		newInput.unitCostCore = self.unitCostCore
		newInput.cross_ind = self.cross_ind
		newInput.ProfileSteps = self.ProfileSteps
		return newInput

"""def printChange(currentValue):
	print currentValue.Tp

v = BuildInput()
v.bind_to(printChange)
v.Tp = 1"""

"""print v.MakePositive
print v._MakePositive"""

"""for property, value in vars(v).iteritems():
	print property, ": ", value"""
	

"""def bind_to(self, callback):
	self._observers.append(callback)

def _SetValueAndNotifyObservers(object, propertyName, value):
	print "Set value" + value
	SetValue(object, propertyName, value)
	for callback in object._observers:
		callback(GetValue(object, propertyName))

def CreatePropertyFor(fieldName):
	return property(lambda s: GetValue(s,fieldName) ,lambda s,v: """"""_SetValueAndNotifyObservers(s,fieldName,v)"""""")
""""""
	RasterPath = CreatePropertyFor("_RasterPath")
MakePositive = CreatePropertyFor("_MakePositive")"""

"""for property, value in vars(v).iteritems():
	print property"""


