"""
Declaration via ORM mapping of Subsurface datamodel, including FEWS time series
compatibla datamodel, requires:
Pyhton packages
 - sqlalchemy
 - geoalchemy2
PostgreSQL/PostGIS
 - schema fews
 - schema borehole
"""

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares for Projects with a FEWS datamodel in 
#                 PostgreSQL/PostGIS database used in Water Information Systems
#   Gerrit Hendriksen@deltares.nl
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

# $Id: orm_initializesubsrufacedb.py 13341 2017-05-12 15:04:24Z hendrik_gt $
# $Date: 2017-05-12 08:04:24 -0700 (Fri, 12 May 2017) $
# $Author: hendrik_gt $
# $Revision: 13341 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datamodel/subsurface/orm_initializesubsrufacedb.py $
# $Keywords: $

## Connect to the DB

from sqlalchemy import create_engine

## Declare a Mapping to the database
from orm_subsurface import Base

def checkschemas(fc):
    'this function is to be created'

# function to create the database, bear in mind, only to be executed when first started
# it first deletes complete database before inserting the datamodel
def createdb(fc):
    f = open(fc)
    engine = create_engine(f.read(), echo=False)
    f.close()
    ## Create the Table in the Database
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)

# drop (delete) database
def dropdb(fc):
    f = open(fc)
    engine = create_engine(f.read(), echo=False)
    f.close()
    Base.metadata.drop_all(engine)

if __name__ == "__main__":
    fc = r"D:\projecten\datamanagement\MiddleEast\Kuwait\datamodel\connection.txt"
    # format is #postgres://user:password@hostname/database (in this case hydrodb)    
    dropdb(fc)    
    createdb(fc) # bear in mind deletes database before creation
