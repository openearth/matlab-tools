"""
Initialize RDBMS with HydroDatabase datamodel and insert lists
"""

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares for LHM Projects
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

# $Id: orm_initializehydrodb.py 938 2016-06-16 14:03:03Z hendrik_gt $
# $Date: 2016-06-16 16:03:03 +0200 (Thu, 16 Jun 2016) $
# $Author: hendrik_gt $
# $Revision: 938 $
# $HeadURL: https://repos.deltares.nl/repos/NHI/trunk/engines/HMDB/orm_initializehydrodb.py $
# $Keywords: $

## Connect to the DB

from sqlalchemy import create_engine
import sqlfunctions

## Declare a Mapping to the database
from orm_osmhydrodb import Base

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


# when database is created this function fills the tables with lookup values (keuzelijsten)
def fillvocabs(fc):
    # get credentials for sqlfunctios.
    f = open(fc,'r')
    cr = f.readline()
    f.close()
    credentials = {}
    credentials['user'] = cr.split('//')[1].split(':')[0]
    credentials['host'] = cr.split('@')[1].split("/")[0]
    credentials['dbname'] = cr.split(credentials['host'])[1].split("/")[1].split("\n")[0]
    credentials['password'] = cr.split(":")[2].split('@')[0]
    credentials['port'] = 5432
    
    #various dictionarys with vocabularies from damo.hetwaterschapshuis.nl
    #http://damo.hetwaterschapshuis.nl/Objectenhandboek%20Watersysteem/DAMO%20Watersysteem%20Objectenhandboek.html?Inleiding.html
    # dict key = orm tablename
    # dict values = [columname,[vocabulary contents]]
    dctvocabs = {}
    dctvocabs['Boundary_type'] = ['boundary_type',[1,2,3,4,5,6,7]] ## Based on 3Di, 1=waterlevelbnd [m NAP]; 2=
                                                                      ## groundwaterlevelbnd [m NAP]; 3=dischargebnd [m3/s]; 
                                                                      ## 4: velocitybnd ; 5: qhbnd; 6: hqbnd; 7: lateral_discharge

    dctvocabs['Boundary_node'] = ['boundary_node',[0,1,2]] ## Based on 3Di, 0="No boundary", 1="Boundary on 1st node", 2="Boundary on last node"
    dctvocabs['Channel_type'] = ['channel_type',[0,1,2]] ## Based on 3Di channel types, 0=embedded, 1=Isolated, 2=connected
    dctvocabs['Category'] = ['category',[0,1,2,3,4]]  ## Can be used for visualization purpose
    dctvocabs['Definition_type'] = ['definition_type',[1]]  ## Type of cross-section, now only 1 type supported
    dctvocabs['Friction_type'] = ['friction_type',[4]]  ## Type of friction, now only 1 type supported

    for key in dctvocabs:
        populatelut(dctvocabs[key],credentials)

# function that actually fills the lookup tables
def populatelut(values,credentials):
    name = values[0]
    cnt = 0
    for i in values[1]:
        cnt = cnt + 1
        print name
        print i
        print str(cnt)
        strSql = """INSERT INTO {t} ({t}_id,{t}) VALUES ({c},'{v}')""".format(t=name,v=i,c=str(cnt))
        sqlfunctions.perform_sql(strSql,credentials)


def checkdatabase(credentials):
    from psycopg2 import connect        
    dbase = credentials['dbname']
    strSql = """SELECT 1 from pg_database WHERE datname='{}'""".format(dbase)
    con = None
    con = connect(user=credentials['user'], host = credentials['host'], password=credentials['password'])
    cur = con.cursor()
    cur.execute(strSql)
    a = cur.fetchall()
    cur.close()
    con.close()
    
    if len(a) == 0:
        from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
        con = None
        con = connect(user=credentials['user'], host = credentials['host'], password=credentials['password'])
        con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = con.cursor()
        cur.execute('CREATE DATABASE {}'.format(dbase))
        cur.close()
        con.close()

        strSql = """CREATE EXTENSION POSTGIS"""
        sqlfunctions.perform_sql(strSql,credentials)
        strSql = """CREATE EXTENSION POSTGIS_TOPOLOGY"""
        sqlfunctions.perform_sql(strSql,credentials)
        strSql = """CREATE EXTENSION HSTORE"""
        sqlfunctions.perform_sql(strSql,credentials)
        
# this is the main function. connectiontext is necessary.
# contents of the connection is postgres://username:password@host/database
# where:
# - username = username to login to database, on local machine this is often postgres
# - password = pasword provided
# - host = hostaddress of the database server, on local machine this is localhost
# - database = database where datamodel should be stored, bear in mind that this should be a PostGIS database
if __name__ == "__main__":
<<<<<<< .mine
    fc = r'd:\svn\openearthtools\python\applications\hydrotools\sandbox\osmmodelbuilding\connection_local.txt'
||||||| .r13009
    fc = r'd:\tools\HYDTools\sandbox\osmmodelbuilding\connection_local.txt'
=======
    #fc = r'd:\projecten\datamanagement\openearth\repos\applications\hydrotools\sandbox\osmmodelbuilding\connection_local.txt'
    fc = r'D:\projecten\datamanagement\openearth\repos\applications\hydrotools\sandbox\osmmodelbuilding\connection_ddp.txt'
>>>>>>> .r13055
    # format is #postgres://user:password@hostname/database (in this case hydrodb)    
    dropdb(fc)    
    createdb(fc) # bear in mind deletes database before creation
    fillvocabs(fc)