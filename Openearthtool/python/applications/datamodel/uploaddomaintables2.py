# -*- coding: utf-8 -*-
"""
Improved sql & domaintables loader, providing a more general framework.
Framework later hoped to be used in importing various data formats.

@author: m.j.pronk@student.tudelft.nl
"""
import csv
import psycopg2
from sqlalchemy import *
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base


creds = {"host": "localhost", "db": "testdb", "user": "epta"}
filename = "MDM-Model.sql"

#TODO make automatic download/update of tables from WDSL service http://domeintabellen-idsw-ws.rws.nl/DomainTableWS.svc

dct = {           'compartment':('domeintabellen\c2013_12_10_Compartiment.csv',('compartmentcode','compartmentnumber','compartmentdescription'),["Code","Cijfercode","Omschrijving"]),
            'measurementmethod':('domeintabellen\Waardebepalingsmethode_2014_06_02.csv',('measurementmethodtype','measurementmethoddescription','measurementmethodlink'),['Code','Omschrijving']),
                        'organ':("domeintabellen\o2013_12_10_Orgaan.csv",('organcode','organdescription','organlink'),['Code','Omschrijving']),
                     'property':('domeintabellen\Hoedanigheid_2014_05_26.csv',('propertycode','propertydescription','propertyreference'),['Code','Omschrijving']),
                      'quality':('domeintabellen\kwaliteitsoordeel.csv',('qualitycode','qualitydescription'),['code','omschrijving']),
                 'sampledevice':('domeintabellen\Bemonsteringsapparaat_2013_12_13.csv',('sampledevicecode','sampledevicedescription','sampledevicelink'),['Cijfercode','Omschrijving']),
                 'samplemethod':('domeintabellen\Bemonsteringsmethode_2013_12_13.csv',('samplemethodcode','samplemethoddescription','samplemethodlink'),['Code','Omschrijving']),
       'spatialreferencedevice':('domeintabellen\Plaatsbepalingsapparaat_2013_12_13.csv',('srdevicecode','srdevicedescription','srdevicelink'),['Code','Omschrijving']),
                         'unit':('domeintabellen\Eenheid_2013_12_16.csv',('unitcode','unitdescription','unitdimension','unitconversionfactor','unitlink'),['Code','Omschrijving','Dimensie','Omrekenfactor'])
                         }

dct2 = {    'taxon_worms':('domeintabellen\parameter_worms.csv',('parameterdescription','aphiaid','scientificname','authority','status','aphiaid_accepted','kingdom','phylum','class','order','family','genus','subgenus','species','subspecies','alt_id','alt_code','standard','referencelink','localname','iddonar','donarname'
),['parameterdescription','aphiaid','scientificname','authority','status','aphiaid_accepted','kingdom','phylum','class','order','family','genus','subgenus','species','subspecies','alt_id','alt_code','standard','referencelink','localname','iddonar','donarname'
]),
            'parameter_chemical':('domeintabellen\Parameter_2014_05_19.csv',('parameterdescription','code','casnumber','sikbid','referencelink'),['Omschrijving','Code','CASnummer','SIKBid'])
            }


def load_domain_tables(dct):
    """Load all domaintables and load them into db by calling write_orm.
    """
    for tablename in dct:
#        print tablename
        csvname, fieldnames, ff = dct[tablename]
        csvname = csvname.replace("\\", "/")  # only for Linux path!
        fieldnames = list(fieldnames)
        dt = load_csv(csvname, ff, fieldnames)
        write_orm(tablename, dt)


def det_delimit(csvname):
    """Returns possible delimiter string from a csvfile.
    Function is not necessary when using csv.Sniffer().
    """
    with open(csvname, 'r') as f:
        header = f.readline()
        if header.find(';') != -1:
            return ";"
        elif header.find(',') != -1:
            return ","
        else:
            return ","  # assume default comma


def load_csv(csvname, ff, fieldnames):
    """Load csv with fieldnames and returns array with dicts.
    """
    with open(csvname, "r") as csvfile:
        output = []
        dt = csv.DictReader(csvfile, delimiter=det_delimit(csvname),
                            quotechar='"')
        for row in dt:
            new_row = {}
            for i, f in enumerate(ff):
                if row[f]:
                    new_row[fieldnames[i]] = row.pop(f)
            if len(fieldnames) > len(ff):
                new_row[fieldnames[-1]] = "http://domeintabellen-idsw.rws.nl"
            output.append(new_row)
#            print new_row
        return output


def load_sql(creds, filename):
    """Load sql file into database defined by credentials dictionary.
    """
    con = None
    try:
        con = psycopg2.connect("dbname={db} user={user} password={user}".format(**creds))
        con.autocommit = True
        cur = con.cursor()
        cur.execute(open(filename, "r").read())

    except psycopg2.DatabaseError, e:
        print 'Error {}'.format(e)

    finally:
        if con:
            con.close()


def write_orm(tablename, dt):
    """Write provided domaintable into the database table.
    """
    print tablename
    engine = create_engine('postgresql://postgres:postgres@localhost/testdb', echo=False)
    Session = sessionmaker(bind=engine)
    session = Session()
    Base = declarative_base()
    Base.metadata.create_all(engine)

    # Reflect database table
    class Test(Base):
        __table__ = Table(tablename, Base.metadata,
                          autoload=True, autoload_with=engine)

    table = []
    for row in dt:
        table.append(Test(**row))
    session.add_all(table)
    session.commit()

#load_sql(creds,filename)
load_domain_tables(dct2)
