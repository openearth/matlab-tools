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
import numpy as _np
from System import Array as _Array

def Interp(x, xArray, yArray):
	"""
	function to interpolate x towards y on mapping X and Y
	REMARK: xArray should be strict-increasing, all values for X should be in range of xArray
	also: only taken np.array()'s
	also: only real numbers (for imaginary part, simply call function with imaginary part)
	ex: 
		a = Interp(_np.array([3. 3.2]), _np.array([2.4 3.4]), _np.array([8+1j, 10+34j].Real)
		b = Interp(_np.array([3.]), _np.array([2.4 3.4], _np.array([8+1j, 10+34j].Imag)
		print(a + b*1j)
	INPUT:	- x [numpy-array] Size is free.
			- xArray [1xN vector] Strictly increasing values
			- yArray [1xN vector]
	OUTPUT: - y [numpy-array] Size is similar as x
	"""
	
	if (_np.size(x) == 1):
		#Find indices two values of xArray which interval contains x
		#Argmax returns the first value where True apears.
		ixR = _np.argmax([xArray > x])
		ixL = ixR - 1
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
			yVec[ix] = Interp(xVec[ix], xArray, yArray)
			
		#After forloop, return main-function
		return y

"""
Ideas to improve: 
 - eliminate recursivity of function
 - sort x before apply functions
 - 
"""
from System import Array 

def BinarySearchArray(array, number):
    """
    function to search for the before and after index of the supplied number 
    in a (sorted) array using binary search
    REMARK: array should be sorted
    ex: 
        array = Array[int]([3,6,8,12,35,78,43])
        index1, index2 = BinarySearchArray(array, 35)
        print "index1 = " + str(index1) + "  -  index2 = " + str(index2)
        
    INPUT:  - (sorted) array with numbers
            - number to search for
    OUTPUT: - index before and index after for the supplied number.
              (if an exact match is made, both indices are the same)
    """
    i = Array.BinarySearch(array, number)
    
    if (i >= 0):
        print "your number is in array : index " + str(i)
        return i,i
    else :
        indexOfNearest = ~i; # invert index to get the nearest index

        if (indexOfNearest == array.Length):
            raise Exception("Number is greater that last item")
        elif (indexOfNearest == 0):
            raise Exception("Number is less than first item")            
        else:
            return indexOfNearest -1, indexOfNearest

