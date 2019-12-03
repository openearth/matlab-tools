#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for FAST project
#       Giorgio Santinelli
#
#       giorgio.santinelli@deltares.nl
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

# $Id$
# $Date$
# $Author$
# $Revision$
# $HeadURL$
# $Keywords$
import numpy as np
import json

def profile2json(lon, lat, z):
    """
    convert lat, lon, z to a json array

    >>> profile2json([10], [10], [5])
    '[[10, 10, 5]]'
    """
    # applying a fixed number of decimal places is a bit annoying
    # http://stackoverflow.com/questions/27909658/json-encoder-and-decoder-for-complex-numpy-arrays
    txt = json.dumps(np.c_[lon, lat, z].tolist())
    return txt

if __name__ == '__main__':
    import doctest
    doctest.testmod()
