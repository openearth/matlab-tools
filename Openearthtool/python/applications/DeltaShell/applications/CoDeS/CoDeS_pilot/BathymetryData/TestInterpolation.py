#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 RoyalHaskoningDHV
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

from BathymetryData.Interpolatie import *

XYZbestand = r"C:\Projecten\Coastal Design Toolbox\Data\Testdata\Bathy\AHN_points.xyz"

XYZobject = _XYZ()
Puntenlijst = [element for element in XYZobject.Read(XYZbestand)]
pointindex = 0

# Initialize arrays for X and Y values
Xvalues = []
Yvalues = []
Zvalues = []

Tempindex = 0

# Make filtering of points to test the interpolation
for Punt in Puntenlijst:	
	Xvalues.append(Punt.X)
	Yvalues.append(Punt.Y)
	Zvalues.append(Punt.Value)
	Tempindex = 0
	
	
print len(Zvalues)

# Write to temp textfile
Checkbestand = open("C:\Projecten\Coastal Design Toolbox\Data\Testdata\check.txt","w")

for index in range(0,len(Xvalues)):
	Checkbestand.write(str(Xvalues[index]) + "\t" + str(Yvalues[index]) + "\t" + str(Zvalues[index]) + "\n")

Checkbestand.close()

minX = math.floor(min(Xvalues))
maxX = math.ceil(max(Xvalues))

minY = math.floor(min(Yvalues))
maxY = math.ceil(max(Yvalues))

diffX = int(maxX - minX)
diffY = int(maxY - minY)

Xpositions = np.linspace(minX,maxX,diffX+1)
Ypositions = np.linspace(minY,maxY,diffY+1)

XI, YI = np.meshgrid(Xpositions,Ypositions)

print("Mesh ready")

# Interpolate point values
ZI = invDist(Xvalues,Yvalues,Zvalues,int(minX),int(minY),diffX+1,diffY+1,1,0)

print("Interpolation ready")

Bestandspad = r"C:\Projecten\Coastal Design Toolbox\Data\Testdata\Bathy\interpolatie.xyz"
GeinterpoleerdBestand = open(Bestandspad,"w")

for rij in range(0,ZI.Dims[0]):
	for kolom in range (0,ZI.Dims[1]):
		X = XI[rij][kolom]
		Y = YI[rij][kolom]
		Z = ZI[rij][kolom]
		
		GeinterpoleerdBestand.write(str(X) + "\t" + str(Y) + "\t" + str(Z) + "\n")


GeinterpoleerdBestand.close()


print "Ready"

#for Punt in Puntenlijst:
	#print (Punt.X)





"""NamenBestand = open(r"C:\Projecten\Coastal Design Toolbox\Data\Testdata\gemeentelijst.txt","w")

GemeenteFeatures = GetShapeFileFeatures(Shapebestand)
GemeenteFeature = GemeenteFeatures[0]

Header = ""

VeldNamen = GemeenteFeature.Attributes.Keys

for Veldnaam in VeldNamen:
	Header += str(Veldnaam) + ","

NamenBestand.write(Header + "\n")

for GemeenteFeature in GemeenteFeatures:
	WaardeCollection = GemeenteFeature.Attributes
	
	Tekst = ""
	
	for Waarde in WaardeCollection:
		Combinatie = str(Waarde)
		
		TempTekst

		TempTekst = Combinatie.split(",")[1].strip("]")
		Tekst += TempTekst +","
				
		print(TempTekst)
		#Tekst += Waarde.Value + ","				
	
	NamenBestand.write(Tekst + "\n")
   
NamenBestand.close()



"""




