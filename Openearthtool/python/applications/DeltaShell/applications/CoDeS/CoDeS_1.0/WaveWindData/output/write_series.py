#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
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
import csv
import datetime
from Scripts.WaveWindData.engine.utils import *

## =============================================================
def write_csv(data, classify):

	with open('D://test2.csv', 'wb') as csvfile:
		writer = csv.writer(csvfile, delimiter=',')
		if classify == True:
			for i in range(len(data)):
				temp = data[i]['class' + str(i + 1)]
				temp = convert_list(temp)
				writer.writerow(temp)
	
		else:

			for i in range(len(data)):
				writer.writerow(data[i])
