"""
Package to work with BODC controlled vocabularies hosted at http://vocab.ndg.nerc.ac.uk.
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

# $Id: bodc.py 10909 2014-06-30 13:31:34Z boer_g $
# $Date: 2014-06-30 06:31:34 -0700 (Mon, 30 Jun 2014) $
# $Author: boer_g $
# $Revision: 10909 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/bodc.py $
# $Keywords: $

import xml.etree.ElementTree as ET

def fromfile_list(xmlfile):
    """
read vocabulary from xml file, which can be obtained via non-RESTfull url
>> import urllib
>> urllib.urlretrieve("http://vocab.nerc.ac.uk/list/P01/current/", 'P06.xml')
Note: we recommend to use RESTfull fromfile_collection() instead.
    """

    D = {}
    D["identifier"] = []
    D["altLabel"]   = []
    D["prefLabel"]  = []
    D["definition"] = []
    D["date"]       = []
   #D["minorMatch"] = [] # TODO
   #D["broadMatch"] = [] # TODO
    
    tree = ET.parse(xmlfile)
    RDF  = tree.getroot()
    for Concept in RDF:
        identifier = Concept.find("{http://www.w3.org/2004/02/skos/core#}externalID").text
       #print(str(i)+':'+identifier)
        D["identifier"].append(identifier.split(':')[3])
        D["altLabel"].append(Concept.find("{http://www.w3.org/2004/02/skos/core#}altLabel").text)
        D["prefLabel"].append(Concept.find("{http://www.w3.org/2004/02/skos/core#}prefLabel").text)
        D["definition"].append(Concept.find("{http://www.w3.org/2004/02/skos/core#}definition").text)
        D["date"].append(Concept.find("{http://purl.org/dc/elements/1.1/}date").text)
        
        #lst = Concept.find("{http://www.w3.org/2004/02/skos/core#}broadMatch")
        #lst = Concept.find("{http://www.w3.org/2004/02/skos/core#}minorMatch")

        #for att in Concept:
        #    print att.tag
    return D
    
def fromfile_collection(xmlfile):
    """
read vocabulary from xml file, which can be obtained via RESTfull url
>> import urllib
>> urllib.urlretrieve ("http://vocab.nerc.ac.uk/collection/L20/current/", 'L20.xml')
    """

    D = {}
    D["identifier"] = []
    D["altLabel"]   = []
    D["prefLabel"]  = []
    D["definition"] = []
    D["date"]       = []
   #D["minorMatch"] = [] # TODO
   #D["broadMatch"] = [] # TODO
    
    tree = ET.parse(xmlfile)
    RDF = tree.getroot()
    
    for Collection in RDF:
        # DO NOT USE for member in Collection: # Collection also has some metadata elements, so get them by name "member"
        for member in Collection.findall('{http://www.w3.org/2004/02/skos/core#}member'):
            for Concept in member:
                #for att in Concept:
                #   print att.tag                
                try: # P01                
                    identifier = Concept.find("{http://purl.org/dc/elements/1.1/}identifier").text
                    D["date"].append(Concept.find("{http://purl.org/dc/elements/1.1/}date").text)
                except: # L20
                    identifier = Concept.find("{http://purl.org/dc/terms/}identifier").text
                    D["date"].append(Concept.find("{http://purl.org/dc/terms/}date").text)
                D["identifier"].append(identifier.split(':')[3])    
                D["altLabel"].append(Concept.find("{http://www.w3.org/2004/02/skos/core#}altLabel").text)
                D["prefLabel"].append(Concept.find("{http://www.w3.org/2004/02/skos/core#}prefLabel").text)
                D["definition"].append(Concept.find("{http://www.w3.org/2004/02/skos/core#}definition").text)

    return D          
    
#def fromsoap:
    """
resolve vocabulary term against soap web service
    """

    # Created on Thu Jan 23 13:05:40 2014
    # @author: hendrik_gt
    # As you see, this is heavily under construction.
    #from suds.client import Client
    #url = 'http://vocab.nerc.ac.uk/vocab2.wsdl'
    #client = Client(url)
    #uris = 'http://vocab.nerc.ac.uk/collection/P01/current/,http://vocab.nerc.ac.uk/collection/P011/current/,http://vocab.nerc.ac.uk/collection/P061/current/'
    #result = client.service.SearchVocab('*salinity*',False,'definition',10,True,uris,'all')
    #def print_results(result):
    #    if result[1] != 0:
    #        for i in range(len(result[3][0])):
    #            print 'concept    =',result[3][0][i][1]
    #            print 'label      =',result[3][0][i][2][0][0]
    #            print 'definition =',result[3][0][i][4][0][0]
    #            print 'member of  =',result[3][0][i][8][0][0]
    #            print 'identifier =',result[3][0][i][9]
    #            print '------------------------------------------'
    #            print ' '
    #    else:
    #        print 'no results found'
    #print_results(result)
    #
    ## TEST
    #result = client.service.getCollections
    #result = client.service.searchVocab('listKey=http://vocab.nerc.ac.uk/collection/P021/current/current&searchTerm=*emperature*')
    #result = client.service.GetConceptScheme('http://vocab.nerc.ac.uk/scheme/ICANCOERO/')
    #result = client.service.GetSchemes()
    #result = client.service.getConceptCollection('http://vocab.nerc.ac.uk/collection/A01/','all')
    #result = client.service.GetCollections
    #test = 'http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/searchVocab?listKey=http://vocab.nerc.ac.uk/collection/P021/current/&searchTerm=*emperature*'
    
if __name__ == '__main__':
    """
test 4 common vocabularies fort SeaDataNet/EMODnet chemistry
    """

## Get files cache of vocabs

    import urllib
    items =['P35','P06','P01','L20']
    for item in items:
        if not(os.path.isfile(item + '.xml')):
           urllib.urlretrieve("http://vocab.nerc.ac.uk/collection/"+item+"/current/", item+'.xml')

## Read files cache of vocabs

    xmlfile = r'L20.xml'
    D = fromfile_collection(xmlfile)    
    print(xmlfile + ': '+ str(len(D["identifier"])) + ' items found')

    xmlfile = r'P350.xml'
    D = fromfile_collection(xmlfile)    
    print(xmlfile + ': '+ str(len(D["identifier"])) + ' items found')

    xmlfile = r'P06.xml'
    D = fromfile_collection(xmlfile)    
    print(xmlfile + ': '+ str(len(D["identifier"])) + ' items found')

    xmlfile = r'P01.xml' # takes longer, old format
    D = fromfile_collection(xmlfile)    
    print(xmlfile + ': '+ str(len(D["identifier"])) + ' items found')
    
