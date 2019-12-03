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
class InputData(object):

	def __init__(self):
		self.Coastline_utm        = []
		self.Coastline_utm_codes  = []	
		self.Profiles_utm        = []
		self.Profiles_utm_codes  = []
		self.Breakwaters_utm 		 = []
		self.Waves               = None
		self.normalize 			 = False
		self.formula             = 'Kamphuis'
		self.beach_slope         = 1.0/100.0
		self.rho_s               = 2650.0
		self.rho_w               = 1025.0
		self.d50                 = 0.000200 # in m
		self.porosity            = 0.4
		self.doc                 = 5.0
		self.gamma               = 0.7		
		self.active_height 		 = 5.0
		self.npoints 			 = 20
		self.time 				 = 25.0
		self.time_step			 = 5.0
		self.rightbnd 			 = 0
		self.leftbnd             = 0
		self.CalculationType     = 1 # 1 == Longshore transport, 2 == Coastline Evolution
		
	def Clone(self):
		clone = InputData()		
		clone.Coastline_utm       = self.Coastline_utm
		clone.Coastline_utm_codes = self.Coastline_utm_codes		
		clone.Profiles_utm       = self.Profiles_utm
		clone.Profiles_utm_codes = self.Profiles_utm_codes
		clone.Breakwaters 		 = self.Breakwaters
		clone.Waves              = self.Waves	
		clone.normalize 		 = self.normalize		
		close.formula            = self.formula
		clone.beach_slope        = self.beach_slope
		clone.rho_s              = self.rho_s
		clone.rho_w              = self.rho_w
		clone.d50                = self.d50    
		clone.porosity           = self.porosity
		clone.doc                = self.doc
		clone.gamma              = self.gamma		
		clone.active_height      = self.active_height
		clone.npoints 			 = self.npoints
		clone.time 				 = self.time
		clone.time_step			 = self.time_step
		clone.rightbnd 			 = self.rightbnd
		clone.lefbnd             = self.leftbnd
		clone.CalculationType    = self.CalculationType
		return clone