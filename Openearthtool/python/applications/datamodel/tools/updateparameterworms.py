# -*- coding: utf-8 -*-
"""
Created on Wed Sep 17 11:29:00 2014

@author: hendrik_gt

update parameter_worms and parameter tabel

basics derived from http://www.marinespecies.org/aphia.php?p=webservice

"""

#!/usr/bin/python

import argparse
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy  import Sequence, ForeignKey, Column, update
from sqlalchemy  import Integer, Float,  Text, String
from sqlalchemy  import Table, MetaData

import sqlfunctions

Base = declarative_base()

from SOAPpy import WSDL
import re
import sys


class worms(Base):
    __tablename__     = 'parameter_worms'
    aphiaid           = Column(Float,primary_key=True)
    scientificname    = Column(String(length=8), index=True,unique=True)
    authority         = Column(Text)
    status            = Column(Text)
    aphiaid_accepted  = Column(Float)
    kingdom           = Column(Text)
    phylum            = Column(Text)
    order             = Column(Text)
    family            = Column(Text)
    genus             = Column(Text)
    subgenus          = Column(Text)
    species           = Column(Text)
    subspecies        = Column(Text)
    source            = Column(Text)    
    # "class"           = Column(String)
    
    def __repr__(self):
        return "<worms: aphiaid='%s', scientificname='%s')>" % (self.aphiaid, self.scientificname)

"not implemented yet"
class pesi(Base):
    __tablename__     = 'parameter_pesi'
    pesiid            = Column(Float,primary_key=True)
    scientificname    = Column(String(length=8), index=True,unique=True)
    authority         = Column(Text)
    status            = Column(Text)
    kingdom           = Column(Text)
    phylum            = Column(Text)
    order             = Column(Text)
    family            = Column(Text)
    genus             = Column(Text)
    subgenus          = Column(Text)
    species           = Column(Text)
    subspecies        = Column(Text)
    source            = Column(Text)    
    
    def __repr__(self):
        return "<pesi: pesiid='%s', scientificname='%s')>" % (self.pesiid, self.scientificname)

class u_soort(Base):
    __tablename__  = 'uniek_soort'
    __table_args__ = {'schema': 'buwa'}
    euring_code    = Column(Integer)
    waarneemcode   = Column(String(length=5),primary_key=True)
    nlnaam         = Column(String(length=75))
    commonname     = Column(String(length=75))
    scientificname = Column(String(length=75))
    idparam        = Column(Integer)

    def __repr__(self):
        return "<u_soort: scientificname='%s', idparam='%s'>" % (self.scientificname, self.idparam)

class param(Base):
    __tablename__        = 'parameter'
    idparameter          = Column(Integer,Sequence('parameter_idparameter_seq'),primary_key=True)
    parameterdescription = Column(Text) 
    foreignkey           = Column(Integer)
    referencetable       = Column(String(length=50))

    def __repr__(self):
        return "<param: idparameter='%s', parameterdescription='%s', foreignkey='%s', referencetable='%s'>" % (self.idparameter, self.parameterdescription, self.foreignkey,self.referencetable)

"get worms records by scientificname"
def get_Records(scientificname, offset_number):
	a = wsdlObjectWoRMS.getAphiaRecords(scientificname, like='true', fuzzy='true', marine_only='false', offset=offset_number)
	return(a)

"get worms records by commonname"
def get_RecordsC(commonname, offset_number):
    a = wsdlObjectWoRMS.getAphiaRecordsByVernacular(commonname,like='true',offset = offset_number)
    return(a)



"""get worms records by commonname via PESI
visit http://www.eu-nomen.eu/portal/webservices.php for more information
"""
def get_RecordsPC(commonname):
    a = wsdlObjectPESI.getPESIRecordsByVernacular(commonname)
    return(a)

def get_RecordsP(scname):
    a = wsdlObjectPESI.getPESIRecords(scname)
    return(a)

    
'Add data to parameter_worms and parameter table if not exists, returns idparameter'
def adddatatopg(sp,session):
    # check unique constraints
    idparameter = None
    apid    = sp.AphiaID
    exist1  = session.query(worms).filter_by(aphiaid=apid).first()
    if exist1==None:
        try:
            element = worms(
                aphiaid           =str(apid),
                scientificname    =sp['scientificname'],
                authority         =sp['authority'],
                status            =sp['status'],
                aphiaid_accepted  =sp['valid_AphiaID'],
                kingdom           =sp['kingdom'],
                phylum            =sp['phylum'],
                order             =sp['order'],
                family            =sp['family'],
                genus             =sp['genus'],
                source            ='worms'    #,
                #subgenus          =sp['subgenus'],
                #species           =sp['species'],
                #subspecies        =sp['subspecies']
                )
            session.add(element)
            session.commit()
        except:
            print('Error inserting %s%s' % (sp['scientificname'], exist1.id))
        
    # part that adds to parameter table
    exist   = session.query(param).filter_by(foreignkey=apid).first()
    if exist==None:
        try:
            element = param(
                parameterdescription =sp.scientificname,
                foreignkey           =str(apid),
                referencetable       ='parameter_worms')
            session.add(element)
            session.commit()
            idparameter = element.idparameter
        except:
            print('Error inserting %s%s' % (sp['scientificname'], exist1.id))
    else:
        idparameter = exist.idparameter
        print ''.join(['returned ',str(idparameter),' for ',sp.scientificname])
    return idparameter


