# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Gerrit Hendriksen
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

"""RI2DE configuration parser

   Set of functions that check the existence of configfiles.
   For each threat config files are created with references to datasets and classes.
"""

import os
import tempfile
import configparser

# first get conifgdir, this should be a know directory for default
CONFIG_DIR = 'D:\projecten\eu\RI2DE\wps\data' #os.path.dirname(os.path.realpath(__file__))

def checkconfig(threatcfg):
    """Checks the existence of a configuration file
    
       input:
           - configdir = global variable
           - threatcfg = configuration file of specified threat
       output:
           - error in case file does not exist or conffile
    """
    conffile = os.path.join(CONFIG_DIR,threatcfg)
    if not os.path.isfile(conffile):
        return False
    else:
        return conffile

def maketempdir():
    """Make tempdir function
    
       not yet implemented, is already thought of in case users wants specific 
       classes or sources changed
    
    """
    dirpath = tempfile.mkdtemp()
    return dirpath

# checks and reads the configuration for the threat erosion embankment due to proximity of rivers
def erosionembankmentsproximityconfig():
    """Reads configuration file for threat erosion embankment due to proximity of rivers
    
       Output:
           - dictionary with key value pairs
    """
    threatcfg = 'config_erosionembankmentsproximityrivers.cfg'
    conffile = checkconfig(threatcfg)
    if conffile is False:
        return False # and do something in the frontend, because continuation is not possible

    # read the config and store objects in a dictionary
    cf = configparser.RawConfigParser()  
    cf.read(conffile)
    conf_dict = dict()
    # Soil data service
    conf_dict['GEOSERVER'] = cf.get('soildata', 'geoserver')
    conf_dict['BASELAYER'] = cf.get('soildata', 'baselayer')
    conf_dict['NUMLAYERS'] = cf.get('soildata', 'nolayers')
    conf_dict['SANDLAYER'] = cf.get('soildata', 'sandlayer')
    conf_dict['CLAYLAYER'] = cf.get('soildata', 'claylayer')
    conf_dict['SILTLAYER'] = cf.get('soildata', 'siltlayer')
    # threat parameter elevation
    #[elevation]
    conf_dict['DEMSOURCE'] = cf.get('elevation', 'demsource')
    conf_dict['DEMBASELAYER']  = cf.get('elevation', 'dembaselayer')
    conf_dict['DEMLAYER']  = cf.get('elevation', 'demlayer')
    # threat parameter closenesstowatercoarse
    conf_dict['closenesstowatercoarse0'] = cf.get('closenesstowatercourse','0')
    conf_dict['closenesstowatercoarse1'] = cf.get('closenesstowatercourse','1')
    conf_dict['closenesstowatercoarse2'] = cf.get('closenesstowatercourse','2')
    #threat parameter slopeembankment
    conf_dict['slopeembankment0'] = cf.get('slopeembankment','0')
    conf_dict['slopeembankment1'] = cf.get('slopeembankment','1')
    conf_dict['slopeembankment2'] = cf.get('slopeembankment','2')
    #measurement slopeprotection
    conf_dict['slopeprotection0'] = cf.get('slopeprotection','0')
    conf_dict['slopeprotection1'] = cf.get('slopeprotection','-1')
    conf_dict['slopeprotection2'] = cf.get('slopeprotection','-2')

    return conf_dict

# for the threat erosion of embankments due to runoff
def erosionembankmentsrunoffconfig():
    """Reads configuration file for threat erosion embankment due to runoff0
    
       Output:
           - dictionary with key value pairs
    """
    threatcfg = 'config_erosionembankmentsrunoff.cfg'
    conffile = checkconfig(CONFIG_DIR,threatcfg)
    if conffile is False:
        return False # and do something in the frontend, because continuation is not possible

    # read the config and store objects in a dictionary
    cf = configparser.RawConfigParser()  
    cf.read(conffile)
    conf_dict = dict()
