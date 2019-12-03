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
import clr
clr.AddReference("System.Windows.Forms")
import os
import math
import struct
import System
import numpy as np

from System.IO import Path as _Path
from System import Array
from SharpMap import Map
from SharpMap import XyzFile as _XYZ
from SharpMap.Extensions.Layers import GdalRasterLayer as _RasterLayer
 
from SharpMap.Layers import VectorLayer as _VectorLayer
from SharpMap.Data.Providers import ShapeFile as _ShapeFile
from SharpMap.Extensions.Data.Providers import GdalFeatureProvider

from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
from SharpMap.Extensions.Layers import BingLayer as _BingLayer
from SharpMap.CoordinateSystems.Transformations import GeometryTransform as _GeometryTransform
from Libraries.MapFunctions import *

from Scripts.BathymetryData import GridFunctions
from Scripts.BathymetryData import Bathy_UI_functions

from GisSharpBlog.NetTopologySuite.Geometries import LineString as _LineString

Kaart = None

for TempObject in CurrentProject.RootFolder.Items:
		if (str(TempObject) == "Bathymetry"):
			Kaart = TempObject.Value

print Kaart.Envelope.MaxX


BathyForm = Bathy_UI_functions.ShowBathymetryUI()
BathyForm.MapExtent = Kaart.Envelope


print BathyForm.MapExtent.MinX
BathyForm.Show()
radioButton = BathyForm.Controls[1]
radioButton.Checked = True
	

class abc():
	def __init__(self):
		self.A = None
		self.B = None
		self.C = None
testabc = abc()
testabc.A = "test"

print testabc.A
LineLayer = GridFunctions.GetMapLayer("Bathymetry","Testline")
ElevationLayer = GridFunctions.GetMapLayer("Bathymetry","GEBCO_elevation")
ElevationPath = ElevationLayer.DataSource.Path

print(ElevationPath)

provider = GdalFeatureProvider()
provider.Open(ElevationPath)	
grid = provider.Grid

# Get elevation cellsize
cellsize = grid.DeltaX

# Create dictionary with three vectors: pointID, X and Y

LineFeatures = LineLayer.GetFeatures(LineLayer.Envelope)

counter = 0

for LineFeature in LineFeatures:
	Line = LineFeature.Geometry
	
	
	if counter == 0:
		Profile = GridFunctions.GetProfileFromGrid(Line,grid,3857)
		
		# Get vertices
		print Line.NumPoints
		
		
		LineLength = Line.Length
		
		print(LineLength)
		NumSteps = int(2*LineLength/cellsize)
		
		print(NumSteps)

		if NumSteps < 2:
			NumSteps = 2		
		
		"""Stepsize = LineLength/NumSteps
		
		print(Stepsize)
		
		StartPoints = dict()
		EndPoints = dict()
		
		StartDistances = dict()
		EndDistances = dict()
		
		SegmentLengths = dict()
		
		CurrentDistance = 0
		
		for PointIndex in range(0,Line.NumPoints-1):
			print("Segment " + str(PointIndex)) 
			SegmentStartpoint = Line.GetPointN(PointIndex)
			SegmentEndpoint = Line.GetPointN(PointIndex + 1)
			
			StartPoints[PointIndex] = SegmentStartpoint
			EndPoints[PointIndex] = SegmentEndpoint
						
			StartDistances[PointIndex] = CurrentDistance
			SegmentLength = math.sqrt(math.pow(SegmentEndpoint.X - SegmentStartpoint.X,2) + math.pow(SegmentEndpoint.Y-SegmentStartpoint.Y,2))
			CurrentDistance += SegmentLength
			
			EndDistances[PointIndex] = CurrentDistance
			SegmentLengths[PointIndex] = SegmentLength
			
		ProfileXCoords = []
		ProfileYCoords = []
		ProfileDistances = []
		Elevations = []
		
		Distance = 0
		
		for TempID in StartDistances:
			print("key " + str(TempID))
			print("value " + str(StartDistances[TempID]))
		
		
		while Distance <= LineLength:
			#	 Find pointindex
			
			SegmentID = 0
			
			for TempID in StartDistances:
				StartDist = StartDistances[TempID]
				EndDist = EndDistances[TempID]
				
				if Distance>= StartDist and Distance <= EndDist:
					SegmentID = TempID
			
			DistanceInSegment = Distance - StartDistances[SegmentID]
			
			print("Distance: " + str(Distance) + ", distance in segment : " + str(DistanceInSegment))
			
			CurrentSegmentLength = SegmentLengths[SegmentID]
						
			#	 Find distance from segment start
			
			diffX = EndPoints[SegmentID].X - StartPoints[SegmentID].X
			diffY = EndPoints[SegmentID].Y - StartPoints[SegmentID].Y			 
			
			#	 Find point location based on relative distance in segment			
			
			X = StartPoints[SegmentID].X + diffX * (DistanceInSegment/CurrentSegmentLength)
			Y = StartPoints[SegmentID].Y + diffY * (DistanceInSegment/CurrentSegmentLength)						
			
			#	 Query grid value on point location
			
			GridValue = GridFunctions.ReadValueFromGrid(grid,X,Y)
			
			ProfileDistances.append(Distance)
			Elevations.append(GridValue)
			ProfileXCoords.append(X)
			ProfileYCoords.append(Y)
			
			Distance += Stepsize"""
		
		print "Profile queried"
		
		ProfileDistances = Profile["dist"]
		Elevations = Profile["Z"]
		ProfileXCoords = Profile["X"]
		ProfileYCoords = Profile["Y"]
		UTMXCoords = Profile["UTM_X"]
		UTMYCoords = Profile["UTM_Y"]
		UTMDistances = Profile["dist_UTM"]
		
		print "Array ready"
		
		profileResultfile = open(r"C:\Projecten\Coastal Design Toolbox\ProfileResult.txt",'w')
		profileResultfile.write("X,Y,distance,elevation,X_UTM,Y_UTM,distance_UTM" + "\n")
		
		
		for Step in range(0,NumSteps):
			profileResultfile.write(str(ProfileXCoords[Step]) + "," + str(ProfileYCoords[Step]) + "," + str(ProfileDistances[Step]) + "," + str(Elevations[Step]) + "," + str(UTMXCoords[Step]) + "," + str(UTMYCoords[Step]) + "," + str(UTMDistances[Step]) + "\n")
			
			# Check in which segment the point is
					
			
		profileResultfile.close()	
			
			
						
	
	counter += 1
	

print "Ready"
