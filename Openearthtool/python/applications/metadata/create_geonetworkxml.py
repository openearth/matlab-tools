# -*- coding: utf-8 -*-
"""
Created on Tue Nov 13 09:23:39 2012
Last version on Thu Dec 06 2012

@author: drs.Ing. Gerrit Hendriksen

Purpose: create xml structure to store in Geonetwork database, 1st version

This script uses a standard xml file created with Geonetword and exported to a local file.
Via a dictionary and xpath dictionary the xml is adjusted. The information is derived from a 
PostgreSQL/PostGIS database and retrieves extent, list of keywords and dates. It is restricted 
to the datamodel of PMR-NCV. Furthermore there is a restriction of 10 keywords.
The function set_init_values fill a set of parameters in the dictionary with fixed values. 
The Main part of the scripts appends some dynamically generated values 
(uuid, extent,keywords,datetime values). The UUID has no status whatsoever, but can be replaced
by a OID or something. 

Last step in de main is the addition of de XML tot dat metadata table in the postgres database.
Mind this, this only works locally. The Online geonetwork (pmr-geoserver.deltares.nl/geonetwork) 
is not properly configured to show meta information. It crashes when metadata is generated. This is 
(2012-12-06) subject of investigation in cooperation with IT.

Tested with fxml = r'D:\projecten\datamanagement\Tools\basis.xml'
To do:
    - create method to store nc's
    - addition of thumbnails (automatic)
Idea's are welcome (as well as projectnumbers -:))

One of those idea's is "Voor databases die we zelf maken heb ik overigens wel wat ideeen. 
Maak een metadatatabel aan met adres gegevens per databron en kan en klare SQL's die je nodig zijn 
om bijvoorbeeld keywords te achterhalen, of de extent. Dat hoef je per database maar een keer te 
doen. Het script zou dan van die tabel gebruik kunnen maken voor het ophalen van extent, 
datum en keywords.


Tips    
!!!!Add data to a geoserver and let it be harvested by Geonetwork!!!!    
https://twiki.auscope.org/wiki/Grid/AddingDataToC3DMMPortal    
"""

from lxml import etree
from uuid import uuid4
from datetime import datetime
import psycopg2
from psycopg2 import extras
import sys
import os

"""
main module extracting all data from the database metadata table
"""
if __name__ == '__main__':

if sys.argv[1] == 'True':
    localhost = True
else:
    localhost = False

localhost = True
print localhost
#local
if localhost:
    gnuname = ""
    gnpwd   = ""
    gnhost  = ""
    gndbname= ""
    strSql = 'select data from metadata where id = 8'
    # dat zou natuurlijk ook anders kunnen, maar goed
else:
    # online geonetwork
    gnuname = ""
    gnpwd   = ""
    gnhost  = ""
    gndbname= "geonetwork"
    strSql = 'select data from metadata where id = 6' 

#get the tree from the root
#a = executesql(strSql,gnuname,gnpwd,gnhost,gndbname)
#tree = etree.fromstring(a[0][0])

# alternative is via file
fxml = r'D:\projecten\datamanagement\Tools\basis.xml'
tree = etree.parse(fxml)

# create initial dictionary an xpaths
dictvalues = set_init_values()
pgmdict = pgmetadatadict()
ns,xpaths = setns_paths()

# check if metadata table in public schema exists if not stop
uname = ""
pwd   = ""
host  = ""
dbname= ""
strSql = """select exists(select relname from pg_class where relname = 'metadata' and relkind='r');"""
arr = executesql(strSql,uname,pwd,host,dbname)

if arr[0][0] == False:
    print 'metadata table not found in database'+dbname
    sys.exit()

# derive complete table metadata
strSql = "select * from metadata"
#a = executesql(strSql,uname,pwd,host,dbname)
conn = connect_PG(uname,pwd,host,dbname)
cur = conn.cursor(cursor_factory = extras.RealDictCursor)
cur.execute(strSql)
res = cur.fetchall()


