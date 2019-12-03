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
import ConfigParser as _ConfigParser
import Scripts.WavePenetration.Entities as _WavePenetrationEntities

class WavePenetrationPersister:
	def __init__(self):
		self.ToolId = "WavePenetrationData"
		self._sectionName = "InputData"
	
	def Save(self, WavePenetrationData, path):
		config = _ConfigParser.RawConfigParser()
		config.optionxform = str
		config.add_section(self._sectionName)
		InputData = WavePenetrationData.InputData
		InputList = [a for a in dir(InputData) if not a.startswith('_') and not callable(getattr(InputData,a))]
		
		for item in InputList:
			config.set(self._sectionName, item, getattr(InputData,item))
		
		with open(path, "wb") as WavePenetrationFile:
			config.write(WavePenetrationFile)
	
	def Load(self, path):
		InputData = _WavePenetrationEntities.WavePenetrationInput()
		
		config = _ConfigParser.RawConfigParser()
		config.optionxform = str
		config.read(path)
		
		InputList = [a for a in dir(InputData) if not a.startswith('_') and not callable(getattr(InputData,a))]
		
		for item in InputList:
			setattr(InputData,item,self._ConvertToFloat(config.get(self._sectionName, item)))
		
		WavePenetrationData = _WavePenetrationEntities.WavePenetrationData(InputData)
		
		return WavePenetrationData
		
	def _ConvertToFloat(self, text):
		"""Try to convert to float if number and convert to boolean if True or False, else pass string"""
		if (text == "None" or text == ""):
			return None
		
		if (text == "True"):
			return True
		
		if (text == "False"):
			return False
		
		try:
			num = float(text)
		except:
			num = text
		
		return num
		
