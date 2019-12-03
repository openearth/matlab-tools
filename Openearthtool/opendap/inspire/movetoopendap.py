#!/usr/bin/env python
import os
import os.path


SRC='/Volumes/trunk'
TRG='/Volumes/opendap'
OPENDAP1='http://opendap.deltares.nl/thredds/catalog/opendap'
OPENDAP2='http://opendap.deltares.nl/opendap'
OPENDAP3='http://opendap.deltares.nl/thredds/dodsC/opendap'
RAWDATA='https://repos.deltares.nl/repos/OpenEarthRawData/trunk'

# fill up todo by walking the tree
#
def printlist():
    ncdirs = []
    walker = os.walk(TRG)
    # look for all netcdf files
    for (dirname, dirnames, fnames) in walker:
        # but not in these directories
        if 'deltares' in dirnames:
            dirnames.remove('deltares')
        if 'waterbase' in dirnames:
            dirnames.remove('waterbase')
        if 'knmi' in dirnames:
            dirnames.remove('knmi')
        if 'test' in dirnames:
            dirnames.remove('test')
        if not [fname
              for fname
              in fnames
              if fname.lower().endswith('.nc')]:
            continue
        ncdirs.append(dirname)

    for dirname in ncdirs:
        # look in the src directory
        src = dirname.replace(TRG, SRC)
        # start looking up the directory tree to find an inspire file
        found = []
        while SRC in src:
            if os.path.exists(src):
                inspirefiles = [fname
                                for fname
                                in os.listdir(src)
                                if fname.lower().endswith('xml')
                                or 'inspire' in fname.lower()]
                if inspirefiles:
                    found = [os.path.join(src,fname) for fname in inspirefiles]
                    # stop looking
                    break
            # strip off the last part of the path
            src, removed = os.path.split(src)
        print " ".join(found), dirname
    
    
import xlrd
book = xlrd.open_workbook('/Users/fedorbaart/Documents/checkouts/OpenEarthTools/opendap/inspire/20110525/combined.xls')

for sheetname in ('uk', 'bg', 'es', 'nl', 'it', 'be', 'pl', 'pt', 'fr'):
    idx = book.sheet_names().index(sheetname)
    sheet = book.sheets()[idx]
    # Check sanity
    assert sheet.cell(2,2).value == 'Inspire xml file'
    assert sheet.cell(2,5).value == 'OpenDAP'
    # loop over cells
    for i in range(2,22):
        inspireurl = sheet.cell(i,2).value.strip()
        opendapurl = sheet.cell(i,5).value.strip()
        if inspireurl.startswith('http') and opendapurl.startswith('http'):
            
            opendaplocal = opendapurl.replace(OPENDAP1, TRG).replace(OPENDAP2,TRG).replace(OPENDAP3, TRG).replace('/catalog.html','').replace('contents.html','')
            if 'http' in opendaplocal:
                print '#SKIPPING', opendaplocal
                continue
            if not os.path.exists(opendaplocal):
                opendaplocal = os.path.dirname(opendaplocal)
            if os.path.isfile(opendaplocal):
                opendaplocal = os.path.dirname(opendaplocal)
            if os.path.isdir(opendaplocal):
                opendaplocal = opendaplocal
            assert os.path.exists(opendaplocal), opendaplocal

            inspirelocal = inspireurl.replace(RAWDATA, SRC)
            if not all((os.path.exists(inspirelocal), os.path.isfile(inspirelocal), os.path.exists(opendaplocal), os.path.isdir(opendaplocal))):
                print '#MANUAL', inspirelocal
            else:
                print "cp '%s' '%s'" % (inspirelocal, opendaplocal)
            
    
        



