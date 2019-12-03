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
import ConfigParser as _ConfigParser
import Scripts.BreakwaterDesign.Entities as _BreakwaterEntities


exceptionlist = ['situation','qthres','profile'] # list with properties that not have to be saved


class BreakwaterPersister:
	def __init__(self):
		self.ToolId = "BreakwaterData"
		self._sectionName = "InputData"
	
	def Save(self, BreakwaterData, path):
		config = _ConfigParser.RawConfigParser()
		config.optionxform = str
		config.add_section(self._sectionName)
		InputData = BreakwaterData.inputData
		InputList = [a for a in dir(InputData) if not a.startswith('_') and not callable(getattr(InputData,a)) and not a in exceptionlist]
		
		for item in InputList:
			config.set(self._sectionName, item, getattr(InputData,item))
		
		with open(path, "wb") as BreakwaterFile:
			config.write(BreakwaterFile)
	
	def Load(self, path):
		InputData = _BreakwaterEntities.BreakwaterInput()
		
		config = _ConfigParser.RawConfigParser()
		config.optionxform = str
		config.read(path)
		
		InputList = [a for a in dir(InputData) if not a.startswith('_') and not callable(getattr(InputData,a)) and not a in exceptionlist]
		
		for item in InputList:
			setattr(InputData,item,self._ConvertToFloat(config.get(self._sectionName, item)))
		
		BreakwaterData = _BreakwaterEntities.BreakwaterData(InputData)
		
		print "BreakwaterData Loaded"
		
		return BreakwaterData
	
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
		
		

#breakwaterData = Load(	
#list = dir(InputData)
#for l in list:
	#print l