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
import numpy as np
import math


def getShoreNormal(x1, y1, x2, y2):
    """
    Function to extract the shore normal, assumed that the user clicked the 
    coastline. The normal will point both directions
    
    INPUT: - x1: x-coordinate of first point [m]
           - y1: y-coordinate of first point [m]
           - x2: x-coordinate of second point [m]
           - y2: y-coordinate of second point [m]
           REMARK: all inputs should be numeric scalars
    """
    
    #To ensure floats (not ints)
    x1 = x1.astype('float')
    y1 = y1.astype('float')
    x2 = x2.astype('float')
    y2 = y2.astype('float')
    
    
    
    #Calculate the middle of the given line
    midpointX = (x1 + x2) / 2
    midpointY = (y1 + y2) / 2
    
    #Calculate the distance
    dist = (((x1 - x2) ** 2) + ((x1 - x2) ** 2))) ** 0.5
    
    #Calc the angle relative to North, and clockwise:
    ##NOT NEEDED YET.....
    return