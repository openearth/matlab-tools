# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares
#       Lilia Angelova
#
#       Lilia.Angelova@deltares.nl
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

import psycopg2
from .secrets_parser import pgconfig
import os




def getscreensdb(x, y):
    """Returns all tops and bottoms of the screens in the closest well."""
    dir_path = os.path.dirname(os.path.realpath(__file__))
    dbcon = pgconfig(os.path.join(dir_path,"db_water_atlas.ini"))

    # Set up connection
    con = psycopg2.connect(**dbcon)
    cur = con.cursor()

    # get closest point
    query = '''SELECT x
                FROM meetpunten_screens
                ORDER BY ST_Distance(meetpunten_screens.geom, ST_SetSRID(ST_MakePoint({}, {}),28992)) ASC
                LIMIT 1'''.format(x, y)

    cur.execute(query)
    result = cur.fetchall()
    # data is split in multiple points for every screen
    x = result[0][0]

    query_same = '''SELECT *, ST_AsText(geom) as point
                    FROM meetpunten_screens
                    WHERE x = {}'''.format(x)
    cur.execute(query_same)
    all_points = cur.fetchall()
    layers = []
    layers.append((all_points[0][13], all_points[0][3]))

    for screen in all_points:
        temp_d = {}
        temp_d["top"] = screen[4]  # bkf_m - mv
        temp_d["bottom"] = screen[5]  # okf_m - mv(surface level)
        temp_d["type"] = "screen"
        layers.append(temp_d)
    return layers

# getscreensdb(215091.703296,613305.499549)
