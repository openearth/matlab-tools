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
#import Scripts.TidalData as _td
from GisSharpBlog.NetTopologySuite.Geometries import Point as _Point


class Tide:
	"""Class which contains all data concerning tides"""
	
	def __init__(self, cons, data, stats):
		
		#Spatial Location of dataset
		self.Location = _Point(None)
		self.cons = cons
		self.data = data
		self.stats = stats
		
		
		self.HAT = None
		self.LAT = None
		self.Location = None
		
		#High Water props
		self.MHW = None
		self.MHWN = None
		self.MHWS = None
		
		#Low Water props
		self.MLW = None
		self.MLWN = None
		self.MLWS = None
		
		self.MSL = None
		
		#Will be given as a 2xN array (compatible with Tide-scripts)
		self.Series = None
		
		self.SourcePath = ''
		
	
	#Twee mogelijke opties:
	#-is het berekenen van alle stats een TOOL-functionaliteit?
	#---Dan moet deze functie, of set functies gewoon bij de tool van Josh blijven
	#-is het breder getrokken, en moet het GENERIEK functioneel zijn?
	#---Dan moeten alle functies hier worden gedefinieerd, en bestaat de knop van Josh alleen
	#---nog uit het uitvoeren van de methode, en het plotten op scherm.
	
	def CalculateStats(self):
		#Hier komen dus de enorme stapel aan stat-functies die Josh destijds al heeft gemaakt
		#Nu nog lege functie
		
		self.HAT = _td.getHAT(self.Series)
		self.LAT = _td.getLAT(self.Series)
		
		#High Water props
		#self.MHW = _td.getMHW(self.Series) #NOT EXISTING
		self.MHWN = _td.getMHWN(self.Series)
		self.MHWS = _td.getMHWS(self.Series)
		
		#Low Water props
		#self.MLW = _td.getMLW(self.Series) #NOT EXISTING
		self.MLWN = _td.getMLWN(self.Series)
		self.MLWS = _td.getMLWS(self.Series)
		
		self.MSL = _td.getMSL(self.Series)

