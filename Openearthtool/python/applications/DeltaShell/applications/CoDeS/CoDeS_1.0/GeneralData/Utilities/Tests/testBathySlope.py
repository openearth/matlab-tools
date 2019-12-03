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
import numpy as np
import math as math

import clr
clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf


def GetDistanceAndSideToCoastLine(xCoastLine,yCoastLine,x0,y0):
	""" Function that determines minimum distance(s) to coastline from a point/array
	INPUT:
	xCoastline = x values of Coastline in metres (numpy array)
	yCoastline = y values of Coastline in metres (numpy array) (same size as xCoastline)
	x0 = x value(s) of point/line/grid of interest in metres (numpy array)
	y0 = y value(s) of point/line/grid of interest in metres (numpy array) (same size as x0)
	Slope = Slope of bathymetry (constant in metres/metres)
	
	OUTPUT:
	minDistance = minimum distance from coastline in metres (same size as x0,y0)
	SideofCoastline = determines side of coastline (same size as x0,y0):
		SideOfCoastline = 1 --> Left/up side of coastline, defined as water
		SideOfCoastline = -1 --> Right/down side of coastlien, defined as land
		SideofCoastline = 0 --> On top of coastline, z=0
	
	"""
	#_swf.MessageBox.Show(str(len(xCoastLine)))
	#_swf.MessageBox.Show("Stepped into distance function")
	xval = xCoastLine[0]
	yval = yCoastLine[0]
	#_swf.MessageBox.Show("X: " + str(x0[0]))
	#_swf.MessageBox.Show("Y: " + str(y0[0]))
	
	
	if ((np.size(x0)!= np.size(y0)) or (np.size(xCoastLine) != np.size(yCoastLine))):
		raise Exception('ERROR: size of x0,y0 or xCoastline,yCoastLine are not the same')
		
	
	numberofPoints = 1000
	
	minDistance = np.zeros_like(x0)
	SideOfCoastline = np.zeros_like(x0)
	
	# Make ravel views to 'flatten' matrices behind the screen
	minDistanceR = minDistance.ravel()
	SideOfCoastlineR = SideOfCoastline.ravel()
	x0R = x0.ravel()
	y0R = y0.ravel()
	
	for ii in range(np.size(x0)):
		
		# Get distance for every coastline vertex/node
		Distance0 = np.sqrt((x0R[ii]-xCoastLine)**2 + (y0R[ii]-yCoastLine)**2)
		
		
		
		# Get index of nearest coastline vertex
		#minDistID = np.argmin(Distance0).Value
		DistSortID = np.argsort(Distance0)
		minDistID1 = DistSortID[0]
		minDistID2 = DistSortID[1]
		
		# Refine segment(s) around this node 
		if ((minDistID1>0 and minDistID1<len(Distance0)) and (minDistID2>0 and minDistID2<len(Distance0))):
			xsegment = np.array([np.linspace(xCoastLine[minDistID1-1],xCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID1],xCoastLine[minDistID1+1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID2-1],xCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID2],xCoastLine[minDistID2+1],num=numberofPoints)])
			
			ysegment = np.array([np.linspace(yCoastLine[minDistID1-1],yCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID1],yCoastLine[minDistID1+1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID2-1],yCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID2],yCoastLine[minDistID2+1],num=numberofPoints)])
		
		elif (minDistID1==0 and minDistID2<len(Distance0)):
			
			xsegment = np.array([np.linspace(xCoastLine[minDistID1],xCoastLine[minDistID1+1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID2-1],xCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID2],xCoastLine[minDistID2+1],num=numberofPoints)])
			
			ysegment = np.array([np.linspace(yCoastLine[minDistID1],yCoastLine[minDistID1+1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID2-1],yCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID2],yCoastLine[minDistID2+1],num=numberofPoints)])
		
		elif (minDistID2==0 and minDistID1<len(Distance0)):
			xsegment = np.array([np.linspace(xCoastLine[minDistID2],xCoastLine[minDistID2+1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID1-1],xCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID1],xCoastLine[minDistID1+1],num=numberofPoints)])
			
			ysegment = np.array([np.linspace(yCoastLine[minDistID2],yCoastLine[minDistID2+1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID1-1],yCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID1],yCoastLine[minDistID1+1],num=numberofPoints)])
			
		elif (minDistID1==len(Distance0) and minDistID2>0):
			xsegment = np.array([np.linspace(xCoastLine[minDistID1-1],xCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID2-1],xCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID2],xCoastLine[minDistID2+1],num=numberofPoints)])
			
			ysegment = np.array([np.linspace(yCoastLine[minDistID1-1],yCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID2-1],yCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID2],yCoastLine[minDistID2+1],num=numberofPoints)])
		
		elif (minDistID2==len(Distance0) and minDistID1>0):
			xsegment = np.array([np.linspace(xCoastLine[minDistID2-1],xCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID1-1],xCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID1],xCoastLine[minDistID1+1],num=numberofPoints)])
			
			ysegment = np.array([np.linspace(yCoastLine[minDistID2-1],yCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID1-1],yCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID1],yCoastLine[minDistID1+1],num=numberofPoints)])
		
		elif (minDistID1==len(Distance0) and minDistID2==0):
			xsegment = np.array([np.linspace(xCoastLine[minDistID1-1],xCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID2],xCoastLine[minDistID2+1],num=numberofPoints)])
								
			ysegment = np.array([np.linspace(yCoastLine[minDistID1-1],yCoastLine[minDistID1],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID2],yCoastLine[minDistID2+1],num=numberofPoints)])
		
		elif (minDistID2==len(Distance0) and minDistID1==0):
			xsegment = np.array([np.linspace(xCoastLine[minDistID2-1],xCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(xCoastLine[minDistID1],xCoastLine[minDistID1+1],num=numberofPoints)])
								
			ysegment = np.array([np.linspace(yCoastLine[minDistID2-1],yCoastLine[minDistID2],num=numberofPoints),\
								np.linspace(yCoastLine[minDistID1],yCoastLine[minDistID1+1],num=numberofPoints)])
		
		xsegment1 = xsegment.flatten()
		ysegment1 = ysegment.flatten()
		
		# Get distance for every node on these segments
		DistanceSeg = np.sqrt((x0R[ii]-xsegment1)**2 + (y0R[ii]-ysegment1)**2)
		
		# Get minimum distance to coastline 
		minDistanceR[ii] = np.nanmin(DistanceSeg)
		minDistSegmentID = np.argmin(DistanceSeg)
		
		
		# Determine side of coastline (=sign of determinant of vectors) 
		# SideOfCoastline = 1 --> Left/up side of coastline, defined as water
		# SideOfCoastline = -1 --> Right/down side of coastlien, defined as land
		# Side of Coastline = 0 --> On top of coastline, z=0
		
		SideOfCoastlineR[ii] = np.sign((xsegment1[minDistSegmentID+2] - xsegment1[minDistSegmentID-2]) * (y0R[ii] - ysegment1[minDistSegmentID-2]) - (ysegment1[minDistSegmentID+2] - ysegment1[minDistSegmentID-2]) * (x0R[ii] - xsegment1[minDistSegmentID-2]))
		
		
	return minDistance,SideOfCoastline


def CalculateDepthWithSlope(minDistance,SideOfCoastline,Slope):
	""" Function that calculates the depth value given a slope and a (offshore) distance (minimum distance)
		INPUT:
			- minDistance: numpy array with distance from point to coastline
			- SideOfCoastline: numpy array with values:
				SideOfCoastline = 1 --> Left/up side of coastline, defined as water
				SideOfCoastline = -1 --> Right/down side of coastlien, defined as land
				Side of Coastline = 0 --> On top of coastline, z=0
			- Slope: Single value with slope in m/m 
		OUTPUT:
			- Z: depth value in same size as minDistance 
	
	"""
	z = np.zeros_like(minDistance)
	
	# Make ravel views to 'flatten' matrices
	zR = z.ravel()
	SideOfCoastlineR = SideOfCoastline.ravel()
	minDistanceR = minDistance.ravel()
	
	for ii in range(np.size(minDistance)):
		if SideOfCoastlineR[ii]>0:
			zR[ii] = Slope*minDistanceR[ii]
		elif SideOfCoastlineR[ii]<0:
			zR[ii] = -(Slope*minDistanceR[ii])
		else:
			zR[ii] = 0
			
	return z
"""
xCoastLine = np.array([-10.0,0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,20.0])
yCoastLine = np.array([-10.0,0.0,1.0,1.5,2.0,3.0,4.0,5.0,5.5,20.0])

x0 = np.array([1.0,2.0])
print x0[0]

y0 = np.array([2.0,3.0])

Slope = 0.5

[minDistance,SideOfCoastline] = GetDistanceAndSideToCoastLine(xCoastLine,yCoastLine,x0,y0)
print minDistance
print SideOfCoastline
z = CalculateDepthWithSlope(minDistance,SideOfCoastline,Slope)
print z[0]
"""

