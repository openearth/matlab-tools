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
class OutputData(object):
	def __init__(self):
		""" Coastline Evolution """
		self.CoastX               = [[483862, 482354],[483762, 482554]]
		self.CoastY               = [[6829624, 6830593],[6828624, 6831593]]
		self.CoastLon             = []
		self.CoastLat             = []
		self.Coastline_utm        = []
		self.Coastline_utm_codes  = []
		self.Years	 			  = []
		self.Time				  = []
		
		""" Longshore Transport """
		self.TransectOrientation    = [350]
		self.SedTransPos 			= [10000]
		self.SedTransNeg			= [-2000]
		self.SedTransNet  			= [8000]
		