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
#In the constructor, an instance of generic data is constructed.
#Therefore, the GenericData-file (with the class) should be imported.
#However, this should be invisible when a class is generated, therefore 'private'
from Scripts.GeneralData.Entities import GenericData as _GenericData

from Libraries.MapFunctions import *
from SharpMap.Extensions.Layers import OpenStreetMapLayer as _OSML
from SharpMap.Layers import GroupLayer
import DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapView as _MapView

class Scenario:
	"""Class which contains all data, methods, etc, linked to a single run of CoDeS"""
	
	def __init__(self):
		self.GenericData = _GenericData()
		self.ToolData = {}
		self.CreateDefaultMap()
		
	def CreateDefaultMap(self):
		# Set General Map
		self.GeneralMap = Map()
		
		# Set different GroupLayers
		self.GroupLayerCoastline = GroupLayer()
		self.GroupLayerCoastline.Name = "Coastline"
		self.GeneralMap.Layers.Add(self.GroupLayerCoastline)

		self.GroupLayerStructures = GroupLayer()
		self.GroupLayerStructures.Name = "Structures"
		self.GeneralMap.Layers.Add(self.GroupLayerStructures)
		self.GroupLayerBathymetry = GroupLayer()
		self.GroupLayerBathymetry.Name = "Bathymetry"
		self.GeneralMap.Layers.Add(self.GroupLayerBathymetry)
		
		self.GroupLayerWaveWind = GroupLayer()
		self.GroupLayerWaveWind.Name = "Wave Wind data"
		self.GeneralMap.Layers.Add(self.GroupLayerWaveWind)
		
		self.GroupLayerTide = GroupLayer()
		self.GroupLayerTide.Name = "Tide"
		self.GeneralMap.Layers.Add(self.GroupLayerTide)
		
		self.GroupLayerCoastlineDevelopment = GroupLayer()
		self.GroupLayerCoastlineDevelopment.Name = "Coastline development"
		self.GeneralMap.Layers.Add(self.GroupLayerCoastlineDevelopment)
		
		self.GroupLayerWavePenetration = GroupLayer()
		self.GroupLayerWavePenetration.Name = "Wave Penetration"
		self.GeneralMap.Layers.Add(self.GroupLayerWavePenetration)
		
		self.OSMLlayer = _OSML()
		self.OSMLlayer.Name = "General Open Street Map"
		self.OSMLlayer.ShowInLegend = False
		
		self.GeneralMap.Layers.Add(self.OSMLlayer)
		#self.GeneralMap.SendToBack(self.OSMLlayer)

