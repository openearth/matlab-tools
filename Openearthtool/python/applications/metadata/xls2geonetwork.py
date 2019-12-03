# -*- coding: utf-8 -*-
"""
Created on Thu Aug 28 20:04:26 2014

@author: hendrik_gt
"""

# -*- coding: utf-8 -*-
"""
history
- Created on Tue Nov 13 09:23:39 2012
- Modified on Thu Dec 06 2012
- Modified on Fri Aug 29 2014

@author: drs.Ing. Gerrit Hendriksen

Purpose: create xml structure to store in Geonetwork database

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
    - get XML definition from the geodatabase, let user choose what flavour (ISO19115 or whatever)
    - create method to store nc's
    - addition of thumbnails (automatic)
Idea's are welcome (as well as projectnumbers -:))

Tips    
!!!!Add data to a geoserver and let it be harvested by Geonetwork!!!!    
https://twiki.auscope.org/wiki/Grid/AddingDataToC3DMMPortal    
"""

import sys
import os
from datetime import datetime
from lxml import etree
from uuid import uuid4
import sqlfunctions
import pandas
import argparse


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

def addmetadata(anxml,credentials,dictvalues):
    # first request for last id, apparantly metadata id is not a serial but a regular integer
    strSql = """SELECT max(id) from metadata"""
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    anid = str(int(str(a[0]).replace('(','').replace(',)',''))+1)
    cdate = datetime.now().isoformat()
    
    strSql = """insert into metadata
                (id, uuid, schemaid, istemplate, isharvested, createdate, changedate, data, source, title, root, owner, groupowner) VALUES
                ('{id}', '{uuid}', 'iso19139', 'n', 'n', '{cd}', '{cd}', '{dataxml}', 'Deltares', '{title}', 'gmd:MD_Metadata' ,1,2
                )""".format(id=anid,uuid=dictvalues['FileID'],cd=cdate,dataxml=anxml,title=dictvalues['Dataset_Title'])
    
    amsg = sqlfunctions.perform_sql(strSql,credentials)
    
    """
    in order to be visible it is neccessary to insert a record in the metadatacateg
    for each metadataid a categoryid (at least one), check categories table for valid id's
    (categoryid < 11), 1 = map, 2 = dataset, 3 = interactive resources
    """
    strSql = """insert into metadatacateg(metadataid,categoryid) values('{fid}',2)""".format(fid=anid)
    sqlfunctions.perform_sql(strSql,credentials)

    '''todo UPDATE spatialindex'''
    strSql = """insert into spatialindex(id,the_geom)
                '{fid}',ST_MPolyFromText('MULTIPOLYGON((({w} {s}, {w} {n}, {e} {n}, {e} {s}, {w} {s})))',4326)
            """.format(fid=anid,
                       w=dictvalues['Extent_WestBoundLongitude'],
                       s=dictvalues['Extent_SouthBoundLatitude'],
                       n=dictvalues['Extent_NorthBoundLatitude'],
                       e=dictvalues['Extent_EastBoundLongitude'])
    
    return amsg

def updatemetadata(auuid,anxml,res,credentials):
    # create connection (localhost)
    fid = res[0][1]
    cd = datetime.now().isoformat()
    strSql = """update metadata set
    (changedate,  data ) =
    ('{date}','{dataxml}')
    where uuid = '{uuid}'""".format(uuid=fid,date=cd,dataxml=anxml)
    amsg = sqlfunctions.perform_sql(strSql, credentials)
    print amsg
    
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
                print(dictvalues[key])
                r[i].text = dictvalues[key]


