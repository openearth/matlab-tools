# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Ioanna Micha
#       ioanna.micha@deltares.nl
#       Joan Sala
#       joan.salacalero@deltares.nl
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_custom.py $
# $Keywords: $

import owslib
from owslib import iso
from owslib.csw import CatalogueServiceWeb
from owslib.fes import PropertyIsEqualTo, PropertyIsLike
from owslib import fes
from owslib.namespaces import Namespaces
import json

# from processes.utils import *
from processes.utils import *

# take the keyword list and create a filter object
def createFilterList(keywords, bbox):
    # Set the bbox query
    bbox_filter = None
    if bbox is not None:
        bbox_filter = fes.BBox(bbox)

    # set the keyword query
    kw = dict(wildCard='*',
              escapeChar='\\',
              singleChar='?',
              propertyname='apiso:AnyText')
    keyword_filter = None
    if len(keywords) > 0:
        if len(keywords) > 1:

            ks = []
            for i in keywords:
                ks.append(fes.PropertyIsLike(literal='{0}'.format(i), **kw))

            keyword_filter = fes.Or(operations=ks)
        elif len(keywords) == 1:  # one keyword
            keyword_filter = PropertyIsLike("apiso:AnyText", "*%s*" % keywords[0], wildCard="*")

    filters = [_f for _f in [keyword_filter, bbox_filter] if _f]
    if len(filters) == 1:
        return filters
    elif len(filters) > 1:
        return (fes.And(operations=filters))


# connect to the csw catalogue server and takes the records according to the filter list
def get_csw_records(csw_urls_list, filterList):
    print (csw_urls_list)
    recordsList = []
    
    for csw_url in csw_urls_list:
	    
		
        csw = CatalogueServiceWeb(csw_url, skip_caps=True)
        csw.getrecords2(constraints=[filterList], typenames='csw:Record', esn='full',
                    outputschema=Namespaces.namespace_dict['gmd'], maxrecords=50)
        
        print csw_url
        for key, rec in csw.records.items():
            OnlineInfo = extract_online_info(rec)
        
            if OnlineInfo == None:
                continue
            record = dict()
            recOwsurl = OnlineInfo[0]
            recLayerName = OnlineInfo[1]
            recTitle = extract_data_info(rec)[0]
            recAbstract = extract_data_info(rec)[1]
            record["title"] = recTitle
            record["abstract"] = recAbstract
            record["owsurl"] = recOwsurl
            record["layername"] = recLayerName
            if not any((record["owsurl"]==d["owsurl"] and record["layername"]==d["layername"] ) for d in recordsList):
                recordsList.append(record)

    return recordsList

def extract_data_info(record):
    for obj_MD_DataIdent in record.identificationinfo:
        return obj_MD_DataIdent.title, obj_MD_DataIdent.abstract

# extract the wms endpoint from the record objects
def extract_online_info(record):
    for obj_CI_Online in record.distribution.online:
        if obj_CI_Online.protocol == "OGC:WCS" or obj_CI_Online.protocol == "OGC:WMS":
           
            return obj_CI_Online.url, obj_CI_Online.name

def json_loads_byteified(json_text):
    return _byteify(
        json.loads(json_text, object_hook=_byteify),
        ignore_dicts=True
    )

def _byteify(data, ignore_dicts=False):
    # if this is a unicode string, return its string representation
    if isinstance(data, unicode):
        return data.encode('utf-8')
    # if this is a list of values, return list of byteified values
    if isinstance(data, list):
        return [_byteify(item, ignore_dicts=True) for item in data]
    # if this is a dictionary, return dictionary of byteified keys and values
    # but only if we haven't already byteified it
    if isinstance(data, dict) and not ignore_dicts:
        return {
            _byteify(key, ignore_dicts=True): _byteify(value, ignore_dicts=True)
            for key, value in data.iteritems()
        }
    # if it's anything else, return it in its original form
    return data


