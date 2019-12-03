"""
Initialize RDBMS with ODV datamodel and insert BODC controlled vocabularies
"""

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

# $Id: odv2orm_initialize.py 15606 2019-07-29 11:55:32Z hendrik_gt $
# $Date: 2019-07-29 04:55:32 -0700 (Mon, 29 Jul 2019) $
# $Author: hendrik_gt $
# $Revision: 15606 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_initialize.py $
# $Keywords: $

## Connect to the DB

import os
import vocabrel
import urllib
import tempfile
from sqlalchemy import create_engine
import sqlfunctions

## Declare a Mapping to the database, the differences are not really in the support tables
oldversion = False
if oldversion:
    from odv2orm_model2 import *
else:
    from odv2orm_model3 import *

credentials={}

def getConnStrFromFile(connFile):
    connFile = open(connFile, 'r+')
    connStr = connFile.read()
    connFile.close()
    return connStr

def getCredentialsFromConnectionString(connStr):
    credentials['user'] = connStr.split('//')[1].split(':')[0]
    credentials['password'] = connStr.split(":")[2].split('@')[0] 
    credentials['host'] = connStr.split('@')[1].split(":")[0]
    credentials['port'] = connStr.split(credentials['host']+':')[1].split("/")[0]
    credentials['dbname'] = connStr.split(credentials['port']+"/")[1].split("\n")[0]
    return credentials

#connectionstring in file "odvconnection_local.txt", for example: postgresql://user:password@localhost:5432/databasename
local=True
if local:
    connFile=r"D:\emodnet\data\odvconnection_local.txt"
    credentials['user'] = 'postgres'
    credentials['password'] = 'wcp163'
    credentials['host'] = 'localhost'
    credentials['port'] = '5432'
    credentials['dbname'] = 'emodnet2019'
    connStr=getConnStrFromFile(connFile)
    
    credentials['user'] = 'postgres'
    credentials['password'] = 'ghn@D3lt@r3s'
    credentials['host'] = 'localhost'
    credentials['port'] = '5432'
    credentials['dbname'] = 'emodnet'

else: 
    connFile =r"D:\projecten\eu\EMODNet\chemistry\repos\odvconnection_local.txt"
    connStr=getConnStrFromFile(connFile)
    credentials=getCredentialsFromConnectionString(connStr)

## Create a Session
from sqlalchemy.orm import sessionmaker
f = open(connFile)
engine = create_engine(f.read(), echo=False)
f.close()
Session = sessionmaker(bind=engine)

## Create the Table in the Database
Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)

session = Session()
session.rollback()

## Add vocabs using the function vocab2orm
def vocab2orm(xmlfile,obj,type=0):
#    print('initialize: inserting: ' + xmlfile + ', please wait ...')
    import bodc
    if type==0:
       vocab = bodc.fromfile_collection(xmlfile)
    elif type==1:
       vocab = bodc.fromfile_list(xmlfile)
    for i in range(len(vocab["identifier"])):
        exist1 = session.query(obj).filter_by(identifier=vocab["identifier"][i]).first()
        if exist1==None:
            print ' '.join(['adding:',vocab["identifier"][i],vocab["prefLabel"][i]])
            if xmlfile.split('.')[0] == 'P01' or xmlfile.split('.')[0] == 'P35':
                row = obj (identifier  = vocab["identifier"][i], 
                           preflabel   = vocab["prefLabel"][i],
                           altlabel    = vocab["altLabel"][i], 
                           definition  = vocab["definition"][i],
                           origin      = xmlfile.split('.')[0])
            else:
                row = obj (identifier  = vocab["identifier"][i], 
                           preflabel   = vocab["prefLabel"][i],
                           altlabel    = vocab["altLabel"][i], 
                           definition  = vocab["definition"][i])
                    
            session.add(row)
            session.commit()
        else: # so the parameter exists and will be updated with proper labels
