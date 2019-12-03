#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#       Dirk Voesenek
#
#       dirk.voesenek@rhdhv.com
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
import os
from Libraries import MapFunctions as _MapFunctions
from Scripts.GeneralData.Entities import Coastline as _Coastline
from Scripts.GeneralData.Entities import CivilStructure as _CivilStructure
from Scripts.GeneralData.Entities import Scenario as _Scenario
from Scripts.GeneralData.Entities import Waves as _Waves
from Scripts.GeneralData.Entities import WaveClimate as _WaveClimate


def GetTestDatadir():
	for i in Application.Plugins:
		if i.Name == "Toolbox":
			toolbox_dir = i.Toolbox.ScriptingRootDirectory
	TestdataDir = toolbox_dir + os.sep + r"Scripts\Tests\Testdata"
	return TestdataDir

def GetCoastline():	
	
	TestdataDir = GetTestDatadir()
	coastlineLayer = _MapFunctions.CreateShapeFileLayer(TestdataDir + os.sep + "CoastlineNorthSea_WebMercator.shp")

	newCoastline = _Coastline("NorthSea",coastlineLayer)
	return newCoastline

def GetBreakwaters():
	TestdataDir = GetTestDatadir()
	BWLayer1 = _MapFunctions.CreateShapeFileLayer(TestdataDir + os.sep + "BreakwaterNorthSea_WebMercator_1.shp")
	BWLayer2 = _MapFunctions.CreateShapeFileLayer(TestdataDir + os.sep + "BreakwaterNorthSea_WebMercator_2.shp")
	
	structure1 = _CivilStructure("BW1",0,0,BWLayer1)
	structure2 = _CivilStructure("BW2",0,0,BWLayer2)
	
	return structure1,structure2

def GetWavesNearshore():
	waveclimate1 = _WaveClimate(1,6,350,0.8)
	waveclimate2 = _WaveClimate(1.5,6,350,0.2)

	waves = _Waves()
	waves.IsOffshore = False
	waves.WaveClimates = [waveclimate1,waveclimate2]
	return waves

	

def GetTestScenario():
	newScenario = _Scenario()
	#newScenario.GenericData.Coastline = GetCoastline()
	#structure1,structure2 = GetBreakwaters()
	#newScenario.GenericData.CivilStructures["BW1"] = structure1
	#newScenario.GenericData.CivilStructures["BW2"] = structure2
	newScenario.GenericData.Waves = GetWavesNearshore()
	
	#	Add layer to general map
	
	#newScenario.GeneralMap.Layers.Add(newScenario.GenericData.Coastline.CoastlineLayer)
	#newScenario.GeneralMap.Layers.Add(structure1.StructureLayer)
	#newScenario.GeneralMap.Layers.Add(structure2.StructureLayer)
	
	
	return newScenario
	
