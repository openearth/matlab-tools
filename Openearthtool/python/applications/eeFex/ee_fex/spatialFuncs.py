#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerben Hagenaars
#
#       Gerben.Hagenaars@deltares.nl
#       
#       Wiebe de Boer
#
#       Wiebe.deBoer@deltares.nl
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
#
# This tool is developed as part of the research cooperation between
# Deltares and the Korean Institute of Science and Technology (KIOST).
# The development is funded by the CoMIDAS project of the South Korean
# government and the Deltares strategic research program Coastal and
# Offshore Engineering. This financial support is highly appreciated.
#
# ========================================
#Spatial Functions for Feature Extraction
#========================================
#JFriedman
#Apr 19/2016
#========================================

#import all necessary packages
#=============================
from pyproj import Proj, transform

#convert to cartesian coordinates to determine possible zones
#============================================================
def ConvertCoordinates(EPSGin, EPSGout, x1, y1):
	inProj = Proj(init='epsg:%s' % EPSGin)  #fixed since coming from OSMaps -> lat/lon
	outProj = Proj(init='epsg:%s' % EPSGout)  #variable based on location!
	xy = transform(inProj, outProj, x1, y1)
	return xy