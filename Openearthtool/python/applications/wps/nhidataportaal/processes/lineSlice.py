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

# $Id: lineSlice.py 12746 2016-05-20 12:35:24Z sala_joan $
# $Date: 2016-08-22 14:35:24 +0200 (Mon, 22 Aug 2016) $
# $Author: sala $
# $Revision: 12746 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/waterbodems/lineSlice.py $
# $Keywords: $

import math
from pyproj import Proj, transform

# Change XY coordinates general function


def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:28992'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)


class lineSlice:

    # Featurecollection with linestring + grid size
    def __init__(self, json_data, grid_size_in):
        self.data = json_data
        self.grid_size = grid_size_in
        self.coords = []

    # Modulus of vector
    def modulus_segment(self, x1, x2, y1, y2):
        return float(math.sqrt((y2-y1)**2 + (x1-x2) ** 2))

    # Slice a vector given a distance
    def slice(self):
        # Get new coords
        for feature in self.data['features']:
            line = feature['geometry']['coordinates']
            if len(line) > 1:  # A linestring feature has more than 1 point
                # Begin point
                xbeg = float(line[0][0])
                ybeg = float(line[0][1])

                # Intermediate points according to grid size
                for xend, yend in feature['geometry']['coordinates']:
                    mod = self.modulus_segment(xbeg, xend, ybeg, yend)
                    pieces = int(mod/self.grid_size)

                    # Segment can or cannot be divided into grid_size
                    if pieces == 0:
                        self.coords.append([xbeg, ybeg])
                    else:
                        for i in range(0, pieces+1):
                            # Unitary vector and subparts
                            uni = [(xend - xbeg) / mod * self.grid_size,
                                   (yend - ybeg) / mod * self.grid_size]
                            self.coords.append(
                                [xbeg + i*uni[0], ybeg + i*uni[1]])

                    # next segment
                    xbeg = xend
                    ybeg = yend

                # Last point
                self.coords.append([xend, yend])

            feature['geometry']['coordinates'] = self.coords

        return self.data

    # Slice a vector given a distance
    def getOrientation(self):
        # Get new coords
        ax = self.coords[-1][0] - self.coords[0][0]
        ay = self.coords[-1][1] - self.coords[0][1]

        if ((ax < 0) and (ay < 0)):
            return "South - West"
        if ((ax < 0) and (ay > 0)):
            return "North - West"
        if ((ax > 0) and (ay < 0)):
            return "South - East"
        if ((ax > 0) and (ay > 0)):
            return "North - East"

        if ((ax == 0) and (ay < 0)):
            return "South"
        if ((ax == 0) and (ay > 0)):
            return "North"
        if ((ax > 0) and (ay == 0)):
            return "East"
        if ((ax > 0) and (ay == 0)):
            return "West"
