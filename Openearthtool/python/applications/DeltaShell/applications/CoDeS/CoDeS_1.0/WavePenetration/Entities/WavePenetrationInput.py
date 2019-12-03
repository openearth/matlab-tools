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
import Scripts.GeneralData.Utilities.PythonObjects as _PythonObjects

class WavePenetrationInput(object):
	
	def __init__(self):
		self._observers = []
		self._Hs = 2
		self._Tp = 6
		self._waveDir = 330
		self._Smax = 30
		self._gridPoints = 3000
		self._harborDepth = 15
		
		self._bwLeftKey = None
		self._bwRightKey = None
		
	def CreatePropertyFor(fieldName):
		return property(lambda s : _PythonObjects.GetValue(s,fieldName),lambda s,v : _PythonObjects.SetValueAndNotifyObs(s,v,fieldName))
	
	def bind_to(self, callback):
		self._observers.append(callback)

	def unbind_to(self, callback):
		self._observers.remove(callback)

	def unbindall(self):
		self._observers = []
	
	Hs = CreatePropertyFor("_Hs")
	Tp = CreatePropertyFor("_Tp")
	waveDir = CreatePropertyFor("_waveDir")
	Smax = CreatePropertyFor("_Smax")
	gridPoints = CreatePropertyFor("_gridPoints")
	harborDepth = CreatePropertyFor("_harborDepth")
		
	bwLeftKey = CreatePropertyFor("_bwLeftKey")
	bwRightKey = CreatePropertyFor("_bwRightKey")
		
		
	