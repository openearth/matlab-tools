# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/brl_modelling/processes/brl_utils_lines.py $
# $Keywords: $

import math
from osgeo import ogr

def _distance(a, b):

    """ Return the distance separating points a and b.

    a and b should each be an (x, y) tuple.

    Warning: This function uses the flat surface formulae, so the output may be
    inaccurate for unprojected coordinates, especially over large distances.

    """

    dx = abs(b[0] - a[0])
    dy = abs(b[1] - a[1])
    return (dx ** 2 + dy ** 2) ** 0.5

def _get_split_point(a, b, dist):

    """ Returns the point that is <<dist>> length along the line a b.

    a and b should each be an (x, y) tuple.
    dist should be an integer or float, not longer than the line a b.

    """

    dx = b[0] - a[0]
    dy = b[1] - a[1]

    m = dy / dx
    c = a[1] - (m * a[0])

    x = a[0] + (dist**2 / (1 + m**2))**0.5
    y = m * x + c
    # formula has two solutions, so check the value to be returned is
    # on the line a b.
    if not (a[0] <= x <= b[0]) and (a[1] <= y <= b[1]):
        x = a[0] - (dist**2 / (1 + m**2))**0.5
        y = m * x + c

    return x, y

def split_line_single(line, length):

    """ Returns two ogr line geometries, one which is the first length
    <<length>> of <<line>>, and one one which is the remainder.

    line should be a ogr LineString Geometry.
    length should be an integer or float.

    """

    line_points = line.GetPoints()
    sub_line = ogr.Geometry(ogr.wkbLineString)

    while length > 0:
        d = _distance(line_points[0], line_points[1])
        if d > length:
            split_point = _get_split_point(line_points[0], line_points[1], length)
            sub_line.AddPoint(line_points[0][0], line_points[0][1])
            sub_line.AddPoint(*split_point)
            line_points[0] = split_point
            break

        if d == length:
            sub_line.AddPoint(*line_points[0])
            sub_line.AddPoint(*line_points[1])
            line_points.remove(line_points[0])
            break

        if d < length:
            sub_line.AddPoint(*line_points[0])
            line_points.remove(line_points[0])
            length -= d

    remainder = ogr.Geometry(ogr.wkbLineString)
    for point in line_points:
        remainder.AddPoint(*point)

    return sub_line, remainder

def split_line_multiple(line, length=None, n_pieces=None):

    """ Splits a ogr wkbLineString into multiple sub-strings, either of
    a specified <<length>> or a specified <<n_pieces>>.

    line should be an ogr LineString Geometry
    Length should be a float or int.
    n_pieces should be an int.
    Either length or n_pieces should be specified.

    Returns a list of ogr wkbLineString Geometries.

    """

    if not n_pieces:
        n_pieces = int(math.ceil(line.Length() / length))
    if not length:
        length = line.Length() / float(n_pieces)

    line_segments = []
    remainder = line

    for i in range(n_pieces - 1):
        segment, remainder = split_line_single(remainder, length)
        line_segments.append(segment)
    else:
        line_segments.append(remainder)

    return line_segments
