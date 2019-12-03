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
import numpy as np
import math

from SharpMap import Map
from SharpMap.Extensions.Data.Providers import GdalFeatureProvider
from SharpMap.Extensions.Layers import GdalRasterLayer as _RasterLayer
from SharpMap.Layers import VectorLayer as _VectorLayer
from SharpMap import XyzFile as _XYZ

from GeoAPI.Geometries import ICoordinate as _ICoordinate
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate

import Libraries.FlowFlexibleMeshFunctions as FMFunctions
from Libraries import MapFunctions as _MapFunctions 

from SharpMap.Extensions.Data.Providers import GdalFeatureProvider
#from Scripts.CoastlineDevelopment import general_functions
from Scripts.BathymetryData import Interpolatie


def ReadValueFromGridLayer(MapName,LayerName,X,Y):
	"""
	Read value from rasterlayer in map
	MapName: name of the map in Deltashell
	LayerName: name of the layer in the specified map
	X: x-coordinate (projected coordinate system)
	Y: y-coordinate (projected coordinate system)	
	"""
	
	Kaartlaag = GetMapLayer(MapName,LayerName)	
	DataPath = Kaartlaag.DataSource.Path	
	
	provider = GdalFeatureProvider()
	provider.Open(DataPath)	
	grid = provider.Grid
	
	# Create coordinate object 
	pCoord = _Coordinate(X,Y,0)
	
	# Evaluate grid value
	gridvalue = grid.Evaluate(pCoord)
	
	return gridvalue
	

def ReadValueFromGrid(grid,X,Y):
	"""
	Evaluate value from in-memory grid
	To be used when querying grid values for a large number of points (rather than ReadValueFromGridLayer)
	grid: grid to be queried (type GdalFeatureProvider.Grid)
	X: x-coordinate (projected coordinate system)
	Y: y-coordinate (projected coordinate system)	
	"""
	# Create coordinate object 
	pCoord = _Coordinate(X,Y,0)
	
	# Evaluate grid value
	gridvalue = grid.Evaluate(pCoord)
	
	return gridvalue



def GetMapLayer(MapName,LayerName):
	"""
	Read layer with specific name from map
	
	MapName: name of the map in Deltashell
	LayerName: name of the layer in the specified map
	
	"""
	
	# Find map in project collection 
	
	Kaart = None

	for TempObject in CurrentProject.RootFolder.Items:
		if (str(TempObject) == MapName):
			Kaart = TempObject.Value
	
	# Find layer in layer collection
	TempLayer = None
	
	for Laag in Kaart.Layers:
		if Laag.Name == LayerName:
			TempLayer = Laag
	
	return TempLayer

def GetProfile(MapName,LayerName,StartX,StartY,EndX,EndY,NumIntervals):
	"""
	Input arguments
	
	MapName: name of the map in Deltashell
	LayerName: name of the layer in the specified map
	Returns profile as four vectors: one with distances, one with elevations based on layer representing bathymetry
	StartX: X-coordinate of profile start
	StartY: Y-coordinate of profile start
	EndX: X-coordinate of profile end
	EndY: Y-coordinate of profile end
	NumIntervals: number of steps in the profile
	
	Output
	
	XCoordinates: vector of X-coordinates of profile points
	YCoordinates: vector of Y-coordinates of profile points
	Distances: vector of distances of profile points from profile start
	Elevations: vector of bathymetry values at the profile points
	
	Usage: XCoordinates,YCoordinates,Distances,Elevations = GetProfile(MapName,LayerName,StartX,StartY,EndX,EndY,NumIntervals)
	"""
	
	Distances = []
	Elevations = []
	XCoordinates = []
	YCoordinates = []
	
	xStep = (EndX-StartX)/float(NumIntervals)
	yStep = (EndY-StartY)/float(NumIntervals)
	
	DistanceToEnd = math.sqrt(math.pow(EndX-StartX,2) + math.pow(EndY-StartY,2))
	DistanceStep = DistanceToEnd/float(NumIntervals)
	
	for Pointindex in range(0,NumIntervals + 1):		
		# Calculate distance
		
		DistanceAtPoint = float(Pointindex)*DistanceStep
		pointX = StartX + float(Pointindex)*xStep
		pointY = StartY + float(Pointindex)*yStep
		
		# Get gridvalue
		Elevation = ReadGridValue(MapName,LayerName,pointX,pointY)
		
		Distances.append(DistanceAtPoint)
		Elevations.append(Elevation)
		XCoordinates.append(pointX)
		YCoordinates.append(pointY)
	
	return XCoordinates,YCoordinates,Distances,Elevations


