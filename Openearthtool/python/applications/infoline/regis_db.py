#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: pronk_mn
# @Date:   2015-10-23 11:36:39
# @Last Modified by:   pronk_mn
# @Last Modified time: 2015-11-03 14:27:17
# -*- coding: utf-8 -*-

"""
REGIS DB query tool
"""

import psycopg2
from shapely.geometry import Point


def getregislayers(x, y):
    """Returns list of regis layers for given point."""

    dbcon = {'database': 'gmdb',
             'user': 'postgres',
             'password': 'postgres',
             'host': 'localhost'}
    table_geom = 'regis_locations'

    # Set up connection
    con = psycopg2.connect(**dbcon)
    cur = con.cursor()

    # Retrieves all geometry for point
    p = Point(x, y)
    cur.execute('''SELECT layer
                FROM {}
                WHERE geom && ST_SETSRID(ST_GeomFromText('{}'),28992)
                '''.format(table_geom, p))
    layers = [x[0] for x in cur.fetchall()]
    return layers

if __name__ == "__main__":
    x = 84901
    y = 445226
    print getregislayers(x, y)
