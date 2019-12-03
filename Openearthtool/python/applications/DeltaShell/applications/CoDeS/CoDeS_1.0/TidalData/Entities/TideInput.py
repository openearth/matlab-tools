#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Josh Friedman
#
#       josh.friedman@deltares.nl
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
class BuildInput:
	def __init__(self):
		self.SetToDefaults()
	
	def SetToDefaults(self):
		for i in Application.Plugins:
			if i.Name == "Toolbox":
				toolbox_dir = i.Toolbox.ScriptingRootDirectory
				
		self.ProjectName = "Name"
		self.WorkDir = toolbox_dir + r"\Scripts\TidalData\WORKING_DIR" # BJ: Adjusted to new map structure #JB: again
		self.DataSource = ""
		self.Filename = "WL_input.txt"
		self.Latitude = "Click Location!"
		self.Longitude = "Click Location!"
		self.StartTime = "2016-01-01"
		self.EndTime = "2016-02-01"
		self.OutputNum = 0
		self.Scenario = None
	
	def Clone(self):
		newInput = BuildInput()
		newInput.ProjectName = self.ProjectName
		newInput.WorkDir = self.WorkDir
		newInput.DataSource = self.DataSource
		newInput.Filename = self.Filename
		newInput.Latitude = self.Latitude
		newInput.Longitude = self.Longitude
		newInput.StartTime = self.StartTime
		newInput.EndTime = self.EndTime
		newInput.OutputNum = self.OutputNum
		
		#The clone should not have acces to scenario-data, since scenario can be updated, while OUTPUT should remain frozen.
		newInput.Scenario = None
		return newInput