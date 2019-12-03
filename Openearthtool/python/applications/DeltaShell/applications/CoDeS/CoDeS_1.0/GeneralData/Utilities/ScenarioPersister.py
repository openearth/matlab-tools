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
import os as _os
import csv as _csv
import clr as _clr
import ast as _ast
import datetime as _datetime
import ConfigParser as _ConfigParser
import numpy as _np
import Scripts.GeneralData.Entities as _entities
import Scripts.BreakwaterDesign.Entities as _BreakwaterEntities
from GisSharpBlog.NetTopologySuite.IO import WKTReader as _wktReader
from GisSharpBlog.NetTopologySuite.Geometries import Point as _Point
from SharpMap.Extensions.Data.Providers import GdalFeatureProvider as _GdalFeatureProvider

_clr.AddReference("System.Windows.Forms")
_clr.AddReference("Log4Net")
from log4net import LogManager
import System.Windows.Forms as _swf


"""config = _ConfigParser.ConfigParser()
config.read(r"C:\Projecten\Coastal Design Toolbox\Temp\TestScenario\test_GenericData.dat")
print config.sections

wavesLocationText = config.get("Waves","Location")
print(config.has_option("Waves","sourcepath"))"""



class ScenarioPersister:
	
	def __init__(self):
		self._log = LogManager.GetLogger("Scenario persister")
		
		self._csvFileDelimiter= ";"
		self._dateTimeFormat = "%Y/%m/%d %H:%M:%S" 
		
		# filenames
		self._genericDataFileName = "GenericData.dat"
		self._civilStructuresFileName = "CivilStructures.dat"
		self._waveClimatesFileName = "WaveClimates.csv"
		self._tideDataFileName = "TideData.csv"
		
		# scenario sectionnames
		self._genericDataSectionName = "GenericData"
		self._toolDataSectionName = "ToolData"
		
		# GenericData sectionnames
		self._settingsSectionName = "Settings"
		self._bathymetrySectionName = "Bathymetry"
		self._civilStructuresSectionName = "CivilStructures"
		self._coastlineSectionName = "Coastline"
		self._wavesSectionName = "Waves"
		self._tideSectionName = "Tide"
		
		self.ToolDataPersisters = []

	def SaveScenario(self, scenario, path):
		try:
			dir = _os.path.dirname(path)
			prefix = _os.path.splitext(_os.path.basename(path))[0]
			
			genericDataFileName = self._AddPrefixToFileName(self._genericDataFileName, prefix)
			genericDataPath = _os.path.join(dir, genericDataFileName)
					
			self.SaveGenericData(scenario.GenericData, genericDataPath, prefix)
			
			# build config file
			config = _ConfigParser.RawConfigParser()
			config.optionxform = str # Make sure upper and lower case is used
			config.add_section(self._genericDataSectionName)
			config.set(self._genericDataSectionName, "Path", genericDataFileName)
			
			config.add_section(self._toolDataSectionName)
			
			for data in scenario.ToolData.iteritems():
				toolId = data[0]
				persister = self._GetPersisterFor(toolId)
				
				if (persister == None):
					self._log.Error("Could not save " + toolId + " data")
					continue
				
				filename = self._AddPrefixToFileName(toolId + ".dat", prefix)
				filePath = _os.path.join(dir, filename)
				
				
				print persister.__class__
				persister.Save(data[1], filePath)
				
				config.set(self._toolDataSectionName, toolId, filename)
			
			with open(path, "wb") as scenariofile:
				config.write(scenariofile)
		except Exception, e:
			self._log.Error("Error during writing scenario: " + str(e))
			return False
		
		return True
	
	def SaveGenericData(self, genericData, path, fileNamePrefix = ""):
		try:
			dir = _os.path.dirname(path)
			
			# build config file
			config = _ConfigParser.RawConfigParser()
			#config.optionxform = str
			config.add_section(self._settingsSectionName)
			config.set(self._settingsSectionName, "SR_EPSGCode", genericData.SR_EPSGCode)
			config.set(self._settingsSectionName, "D50", genericData.D50)
			config.set(self._settingsSectionName, "D90", genericData.D90)
			
			# save Bathymetry
			self._log.Debug("Saving Bathymetry")
			if (genericData.Bathymetry != None):
				config.add_section(self._bathymetrySectionName)
				config.set(self._bathymetrySectionName, "IsDepth", genericData.Bathymetry.IsDepth)
				config.set(self._bathymetrySectionName, "BathymetryType", genericData.Bathymetry.BathymetryType)
				
				if (genericData.Bathymetry.BathymetryType == _entities.BathymetryType.Slope):
					config.set(self._bathymetrySectionName, "SlopeValue", genericData.Bathymetry.SlopeValue)
				if (genericData.Bathymetry.BathymetryType == _entities.BathymetryType.Ascii):
					config.set(self._bathymetrySectionName, "OriginalSpatialReference", genericData.Bathymetry.OriginalSpatialReference)
					config.set(self._bathymetrySectionName, "SourcePath", genericData.Bathymetry.SourcePath)
					config.set(self._bathymetrySectionName, "UnitDescription", genericData.Bathymetry.UnitDescription)
			
			# save CivilStructures
			self._log.Debug("Saving CivilStructures")
			if (genericData.CivilStructures != None):
				
				civilStructuresFileName = self._AddPrefixToFileName(self._civilStructuresFileName, fileNamePrefix)
				civilStructuresPath = _os.path.join(dir, civilStructuresFileName)				
				
				self.SaveCilvilStructures(genericData.CivilStructures, civilStructuresPath)
				
				config.add_section(self._civilStructuresSectionName)
				config.set(self._civilStructuresSectionName, "Structures", civilStructuresFileName)
			
			# save Coastline
			self._log.Debug("Saving Coastline")
			if (genericData.Coastline != None):
				config.add_section(self._coastlineSectionName)
				
				#self._log.Debug("Name is " + genericData.Coastline.Name)
				config.set(self._coastlineSectionName, "Name", genericData.Coastline.Name)
				config.set(self._coastlineSectionName, "CoastlineGeometry", genericData.Coastline.CoastlineGeometry)
				#self._log.Debug("Name is " + genericData.Coastline.Name)
			
			# save Waves
			self._log.Debug("Saving Waves")
			if (genericData.Waves != None):
				#self._log.Debug("Waves present")
				config.add_section(self._wavesSectionName)
				config.set(self._wavesSectionName, "SourcePath", genericData.Waves.SourcePath)
				if genericData.Waves.Location <> None:
					config.set(self._wavesSectionName, "Location", _Point(genericData.Waves.Location.X, genericData.Waves.Location.Y))
				config.set(self._wavesSectionName, "Z", genericData.Waves.Z)
				config.set(self._wavesSectionName, "Type", genericData.Waves.Type)
				config.set(self._wavesSectionName, "ReturnPeriodExtremeValue", genericData.Waves.ReturnPeriodExtremeValue)
				config.set(self._wavesSectionName, "ExtremeValueClimate", genericData.Waves.ExtremeValueClimate)
				config.set(self._wavesSectionName, "IsOffshore", genericData.Waves.IsOffshore)
				
				waveClimatesFileName = self._AddPrefixToFileName(self._waveClimatesFileName, fileNamePrefix)
				waveClimatesPath = _os.path.join(dir, waveClimatesFileName)
				config.set(self._wavesSectionName, "WaveClimates", waveClimatesFileName)
				
				self.SaveWaveClimates(genericData.Waves.WaveClimates, waveClimatesPath, fileNamePrefix)
			
			# save tide
			self._log.Debug("Saving tide")
			if (genericData.Tide != None):
				config.add_section(self._tideSectionName)
				config.set(self._tideSectionName, "Location", genericData.Tide.Location)
				config.set(self._tideSectionName, "cons", genericData.Tide.cons)
				
				tideDataFileName = self._AddPrefixToFileName(self._tideDataFileName, fileNamePrefix)
				tideDataPath = _os.path.join(dir, tideDataFileName)
				self._SaveTideData(genericData.Tide.data, tideDataPath)
				
				config.set(self._tideSectionName, "dataPath", tideDataFileName)
				
				statsToDoubleLookup = {k : v.Value for (k, v) in genericData.Tide.stats.iteritems()}
				config.set(self._tideSectionName, "stats", statsToDoubleLookup)
				
				config.set(self._tideSectionName, "HAT", genericData.Tide.HAT)
				config.set(self._tideSectionName, "LAT", genericData.Tide.LAT)
				config.set(self._tideSectionName, "MHW", genericData.Tide.MHW)
				config.set(self._tideSectionName, "MHWN", genericData.Tide.MHWN)
				config.set(self._tideSectionName, "MHWS", genericData.Tide.MHWS)
				config.set(self._tideSectionName, "MLW", genericData.Tide.MLW)
				config.set(self._tideSectionName, "MLWN", genericData.Tide.MLWN)
				config.set(self._tideSectionName, "MLWS", genericData.Tide.MLWS)
				config.set(self._tideSectionName, "MSL", genericData.Tide.MSL)
				config.set(self._tideSectionName, "SourcePath", genericData.Tide.SourcePath)
				config.set(self._tideSectionName, "MLW", genericData.Tide.MLW)
	
			with open(path,"wb") as genericDataFile:
				config.write(genericDataFile)
			
		except Exception, e:
			self._log.Error("Error during writing general data: " + str(e))
			return False
		
		return True
	
	def SaveCilvilStructures(self, structures, path):
		try:
			config = _ConfigParser.RawConfigParser()
			for structure in structures.viewvalues() :
				sectionName = structure.Name
				config.add_section(sectionName)
	
				config.set(sectionName, "StructureGeometry", structure.StructureGeometry)
				
			with open(path,"wb") as cilvilStructuresFile:
				config.write(cilvilStructuresFile)
		
		except Exception, e:
			self._log.Error("Error during writing cilvilstructures : " + str(e))
			return False
		
		return True
	
	def SaveWaveClimates(self, waveClimates, path, fileNamePrefix = ""):
		try:
			with open(path, "wb") as csvfile:
				writer = _csv.writer(csvfile, delimiter = self._csvFileDelimiter)
				writer.writerow(["Hs","Tp","Dir", "Occurences"])
				
				for structure in waveClimates :
					writer.writerow([structure.Hs, structure.Tp, structure.Dir, structure.Occurences])
					
		except Exception, e:
			self._log.Error("Error during writing WaveClimates : " + str(e))
			return False
		
		return True
	
	def LoadScenario(self, path):
		dir = _os.path.dirname(path)
		
		_newScenario = _entities.Scenario()
		
		try:
			config = _ConfigParser.RawConfigParser()
			config.optionxform = str # Make sure upper and lower case is taken into account
			config.read(path)
			
			genericDataFileName = config.get(self._genericDataSectionName, "Path")
			genericDataPath = _os.path.join(dir,genericDataFileName)

			_newScenario.GenericData = self.LoadGenericData(genericDataPath)
			
			toolIds = config.options(self._toolDataSectionName)
			for toolId in toolIds:
				persister = self._GetPersisterFor(toolId)
				#_swf.MessageBox.Show("Persister found for " + str(toolId))
				
				if (persister == None):
					self._log.Error("Could not load " + toolId + " data, no persister found")
					continue
					
				fileName = _os.path.join(dir,config.get(self._toolDataSectionName, toolId))
				
				#_swf.MessageBox.Show("Filepath: " + str(fileName))
				
				_newScenario.ToolData[toolId] = persister.Load(fileName)
				
				#_swf.MessageBox.Show("Tooldata loaded in scenario for " + str(toolId))
				
		except Exception, e:
			self._log.Error("Error during reading of scenario: " + str(e))
			return None
	
		return _newScenario
	
	def LoadGenericData(self, path):
		dir = _os.path.dirname(path)
			
		try:
			newGenericData = _entities.GenericData()
			
			config = _ConfigParser.RawConfigParser()
			config.read(path)
			
			newGenericData.SR_EPSGCode = config.getint(self._settingsSectionName, "SR_EPSGCode")
			newGenericData.D50 = self._ConvertToFloat(config.get(self._settingsSectionName, "D50"))
			newGenericData.D90 = self._ConvertToFloat(config.get(self._settingsSectionName, "D90"))
			
			# load Bathymetry
			self._log.Debug("Loading Bathymetry")
			if (config.has_section(self._bathymetrySectionName)):
				batType = config.get(self._bathymetrySectionName, "BathymetryType")
				isDepth = config.getboolean(self._bathymetrySectionName, "IsDepth")
							
				if (batType == _entities.BathymetryType.Slope):
					newGenericData.Bathymetry = _entities.SlopeBathymetry(batType)
					newGenericData.Bathymetry.SlopeValue = self._ConvertToFloat(config.get(self._bathymetrySectionName, "SlopeValue"))
					
				if (batType == _entities.BathymetryType.Ascii):
					sourcePath = config.get(self._bathymetrySectionName, "SourcePath")
					provider = _GdalFeatureProvider()
					provider.Open(sourcePath)
					newGenericData.Bathymetry = _entities.AsciiBathymetry(provider.Grid, sourcePath, isDepth)
					newGenericData.Bathymetry.OriginalSpatialReference = config.get(self._bathymetrySectionName, "OriginalSpatialReference")				
					newGenericData.Bathymetry.UnitDescription = config.get(self._bathymetrySectionName, "UnitDescription")
			
			# load CivilStructures
			self._log.Debug("Loading CivilStructures")
			if (config.has_section(self._civilStructuresSectionName)):
				
				cilvilStructuresFileName = config.get(self._civilStructuresSectionName, "Structures")
				cilvilStructuresPath = _os.path.join(dir, cilvilStructuresFileName)
				
				newGenericData.CivilStructures = self.LoadCilvilStructures(cilvilStructuresPath)
			
			# load Coastline
			self._log.Debug("Loading Coastline")
			if (config.has_section(self._coastlineSectionName)):
				name = config.get(self._coastlineSectionName, "Name")
				geometry = self._CreateGeometryFromText(config.get(self._coastlineSectionName, "CoastlineGeometry"))
				
				newGenericData.Coastline = _entities.Coastline(name, None)
				newGenericData.Coastline.CoastlineGeometry = geometry
			
			# load Waves
			self._log.Debug("Loading Waves")
			
			if (config.has_section(self._wavesSectionName)):
				
				waves = _entities.Waves()
				waves.SourcePath = config.get(self._wavesSectionName, "SourcePath")
				
				if config.has_option(self._wavesSectionName,"Location"):					 
					waves.Location = self._CreateGeometryFromText(config.get(self._wavesSectionName,"Location"))
				waves.Z = self._ConvertToFloat(config.get(self._wavesSectionName, "Z"))
				waves.Type = config.get(self._wavesSectionName, "Type")
				waves.ReturnPeriodExtremeValue = self._ConvertToFloat(config.get(self._wavesSectionName, "ReturnPeriodExtremeValue"))
				waves.ExtremeValueClimate = self._ConvertToFloat(config.get(self._wavesSectionName, "ExtremeValueClimate"))
				waves.IsOffshore = config.getboolean(self._wavesSectionName, "IsOffshore")
			   
				waveClimatesFileName = config.get(self._wavesSectionName, "WaveClimates")
				waveClimatesPath = _os.path.join(dir, waveClimatesFileName)
				
				waves.WaveClimates = self.LoadWaveClimates(waveClimatesPath)
				newGenericData.Waves = waves
			
			# load tide
			self._log.Debug("Loading tide")
			if (config.has_section(self._tideSectionName)):
				
				location = self._CreateGeometryFromText(config.get(self._tideSectionName, "Location"))
				cons = config.get(self._tideSectionName, "cons")
				
				tideDataPath = _os.path.join(dir, config.get(self._tideSectionName, "dataPath"))
				
				data = self._LoadTideData(tideDataPath)
				dict = _ast.literal_eval(config.get(self._tideSectionName, "stats"))
				stats = {k : _np.float64(v) for (k, v) in dict.iteritems()}
				
				tide = _entities.Tide(cons, data, stats)
				
				tide.Location = location
				tide.HAT = self._ConvertToFloat(config.get(self._tideSectionName, "HAT"))
				tide.LAT = self._ConvertToFloat(config.get(self._tideSectionName, "LAT"))
				tide.MHW = self._ConvertToFloat(config.get(self._tideSectionName, "MHW"))
				tide.MHWN = self._ConvertToFloat(config.get(self._tideSectionName, "MHWN"))
				tide.MHWS = self._ConvertToFloat(config.get(self._tideSectionName, "MHWS"))
				tide.MLW = self._ConvertToFloat(config.get(self._tideSectionName, "MLW"))
				tide.MLWN = self._ConvertToFloat(config.get(self._tideSectionName, "MLWN"))
				tide.MLWS = self._ConvertToFloat(config.get(self._tideSectionName, "MLWS"))
				tide.MSL = self._ConvertToFloat(config.get(self._tideSectionName, "MSL"))
				tide.SourcePath = config.get(self._tideSectionName, "SourcePath")
				tide.MLW = self._ConvertToFloat(config.get(self._tideSectionName, "MLW"))
				
				newGenericData.Tide = tide
			
		except Exception, e:
			self._log.Error("Error during loading of GenericData: " + str(e))
			return None
			
		return newGenericData
	
	def LoadCilvilStructures(self, path):
		cilvilStructures = {}
		
		try:
			config = _ConfigParser.RawConfigParser()
			config.read(path)
			structureNames = config.sections()
			
			for structureName in structureNames :
				structure = _entities.CivilStructure(structureName)
				structure.StructureGeometry = self._CreateGeometryFromText(config.get(structureName, "StructureGeometry"))
				
				cilvilStructures[structureName] = structure
		
		except Exception, e:
			self._log.Error("Error during loading of cilvilstructures : " + str(e))
			return None
		
		return cilvilStructures
	
	def LoadWaveClimates(self, path):
		try:
			with open(path) as csvfile:
				lines = _csv.reader(csvfile, delimiter = self._csvFileDelimiter)
				
				climates = []
				firstRow = True
				for line in lines:
					
					if (firstRow): # skip header
						firstRow = False
						continue
					
					waveHeight = self._ConvertToFloat(line[0])
					wavePeriod = self._ConvertToFloat(line[1])
					direction = self._ConvertToFloat(line[2])
					occurences = self._ConvertToFloat(line[3])
					
					climates.append(_entities.WaveClimate(waveHeight, wavePeriod, direction, occurences))
		except Exception, e:
			self._log.Error("Error during loading of WaveClimates : " + str(e))
			return None
			
		return climates
	
	def SaveWithDialog(self, saveFunction, object):
		dialog = _swf.SaveFileDialog()
		dialog.Filter = "data file|*.dat"
		dialog.DefaultExt = ".dat"
		dialog.Title = "Save to file"
		dialog.OverwritePrompt = True
		
		if (dialog.ShowDialog() != _swf.DialogResult.OK) :
			return
		
		saveFunction(object, dialog.FileName)
	
	def LoadWithDialog(self, loadFunction):
		dialog = _swf.OpenFileDialog()
		dialog.Filter = "data file|*.dat"
		dialog.Title = "Load from file"
		dialog.Multiselect = False
		dialog.CheckFileExists  = True
		
		if (dialog.ShowDialog() != _swf.DialogResult.OK) :
			return
		
		return loadFunction(dialog.FileName)
	
	def _CreateGeometryFromText(self, geometryAsText):
		reader = _wktReader()
		return reader.Read(geometryAsText)
	
	def _SaveTideData(self, tideData, path):
		try:
			with open(path, "wb") as csvfile:
				writer = _csv.writer(csvfile, delimiter = self._csvFileDelimiter)
				writer.writerow(["Datetime","value"])
				
				for dateTimeValue in tideData :
					dateLine = dateTimeValue[0].strftime(self._dateTimeFormat)
					writer.writerow([dateLine, dateTimeValue[1]])
					
		except Exception, e:
			self._log.Error("Error during writing tide data : " + str(e))
			return False
		
		return True
	
	def _LoadTideData(self, path):
		try:
			with open(path) as csvfile:
				lines = _csv.reader(csvfile, delimiter = self._csvFileDelimiter)
				
				tideData = []
				firstRow = True
				for line in lines:
					
					if (firstRow): # skip header
						firstRow = False
						continue
					
					# dateTime (0), value (1)
					dateLine = _datetime.datetime.strptime(line[0],self._dateTimeFormat)
					tideData.append([dateLine, float(line[1])])
		except Exception, e:
			self._log.Error("Error during loading of tide data : " + str(e))
			return None
			
		return tideData
	
	def _ConvertToFloat(self, text):
		if (text == "None" or text == ""):
			return None
		
		return float(text)
	
	def _GetPersisterFor(self, key):		
		for persister in self.ToolDataPersisters:			
			if (persister.ToolId.lower() == key.lower()):				
				return persister
		
	def _AddPrefixToFileName(self, fileName, prefix):
		 return _os.path.join(prefix + "_" + fileName)


# test

		
		


"""class MyObject:
	def __init__(self):
		self.testprop = "test"

class MyPersister:
	def __init__(self):
		self.ToolId = "MyObject"
		
	def Save(self, myObject, path):
		config = _ConfigParser.RawConfigParser()
		config.add_section("props")
		config.set("props", "testprop", myObject.testprop)
		
		with open(path, "wb") as myObjectFile:
				config.write(myObjectFile)
				
	def Load(self, path):
		newMyObject = MyObject()
		
		config = _ConfigParser.RawConfigParser()
		config.read(path)
		
		newMyObject.testprop = config.get("props", "testprop")
		
		return newMyObject

from Scripts.Tests.TestScripts.MakeTestFeatures import *
"""
#path = "D:\\temp\\newScenario.dat"

#scenarioPersister = ScenarioPersister()
#scenarioPersister.ToolDataPersisters.append(MyPersister())

#scenario = GetTestScenario()
#scenario.ToolData["MyObject"] = MyObject()

#scenarioPersister.SaveScenario(scenario, path)
#scenario = scenarioPersister.LoadScenario(path)
