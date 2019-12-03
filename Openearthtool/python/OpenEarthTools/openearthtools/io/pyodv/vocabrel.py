# vocabulary mapping
#
# Alexander Barth, 2014

import os
import os.path
import json
import urllib2
import xml.etree.ElementTree as ET
import tempfile

namespaces = {'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
              'skos': 'http://www.w3.org/2004/02/skos/core#',
              'dc': 'http://purl.org/dc/terms/',
              'rdfs': 'http://www.w3.org/2000/01/rdf-schema#',
              'grg': 'http://www.isotc211.org/schemas/grg/',
              'owl': 'http://www.w3.org/2002/07/owl#',
              'void': 'http://rdfs.org/ns/void#'}


def narrower_concepts(tree,concept_prefix,narrower_prefix):
    """returns a dictonary with all relating all concepts from the XML tree to narrower concepts"""

    concepts = tree.findall('skos:Collection/skos:member/skos:Concept',namespaces)

    mapping = {}


    for concept in concepts:
        concept_notation = concept.find('skos:notation',namespaces).text

        assert(concept_notation.startswith(concept_prefix))
        concept_notation = concept_notation[len(concept_prefix):]
        
        urls = [n.attrib['{%s}resource' % namespaces['rdf']] for n in concept.findall('skos:narrower',namespaces)]

        ids = [url[len(narrower_prefix):].replace('/','') for url in urls if url.startswith(narrower_prefix)]

        mapping[concept_notation] = ids


    return mapping

def getXMLtree(collection):
    cachdir = '/tmp/'
    path = tempfile.gettempdir()
    #print path

    if not os.path.exists(cachdir):
        print ''.join(['path ',cachdir,' does not exist and will be set to ',path]) 
        cachdir = path

    fname = os.path.join(cachdir,'cached-' + collection + '.xml')

    if not os.path.isfile(fname):
        url = 'http://vocab.nerc.ac.uk/collection/' + collection + '/current/'
        print 'Downloading',collection,'from',url
        response = urllib2.urlopen(url)
        xml = response.read()

        localFile = open(fname, 'w')
        localFile.write(xml)
        localFile.close()        
        tree = ET.fromstring(xml)
    else:
        tree = ET.parse(fname)

    return tree

def sdn_mapping(collection,tocollection):
    tree = getXMLtree(collection)

    narrower_prefix = 'http://vocab.nerc.ac.uk/collection/' + tocollection + '/current/'
    concept_prefix = 'SDN:' + collection + '::'

    mapping = narrower_concepts(tree,concept_prefix,narrower_prefix)
    return mapping
    

def sea_bbox(collection):
    tree = getXMLtree(collection)

    """returns a dictonary with all relating all concepts from the XML tree to narrower concepts"""

    concepts = tree.findall('skos:Collection/skos:member/skos:Concept',namespaces)

    mapping = {}

    for concept in concepts:
        concept_notation = concept.find('skos:notation',namespaces).text
        concept_definition = concept.find('skos:definition',namespaces).text

        try:            
            #print "concept_definition ",concept_definition,concept_notation
            #print "concept_definition ",json.loads(concept_definition)
            tmp = json.loads(concept_definition)
            mapping[concept_notation] = tmp['Spatial_Coverage']
        except:
            print "no definition for ",concept.find('skos:prefLabel',namespaces).text


    return mapping

def test():    
    mapping = sdn_mapping('P35','P01')
    #mapping = sdn_mapping('P02','P01')
    #mapping = sea_bbox('C19')
        
    #print mapping
    print 'P35 WATERTEMP corresponds to ',mapping['WATERTEMP']
    c = 0
    for k in mapping:
        for v in mapping[k]:
            c = c+1
            print c, k, v
    
    
