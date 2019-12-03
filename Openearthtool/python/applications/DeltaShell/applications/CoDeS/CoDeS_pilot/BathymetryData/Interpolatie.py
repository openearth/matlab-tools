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
from math import pow  
from math import sqrt  
import numpy as np  
 
  
def pointValue(x,y,power,smoothing,xv,yv,values):
    """Interpolate point at location x,y based on sample locations defined in xv,yv and values""" 
    nominator=0  
    denominator=0  
    for i in range(0,len(values)):  
        dist = sqrt((x-xv[i])*(x-xv[i])+(y-yv[i])*(y-yv[i])+smoothing*smoothing);  
        #If the point is really close to one of the data points, return the data point value to avoid singularities  
        
        nominator=nominator+(values[i]/pow(dist,power))  
        denominator=denominator+(1/pow(dist,power))  
    #Return NODATA if the denominator is zero  
    if denominator > 0:  
        value = nominator/denominator  
    else:  
        value = -9999  
    return value  
  
def invDist(xv,yv,values,minX,minY,xsize,ysize,power,smoothing):
    """
    Interpolate values to grid based on sample locations xv, yv and values
    
    Input arguments
    xv: vector of x-coordinates of sample locations
    yv: vector of y-coordinates of sample locations
    values: values of sample location to be interpolated
    minX: x-coordinate of lower left corner of the result grid
    minY: x-coordinate of lower left corner of the result grid
    xsize: number of columns in result grid
	ysize: number of rows in result grid
	power: power to be applied in inverse distance calculation
	smoothing: smoothing factor (lower = less smooth)
    
    
    """
    valuesGrid = np.zeros((ysize,xsize)) 


    for x in range(minX,minX + xsize):
        xindex = x - minX    
        for y in range(minY,minY + ysize):  
            yindex = y - minY            
            puntwaarde = pointValue(x,y,power,smoothing,xv,yv,values)            
            valuesGrid[yindex][xindex] = puntwaarde                      
    return valuesGrid  
      
  