#            print i
            a = vocab["altLabel"][i]
            p = vocab["prefLabel"][i]
#            p = p.replace("""'""",'`')
#            p = p.replace("""+""",' plus ')
            p = p.encode('utf-8')
            p = p.strip()
            _id = vocab["identifier"][i]
            strSql = "UPDATE parameter SET altlabel = $${a}$$, preflabel = $${p}$$ WHERE identifier = '{id}' ".format(a=a,p=p,id=_id)
            try:
                sqlfunctions.perform_sql(strSql,credentials)
            except:
                print ' '.join([vocab["altLabel"][i],(vocab["prefLabel"][i]).replace("""'""",'`').replace("""+""",' plus ').encode('utf-8').strip(),vocab["identifier"][i]])
                print strSql
            

## Get files cache of vocabs
tmpdir = tempfile.gettempdir()
items =['P35','P06','P01','L20','P36','L04','P02','S27']
for item in items:
    if not(os.path.isfile(os.path.join(tmpdir,item + '.xml'))):
#        print 'retrieving', tmpdir,item + '.xml'
        urllib.urlretrieve("http://vocab.nerc.ac.uk/collection/"+item+"/current/", os.path.join(tmpdir,item+'.xml'))
    else:
        print ' '.join(['file', tmpdir,item + '.xml', 'already there'])

## Add vocabs
vocab2orm(os.path.join(tmpdir,'P01.xml'),Parameter)
vocab2orm(os.path.join(tmpdir,'P35.xml'),Parameter)
vocab2orm(os.path.join(tmpdir,'P36.xml'),P36)
vocab2orm(os.path.join(tmpdir,'P06.xml'),P06)
vocab2orm(os.path.join(tmpdir,'L20.xml'),L20)
vocab2orm(os.path.join(tmpdir,'L04.xml'),L04)
vocab2orm(os.path.join(tmpdir,'P02.xml'),P02)
vocab2orm(os.path.join(tmpdir,'S27.xml'),S27)


xmlfile,obj = (os.path.join(tmpdir,'P01.xml'),Parameter)
# now map the P36 to the P35
mapping = vocabrel.sdn_mapping('P36','P35')
i=0
mapping = vocabrel.sdn_mapping('P36','P35')
for k in mapping:   # for each key
    for v in mapping[k]:
#        print v,k
        strSql = """select id from p36 where identifier = '{k}'""".format(k=k)
        a = sqlfunctions.executesqlfetch(strSql,credentials)
        strSql = """UPDATE parameter set p36_id = '{id}'
                    where identifier='{pident}';""".format(id=a[0][0],pident=v)
        sqlfunctions.perform_sql(strSql,credentials)        

mapping = vocabrel.sdn_mapping('P35','P01')
for k in mapping:   # for each key
    for v in mapping[k]:
        strSql = """select id from p36 where identifier = '{v}'""".format(v=v)
        a = sqlfunctions.executesqlfetch(strSql,credentials)
        if len(a)>0:
            strSql = """UPDATE parameter SET p36_id = '{p36id}' 
                        where identifier='{p01id}'""".format(p36id=a[0][0],p01id=k)
            sqlfunctions.perform_sql(strSql,credentials) 

mapping = vocabrel.sdn_mapping('L04','P02')
for k in mapping:   # for each key
    for v in mapping[k]:
        print(k,v)
        strSql = """select id from L04 where identifier = '{k}'""".format(k=k)
        a = sqlfunctions.executesqlfetch(strSql,credentials)
        if len(a)>0:
            strSql = """UPDATE p02 SET l04_id = '{l04id}' 
                        where identifier='{p02id}'""".format(l04id=a[0][0],p02id=v)
            sqlfunctions.perform_sql(strSql,credentials) 


