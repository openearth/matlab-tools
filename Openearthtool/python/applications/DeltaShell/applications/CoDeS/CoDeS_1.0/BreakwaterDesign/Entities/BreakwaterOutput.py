#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
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
class BreakwaterOutput():
		def __init__(self):
			self.Tm = []
			self.stp = []
			self.irri = []
			self.delta = []
			self.N = []
			self.Dn50 = {}
			self.irricrit = []
			self.isPlunging = []
			self.grad = {}
			self.isTooLarge = {}
			self.gammabeta = []
			self.gamma_crest = []
			self.Rc_required = []
			self.crestheight_required = []
			self.Rc = []
			self.qovertopping = []
			self.qovertopping_crest = []
			self.M50 = {}
			self.layer = {}
			self.alignment = {}
			self.volumes = {}
			self.costs = {}
			self.costs_perm = {}
			self.totalvolumes = {}
			self.totalcosts = {}
			self.y_layer = {}
			self.Hs = []
			self.Tp = []
			self.theta = []
			self.z = []
			self.crestheight = []
			self.profile = {}
			self.cross_ind = 0
		