def GetProfileFromGrid(LineGeometry, grid,CS_code_ori,NumSteps):
	"""
	Get profile along line geometry based on grid values
	
	Input arguments
	
	LineGeometry: geometry of profile line (NetTopologySuite.Extensions.Features.Feature.Geometry)
	grid: grid to be queried (SharpMap.Extensions.Data.Providers.Grid)
	CS_code_ori: EPSG code of coordinate system of profile line

	Output
	
	ProfileDict: Dictionay containing vectors dist, dist_UTM,X,UTM_X,UTM_Y,Y,Z
	dist_UTM, UTM_X, UTM_Y are the 'real-world' distances and coordinates to be used from the output
	
	"""
	# Calculate number of steps in the profile
	
	cellsize = grid.DeltaX
	
	LineLength = LineGeometry.Length
	#NumSteps = int(2*LineLength/cellsize)
	
	#print(NumSteps)

	if NumSteps < 2:
		NumSteps = 2		
	
	Stepsize = LineLength/NumSteps
	
	#print(Stepsize)
	
	# Compose dictionaries with start- and endpoints, start- and enddistances of segments and segment lengths (based on ID of segment in line)
	StartPoints = dict()
	EndPoints = dict()	
	StartDistances = dict()
	EndDistances = dict()	
	SegmentLengths = dict()
	
	CurrentDistance = 0
	
	for PointIndex in range(0,LineGeometry.NumPoints-1):
		print("Segment " + str(PointIndex)) 
		SegmentStartpoint = LineGeometry.GetPointN(PointIndex)
		SegmentEndpoint = LineGeometry.GetPointN(PointIndex + 1)
		
		StartPoints[PointIndex] = SegmentStartpoint
		EndPoints[PointIndex] = SegmentEndpoint
					
		StartDistances[PointIndex] = CurrentDistance
		SegmentLength = math.sqrt(math.pow(SegmentEndpoint.X - SegmentStartpoint.X,2) + math.pow(SegmentEndpoint.Y-SegmentStartpoint.Y,2))
		CurrentDistance += SegmentLength
		
		EndDistances[PointIndex] = CurrentDistance
		SegmentLengths[PointIndex] = SegmentLength
	
	#	 Initialize vectors for storage of the profile
	ProfileXCoords = []
	ProfileYCoords = []
	UTM_XCoords = []
	UTM_YCoords = []
	ProfileDistances = []
	ProfileDistances_UTM = []
	Elevations = []
	
	Distance = 0
	Previous_UTM_X = 0
	Previous_UTM_Y = 0
	UTM_distance = 0
	
	#	 Step along the line
	
	while Distance <= LineLength:
		#	 Find index of segment
		
		SegmentID = 0
		
		for TempID in StartDistances:
			StartDist = StartDistances[TempID]
			EndDist = EndDistances[TempID]
			
			if Distance>= StartDist and Distance <= EndDist:
				SegmentID = TempID
		
		DistanceInSegment = Distance - StartDistances[SegmentID]
		
		CurrentSegmentLength = SegmentLengths[SegmentID]
					
		#	 Find distance from segment start
		
		diffX = EndPoints[SegmentID].X - StartPoints[SegmentID].X
		diffY = EndPoints[SegmentID].Y - StartPoints[SegmentID].Y			 
		
		#	 Find point location based on relative distance in segment			
		
		X = StartPoints[SegmentID].X + diffX * (DistanceInSegment/CurrentSegmentLength)
		Y = StartPoints[SegmentID].Y + diffY * (DistanceInSegment/CurrentSegmentLength)						
		
		#	 Query grid value on point location
		
		GridValue = ReadValueFromGrid(grid,X,Y)
		
		ProfileDistances.append(Distance)
		Elevations.append(GridValue)
		ProfileXCoords.append(X)
		ProfileYCoords.append(Y)
		
		# Transform Coords to UTM 
		
		inputCoords = np.array([[X,Y]])
		#np.array([[None,None],[None,None]])
		#print inputCoords
		UTMZone,UTM_coords = points_to_utm(inputCoords,CS_code_ori)
		UTM_X = UTM_coords[0][0]
		UTM_Y = UTM_coords[0][1]
		
		UTM_XCoords.append(UTM_X)
		UTM_YCoords.append(UTM_Y)
		
		# Calculate UTM distance
		
		if Distance == 0:
			UTM_distance = 0
		else:
			UTM_distance_to_next = math.pow(math.pow((UTM_X - Previous_UTM_X),2) + math.pow((UTM_Y - Previous_UTM_Y),2),0.5)
			UTM_distance += UTM_distance_to_next
		
		ProfileDistances_UTM.append(UTM_distance)
		
		Previous_UTM_X = UTM_X
		Previous_UTM_Y = UTM_Y
		
		
		Distance += Stepsize
	
	
	ProfileDict = dict()
	ProfileDict["dist"] = ProfileDistances
	ProfileDict["X"] = ProfileXCoords
	ProfileDict["Y"] = ProfileYCoords
	ProfileDict["Z"] = Elevations
	ProfileDict["UTM_X"] = UTM_XCoords
	ProfileDict["UTM_Y"] = UTM_YCoords
	ProfileDict["dist_UTM"] = ProfileDistances_UTM
	
	return ProfileDict	


