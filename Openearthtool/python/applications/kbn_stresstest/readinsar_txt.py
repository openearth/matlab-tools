# -*- coding: utf-8 -*-
"""
Created on Tue Jun 12 07:47:49 2018

@author: hendrik_gt
"""
# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for WegenApp (hobbelkaart)
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

# $Id: getdata_overroads.py 14301 2018-04-16 08:40:40Z hendrik_gt $
# $Date: 2018-04-16 10:40:40 +0200 (Mon, 16 Apr 2018) $
# $Author: hendrik_gt $
# $Revision: 14301 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wegen/getdata_overroads.py $
# $Keywords: $

"""
This tool reads insar text files with elevation differences on locations (point locations) into
a postgres database
"""

"""database creation section"""
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy  import Sequence, ForeignKey, Column
from sqlalchemy  import Binary, Boolean, Integer, Float, DateTime, String, Text
from sqlalchemy import create_engine
from geoalchemy2 import Geometry
from geoalchemy2.functions import ST_X, ST_Y

Base = declarative_base()

## table classes for the controlled vocabularies
class Insarlocations(Base):
    __tablename__ = 'insarlocations'
    locid         = Column(Integer,primary_key=True,nullable=False)    
    name          = Column(String)
    lon           = Column(Float)
    lat           = Column(Float)
    geometry      = Column(Geometry('POINT', srid=28992))
    demvalue      = Column(Float)
    orgfile       = Column(String)

    def __repr__(self):
        return "<Insarlocations: locid=%s)>" % (self.locid)   

class Insarvalues(Base):
    __tablename__ = 'insarvalues'
    index         = Column(Integer,primary_key=True,nullable=False)    
    name          = Column(String)
    value         = Column(Float)
    date          = Column(DateTime)
    locid         = Column(Integer)

    def __repr__(self):
        return "<Insarvalues: valid=%s, locid=%s)>" % (self.name)

def createdb(fc):
    credentials = sf.get_credentials(fc)
    cstr = 'postgres://'+credentials['user']+':'+credentials['password']+'@'+credentials['host']+'/'+credentials['dbname']
    engine =create_engine(cstr, echo=False)
    
    ## Create the Table in the Database
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    return Base.metadata.tables.keys()        

""" read the data """"
import os
import glob
import json
import numpy as np
import psycopg2 as pg
import pandas as pd
import sqlfunctions as sf


fc = r'D:\projecten\datamanagement\Nederland\wegen\credentials.txt'

credentials = sf.get_credentials(fc)
cstr = 'postgres://'+credentials['user']+':'+credentials['password']+'@'+credentials['host']+'/'+credentials['dbname']
engine =create_engine(cstr, echo=False)
   
createdb(fc)

lstcsv = glob.glob(r'D:\projecten\datamanagement\Nederland\wegen\ftp\insar\a10\data\*.csv')

lstcsv = glob.glob(r'D:\projecten\datamanagement\Nederland\wegen\ftp\insar\a27\data\*.csv')

lstcsv = glob.glob(r'D:\projecten\datamanagement\Nederland\wegen\ftp\insar\a12\data\*.csv')

for insarf in lstcsv:
    loadinsarpts(insarf,engine)

def loadinsarpts(insarf, engine):
    connection = engine.raw_connection() 
    df = pd.read_csv(insarf)
    dfloc = pd.DataFrame(df, columns=['pnt_id', u'pnt_lat', u'pnt_lon', u'pnt_demheight'])
    dfloc = dfloc.rename(columns={'pnt_id':'name', u'pnt_lat':'lat', u'pnt_lon':'lon', u'pnt_demheight':'demvalue'})
    dfloc['orgfile'] = os.path.basename(insarf).replace('.csv','')
    dfloc.to_sql('insarlocations', engine,if_exists='append',index=False,chunksize = 1000)
     
    lstcols = [s for s in df.columns.tolist() if 'd_' in s]
    print(' '.join(['loading data from',os.path.basename(insarf).replace('.csv','')]))
    for col in lstcols:
        adate = pd.to_datetime(col.replace('d_',''))
        print(' '.join(['date =',col.replace('d_','')]))
        dft = pd.DataFrame(df,columns=['pnt_id',col])
        dft['date'] = adate
        dft = dft.rename(columns={'pnt_id':'name', col:'value'})
        dft.index +=1
        dft['i'] = dft.index.values
        args_str = ','.join(cursor.mogrify("(%s,%s,%s,%s)", x) for x in tuple(map(tuple,dft.values)))
        cur = connection.cursor()
        cur.execute("""INSERT INTO insarvalues (name,value,date,locid) VALUES"""+args_str.decode('utf-8'))
        connection.commit()
    cur.close()

"""part below updates the locid in insarvalues"""
strSql= """select distinct l.locid,v.name 
from insarvalues v
join insarlocations l on l.name = v.name
where v.locid is null"""
results = sf.executesqlfetch(strSql,credentials)

strSql = """select locid,name from insarlocations"""
results = sf.executesqlfetch(strSql,credentials)

cstr = 'postgres://'+credentials['user']+':'+credentials['password']+'@'+credentials['host']+'/'+credentials['dbname']
engine =create_engine(cstr, echo=False)

for locid,name in results:
    strSql = """update insarvalues v
                set locid = {lid}
                where v.name = '{n}'""".format(lid=locid,n=name)
    sf.perform_sql(strSql,credentials)

