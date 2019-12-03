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
import csv
import datetime

def read_csv(fileName, headerRow, Delimiter, dtFormat):

	data = []
	lineNr = 1
	with open(fileName) as csvfile:
		lines = csv.reader(csvfile,delimiter = Delimiter)
		for line in lines:
			if lineNr > headerRow:
				dt = datetime.datetime.strptime(line[0],dtFormat)
				wh = float(line[1])
				wl = float(line[2])
				dir = float(line[3])
				data.append([dt, wh, wl, dir])
			lineNr += 1
	
	return data