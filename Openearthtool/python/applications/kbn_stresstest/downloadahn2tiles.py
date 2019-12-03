# -*- coding: utf-8 -*-
"""
Created on Wed Apr 10 12:50:36 2019

@author: wcp_W1903446
"""

from os import makedirs
from os.path import basename, join
import zipfile
import requests
import numpy as np
import os
import sqlfunctions
import subprocess
import glob

# config
downloaddir = r'/mnt/d/RoadsNL/download'
tifdir = r'/mnt/d/RoadsNL/geotiff'
buftifdr = r'/mnt/d/RoadsNL/geotiff_buffered'
baseurl = r'http://geodata.nationaalgeoregister.nl/ahn2/extract/ahn2_05m_ruw'
blad_list = r"/mnt/d/RoadsNL/kbn_stresstest/blad_list_roads.txt"

def download_extract_zip(DATA_URL, DATA_DIR, TIFDIR):
    # pretend DATA_URL could point to an archive file URL only known at runtime
    # i.e. we don't know if it's a zip, gz, etc., which is why we use 
    # unpack_archive instead of ZipFile
    ZIP_FNAME = join(DATA_DIR, basename(DATA_URL)) 
    print('Downloading', DATA_URL)
    resp = requests.get(DATA_URL)
    with open(ZIP_FNAME, 'wb') as wf:
        print("Saving to", ZIP_FNAME)
        wf.write(resp.content)                

credentials = {}
credentials['user'] = 'admin'
credentials['password'] = '&Ez3)r5{Gc'
credentials['host'] = 'al-pg010.xtr.deltares.nl'
credentials['port'] = '5432'
credentials['dbname'] = 'hobbelkaart'
credentials['port'] = 5432

strSql = """select bladnr from ahn2.bladindex_ahn2 b
join wegvakken_stresstest2018_split c on st_intersects(st_buffer(c.geom,250),b.geom)"""
#a = sqlfunctions.executesqlfetch(strSql, credentials)

i=0

#for b in np.nditer(np.unique(a)):
with open(blad_list, 'r') as fp:
    for cnt, line in enumerate(fp):
        b = line.strip()
        downloadurl = '{}/r{}.tif.zip'.format(baseurl, b)
        print('{} - {}'.format(i,b))
        print('{} - {}'.format(i,downloadurl))
        i+=1
        if not os.path.exists(os.path.join(tifdir, '{}.tif'.format(b))):
            download_extract_zip(downloadurl, downloaddir, tifdir)