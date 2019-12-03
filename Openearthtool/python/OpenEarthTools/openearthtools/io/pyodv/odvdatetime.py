__version__ = "$Revision: 11667 $"

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

# $Id: odvdatetime.py 11667 2015-02-03 18:41:56Z santinel $
# $Date: 2015-02-03 10:41:56 -0800 (Tue, 03 Feb 2015) $
# $Author: santinel $
# $Revision: 11667 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odvdatetime.py $
# $Keywords: $

import datetime
import numpy, jdcal # Julian calendar

def iso2datetime(s):    
    """parses ODV datetime string to datetime. 
    ODV prescribes ISO8601 yyyy-mm-ddTHH:MM:SS:000 but many
    files do not obey this exactly, and use for instance yyyy mm dd HH:MM:SS"""
    
# cannot handle wrong dates like     2002-03-23 06:10:00
#    yyyy   = int(s.split('-')[0])
#    mm     = int(s.split('-')[1])
#    dd     = int(s.split('-')[2].split('T')[0])
#    HH     = int(s.split('-')[2].split('T')[1].split(':')[0])
#    MM     = int(s.split('-')[2].split('T')[1].split(':')[1])
#    SS     = int(s.split('-')[2].split('T')[1].split(':')[2].split('.')[0])

    yyyy = int(s[0:4])
    mm   = 0
    dd   = 0
    HH   = 0
    MM   = 0
    SS   = 0
    # nest to handle shorter ISO 8601 strings
    if len(s) > 5:
     mm     = int(s[5:7])
     if len(s) > 8:
       dd     = int(s[8:10])
       if len(s) > 11:
         HH     = int(s[11:13])
         if len(s) > 14:
           MM     = int(s[14:16])
           if len(s) > 17:
             SS     = int(s[17:19])
    
    try:
     #msec  = int(s.split('-')[2].split('T')[1].split(':')[2].split('.')[1]) # 2006-2007 VOS files have : where there should be a .
     msec  = int(s[20:])
    except:
     msec  = 0
    
    return datetime.datetime(yyyy,mm,dd,HH,MM,SS,msec)

def julian2datetime(jd):
    """parses ODV Julain date number to datetime."""
    
    [yyyy,mm,dd,f]=jdcal.jd2gcal(jd,0)
    
    HH   = int(numpy.floor(f*24))
    MM   = int(numpy.floor((f*24-HH)*60))
    SS   = int(numpy.floor(((f*24-HH)*60-MM)*60))
    msec = int((((f*24-HH)*60-MM)*60-SS)*1000)
    
    return datetime.datetime(yyyy,mm,dd,HH,MM,SS,msec)
