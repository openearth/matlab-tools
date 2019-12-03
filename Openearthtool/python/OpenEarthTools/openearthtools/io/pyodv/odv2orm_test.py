# first test to add a colletion of odv data to PostgreSQL-PostGIS database using ORM
# http://geoalchemy-2.readthedocs.org/en/latest/orm_tutorial.html

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Gerben J. de Boer
#
#       gerben.deboer@deltares.nl
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

# $Id: odv2orm_test.py 10926 2014-07-03 09:43:28Z boer_g $
# $Date: 2014-07-03 02:43:28 -0700 (Thu, 03 Jul 2014) $
# $Author: boer_g $
# $Revision: 10926 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_test.py $
# $Keywords: $

## Connect to the DB
from sqlalchemy import create_engine
from sqlalchemy import create_engine
f = open('odvconnection.txt')
engine = create_engine(f.read(), echo=True)
f.close()

## Declare a Mapping
from odv2orm_model import *

## Create the Table in the Database
Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)

## Create a Instance of the Mapped Class
from odv2orm_testdict import *

## Create a Session
from sqlalchemy.orm import sessionmaker
Session = sessionmaker(bind=engine)

session = Session()
session.rollback()

## Add New Objects
for table in ["Edmo","P01","P06","Cdi","Odvfile","Observation"]:
   print "=============== " + table
   for row in D[table]:
      session.add(row)
   session.commit()
 
## query
print(session.query(Cdi ).filter_by( cdi=5523).first())
print(session.query(Edmo).filter_by(identification=1528).first())
print(session.query(P01 ).filter_by(identification="TEMPPR01").first())
print(session.query(P06 ).filter_by(identification="UPAA"    ).first())

session.close()