# if uidentifier is filled, a geonetwork record is present, if so delete the record and update,
# if not, create an insert query   
for r in range(len(res)):
    axml = os.path.join(r'D:\projecten\RWS\overzicht',res[r]['title']+'.xml')
    fxml = open(axml,'wb')
    dictvalues.clear()
    if not isinstance(res[r]['uidentifier'],str):
        #create unique identifier
        auuid = str(uuid4())
        dictvalues['FileID'] = auuid
        
        # derive date time
        mdcreationdate = datetime.now().isoformat().split('.')[0]
        dictvalues['Date_of_creation'] = mdcreationdate
        mdchangedate = mdcreationdate
        updatemd = False
    else:
        # create update query
        auuid = res[r]['uidentifier']
        mdcreationdate = ''
        mdchangedate = datetime.now().isoformat().split('.')[0]
        updatemd = True
    
    # for each key in de pgmdict (fields in de the metadata table)
    # the dictvalues are written or overwritten
    for key in pgmdict.keys():
        dictvalues[pgmdict[key]] = res[r][key]
    
    # 3 query columns are available in the metadata table
    # qry_spatialextent
    # qry_timeextent
    # qry_keywords
    print 'retrieving keywords for '+res[r]['title']
    arkwrds = []
    arkwrds = executesql(res[r]['qry_keywords'],uname,pwd,host,dbname)
    dictvalues['Keywords'] = cvrtarr2str(arkwrds)
    print 'number of keywords added',len
    print 'retrieving spatial extent for '+res[r]['title']        
    arrbnd = executesql(res[r]['qry_spatialextent'],uname,pwd,host,dbname)
    dictvalues['Extent_EastBoundLongitude'] = str(arrbnd[0][1])
    dictvalues['Extent_WestBoundLongitude'] = str(arrbnd[0][0])
    dictvalues['Extent_SouthBoundLatitude'] = str(arrbnd[0][2])
    dictvalues['Extent_NorthBoundLatitude'] = str(arrbnd[0][3])
    print 'spatial extent',arrbnd
    print 'retrieving temporal extent for '+res[r]['title']
    artime = executesql(res[r]['qry_timeextent'],uname,pwd,host,dbname)
    if len(artime) != 0:
        begtime = artime[0][0].isoformat()
        endtime = artime[0][1].isoformat()
    else:
        begtime = mdcreationdate
        endtime = mdcreationdate
    
    dictvalues['Extent_Time_begin'] = begtime
    dictvalues['Extent_Time_end'] = endtime
    print 'temporal extent =',begtime,'to',endtime
    
    # miscelleneous variables
    strSql = """select 'EPSG:'||trim(' ' from to_char(find_srid('public','"""+res[r]['geom_table']+"""','"""+res[r]['geom_column']+"""'),'99999D'))"""
    try:
        spref = executesql(strSql,uname,pwd,host,dbname)
    except Exception, e:
        print e.pgerror
        sys.exit()
    
    dictvalues['Geographic_Reference'] = spref[0][0]
    # check http://support.esri.com/en/knowledgebase/techarticles/detail/23278
    # to determine scale based on extent and screen resolution
    dictvalues['Distribution_Online_Resource'] = 'pmr-geoserver.deltares.nl'
    dictvalues['Distribution_Name'] = res[r]['title']
    dictvalues['Distribution_Online_Source'] = 'pmr-geoserver.deltares.nl'
    
    #settext sets all the variables in the xml structure according to xpaths
    #using the dictvalues array
    settext(tree,xpaths,ns,dictvalues)
    
    #convert element tree object to text
    dataxml = etree.tostring(tree,pretty_print=True)
    fxml.writelines(dataxml)
    fxml.close()
    
    
    # xml and some other metadata set in the geonetwork database
    if updatemd:
        updatemetadata(mdcreationdate,mdchangedate,dictvalues['FileID'],dictvalues['Dataset_Title'],dataxml)
        print 'metadata updated for dataset'+res[r]['title']
    else:
        addmetadata(mdcreationdate,mdchangedate,dictvalues['FileID'],dictvalues['Dataset_Title'],dataxml)
        print 'metadata added for dataset'+res[r]['title']
        #create method to update table metadata in database schema pmr
    print '--------------------------------------------------------------------------'
    print ''


