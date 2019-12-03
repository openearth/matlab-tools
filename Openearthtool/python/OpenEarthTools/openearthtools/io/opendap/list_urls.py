# -*- coding: utf-8 -*-
"""
Created on Tue Jan 31 10:46:00 2012

@author: Hessel Winsemius
"""

"""
list_urls.py returns a list of urls, based on an url link to a OPeNDAP catalog.xml

Description:

Status:
    Still under construction by Sperna-Weiland, Schellekens, Van Verseveld and Winsemius

 Copyright notice
  --------------------------------------------------------------------
  Copyright (C) 2011 Deltares
      H.(Hessel) C. Winsemius

      hessel.winsemius@deltares.nl

      Rotterdamseweg 185
      Delft
      The Netherlands

  This function is free software under the PBL-Deltares MoU: redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation, either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library. If not, see <http://www.gnu.org/licenses/>.
  --------------------------------------------------------------------

 Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
Created: 04 Nov 2010
Created and tested with python 2.6.5.4

$Id: list_urls.py 8903 2013-07-09 09:51:58Z boer_g $
$Date: 2013-07-09 02:51:58 -0700 (Tue, 09 Jul 2013) $
$Author: boer_g $
$Revision: 8903 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/opendap/list_urls.py $
$Keywords: $

"""

import os, glob
import logging
import logging.handlers
import urllib
import urlparse
from xml.dom import minidom
from opendap import opendap, pydaptonetCDF4
from pydap.client import open_url
from pylab import *

def list_urls(inputLoc):
    """
    Generate list of OPeNDAP links to NetCDF files from a catalog.xml.
    This function does not yet take care of recursive catalog entries.
    input:
        inputLoc:   string, url to catalog.xml on OPeNDAP server
    output:
        inputFiles: List of strings, urls to OPeNDAP links
    """
    urlparseObj     = urlparse.urlsplit(inputLoc)
    urlNetLoc       = urlparseObj.scheme + '://' + urlparseObj.netloc
    urlObj          = urllib.urlopen(inputLoc)
    domObj          = minidom.parse(urlObj)
    services        = domObj.getElementsByTagName('service')
    for service in services:
        if service.getAttribute('serviceType').lower() == 'opendap':
            baseUrl = urlNetLoc + service.getAttribute('base')
    childObjs       = domObj.getElementsByTagName('dataset')
    inputFiles      = [] # create empty list
    for childObj in childObjs:
        childUrl    = childObj.getAttribute('urlPath')
        if childUrl != '':
            inputFiles.append(baseUrl + childUrl)
    inputFiles.sort()
    return inputFiles