"""
main module extracting all data from the database metadata table
"""
if __name__ == '__main__':
    adescr= """
            This procedure creates an xml file with INSPIRE Metadata and is able to load it in the geonetwork 
            table of PostgreSQL/PostGIS database.
            
            several inputs are required:
                - credential file for the database with a created geonetwork datamodel (can only be done by applying geonetwork)
                (empy file is provide with this script)
                - basexml (empty INSPIRE XML, provide)
                - xls file with metainformation (a version with 1 line filled is provided, fieldnames should not be changed)
            File with credentials should have the following parameters:
                - uname = 
                - pwd   = 
                - host  = 
                - dbname = 
            
            status = beta
            
            Dependencies:
            - lxml
            - uuid
            - sqlfunctions (https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/sql/)
            - pandas
            """
    parser = argparse.ArgumentParser(description=adescr)
    parser.add_argument('--cf','-cf', default=r'D:\projecten\datamanagement\oet\applications\metadata\pglocal.txt', type=str, help='file with credentials for access to the database')
    parser.add_argument('--xml','-xml', default=r'D:\projecten\datamanagement\oet\applications\metadata\basis.xml', type=str, help='file with empty INSPIRE Metadata in xml format')
    parser.add_argument('--xls','-xls', default=r'D:\projecten\datamanagement\oet\applications\metadata\metadata.xlsx', type=str, help='xls with proper fieldnames, see')
    parser.add_argument('--tp','-tp',default=None,type=str,help='target directory where xmls will be stored')
    parser.add_argument('--sh','--sh',default='sheet1',type=str,help='give sheetname, default is sheet1')
    args = parser.parse_args()
    
    
    cf = args.cf  #cf = r'D:\projecten\datamanagement\oet\applications\metadata\pglocal.txt'
    fxml = args.xml #fxml = r'D:\projecten\datamanagement\oet\applications\metadata\basis.xml'
    fxls = args.xls #fxls = r'D:\projecten\datamanagement\oet\applications\metadata\metadata.xlsx'
    tp = args.tp
    sh = args.sh
    if not os.path.isfile(cf):
        print ''.join(['given file with credentials does not exist, file is',cf])
        sys.exit()
    else:
        print 'credentials file', cf
    
    if not os.path.isfile(fxml):
        print ''.join(['given xml file does not exist, file is',fxml])
        sys.exit()
    else:
        print 'xml file ',fxml
    
    if not os.path.isfile(fxls):
        print ''.join(['given excel file does not exist, file is',fxls])
        sys.exit()
    else:
        print 'xls file ',fxls
    
    if not os.path.isdir(tp):
        print ''.join(['given directory does not exist, directory is',tp])
        sys.exit()
    else:
        print 'targetpath ',tp
    
    '''get credenitals'''
    credentials = sqlfunctions.get_credentials(cf,'geonetwork')
            
    '''load the xls into a Pandas Dataframe'''
    df = pandas.read_excel(fxls,sh)
    
    '''read the base xml'''
    tree = etree.parse(fxml)
    
    '''load xml templates '''
    dictvalues = set_init_values()
    pgmdict = pgmetadatadict()
    ns,xpaths = setns_paths()
    
    '''read current contenct from the database geonetwork, table metadata'''
    strSql = """select id,uuid,title from metadata 
    where istemplate = 'n'"""
    #a = executesql(strSql,uname,pwd,host,dbname)
    content = sqlfunctions.executesqlfetch(strSql,credentials)
    
    
    # if uidentifier is filled, a geonetwork record is present, if so delete the record and update,
    # if not, create an insert query   
    for r in range(df.shape[0]):
        axml = os.path.join(tp,df['title'][r]+'.xml')
        fxml = open(axml,'wb')
        dictvalues.clear()
        print 'processing',df['title'][r]
        updatemd = False
        for i in content:
            if i.count(df['title'][r]) != 0:    
                updatemd = True
        
        if not updatemd:
            auuid = str(uuid4())
            print auuid, ' for file fxml'
            dictvalues['FileID'] = auuid
        else:
            strSql = """select * from metadata 
            where title = '{t}'""".format(t=df['title'][r])
            #a = executesql(strSql,uname,pwd,host,dbname)
            res = sqlfunctions.executesqlfetch(strSql,credentials)
            dictvalues['FileID'] = res[0][1]
        
        # for each key in de pgmdict (fields in de the metadata table)
        # the dictvalues are written or overwritten
        
        for key in pgmdict.keys():
            if type(df[key][r]) is int:
                dictvalues[pgmdict[key]] = str(df[key][r])
            else:
                dictvalues[pgmdict[key]] = df[key][r]
        
        dictvalues['Distribution_Name'] = df['title'][r]
        dictvalues['keywords'] = df['keywords'][r]
        dictvalues['Extent_WestBoundLongitude'] = str(df['extent'][r].split(',')[0]).strip()
        dictvalues['Extent_NorthBoundLatitude'] = str(df['extent'][r].split(',')[1]).strip()
        dictvalues['Extent_EastBoundLongitude'] = str(df['extent'][r].split(',')[2]).strip()
        dictvalues['Extent_SouthBoundLatitude'] = str(df['extent'][r].split(',')[3]).strip()
        '''dates are in yyyymmdd format'''
        dictvalues['Extent_Time_begin'] = datetime.strptime(str(df['min_date'][r]),'%Y%m%d').isoformat()
        dictvalues['Extent_Time_end'] = datetime.strptime(str(df['max_date'][r]),'%Y%m%d').isoformat()
        dictvalues['Geographic_Reference'] = str(df['srid'][r])
        
        df['repos'][r]
        df['wfs'][r]
        df['wms'][r]
        df['wcs'][r]
    
        dictvalues['Distribution_Online_Resource'] = df['wms'][r]
        dictvalues['Distribution_Online_Source'] = df['repos'][r]

        #settext sets all the variables in the xml structure according to xpaths
        #using the dictvalues array
        settext(tree,xpaths,ns,dictvalues)
        print 'copying values to xml'        
        #convert element tree object to text
        dataxml = etree.tostring(tree,pretty_print=True)
        fxml.writelines(dataxml)
        fxml.close()
        
        # xml and some other metadata set in the geonetwork database
        if updatemd:
            anid = updatemetadata(dictvalues['FileID'],dataxml,res,credentials)
            print 'metadata updated for dataset'+df['title'][r]
        else:
            anid = addmetadata(dataxml,credentials,dictvalues)
            print 'metadata added for dataset'+df['title'][r]
            #create method to update table metadata in database schema pmr
    
        print '--------------------------------------------------------------------------'
        print ''