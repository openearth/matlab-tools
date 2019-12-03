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

## =============================================================
def convert_list(data):
	
	result = []

	for i in range(0,len(data)):
		if (isinstance(data[i], np.NumpyDotNet.ScalarFloat64)):
			result.append(data[i].Value)
		else:
			result.append(data[i])

	return result
	

## =============================================================
def column(matrix, i):
    return [row[i] for row in matrix]

## =============================================================
def StrToFloat(numString, defaultValue=None):
    """Conversion of string to float, when possible. Returns None when conversion is not possible"""
    try:
        numVal = float(numString)
    except ValueError:
        numVal = defaultValue
    
    return numVal

## =============================================================
def validText(text):
	"""returns T/F whether """
	if(text == "") or (text == None):
		return False
	else:
		return True
		
		
