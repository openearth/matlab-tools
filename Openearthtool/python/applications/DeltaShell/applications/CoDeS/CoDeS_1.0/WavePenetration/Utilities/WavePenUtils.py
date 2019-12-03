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
## Module for WavePenetration
## Developed for CoDeS
## Author: J.H.Boersma / Witteveen+Bos
## Date: April 6th, 2016



## =====Import necessary modules================================
from System import Array as _Array
import numpy as _np
import math


## =============================================================
def PointInPolygon(x,y,polygon):
	"""
	determine if a point is inside a given polygon or not.
	INPUT:  - X coordinate (scalar)
			- Y coordinate (scalar)
			- POLYGON (a list of (x,y) pairs)
	
	OUTPUT: - TRUE/FALSE
	"""
	
	#Initiate
	n = len(polygon)
	inside = False
	
	p1x,p1y = polygon[0]
	for i in range(n+1):
		p2x, p2y = polygon[i % n]
		#At least: the point should be between min and max
		if (y > min(p1y, p2y)):
			if (y <= max(p1y, p2y)):
				if (x <= max(p1x, p2x)):
					if (p1y != p2y):
						xinters = (y-p1y) * (p2x-p1x)/(p2y-p1y) + p1x
					if (p1x == p2x) or (x <= xinters):
						inside = not inside
		#Reset the checked point in polygon
		p1x, p1y = p2x, p2y
	
	return inside


## =============================================================
def CreateHarborPolygon(BreakwaterL, Coastline, BreakwaterR):
	"""
	Function to create a polygon (list of (x,y)-pairs), based on geometries which can be used for clipping
	REMARK: the starts of the breakwaters are at the coast, the endpoints are offshore.
	REMARK: coastline is defined as line with on the LEFT side WATER, on the RIGHT side LAND. 
	INPUT:  - BreakwaterL
			- Coastline (not implemented)
			- BreakwaterR 
			REMARK: all input variables are geometries with attributes X and Y
			
	OUTPUT: - POLYGON (a list of (x,y) pairs)
	"""
	
	#Initialize list(s)
	bwLCoords = []
	clCoords = []
	bwRCoords = []
	harborPolygon = []
		
	#Pass values of left breakwater
	for idx in range(BreakwaterL.NumPoints):
		bwLCoords.append([BreakwaterL.Coordinates[idx].X, \
				BreakwaterL.Coordinates[idx].Y])
		
	"""
	#For now: keep it without coastline	
	#Pass values of the coast line
	for idx in range(Coastline.NumPoints):
		clCoords.append([Coastline.Coordinates[idx].X, \
				Coastline.Coordinates[idx].Y])
	"""
	
	#Pass values of right breakwater
	for idx in range(BreakwaterR.NumPoints):
		bwRCoords.append([BreakwaterR.Coordinates[idx].X, \
				BreakwaterR.Coordinates[idx].Y])
	
	#Reverse the right break water
	bwRCoords.reverse();
	
	#Extend the lists (NOT append)
	harborPolygon.extend(bwLCoords)
	harborPolygon.extend(clCoords)
	harborPolygon.extend(bwRCoords)
	
	return harborPolygon


## =============================================================
def GetLocalHarborExtend(globalHarborPolygon, harborEntry, deltaRad):
	"""
	Function to get the extend for certain harbor, relative to harbor entry (so: local)
	INPUT:  - POLYGON (a list of (x,y) pairs)
			- HARBORENTRY (a (x,y)-pair)
			- DELTARAD (angle of harborentry in [rad])
			REMARK: Angle between northing towards and harbor perpendicular
			
	OUTPUT: - quadruple of xMin, xMax, yMin, yMax			
	"""
	
	#Extract the X and Y coordinates from the polygon, and convert towards local coordinates
	coordsX = _np.array([coord[0] for coord in globalHarborPolygon])
	coordsY = _np.array([coord[1] for coord in globalHarborPolygon])
	locX, locY = RotateToLocalHarbor(coordsX, coordsY, harborEntry, deltaRad)
	
	#Determine the minima and maxima of these coordinates
	xMin = _np.min(locX)
	xMax = _np.max(locX)
	
	yMin = _np.min(locY)
	yMax = _np.max(locY)
	
	return [xMin, xMax, yMin, yMax]


## =============================================================
def HarborMeshGrid(harborExtend, gridPoints):
	"""
	Function to get a approximate equally grid for the harborExtend.
	INPUT:  - HARBOREXTEND (a quadruple with xmin, xmax, ymin and ymax)
			REMARK: yMin is always (approx.) zero, since the harbor is defined as positive direction
			- GRIDSIZE (scalar)
	
	OUTPUT: - a meshgrid (x,y)
	"""
	
	#New: the grid input box is not any-more a string, converted to a numeric. For me: unknown type
	#Try to cast towards a numpy numeric 
	gridPoints = _np.int(gridPoints)
	
	#Number of points on each axis is dependend on extend. To be implemented
	xPoints = _np.ceil(_np.sqrt(gridPoints))
	yPoints = _np.ceil(_np.sqrt(gridPoints))
	
	xRange = _np.linspace(harborExtend[0], harborExtend[1], xPoints)
	yRange = _np.linspace(harborExtend[2], harborExtend[3], yPoints)
	xLocal, yLocal = _np.meshgrid(xRange, yRange)
	
	return xLocal, yLocal


