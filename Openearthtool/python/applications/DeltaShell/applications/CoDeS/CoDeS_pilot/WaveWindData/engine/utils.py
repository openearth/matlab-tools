#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Witteveen+Bos
#       Jaap de Rue
#
#       jaap.de.rue@witteveenbos.com
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