# function converst array to a string of keywords suitable for inserting in to a dictionary
def cvrtarr2str(arrkwrds):
    if len(arrkwrds) != 0:
        keywords = zip(*arrkwrds)[0]
        for i in range(len(keywords)):
            if i == 0:
                kwrds = keywords[i]
            else:
                kwrds = kwrds +','+ keywords[i]
    else:
        kwrds = ''
    return kwrds

#"""
#next function creates a dictionary that is the link between the metadata dictionary defined
#by setns_paths and the metadata table, the keys in the dictionary correspond with the field names
#in the metadatatable
#"""
def pgmetadatadict():
    pgmddict = {
    'dataset_person':'Dataset_Contact',
    'dataset_party':'Dataset_Contact_Name',
    'dataset_phone':'Dataset_Contact_Phone',
    'dataset_address':'_Contact_Address',
    'dataset_city':'Dataset_Contact_City',
    'dataset_pobx':'Dataset_Contact_POBox',
    'dataset_country':'Dataset_Contact_Country',
    'dataset_mail':'Dataset_Contact_Email',
    'resp_person':'Responsible_Party_Person',
    'resp_party':'Responsible_Party_Organisation',
    'resp_phone':'Responsible_Party_Contact_Phone',
    'resp_address':'Responsible_Party_Contact_Address',
    'resp_city':'Responsible_Party_Contact_City',
    'resp_pobx':'Responsible_Party_Contact_POBox',
    'resp_country':'Responsible_Party_Contact_Country',
    'resp_mail':'Responsible_Party_Contact_Email',
    'title':'Dataset_Title',
    'purpose':'Dataset_Purpose',
    'abstract':'Dataset_Abstract',
    'url':'Distribution_Online_Resource',
    'vocabular':'Vocabular'}
    return pgmddict

def gainmetadataformPG():
    uname = ""
    pwd   = ""
    host  = ""
    dbname= ""
    # get data time string
    strSql = """Select min(date) as begtime,max(date) as endtime from observation"""
    
    # get info from database
    artime = executesql(strSql,uname,pwd,host,dbname)
    if len(artime) != 0:
        begtime = artime[0][0].isoformat()
        endtime = artime[0][1].isoformat()
    else:
        begtime = mdcreationdate
        endtime = mdcreationdate
    print begtime,endtime
    # get extent information from database
    strSql = """select min(st_x(thegeometry)) as minx, 
    max(st_x(thegeometry)) as maxx,
    min(st_y(thegeometry)) as miny,
    max(st_y(thegeometry)) as maxy
    from location """    
    
    arrbnd = executesql(strSql,uname,pwd,host,dbname)
    if len(arrbnd) != 0:
        eastbnd = arrbnd[0][1]
        westbnd = arrbnd[0][0]
        nrtbnd = arrbnd[0][3]
        sthbnd = arrbnd[0][2]
    else:
        eastbnd = 'unkwown'
        westbnd = 'unkwown'
        nrtbnd = 'unkwown'
        sthbnd = 'unkwown'
    
    # create list of keywords, this can be (also the other queries) be
    # detailled by various where clausules, for instance only shell, fish, birds
    strSql = """select distinct parameterdescription from observation o
    join parameter p on p.idparameter = o.idparameter
    limit 10
    """
    
    arrkwrds = executesql(strSql,uname,pwd,host,dbname)
    
    if len(arrkwrds) != 0:
        keywords = zip(*arrkwrds)[0]
        for i in range(len(keywords)):
            if i == 0:
                kwrds = keywords[i]
            else:
                kwrds = kwrds +','+ keywords[i]
    else:
        kwrds = ''
    
    dictvalues['Keywords'] = kwrds
    dictvalues['Extent_Time_begin'] = begtime
    dictvalues['Extent_Time_end'] = endtime
    dictvalues['Extent_EastBoundLongitude'] = str(eastbnd)
    dictvalues['Extent_WestBoundLongitude'] = str(westbnd)
    dictvalues['Extent_SouthBoundLatitude'] = str(sthbnd)
    dictvalues['Extent_NorthBoundLatitude'] = str(nrtbnd)
    

