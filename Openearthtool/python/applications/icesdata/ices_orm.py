# -*- coding: utf-8 -*-
"""
Copyright notice
 --------------------------------------------------------------------
 Copyright (C) 2014,2015 Deltares for EMODnet Chemistry
     Gerben J. de Boer
     Gerrit Hendriksen
     gerrit.hendriksen@deltares.nl

 This library is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this library.  If not, see <http://www.gnu.org/licenses/>.
 --------------------------------------------------------------------
 
Created on Fri Sep 26 20:04:37 2014

@author: hendrik_gt


check http://ocean.ices.dk/webservices/hydchem.asmx?WSDL

uses credential file for ORM, with following sequence of strings
postgres://username:password@host/dbase

$Id: ices_orm.py 12173 2015-08-13 12:26:12Z hendrik_gt $
$Date: 2015-08-13 05:26:12 -0700 (Thu, 13 Aug 2015) $
$Author: hendrik_gt $
$Revision: 12173 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/icesdata/ices_orm.py $
$Keywords: $

"""

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy  import Sequence, ForeignKey, Column
from sqlalchemy  import Integer, Float, DateTime, String
from geoalchemy2 import Geometry
from geoalchemy2.functions import ST_X, ST_Y

from sqlalchemy import create_engine


Base = declarative_base()

## controlled vocabularies

class IcesStation(Base):
    __tablename__ = 'icesstation'
    stationid     = Column(Integer,Sequence('icesstation_id_seq'),primary_key=True,autoincrement=True,unique=True) # internal DB only
    platform      = Column(String, index=True,unique=True)                  # unique EDMO_code number, could be PK?
    stationcode   = Column(Integer,unique=True)
    geom          = Column(Geometry('POINT', srid=4326)) # SDN requires WGS84

    def __repr__(self):
        return "<IcesStation: stationid=%d, platform='%s')>" % (self.stationid, self.platform)

class Parameter(Base): # quantities
    __tablename__ = 'parameter'
    parameterid   = Column(Integer,Sequence('parameter_id_seq'),primary_key=True,autoincrement=True,unique=True) # internal DB only
    parametercode = Column(String,unique=True)
    parameter     = Column(String,unique=True)
    unit          = Column(String,unique=True)
    oceanography  = relationship("Oceanography", backref='parameter')
    
    def __repr__(self):
        return "<Parameter: parameterid='%s', parameter='%s')>" % (self.parameterid, self.parameter)
        
class Oceanography(Base): # quantities
    __tablename__ = 'oceanography'
    oceanid       = Column(Integer,Sequence('ocean_id_seq'),primary_key=True,autoincrement=True,unique=True)  # technical key as PK
    geom          = Column(Geometry('POINT', srid=4326)) # SDN requires WGS84
    datetime      = Column(DateTime, index=True)         # candidate key, fixed length 8 confirmed by Roy Lowry
    parameterid   = Column(Integer,ForeignKey('parameter.parameterid'))
    pressure      = Column(Float)
    value         = Column(Float)
    
    def __repr__(self):
        return "<Oceanography: oceanid='%s', stationid='%s')>" % (self.oceanid, self.stationid)
        
class Oceanupdates(Base): #for each parameter last update is logged
    __tablename__ = 'oceanupdates'
    updateid      = Column(Integer,Sequence('update_id_seq'),primary_key=True,autoincrement=True,unique=True)  # technical key as PK
    datetime      = Column(DateTime, index=True)         # candidate key, fixed length 8 confirmed by Roy Lowry
    parameterid   = Column(Integer,ForeignKey('parameter.parameterid'))
    
    def __repr__(self):
        return "<Oceanupdates: parameterid='%s', datetime='%s')>" % (self.parameterid, self.datetime)
        

def initializeices():
    f = open(r'D:\projecten\ices\connection.txt')
    engine = create_engine(f.read(), echo=False)
    f.close()
    
    ## Create the Table in the Database
    #TODO if tables exist and have to be created again, then
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    
    ## Create a Session
    from sqlalchemy.orm import sessionmaker
    Session = sessionmaker(bind=engine)
    
    session = Session()
    session.rollback()
    
    fillparameters(session)