if __name__ == '__main__':    
    adescr= """ Find official ID's for species
                First implemented by using the WoRMS webservice
                visit http://marinespecies.org/aphia.php?p=webservice for more information on this service
                Second implementation also uses the PESI list
                visit http://www.eu-nomen.eu/portal/webservices.php for more information on this service
                
                The outcome is added to the table parameter_worms, or parameter_pesi (initially)
                first todo is to enable also addition to taxon_worms and taxon_pesi, 
                perhaps this can be done by setting worms.__tablename__ = 'taxon_worms'. 
                Is not implemented nor tested.
            """
    parser = argparse.ArgumentParser(description=adescr)
    parser.add_argument('--cf','-c', default=None, type=str, help='file with credentials for access to the database')
    parser.add_argument('--name','-name', default='commonname', type=str, help='specify if search on WoRMS/PESI is done by CommonName (English) or scientificname, Common Name is default')
    parser.add_argument('--l','-list', default='WoMRS', type=str, help='specify if search is done using the WoRMS or PESI vocabulary, WoRMS is default, PESI not fully tested/implemented yet')
    
    args = parser.parse_args()

    ## Connect to the DB
    fn = args.cf
    fn = r'D:\projecten\datamanagement\oet\applications\datamodel\tools\connection.txt'
    f = open(fn)
    engine = create_engine(f.read(), echo=False) # echo=True is very slow
    f.close()
    
    f = open(fn)
    aline = f.readline()
    c = aline.split('//')[1]
    credentials = {}
    credentials['dbname'] = c.split('/')[1].split('\n')[0]
    credentials['user']   = c.split(':')[0]
    host = c.split(':')[1].split('/')[0] 
    credentials['host'] = host[host.rfind('@')+1:len(host)]
    credentials['password'] = host[0:host.rfind('@')]
    f.close()
    
    # get the boolean commonname (default is True)
    if args.name != 'commonname':
        commonname = False
    
    if args.l != 'WoRMS':
        wsdlObjectPESI = WSDL.Proxy('http://www.eu-nomen.eu/portal/soap.php?p=soap&wsdl=1')
    else:
        wsdlObjectWoRMS = WSDL.Proxy('http://www.marinespecies.org/aphia.php?p=soap&wsdl=1')

    ## Declare a Mapping
    ## Create a Session
    
    Session = sessionmaker(bind=engine)
    
    session = Session()
    session.rollback()    
    
#    'define unieksoort'
#    metadata = MetaData()
#    usoort = Table('uniek_soort',metadata,
#                Column('euring_code',Integer),
#                Column('waarneemcode',String(length=5),primary_key=True),
#                Column('nlnaam',String(length=75)),
#                Column('commonname',String(length=75)),
#                Column('scientificname',String(length=75)),
#                Column('idparam',Integer),
#                schema='buwa'
#               )
    
    
try:
    lst = session.query(u_soort).filter_by(idparam = None).all()
except Exception as err:
    session.close()
    print 'error occured while performing a query',err

if not (lst is None):
    for i in range(len(lst)):
        spec = lst[i].scientificname
        if not(spec is None) and spec.find('/') == -1:
            code = lst[i].waarneemcode
            if spec.find('spec.') > -1:
                spec = spec.split('spec.')[0]
            if spec.find('sp.') > -1:
                spec = spec.split('sp.')[0]
            spec = spec.rstrip()
            if commonname:
                wormsspec = get_RecordsC(spec, 1)
            else:
                wormsspec = get_Records(spec, 1)
            
            if not (wormsspec is None):
                # check and if needed add to table parameterworms
                # check and if add to table parameter
                idpar = adddatatopg(wormsspec[0],session)
                # update uniek_soort the idparameter to uniek_soort
                strSql = """UPDATE buwa.uniek_soort set idparam = {id}
                            WHERE waarneemcode = '{c}'""".format(id=idpar,c=code)
                sqlfunctions.perform_sql(strSql,credentials)
                print ''.join([spec,'with idparam ',str(idpar),' added to uniek_soort'])
            else:
                print ''.join([spec,' not found in marinespecies.org'])      
session.close()

#                    stmt = usoort.update().\
#                           where(usoort.c.waarneemcode == code).\
#                           values(idparam=str(idpar))                    
#                    session.execute(stmt)
#                    session.rollback()
    
session.query(usoort).\
    filter(usoort.c['waarneemcode']==code).\
    update(usoort.c['idparam']=idpar)
session.commit()