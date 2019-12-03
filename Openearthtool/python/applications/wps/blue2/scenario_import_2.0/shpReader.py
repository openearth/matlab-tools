# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
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
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: emisk_utils_wcs.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-30 08:21:10 +0100 (Tue, 30 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/emisk_utils_wcs.py $
# $Keywords: $

import shapefile

class shpFile:
	
	def __init__(self, fname, idfield):
		""" Shapefile file object """
		self.sf = shapefile.Reader(fname)
		self.idfield = idfield
		self.posfield = self.getPosField()

	def getPosField(self):
		""" Gets all variables with 3 dimensions at least """		
		i = -1
		for f in self.sf.fields:
			if f[0] == self.idfield:	return i
			i+=1
		return i

	def getFeatureGeometries(self):
		""" Gets all variables with 3 dimensions at least """		
		idsGeoms = {}
		for f in self.sf.shapeRecords():			
			idsGeoms[f.record[self.posfield]] = f.shape
		return idsGeoms

