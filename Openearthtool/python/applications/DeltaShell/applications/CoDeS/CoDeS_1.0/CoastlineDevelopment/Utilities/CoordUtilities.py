#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Aline Kaji
#
#       aline.kaji@witteveenbos.com
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
import numpy as np
from NetTopologySuite.Extensions.Features import Feature as _Feature
from Libraries import MapFunctions as _MapFunctions

def ConvertPointGeometryToUTM(InputCoordinate,CSCodeSource,CSCodeUTM = None):
	
	CS_code_WGS84 = 4326
	
	InputPointGeometry = _MapFunctions.CreatePointGeometry(InputCoordinate.X,InputCoordinate.Y)
	
	conversionFeatureWGS84 = _MapFunctions.TransformGeometry(InputPointGeometry, CSCodeSource,CS_code_WGS84)
	
	# Define UTM zone if not given
	if CSCodeUTM == None:
		CSCodeUTM = int(32600 + int(np.ceil((conversionFeatureWGS84.X + 180)/6).Value) + (100*np.abs(((conversionFeatureWGS84.Y/np.abs(conversionFeatureWGS84.Y).Value)*0.5)-0.5).Value))
	else:
		CSCodeUTM = int(CSCodeUTM)
	
	# Convert coordinate from WGS84 to UTM
	conversionFeatureUTM = _MapFunctions.TransformGeometry(conversionFeatureWGS84, CS_code_WGS84, CSCodeUTM)
	
	# Export to list
	xnew = conversionFeatureUTM.X
	ynew = conversionFeatureUTM.Y
			
	return xnew, ynew, CSCodeUTM
	
def crossshore_to_orientation(basepoints,endpoints):
	
	coast_orientation = np.zeros((np.size(basepoints)/2,1))
	for i in range(0,(np.size(basepoints)/2)):
		end_point   = np.array(basepoints[i])
		start_point = np.array(endpoints[i])
		
		x_diff = np.diff([start_point[0],end_point[0]])
		y_diff = np.diff([start_point[1],end_point[1]])
		
		coast_orientation[i] = np.arctan2(x_diff,y_diff)/np.pi*180
		if float(coast_orientation[i]) < 0:
			coast_orientation[i] = coast_orientation[i]+360
		
	return coast_orientation
	
#CS_code_compute_1, start_point_utm  = points_to_utm(np.array([[570000,6800000]]),3857)

#print start_point_utm[0]