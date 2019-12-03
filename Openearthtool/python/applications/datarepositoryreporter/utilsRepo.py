# -*- coding: utf-8 -*-
"""
Created on Fri Feb 16 13:42:01 2018
Modules which contains all kind of helper functions for reporting a repository

$Id: utilsRepo.py 16027 2019-11-22 15:58:07Z c.denheijer $
$Date: 2019-11-22 07:58:07 -0800 (Fri, 22 Nov 2019) $
$Author: c.denheijer $
$Revision: 16027 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datarepositoryreporter/utilsRepo.py $

@authors:
    - Kees den Heijer (Deltares)
    - Jochem Boersma (Witteveen+Bos)
"""


# External modules
import collections
import logging
from configparser import ConfigParser
import os

# Own modules
# from datasetinfo import DataSetInfo
import datasetinfo

# GLOBALS
CFG_FILENAME = 'dataset_details.cfg'  # standard name of track change files


#%% ===========================================================================
def size2hr(fsize):
    """convert file size (int) into human readible string (GB,MB,KB,B)"""
    if fsize is None:
        return '-'
    elif fsize > 1024e6:
        return '%.1f GB'%(float(fsize)/1024e6)
    elif fsize > 1024e3:
        return '%.1f MB'%(float(fsize)/1024e3)
    elif fsize > 1024:
        return '%.1f KB'%(float(fsize)/1024)
    else:
        return '%i B'%fsize


def hr2size(fsize):
    """convert file size string, including units, to file size in bytes as float"""
    if fsize == '-':
        return 0.
    elif fsize.endswith('B'):
        val, unit = fsize.split()
        if unit == 'GB':
            return float(val) * 1024e6
        elif unit == 'MB':
            return float(val) * 1024e3
        elif unit == 'KB':
            return float(val) * 1024
        elif unit == 'B':
            return float(val)
        else:
            return 0.


def href(url, name):
    """returns a TeX-string with a clickable url"""
    return '\href{%s}{%s}' % (url.replace(' ', '%20'), name)



def escapeSVNkeywords():
    """returns a TeX-string where SVN keywords are escaped"""
    keywords = ['HeadURL', 'LastChangedDate', 'LastChangedDate', 'LastChangedBy']
    txt = '\svnidlong\n'
    for keyword in keywords:
        txt += '{$%s$}\n' % keyword
    txt += '\svnid{$%s$}\n\n' % 'Id'  #Why is 'Id' not set in the list of keywords?
    return txt


def convertPath(path):
    """for windows support"""
    if os.path.sep != '/':
        path = path.replace(os.path.sep, '/')
    return path

#%% ===========================================================================
def createTEXoverview(datasets, destfilename, skipEmpty=False):
    """
    create an overview of all changes in repository
    
    Parameters
    ----------
    - cfgfiles :: list of all fullfilepaths of LOCAL cfg-files
    - destfilename :: fullfilename of the export file, where the tables should be written
    - skipEmpty :: flag to skip rows/datasets with no (0) raw data
    
    Returns nothing, content written to disk   
    """
    
    txt = escapeSVNkeywords()
    txt += '\\begin{tabular}{ l l c c c c c c }\ndataset & domain & date & contact & volume & readme & scripts & thredds\\\\\n\hline\n'
    
    for singleSet in datasets:
        # First check whether particular file exists
#        if not os.path.exists(singleSet):
#            logging.error('{} is not available on local disk'.format(cfgfile))
#            continue
        logging.info('converting {} to table row'.format(singleSet))
        # read cfg in order to provide as input to the as_tablerow method
        cfg = ConfigParser(dict_type=collections.OrderedDict)
        cfg.read(singleSet)
        if skipEmpty and cfg['general']['raw'] == 'False':
            # skip row if flag is True and dataset has no raw data
            continue
        else:
            txt += datasetinfo.DataSetInfo(path=singleSet).as_tablerow(cfg=cfg) + '\n'

    txt += '\\end{tabular}'

    with open(destfilename, 'w') as fobj:
        fobj.write(txt)
    
    return # Nothing file written to disk



#%% Determine the name of the logfile
def startLogging(logfullfile=None, level=logging.DEBUG, header=None):
    """
    Starting the log-process. Should be called before the first logging.entry
    
    Parameters:
    -----------
    - logfullfile (str) : fullfilename of the logfile
                          setting this parameter to None (default) only prints 
                          towards console
    - level (log-depth) : logging depth of particular logger
    - header            : optional ASCII-art header for log-file

    Returns:
    --------
    nothing
    """
    
    # TODO: exception for non-existing directory?
    
    # Start the logging process of the file
    logging.basicConfig(filename=logfullfile,
                        level=level,
                        format='[%(asctime)s]; [%(levelname)-8s]; %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S',
                        )

    # Write messages towards the console, unless a StreamHandler already exists
    # Remark: a FileHandler inherits from StreamHandler. Therefore check with 
    # 'type' and not with 'isinstance'
    isStreamHandler = [type(handler) == logging.StreamHandler 
                       for handler in logging.getLogger().handlers]
    if not any(isStreamHandler):
        logging.getLogger().addHandler(logging.StreamHandler())
    
    # Put a header for the logfile, if this is given
    if header is not None:
        # Printing the header in style
        logging.info('{:=^60}'.format(''))
        logging.info('{:=^60}'.format(header.upper()))
        logging.info('{:=^60}'.format(''))

    return # nothing: the logging process is started