## =============================================================
def InterpWavePen(x, xArray, yArray):
	"""
	function to interpolate x towards y on mapping X and Y, specified for WavePenetration, since assumptions are made.
	REMARK: xArray should be strict-increasing, all values for X should be in range of xArray
	REMARK: xArray should be an system array
	INPUT:	- x [numpy-array]   Size is free.
			- xArray [1xN vector] Strictly increasing values
			- yArray [1xN vector]
			
	OUTPUT: - y [numpy-array]   Size similar to x
	"""
	
	if (_np.size(x) == 1):
		#Find indices two values of xArray which interval contains x
		ixL, ixR = BinarySearchArray(xArray, float(x))
		
		#If EXACT the same, return the exact value of the array
		if (ixL == ixR):
			return yArray[ixL]
		else:
			#return interpolated value between two indices
			return yArray[ixL] + ((yArray[ixR] - yArray[ixL])/(xArray[ixR] - xArray[ixL])) * (x - xArray[ixL])
	else:
		#Initialize output analog to input
		y = _np.zeros(x.shape, dtype=yArray.dtype)
		
		#Generate vector-views of eventually matrixes
		xVec = _np.ravel(x)
		yVec = _np.ravel(y)
		#xVec is a vector, iterate over it, and call function recursively
		for ix in range(0,_np.size(x)):
			yVec[ix] = InterpWavePen(xVec[ix], xArray, yArray)
			
		#After forloop, return main-function
		return y
	
	"""
	Ideas to improve: 
	 - eliminate recursivity of function
	 - sort x before apply functions
	 - DONE: binary search
	"""


## =============================================================
def BinarySearchArray(array, number):
	"""
	function to search for the before and after index of the supplied number 
	in a (sorted) array using binary search
	REMARK: array should be sorted
	ex: 
		array = _Array[int]([3,6,8,12,35,78,43])
		index1, index2 = BinarySearchArray(array, 35)
		print "index1 = " + str(index1) + "  -  index2 = " + str(index2)
		
	INPUT:  - (sorted) array with numbers
			- number to search for
			
	OUTPUT: - index before and index after for the supplied number.
			  (if an exact match is made, both indices are the same)
	"""
	i = _Array.BinarySearch(array, number)
	
	if (i >= 0):
		#If the value is EXACT in the array, return it twice.
		#print "your number is in array : index " + str(i)
		return i,i
	else:
		indexOfNearest = ~i; # invert index to get the nearest index

		#For WavePenetration SPECIFIC: not needed, since it is by definition always inside range		
		#if (indexOfNearest == array.Length):
		#	raise Exception("Number is greater that last item")
		#elif (indexOfNearest == 0):
		#	raise Exception("Number is less than first item")			
		#else:
		return indexOfNearest -1, indexOfNearest


## =============================================================
def RotateToLocalHarbor(xGlob, yGlob, harborEntry, deltaRad):
	"""
	Function to rotate the local harbor coordinates (with harborEntry as origin
	and deltaRad the angle of harborEntry) towards global map
	INPUT:  - (XGLOB, YGLOB) meshgrid of global coordinates [NxM np.array]
			- HARBORENTRY (coordinates (x,y)-pair)
			- DELTARAD (angle of harborentry, scalar [rad])
			
	OUTPUT: - (XLOCAL, YLOCAL) meshgrid of local coordinates [NxM np.array]
	"""

	xShift = xGlob - harborEntry[0]
	yShift = yGlob - harborEntry[1]
	
	xLocal =  (xShift * _np.cos(math.pi + deltaRad)) + (yShift * _np.sin(math.pi + deltaRad))
	yLocal = -(xShift * _np.sin(math.pi + deltaRad)) + (yShift * _np.cos(math.pi + deltaRad))
	
	return xLocal, yLocal


## =============================================================
def RotateToGlobalMap(xLocal, yLocal, harborEntry, deltaRad):
	"""
	Function to rotate the local harbor coordinates (with harborEntry as origin
	and deltaRad the angle of harborEntry) towards global map
	INPUT:  - (XLOCAL, YLOCAL) meshgrid of local coordinates [NxM np.array]
			- HARBORENTRY (coordinates (x,y)-pair)
			- DELTARAD (angle of harborentry, scalar [rad])
			
	OUTPUT: - (XGLOB, YGLOB) meshgrid of global coordinates [NxM np.array]
	"""

	xGlob = harborEntry[0] + (xLocal * _np.cos(math.pi-deltaRad)) + (yLocal * _np.sin(math.pi-deltaRad))		#[XxY meshgrid]
	yGlob = harborEntry[1] - (xLocal * _np.sin(math.pi-deltaRad)) + (yLocal * _np.cos(math.pi-deltaRad))		#[XxY meshgrid]

	return xGlob, yGlob
