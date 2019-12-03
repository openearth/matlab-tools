#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares for LHM Projects
#       Gerrit Hendriksen@deltares.nl
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

# $Id: nhi_point2model.py 13630 2017-09-01 09:12:48Z sala $
# $Date: 2017-09-01 11:12:48 +0200 (Fri, 01 Sep 2017) $
# $Author: sala $
# $Revision: 13630 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/nhi_point2model.py $
# $Keywords: $

import math
from coords import change_coords
apoint = [466891,6800616]
acrs = 'EPSG:3857'
acrst = 'EPSG:28992'
cs = 250
calcs = 2500 # calculation size (meter)

def modelextent(apoint,acrs,cs,calcs):
    #first convert to 28992
    ptt = change_coords(apoint[0],apoint[1],acrs,acrst)
    
    rect = [round_int(ptt[0],cs)-cs/2-calcs,
            round_int(ptt[1],cs)-cs/2-calcs,
            round_int(ptt[0],cs)+cs/2+calcs,
            round_int(ptt[1],cs)+cs/2+calcs]
    return rect

def round_int(n,cs):
    return round(math.ceil(n)/cs)*cs