"""
In geonetework 1 table is of interest to be appended/adjusted, these are:
    - metadata
    - metadatacateg

Two options possible:
    1. add metadata
    2. update metadata
"""

def addmetadata(mdcreationdate,mdchangedate,auuid,atitle,anxml):
    # create connection (localhost)
    #uname = "postgres"
    #pwd   = "ghn"
    #host  = "localhost"
    #dbname= "geonetwork"
    
    # online geonetwork
    uname = ""
    pwd   = ""
    host  = ""
    dbname= ""
    # first request for last id, apparantly metadata id is not a serial but a regular integer
    try:
        conn = connect_PG(uname,pwd,host,dbname)
        cur = conn.cursor()
        strSql = 'SELECT max(id) from metadata'
        cur.execute(strSql)
        a = cur.fetchall()
    except Exception,e:
        print 'error occurred while accessing geonetwork database and requisting for metadata id'
        print e.message
        sys.exit()
    finally:
        cur.close()
        conn.close()
    
    anid = str(int(str(a[0]).replace('(','').replace(',)',''))+1)
    
    strSql = """insert into metadata
    (id,uuid,  schemaid,  istemplate,  isharvested,  createdate,  changedate,  data,  source,  title,  root,  owner,  groupowner) VALUES
    ('"""+anid+"""','"""+dictvalues['FileID']+"""','iso19139','n','n','"""+mdcreationdate+"""','"""+mdchangedate+"""','"""+dataxml+"""','"""+'Deltares'+"""','"""+dictvalues['Dataset_Title']+"""','"""+'gmd:MD_Metadata'+"""',1,2)"""
    
    amsg = commitsql(strSql,uname,pwd,host,dbname)
    
    """
    in order to be visible it is neccessary to insert a record in the metadatacateg
    for each metadataid a categoryid (at least one), check categories table for valid id's
    (categoryid < 11), 1 = map, 2 = dataset, 3 = interactive resources
    """
    strSql = 'insert into metadatacateg(metadataid,categoryid) values('+anid+',2)'
    commitsql(strSql,uname,pwd,host,dbname)

def updatemetadata(mdcreationdate,mdchangedate,auuid,atitle,anxml):
    # create connection (localhost)
    #uname = "postgres"
    #pwd   = "ghn"
    #host  = "localhost"
    #dbname= "geonetwork"
    
    # online geonetwork
    uname = ""
    pwd   = ""
    host  = ""
    dbname= ""
    
    # first request for last id, apparantly metadata id is not a serial but a regular integer
    try:
        conn = connect_PG(uname,pwd,host,dbname)
        cur = conn.cursor()
        strSql = """SELECT id from metadata where uuid ='"""+auuid+"""'"""
        cur.execute(strSql)
        a = cur.fetchall()
    except Exception,e:
        print 'error occurred while accessing geonetwork database and requisting for metadata id'
        print e.message
        sys.exit()
    finally:
        cur.close()
        conn.close()
    
    anid = str(a[0]).replace('(','').replace(',)','')
    
    strSql = """update metadata set
    (id,uuid,  schemaid,  istemplate,  isharvested,  createdate,  changedate,  data,  source,  title,  root,  owner,  groupowner) =
    ('"""+anid+"""','"""+dictvalues['FileID']+"""','iso19139','n','n','"""+mdcreationdate+"""','"""+mdchangedate+"""','"""+dataxml+"""','"""+'Deltares'+"""','"""+dictvalues['Dataset_Title']+"""','"""+'gmd:MD_Metadata'+"""',1,2)
    where uuid = '"""+auuid+"""'"""
    
    amsg = commitsql(strSql,uname,pwd,host,dbname)
    print amsg


