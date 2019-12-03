# -*- coding: utf-8 -*-
"""
Created on Wed Jul 30 19:40:13 2014

$Id: netcdf2final.py 11012 2014-07-30 19:10:10Z heijer $
$Date: 2014-07-30 12:10:10 -0700 (Wed, 30 Jul 2014) $
$Author: heijer $
$Revision: 11012 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/misc/netcdf2final.py $

@author: heijer
"""

from netCDF4 import Dataset
import argparse
import datetime
import glob
import os
import getpass

def makefinal(fname, msg, verbose):
    """
    update netcdf file to make in final
    """
    utcnow = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%MZ')
    try:
        ds = Dataset(fname, 'a')
        ds.date_modified = utcnow
        ds.date_issued = utcnow
        if hasattr(ds, 'history'):
            hist = '\n%s'%ds.history
        else:
            hist = ''
        ds.history = '%s: %s%s'%(utcnow, msg, hist)
    finally:
        ds.close()
        if verbose:
            print '%s: %s made final'%(utcnow, fname)

def walk(directory, msg, verbose):
    files = glob.glob(os.path.join(directory, '*.nc'))
    for f in files:
        makefinal(f, msg, verbose)

def getargparser():
    """
    handle input arguments
    """
    parser = argparse.ArgumentParser(description="""
    Make netCDF dataset final.
    Change attribute "processing_level" to "final"
    Change attributes "date_modified" and "date_issued" to the present UTC time.
    Add summary of changes to "history" attribute.""")
    parser.add_argument('-f', '--file', metavar='FILE', type=str, 
                       help='filename of netCDF file')
    parser.add_argument('-d', '--directory', metavar='DIRECTORY', type=str,
                       help='directory containing netCDF files')
    username = getpass.getuser()
    message = 'Processing level changed to final by %s'%username
    parser.add_argument('-m', '--message', metavar='MESSAGE', type=str,
                       help='message to be added to history attribute (default: %s)'%message,
                       default=message)
    parser.add_argument('-v', '--verbose', action='store_true', default=True,
                       help='display processed files')
    return parser
    
if __name__ == '__main__':
    args = getargparser().parse_args()
    if not args.file == None:
        makefinal(args.file, args.message, args.verbose)
    elif not args.directory == None:
        walk(args.directory, args.message, args.verbose)
    else:
        print 'NOTICE: Either FILE or DIRECTORY must be provided as input'
        getargparser().parse_args(['-h'])