mapping = vocabrel.sdn_mapping('P02','P01')
for k in mapping:   # for each key
    for v in mapping[k]:
        print(k,v)
        strSql = """select id from p02 where identifier = '{k}'""".format(k=k)
        a = sqlfunctions.executesqlfetch(strSql,credentials)
        if len(a)>0:
            strSql = """UPDATE parameter SET p02_id = '{p02id}' 
                        where identifier='{p01id}'""".format(p02id=a[0][0],p01id=v)
            sqlfunctions.perform_sql(strSql,credentials) 

mapping = vocabrel.sdn_mapping('S27','P01')
for k in mapping:   # for each key
    for v in mapping[k]:
        print(k,v)
        strSql = """select id from s27 where identifier = '{k}'""".format(k=k)
        a = sqlfunctions.executesqlfetch(strSql,credentials)
        if len(a)>0:
            strSql = """UPDATE parameter SET s27_id = '{s27id}' 
                        where identifier='{p01id}'""".format(s27id=a[0][0],p01id=v)
            sqlfunctions.perform_sql(strSql,credentials) 


## Add z types, after p01

codes = ['PRESPR01','ADEPZZ01','COREDIST','MINWDIST','MAXCDIST','MINCDIST','MAXDIST']
units = ['ULAA'    ,'UPDB'    ,'ULAA'    ,'ULAA'    ,'ULAA'    ,'ULAA'    ,'ULAA'   ]

i=0
l = len(codes)
printProgressBar(0, l, prefix = 'Progress:', suffix = 'Complete', length = 50)
for i,code in enumerate(codes):
    print(' '.join(['adding',code]))
    exist1 = session.query(Z).filter_by(identifier=codes[i]).first()
    if exist1==None:
        rec = session.query(Parameter.preflabel,     
                    Parameter.altlabel,      
                    Parameter.definition).filter(Parameter.identifier==codes[i])
        uid = session.query(P06.id).filter(P06.identifier==units[i]).all()[0][0]
        if rec.count() != 0:
            row = Z(identifier = codes[i],
                    p06_unit   = units[i], 
                    preflabel  = rec[0][0],
                    altlabel   = rec[0][1], 
                    definition = rec[0][2],
                    p06_id     = uid)
                           
            session.add(row)
        else:
            print('no entry found in parameter table for ',code)
    sleep(0.1)
    # Update Progress Bar
    printProgressBar(i + 1, l, prefix = 'Progress:', suffix = 'Complete', length = 50)

session.commit()
session.close()

print('Dont forget to set field definitions for cdi, cdi, edmo')


# several unique constraints are necessary
strSql="""
ALTER TABLE public.cdi
    ADD CONSTRAINT cdi_unique UNIQUE (cdi);"""
sqlfunctions.perform_sql(strSql, credentials)    

strSql="""
ALTER TABLE public.edmo
    ADD CONSTRAINT cu_edmo UNIQUE (code);
"""
sqlfunctions.perform_sql(strSql, credentials)    

# set proper sequences
lstsequences = ['odvfile_id_seq',
                'cdi_id_seq',
                'edmo_id_seq',
                'l20_id_seq',
                'observation_id_seq',
                'p06_id_seq',
                'p36_id_seq',
                'parameter_id_seq',
                'z_id_seq']    

lstsequences = ['cdi_id_seq',
                'edmo_id_seq',
                'observation_id_seq'] 

lstsequences = ['s27_id_seq']   


for s in lstsequences:
    strSql = """CREATE SEQUENCE public.{seq}
      INCREMENT 1
      MINVALUE 1
      MAXVALUE 9223372036854775807
      START 1
      CACHE 1;
    """.format(seq=s)
    sqlfunctions.perform_sql(strSql,credentials)
    
    tbl = s.split('_')[0]
    strSql = """alter table {t} alter column id set default nextval('{seq}');""".format(t=tbl,seq=s)
    sqlfunctions.perform_sql(strSql,credentials)


# add schema temp
strSql = """create schema if not exists temp"""
sqlfunctions.perform_sql(strSql,credentials)

### end of intitialisation (preparation of the database)