# derive from dataset PostgreSQL/PostGIS
"""
Below functions to derive data from database PMR-NCV
"""
def connect_PG(uname,pwd,host,dbname):
    # create connection
    try:
        conn.close()
    except NameError:
        print ''
    finally:
        conn = psycopg2.connect("dbname="+dbname+" host="+host+" user="+uname+" password="+pwd)
    
    return conn
    
# define function that executes query
def executesql(strSql,uname,pwd,host,dbname):
    conn = connect_PG(uname,pwd,host,dbname)    
    cur = conn.cursor()
    arr = []
    try:
        cur.execute(strSql)
        arr = cur.fetchall()
    except Exception,e:
        conn.close()
        print e.message
    finally:
        cur.close()
        conn.close()
    return arr

# function that commits queries and returns error message (if there is one)
def commitsql(strSql,uname,pwd,host,dbname):
    conn = connect_PG(uname,pwd,host,dbname)    
    cur = conn.cursor()
    try:
        cur.execute(strSql)
        conn.commit()
    except Exception,e:
        conn.close()
    finally:
        cur.close()
        conn.close()


"""
Function creates dictionary initial values
"""

def set_init_values():
    dictvalues = {
        'FileID':'',
        'Responsible_Party_Person':'Helpdesk',
        'Responsible_Party_Organisation':'Deltares',
        'Responsible_Party_Position':'Datamanager',
        'Responsible_Party_Contact_Phone':'',
        'Responsible_Party_Contact_Address':'Rotterdamseweg 185',
        'Responsible_Party_Contact_City':'Delft',
        'Responsible_Party_Contact_POBox':'',
        'Responsible_Party_Contact_Country':'The Netherlands',
        'Responsible_Party_Contact_Email':'info@deltares.nl',
        'Date_of_creation':'',
        'Geographic_Reference':'',
        'Dataset_Title': '',
        'Dataset_Date':'',
        'Dataset_Abstract': '',
        'Dataset_Purpose':'',
        'Dataset_Contact':'',
        'Dataset_Contact_Name':'Deltares',
        'Dataset_Contact_Phone':'',
        'Dataset_Contact_Address':'Rotterdamseweg 185',
        'Dataset_Contact_City':'Delft',
        'Dataset_Contact_POBox':'',
        'Dataset_Contact_Country':'The Netherlands',
        'Dataset_Contact_Email':'info@deltares.nl',
        'Equivalent_Scale':'50000',
        'Extent_Time_begin':'',
        'Extent_Time_end':'',
        'Extent_EastBoundLongitude': '',
        'Extent_WestBoundLongitude': '',
        'Extent_SouthBoundLatitude': '',
        'Extent_NorthBoundLatitude': '',
        'Distribution_Name':'',
        'Distribution_Online_Source':'',
        'vocabular':''
        }
    return dictvalues