def Convert_XYZ_to_grid(XYZPath,GridPath):	

	Interpolatielog = open(r"C:\Temp\Interpolatielog.txt",'a')
	
	# Read xyz-file to arrays

	XYZobject = _XYZ()
	Puntenlijst = [element for element in XYZobject.Read(XYZPath)]
	pointindex = 0
	
	# Initialize arrays for X and Y values
	Xvalues = []
	Yvalues = []
	Zvalues = []
	
	# Make filtering of points to test the interpolation
	for Punt in Puntenlijst:	
		Xvalues.append(Punt.X)
		Yvalues.append(Punt.Y)
		Zvalues.append(Punt.Value)
	
	minX = math.floor(min(Xvalues))
	maxX = math.ceil(max(Xvalues))
	
	minY = math.floor(min(Yvalues))
	maxY = math.ceil(max(Yvalues))
	
	diffX = int(maxX - minX)
	diffY = int(maxY - minY)
	
	
	
	NumStepsX = diffX
	NumStepsY = diffY	
	
	MaxDiff = diffX
	
	if diffY > diffX:
		MaxDiff = diffY
	
	NumSteps = MaxDiff
	Cellsize = 1
		
		
	Interpolatielog.write(str(NumStepsX)+ "\n")
	Interpolatielog.write(str(NumStepsY)+ "\n")
	
	
	Interpolatielog.write("cellsize interpolation: " + str(Cellsize)+ "\n")
	Interpolatielog.write("Xdiff: " + str(diffX)+ "\n")
	Interpolatielog.write("Ydiff: " + str(diffY)+ "\n")
	Interpolatielog.write("Maxdiff: " + str(MaxDiff)+ "\n")	
	
	if MaxDiff > 25:
		
		NumSteps = 25
		Cellsize = MaxDiff/(25)
		Interpolatielog.write("More than 25 m" + "\n")
		Interpolatielog.write("cellsize interpolation: " + str(Cellsize) + "\n")
		
		NumStepsX = math.floor(diffX/Cellsize)
		NumStepsY = math.floor(diffY/Cellsize)
	
	Interpolatielog.write(str(NumStepsX)+ "\n")
	Interpolatielog.write(str(NumStepsY)+ "\n")
	
	
	Xpositions = np.linspace(minX,maxX,NumStepsX+1)
	Ypositions = np.linspace(minY,maxY,NumStepsY+1)
	
	XI, YI = np.meshgrid(Xpositions,Ypositions)	
	
	Interpolatielog.close()
	
	# Interpolate point values to grid
	ZI = Interpolatie.invDist(Xvalues,Yvalues,Zvalues,int(minX),int(minY),diffX+1,diffY+1,1,0)
	
	# Flip matrix on horizontal axis
	
	ZI_flip = np.flipud(ZI)
		
	# Write grid to file
	
	# Write header
	
	AscGridFile = open(GridPath,"w")
	
	AscGridFile.write("ncols		 " + str(diffX+1) + "\n")
	AscGridFile.write("nrows		 " + str(diffY+1) + "\n")
	AscGridFile.write("xllcorner	 " + str(minX) + "\n")
	AscGridFile.write("yllcorner	 " + str(minY) + "\n")
	AscGridFile.write("cellsize	  " + "1" + "\n")
	AscGridFile.write("NODATA_value  " + "-9999" + "\n");
	
	for rij in range(0,ZI_flip.Dims[0]):
		regel = ""
		for kolom in range (0,ZI_flip.Dims[1]):
			Z = ZI_flip[rij][kolom]
			regel += str(Z) + " "
		AscGridFile.write(regel + "\n")
			
	
	
	
	
	AscGridFile.close()
	


