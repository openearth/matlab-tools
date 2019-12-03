#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Aline Kaji
#
#       aline.kaji@witteveenbos.com
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
import Scripts.CoastlineDevelopment.Entities as _CoastlineEntities

class CoastlineDevelopmentPersister:

	def __init__(self):
		self.ToolId = "coastlinedevelopment"
		self._sectionName = "InputData"
	
	def Save(self, CoastlineDevelopmentData, path):
		config = _ConfigParser.RawConfigParser()
		
		config.add_section(self._sectionName)
		InputData = CoastlineDevelopmentData.InputData
				
		InputList = [a for a in dir(InputData) if not a.startswith('_') and not callable(getattr(InputData,a))]
		
		for item in InputList:
			itemValue = getattr(InputData,item)
			
			#	Store only basic 
			if isinstance(itemValue,int) or isinstance(itemValue,float) or isinstance(itemValue,str):
				config.set(self._sectionName, item, itemValue)
			
				
		
		with open(path, "wb") as CoastlineDevelopmentFile:
			config.write(CoastlineDevelopmentFile)
		
		
	def Load(self, path):
		InputData = _CoastlineEntities.CoastlineInput.InputData()
		
		config = _ConfigParser.RawConfigParser()
		config.read(path)
		
		InputList = [a for a in dir(InputData) if not a.startswith('_') and not callable(getattr(InputData,a))]
		
		
		for item in InputList:			
			if item not in ['Coastline_utm','Coastline_utm_codes','Profiles_utm','Profiles_utm_codes','Breakwaters_utm','Waves']:				
				setattr(InputData,item,self._ConvertToFloat(config.get(self._sectionName, item)))
		
		CoastlineDevelopmentData = _CoastlineEntities.CoastlineDevelopmentData(InputData)		
		
		return CoastlineDevelopmentData
		
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
		
"""#	Make new CoastlineInput object

input = _CoastlineEntities.CoastlineInput.InputData()
coastlineData = _CoastlineEntities.CoastlineDevelopmentData(input)

persister = CoastlineDevelopmentPersister()
data = persister.Load(r"C:\Projecten\Coastal Design Toolbox\Temp\CoastlineDevelopment.dat")"""


