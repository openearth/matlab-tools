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
import os
import math
import struct
import System
import numpy as np

from System.IO import Path as _Path
from System import Array
from SharpMap import Map
from SharpMap.Extensions.Layers import GdalRasterLayer as _RasterLayer
 
from SharpMap.Layers import VectorLayer as _VectorLayer
from SharpMap.Data.Providers import ShapeFile as _ShapeFile

from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
from SharpMap.Extensions.Layers import BingLayer as _BingLayer
from SharpMap.CoordinateSystems.Transformations import GeometryTransform as _GeometryTransform
from Libraries.MapFunctions import *
from SharpMap import XyzFile as _XYZ

import Scripts.BathymetryData as bd
import Scripts.LinearWaveTheory as lwt

from Libraries import MapFunctions


#Puntenlaag = Scripts.BathymetryData.GridFunctions.GetMapLayer("Overview map","Depthpoints")
#Datapath = Puntenlaag.DataSource.Path

#Puntenbestand = _ShapeFile(Datapath)

OffshoreX = 0
OffshoreY = 0
NearshoreX = 0
NearshoreY = 0

"""for PuntFeature in Puntenbestand.Features:
	WaardeCollection = PuntFeature.Attributes
		
	
	for Waarde in WaardeCollection:
		print Waarde
		if Waarde.Value == "Offshore":
			
			OffshoreX = PuntFeature.Geometry.X
			OffshoreY = PuntFeature.Geometry.Y
		if Waarde.Value == "Nearshore":
			NearshoreX = PuntFeature.Geometry.X
			NearshoreY = PuntFeature.Geometry.Y
			
print OffshoreX
"""

#Two depths: offshore and nearshore (with lat/lon and bathy gives depth in [m + ref])
#offshoreDepth = GridFunctions.ReadGridValue("Overview map","Depth",OffshoreX, OffshoreY)    #Depth [m]
offshoreDepth = np.array(-500.0)
#nearshoreDepth = GridFunctions.ReadGridValue("Overview map","Depth",NearshoreX, NearshoreY) #Depth [m]
nearshoreDepth = np.array(-2.0)


#Shore normal (with north, in deg) defined by bathy
#(single entry, since one coast per call)
#shoreNormal = getShoreNormal(nearshLat, nearshLon); 		#Shore direction [deg]
shoreNormal = np.array(220)


#Convert to absolute depths [m] (only for internal use)
offshZ = abs(offshoreDepth) 
nearshZ = abs(nearshoreDepth)


#Wave-climate offshore (3 arrays) (+ occurence?)
Hs = np.array([3.25, 1.01, 13, 13.2, 2.2, 1, 5.5, 5, 4]);			#Wave-heigth [m]
Tp = np.array([8, 7, 15, 15, 5, 9, 12, 1, 32]);     				#Wave-period [s]
dirWave = np.array([220, 240, 190, 30, -70, 41., 40, 310, 130]);  	#Wave direction [deg]


#The angle between shore and wave.
# (in degrees, modulo 360, but between -180 and 180)
# ref: Waves in Oceanic and Coastal Waters p.205, fig 7.7
relDir = (shoreNormal - dirWave + 180) % 360 - 180

#If DirWave == ShoreNormal, then the wave will go 'gerade aus'.
#If DirWave <= ShoreNormal - 90 or 
#	DirWave >  ShoreNormal + 90
#then the wave will never reach the coast.

#These instances should be removed from the table.
ixD = (-90 < relDir) & (relDir < 90)
#Selecting the values which are in valid range.
Hs = Hs[ixD]
Tp = Tp[ixD]
relDir = relDir[ixD]

print('Due to shore normal and wave direction, %d wave-instances are removed' % (sum(~ixD)))

(Hsnew, Tpnew, relDirnew) = lwt.calcWaveConditions(Hs, Tp, relDir, offshZ, nearshZ)

print('done')