"""
set namespace (ns) and xpaths for use in geonetwork
"""
def setns_paths():
    ns = {'gmd':'http://www.isotc211.org/2005/gmd',
          'gco':'http://www.isotc211.org/2005/gco',
          'gml':'http://www.opengis.net/gml'}
    xpaths = {
        'FileID':'//gmd:fileIdentifier//gco:CharacterString',
        'Responsible_Party_Person':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:individualName//gco:CharacterString',
        'Responsible_Party_Organisation':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:organisationName//gco:CharacterString',
        'Responsible_Party_Position':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:positionName//gco:CharacterString',
        'Responsible_Party_Contact_Phone':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:contactInfo//gmd:CI_Contact//gmd:phone//gmd:CI_Telephone//gmd:voice//gco:CharacterString',
        'Responsible_Party_Contact_Address':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:contactInfo//gmd:CI_Contact//gmd:address//gmd:CI_Address//gmd:deliveryPoint//gco:CharacterString',
        'Responsible_Party_Contact_City':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:contactInfo//gmd:CI_Contact//gmd:address//gmd:CI_Address//gmd:city//gco:CharacterString',
        'Responsible_Party_Contact_POBox':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:contactInfo//gmd:CI_Contact//gmd:address//gmd:CI_Address//gmd:postalcode//gco:CharacterString',
        'Responsible_Party_Contact_Country':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:contactInfo//gmd:CI_Contact//gmd:address//gmd:CI_Address//gmd:country//gco:CharacterString',
        'Responsible_Party_Contact_Email':'//gmd:contact//gmd:CI_ResponsibleParty//gmd:contactInfo//gmd:CI_Contact//gmd:address//gmd:CI_Address//gmd:electronicMailAddress//gco:CharacterString',
        'Date_of_creation':'//gmd:dateStamp//gco:DateTime',
        'Geographic_Reference':'//gmd:referenceSystemInfo//..//gmd:code//gco:CharacterString',
        'Dataset_Title': '//gmd:identificationInfo//gmd:citation//gmd:title//gco:CharacterString',
        'Dataset_Date':'//gmd:identificationInfo//..//gmd:date//gco:DateTime',
        'Dataset_Abstract': '//gmd:identificationInfo//gmd:abstract//gco:CharacterString',
        'Dataset_Purpose':'//gmd:identificationInfo//gmd:purpose//gco:CharacterString',
        'Dataset_Contact':'//gmd:identificationInfo//gmd:pointOfContact//gco:CharacterString',
        'Dataset_Contact_Name':'//gmd:identificationInfo//gmd:organisationName//gco:CharacterString',
        'Dataset_Contact_Phone':'//gmd:identificationInfo//gmd:pointOfContact//gmd:voice//gco:CharacterString',
        'Dataset_Contact_Address':'//gmd:identificationInfo//gmd:pointOfContact//gmd:deliveryPoint//gco:CharacterString',
        'Dataset_Contact_City':'//gmd:identificationInfo//gmd:pointOfContact//gmd:city//gco:CharacterString',
        'Dataset_Contact_POBox':'//gmd:identificationInfo//gmd:pointOfContact//gmd:postalcode//gco:CharacterString',
        'Dataset_Contact_Country':'//gmd:identificationInfo//gmd:pointOfContact//gmd:country//gco:CharacterString',
        'Dataset_Contact_Email':'//gmd:identificationInfo//gmd:pointOfContact//gmd:electronicMailAddress//gco:CharacterString',
        'Keywords': '//gmd:descriptiveKeywords//..//gmd:keyword//gco:CharacterString',
        'Vocabular':'//gmd:descriptiveKeywords//..//gmd:MD_Keywords//gmd:type//gmd:MD_KeywordTypeCode',
        'Extent_Time_begin':'//gml:beginPosition',
        'Extent_Time_end':'//gml:endPosition',
        'Extent_EastBoundLongitude': '//gmd:extent//gmd:eastBoundLongitude//gco:Decimal',
        'Extent_WestBoundLongitude': '//gmd:extent//gmd:westBoundLongitude//gco:Decimal',
        'Extent_SouthBoundLatitude': '//gmd:extent//gmd:southBoundLatitude//gco:Decimal',
        'Extent_NorthBoundLatitude': '//gmd:extent//gmd:northBoundLatitude//gco:Decimal',
        'Distribution_Online_Resource':'//gmd:distributionInfo//gmd:onLine//gmd:URL',
        'Distribution_Name':'//gmd:distributionInfo//gmd:onLine//gmd:name//gco:CharacterString',
        'Distribution_Online Source':'//gmd:distributionInfo//gmd:MD_DigitalTransferOptions//gmd:onLine//gmd:CI_OnlineResource//gmd:linkage//gmd:URL',
        'Equivalent_Scale':'//gmd:spatialResolution//gmd:MD_Resolution//gmd:equivalentScale//gmd:MD_RepresentativeFraction//gmd:denominator//gco:Integer'
        }
    return ns,xpaths

"""
Function sets value in xml tree if key is found within xpaths dictionary
"""
def settext(tree,xpaths,ns,dictvalues):
    for key in dictvalues.keys():
        apath = xpaths.get(key)
        if apath != None:
            r = tree.xpath(apath,namespaces=ns)
            for i in range(len(r)):
                r[i].text = dictvalues[key]
