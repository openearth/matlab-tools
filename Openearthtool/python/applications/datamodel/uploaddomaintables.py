# -*- coding: utf-8 -*-
"""
Created on Wed May 28 11:49:02 2014

preferably this should by done using xsd services provided by Aquo (check http://www.aquo.nl/Aquo/schemas/)
using a selection of tables, for now the csv versions of these tables are used

A cache of the http://domeintabellen-idsw.rws.nl/ is stored in folder domeintabellen

@author: hendrik_gt
"""

import os
from StringIO import StringIO
import pandas.io.sql as psql
import pandas
import psycopg2


def flushCopyBuffer(bufferFile,atable,credentials,cols):
    conn = psycopg2.connect("dbname={dbname} host={host} user={user} password={password}".format(**credentials))
    cur = conn.cursor()
    bufferFile.seek(0)   # Little detail where lures the deamon...
    cur.copy_from(bufferFile, atable, sep=',',columns=cols)
    cur.connection.commit()
    bufferFile.close()
    bufferFile = StringIO()
    return bufferFile

def get_credentials(credentialfile,dbase=None):
    fdbp = open(credentialfile,'rb')
    credentials = {}
    if dbase != None:
        credentials['dbname'] = dbase
    for i in fdbp:
        item = i.split('=')
        if str.strip(item[0]) == 'dbname':
            if dbase == None:
                credentials['dbname'] = str.strip(item[1])
        if str.strip(item[0]) == 'uname':
            credentials['user'] = str.strip(item[1])
        if str.strip(item[0]) == 'pwd':
            credentials['password'] = str.strip(item[1])
        if str.strip(item[0]) == 'host':
            credentials['host'] = str.strip(item[1])
    print 'credentials set for database ',credentials['dbname'],'on host',credentials['host']
    print 'for user',credentials['user']
    return credentials    
       
cf = r'D:\projecten\datamanagement\oet\applications\datamodel\pg_connectionprops.txt'
credentials = get_credentials(cf)

'''
dctdlabels is a dictionary with followint characteristics:
- key = target table in the data model
- values are:
    # csv filename with 1 header with list of values
    # list of columns to be filled in the data dabase
    # list of columns in csv to be mapped
'''

dctdtbls = {      'compartment':('domeintabellen\c2013_12_10_Compartiment.csv',('compartmentcode','compartmentnumber','compartmentdescription'),["Code","Cijfercode","Omschrijving"]),
            'measurementmethod':('domeintabellen\Waardebepalingsmethode_2014_06_02.csv',('measurementmethodtype','measurementmethoddescription','measurementmethodlink'),['Code','Omschrijving']),
                        'organ':("domeintabellen\o2013_12_10_Orgaan.csv",('organcode','organdescription','organlink'),['Code','Omschrijving']),
                     'property':('domeintabellen\Hoedanigheid_2014_05_26.csv',('propertycode','propertydescription','propertyreference'),['Code','Omschrijving']),
                      'quality':('domeintabellen\kwaliteitsoordeel.csv',('qualitycode','qualitydescription'),['Code','Omschrijving']),
                 'sampledevice':('domeintabellen\Bemonsteringsapparaat_2013_12_13.csv',('sampledevicecode','sampledevicedescription','sampledevicelink'),['Cijfercode','Omschrijving']),
                 'samplemethod':('domeintabellen\Bemonsteringsmethode_2013_12_13.csv',('samplemethodcode','samplemethoddescription','samplemethodlink'),['Code','Omschrijving']),
       'spatialreferencedevice':('domeintabellen\Plaatsbepalingsapparaat_2013_12_13.csv',('spatialreferencedevicecode','spatialreferencedevicedescription','spatialreferencedevicelink'),['Code','Omschrijving']),
                         'unit':('domeintabellen\Eenheid_2013_12_16.csv',('unitcode','unitdescription','unitdimension','unitconversionfactor','unitlink'),['Code','Omschrijving','Dimensie','Omrekenfactor'])
            }
reflink = 'http://domeintabellen-idsw.rws.nl'

for t in dctdtbls.keys():
    acsv = dctdtbls[t][0]
    if not os.path.isfile(acsv):
        print 'file not found'
        print acsv
        sys.exit()
    df = pandas.read_csv(acsv,sep=';')
    'copy of the datafram, with ontly the expexted columns'
    dfc = df[dctdtbls[t][2]]
    dfc['reference'] = reflink
    ioResult = StringIO()
    cols = dctdtbls[t][1]
    dfc.to_csv(ioResult,index=False,header=False,cols=dfc.columns)
    flushCopyBuffer(ioResult,t,credentials,cols)