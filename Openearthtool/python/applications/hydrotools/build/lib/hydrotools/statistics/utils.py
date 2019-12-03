# -*- coding: utf-8 -*-
"""
Created on Mon Jul 21 07:36:06 2014
Modified   Mon nov 12,2015

@author: André Hendriks (after schelle)
-------------------------------------------------------------------------------
This program uses routines from the earth2observe utility e2o_utils, which is
licensed under the Creative Commons Attribution-ShareAlike 4.0 International
Public License. The full license text of this license is available at
<http://creativecommons.org/licenses/by-sa/4.0/legalcode>
-------------------------------------------------------------------------------
"""

import logging
import logging.handlers
import ConfigParser
import os
import sys


def configGet(log,config,section,var,default):
    """
    Gets a string from a config file (.ini) and returns a default value if
    the key is not found. If the key is not found it also sets the value
    with the default in the config-file

    Input:
        - config - python ConfigParser object
        - section - section in the file
        - var - variable (key) to get
        - default - default string

    Returns:
        - string - either the value from the config file or the default value
    """


    try:
        ret = config.get(section, var)
    except:
        ret = default
        log.info("returning default (" + str(default) + ") for " + section
                 + ":" + var)
        configSet(config, section, var, str(default), overwrite=False)


    return ret

def configSet(config, section, var, value, overwrite=False):
    """
    Sets a string in the in memory representation of the config object
    Does NOT overwrite existing values if overwrite is set to False (default)

    Input:
        - config - python ConfigParser object
        - section - section in the file
        - var - variable (key) to set
        - value - the value to set
        - overwrite (optional, default is False)

    Returns:
        - nothing

    """

    if not config.has_section(section):
        config.add_section(section)
        config.set(section,var,value)
    else:
        if not config.has_option(section,var):
            config.set(section,var,value)
        else:
            if overwrite:
                config.set(section,var,value)

def iniFileSetUp(configfile):
    """
    Reads .ini file and sets default values if not present
    """
    # TODO: clean up wflwo specific stuff
    #setTheEnv(runId='runId,caseName='caseName)
    # Try and read config file and set default options
    config = ConfigParser.SafeConfigParser()
    config.optionxform = str
    config.read(configfile)
    return config

def setLogger(logfilename,loggername, level=logging.INFO):
    """
    Set-up the logging system and return a logger object. Exit if this fails
    """

    try:
        #create logger
        logger = logging.getLogger(loggername)
        if not isinstance(level, int):
            logger.setLevel(logging.DEBUG)
        else:
            logger.setLevel(level)
        ch = logging.FileHandler(logfilename,mode='w')
        console = logging.StreamHandler()
        console.setLevel(logging.DEBUG)
        ch.setLevel(logging.DEBUG)
        #create formatter
        formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        #add formatter to ch
        ch.setFormatter(formatter)
        console.setFormatter(formatter)
        #add ch to logger
        logger.addHandler(ch)
        logger.addHandler(console)
        logger.debug("File logging to " + logfilename)
        return logger
    except IOError:
        print "ERROR: Failed to initialize logger with logfile: " + logfilename
        sys.exit(2)

def closeLogger(logger, ch):
    """
    Closes the logger
    """
    logger.removeHandler(ch)
    ch.flush()
    ch.close()
    return logger, ch

