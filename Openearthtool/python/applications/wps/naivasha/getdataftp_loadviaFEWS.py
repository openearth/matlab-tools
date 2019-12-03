# -*- coding: utf-8 -*-
"""
Created on Tue Jun 23 16:11:28 2015

@author: hendrik_gt
"""

"""
Load data from FTP, transform it, save to csv and let FEWS load the data.
"""

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares for IWRAP
#       Gerrit Hendriksen
#
#       gerrit.hendriksen@deltares.nl
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

# $Id: odv2orm_initialize.py 11010 2014-07-30 10:03:46Z boer_g $
# $Date: 2014-07-30 12:03:46 +0200 (wo, 30 jul 2014) $
# $Author: boer_g $
# $Revision: 11010 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_initialize.py $
# $Keywords: $

import os
from ftplib import FTP
import pandas

cf = r"D:\Naivasha\tools\ftpcredentials.txt"

def credentials():
    cr = get_credentials(cf)
    return cr

def get_credentials(credentialfile):
    fdbp = open(credentialfile,'rb')
    credentials = {}
    for i in fdbp:
        item = i.split('=')
        if str.strip(item[0]) == 'url':
            credentials['url'] = str.strip(item[1])
        if str.strip(item[0]) == 'uname':
            credentials['user'] = str.strip(item[1])
        if str.strip(item[0]) == 'password':
            credentials['password'] = str.strip(item[1])
        if str.strip(item[0]) == 'writedir':
            credentials['writedir'] = str.strip(item[1])
        if str.strip(item[0]) == 'directory':
            if str.strip(item[1]) != '':
                credentials['directory'] = str.strip(item[1])
    return credentials

def downloadfromftp(crd):
    ftp = FTP(crd['url'],crd['user'],crd['password'])
    if crd['directory'] != '':
        ftp.cwd(crd['directory'])
    filenames = ftp.nlst()
    
    for filename in filenames:
        local_filename = os.path.join(crd['writedir'], filename)
        try:
            file = open(local_filename, 'wb')
            ftp.retrbinary('RETR '+ filename, file.write)
            file.close()
            # immediately transform the file to FEWS_CSV and transform Puls to mm rain (*0.2)
            statsize = os.stat(local_filename).st_size
            if statsize > 0:
                print local_filename,statsize
                transform2csv(crd,local_filename)
        except Exception:
            print "something is wrong"
        finally:
            # remove filename that has been converted
            os.unlink(local_filename)    
    ftp.quit()

def transform2csv(crd,local_filename):
    fout = local_filename.replace('.txt','.csv')
    df = pandas.read_csv(local_filename,sep='\t',index_col=False)
    df['rain']=df.Puls*0.2
    f = open(fout,'wb')
    f.write(','.join(['Location Names',local_filename.split('-')[1]])+'\r\n')
    f.write(','.join(['Location Ids',local_filename.split('-')[1]])+'\r\n')
    f.write(','.join(['Time','precipitation'])+'\r\n')
    df.to_csv(f,index=False,header=False,na_rep='NaN',columns=['Datum','rain'])
    f.close()
    
if __name__ == '__main__':   
    ## make connection to FTP and create a list of files
    crd = credentials()
    downloadfromftp(crd)
    
    # call FEWS import module
    fewsdir = crd['writedir']
    
    
    
    
def tests():    
    import glob
    for local_filename in glob.glob(r'D:\temp\ellitrack\*.txt'):
        transform2csv(crd,local_filename)