# fill parameter table
def fillparameters(session):
    row = Parameter(parametercode = 'TEMP' , parameter = 'Temperature', unit = 'deg C')
    session.add(row)
    row = Parameter(parametercode = 'PSAL' , parameter = 'Salinity', unit = 'psu')
    session.add(row)
    row = Parameter(parametercode = 'DOXY' , parameter = 'Oxygen', unit = 'O2, ml/l')
    session.add(row)
    row = Parameter(parametercode = 'PHOS' , parameter = 'Phosphate Phosphorus', unit = 'PO4-P, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'TPHS' , parameter = 'Total Phosphorus', unit = 'P, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'AMON' , parameter = 'Ammonium', unit = 'NH4-N, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'NTRI' , parameter = 'Nitrite Nitrogen', unit = 'NO2-N, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'NTRA' , parameter = 'Nitrate Nitrogen', unit = 'NO3-N, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'NTOT' , parameter = 'Total Nitrogen', unit = 'N, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'SLCA' , parameter = 'Silicate Silicon', unit = 'SiO4-Si, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'H2SX' , parameter = 'Hydrogen Sulphide Sulphur', unit = 'H2S-S, umol/l')
    session.add(row)
    row = Parameter(parametercode = 'PHPH' , parameter = 'Hydrogen Ion Concentration', unit = 'H')
    session.add(row)
    row = Parameter(parametercode = 'ALKY' , parameter = 'Alkalinity', unit = 'meq/l')
    session.add(row)
    row = Parameter(parametercode = 'CPHL' , parameter = 'Chlorophyll a', unit = 'ug/l')
    session.add(row)
    session.commit()    


def storeinpg(Session,codeparam,result):
    lst = result['ICEData']
    session = Session()
    session.rollback()
    idparam = session.query(Parameter.parameterid).filter_by(parametercode=codeparam).first()
    for i in range(len(lst)):
        if i == len(lst)-1:
            obj = session.query(Oceanupdates.datetime).filter_by(parameterid=idparam).first()
            if obj == None:
                element = Oceanupdates(
                            parameterid = idparam,
                            datetime    = lst[i]['DateTime'])
                session.add(element)
            else:
                obj.datetime = lst[i]['DateTime']
                session.commit()
        
        element = Oceanography(
                      parameterid =idparam,
                      geom        = 'srid=4326;POINT('+str(lst[i]['Longitude'])+' '+str(lst[i]['Latitude'])+')',
                      datetime    = lst[i]['DateTime'],
                      pressure    = lst[i]['Pressure'],
                      value       = lst[i]['Value'])
        session.add(element)
        session.commit()    
    session.close()

def fillhydchemical(session,year):
    #create connection with ices via SOAP
    from suds.client import Client
    import time
    
    from sqlalchemy.orm import sessionmaker
    f = open(r'D:\projecten\ices\connection.txt')
    engine = create_engine(f.read(), echo=False)
    f.close()
    
    Session = sessionmaker(bind=engine)
    
    session = Session()
    session.rollback()
        
    # chemical data
    url = 'http://ocean.ices.dk/webservices/hydchem.asmx?WSDL'
    client = Client(url)

    #get parameters
    lstparameters = session.query(Parameter)
    # get last entry for all parameters and delete last month
    updatehistory = session.query(Oceanupdates)
    #
    session.close()
    for p in lstparameters:
        for year in range(1900,2014,1):
            for i in range(1,12,1):
                if i != 12:
                    t0 = time.time()
                    result = client.service.GetICEData(p.parametercode,year,year,i,i+1,-180.0,180.0,-90.0,90,0.0,100.0)
                    if len(result) > 0:
                        storeinpg(Session,p.parametercode,result)
                    print ''.join(['inserted ',p.parametercode,' for year ',str(year),' for month ',str(i),' to ',str(i+1),' in ',str(time.time() - t0),' seconds'])
    session.close()