def GetAscGridFromGebco(CurrentExtent,AscResultPath):
	
	MinX = CurrentExtent.MinX
	MaxX = CurrentExtent.MaxX
	
	MinY = CurrentExtent.MinY
	MaxY = CurrentExtent.MaxY	
	
	# Read X and Y dimensions
	
	diffX = MaxX - MinX
	diffY = MaxY - MinY
	
	GebcoExtract = FMFunctions.GetGebcoBathymetryData(MinX,MinY,MaxX,MaxY,3857)
		
	# Calculate number of cells in X and Y direction, based on cellsize 1000
	
	cellsize = 1000

	NumXSteps = int(math.floor(diffX/cellsize))
	NumYSteps = int(math.floor(diffY/cellsize))
	
	startX = math.floor(MinX)
	startY = math.floor(MinY)
		
	XValues = np.linspace(startX,startX + cellsize*NumXSteps,NumXSteps+1)
	YValues = np.linspace(startY,startY + cellsize*NumYSteps,NumYSteps+1)	
	
	# Create matrix based on number of step in X and Y-direction

	ZGrid = np.zeros((NumYSteps + 1,NumXSteps + 1))
		
	for column in range(0,len(XValues)):
		X = XValues[column]
		for row in range(0,len(YValues)):
			Y = YValues[row]
			
			Locatie = _Coordinate()
			Locatie.X = X
			Locatie.Y = Y	
			
			# Get elevation from GEBCO
			ElevationValue = FMFunctions.GetGebcoBathymetryValueFor(Locatie,3857,GebcoExtract)
			ZGrid[row,column] = ElevationValue	
	
		
	AscGridFile = open(AscResultPath,'w')
	
	ZI_flip = np.flipud(ZGrid)
			
	# Write grid to file
	
	# Write header rows
	
	AscGridFile.write("ncols		 " + str(NumXSteps+1) + "\n")
	AscGridFile.write("nrows		 " + str(NumYSteps+1) + "\n")
	AscGridFile.write("xllcorner	 " + str(MinX-0.5*cellsize) + "\n")
	AscGridFile.write("yllcorner	 " + str(MinY-0.5*cellsize) + "\n")
	AscGridFile.write("cellsize	  " + str(cellsize) + "\n")
	AscGridFile.write("NODATA_value  " + "-9999" + "\n");
	
	for rij in range(0,ZI_flip.Dims[0]):
		regel = ""
		for kolom in range (0,ZI_flip.Dims[1]):
			Z = ZI_flip[rij][kolom]
			regel += str(Z) + " "
		AscGridFile.write(regel + "\n")
	
	
	AscGridFile.close()
	"""
	resultaatbestand = open(r"C:\Projecten\Coastal Design Toolbox\GebcoExtract_XYZlijst.txt",'w')
	
	
	for XValue in XValues:
		for YValue in YValues:
			Locatie = _Coordinate()
			Locatie.X = XValue
			Locatie.Y = YValue	
			waarde = FMFunctions.GetGebcoBathymetryValueFor(Locatie,3857,GebcoExtract)			
			resultaatbestand.write(str(XValue) + "," + str(YValue) + "," + str(waarde) + "\n")
	
	resultaatbestand.close()
	"""
	print("Conversion of Gebco ready")
	

def points_to_utm(x_y,CS_code_ori):
		
	CS_code_WGS84 = 4326
	
	x_y_new = np.zeros((np.size(x_y)/2,2))
	for i in range(0,(np.size(x_y)/2)):
		conversion_feature = Feature(Geometry = _MapFunctions.CreatePointGeometry(x_y[i][0],x_y[i][1]))
		conversion_feature = _MapFunctions.TransformGeometry(conversion_feature.Geometry, CS_code_ori,CS_code_WGS84)
		if i == 0:
			CS_code_UTM = int(32600 + int(np.ceil((conversion_feature.X + 180)/6).Value) + (100*np.abs(((conversion_feature.Y/np.abs(conversion_feature.Y).Value)*0.5)-0.5).Value))
		conversion_feature = _MapFunctions.TransformGeometry(conversion_feature, CS_code_WGS84, CS_code_UTM)
		x_y_new[i] = np.array([conversion_feature.X,conversion_feature.Y])
			
	return CS_code_UTM, x_y_new


