#!/usr/bin/env python

"""Python script to check dead links
 in metadata from a csw enabled server."""

from owslib.csw import CatalogueServiceWeb
from owslib.wfs import WebFeatureService
from owslib.wms import WebMapService

import requests
# from lxml import etree, objectify
# from pprint import pprint

__author__ = "Maarten Pronk"
__version__ = "0.1"
__email__ = "maarten.pronk@deltares.nl"
__status__ = "Prototype"


def crawlcswlinks(url, keywords):
    csw = CatalogueServiceWeb(url)
    csw.getrecords2(constraints=keywords, maxrecords=100, esn='full')

    """Record has the following keys:
    'abstract', 'accessrights', 'alternative', 'bbox', 'bbox_wgs84', 'contributor', 'coverage', 'created', 
    'creator', 'date', 'format', 'identifier', 'identifiers', 'ispartof', 'issued', 'language', 'license', 
    'modified', 'publisher', 'rdf', 'references', 'relation', 'rights', 'rightsholder', 'source', 'spatial', 
    'subjects', 'temporal', 'title', 'type', 'uris', 'xml'"""

    metadata = {}
    protocols = set()

    for record in csw.records:
        record = csw.records[record]
        # xml = record.xml
        # ns = etree.FunctionNamespace("http://purl.org/dc/elements/1.1/")
        # ns.prefix = "gmd"
        # root = etree.fromstring(xml)

        # put urls in metadata dictionairy
        metadata[record.identifier] = {}

        for url in record.uris:
            metadata[record.identifier][url['description']] = url
            protocols.add(url['protocol'])

        # remove all namespaces
        # for elem in root.getiterator():
        #     if not hasattr(elem.tag, 'find'): continue  # (1)
        #     i = elem.tag.find('}')
        #     if i >= 0:
        #         elem.tag = elem.tag[i+1:]
        # objectify.deannotate(root, cleanup_namespaces=True)

        # write metadata
        # with open(record.identifier+'.xml','wb') as f:
            # f.write(etree.tostring(root, pretty_print=True))

    return protocols, metadata


def report(protocols, metadata):
    for uid, meta in metadata.items():
        
        print("Checking uid {}".format(uid))

        for description, link in meta.items():
            # take part before : as in WWW:LINK-
            p = link['protocol']
            
            # hacky way to check protocols
            if "OGC" in p:
                if "WFS" in p:
                    checkwfs(link['url'], p)
                elif "WMS" in p:
                    checkwms(link['url'])
                else:
                    print("Unknown OGC protocol: {} for {}".format(p, link['url']))
            elif "WWW" in p:
                checkwww(link['url'])
            else:
                print("\tUnknown protocol: {} for {}".format(p, link['url']))
                checkwww(link['url'])


def checkwfs(url, p):
    if p == "OGC:WFS-1.1.0-http-get-feature":
        # print("\t Warning: WFS get feature link")
        return checkwww(url)
    else:
        try:
            wfs = WebFeatureService(url)
            if len(list(wfs.contents)) == 0:
                print("\t WFS empty at {}".format(url))
                return False
            return True
        except Exception as e:
            print("\t{} failed with {}".format(url, e))
            return False
        else:
            return True


def checkwms(url):
    try:
        wms = WebMapService(url)
        if len(list(wms.contents)) == 0:
            print("\t WMS empty at {}".format(url))
        return True
    except Exception as e:
        print("\t{} failed with {}".format(url, e))
        return False    
    else:
        return True

def checkwww(url):
    """Quickly checks if url is dead.
    Prints information if head request returns other codes
    than allowed codes (200, 401).

    404 Not found
    """
    allowedcodes = {200:"OK", 401:"Login"}
    resp = requests.head(url)
    if resp.status_code not in allowedcodes:
        print("\t{} failed with code {}: {}".format(url, resp.status_code, resp.text))
        
        return False
    else:
        return True

if __name__ == "__main__":
    url = 'http://marineprojects.openearth.nl/geonetwork/srv/eng/csw'
    keywords = []  # search all
    report(*crawlcswlinks(url, keywords))
