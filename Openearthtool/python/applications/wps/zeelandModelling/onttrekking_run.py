# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerrit Hendriksen, Joan Sala
#
#       gerrit.hendriksen@deltares.nl, joan.salacalero@deltares.nl
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

# $Id: onttrekking_run.py 13784 2017-10-04 06:50:02Z sala $
# $Date: 2017-10-04 08:50:02 +0200 (Wed, 04 Oct 2017) $
# $Author: sala $
# $Revision: 13784 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/zeeland/onttrekking_run.py $
# $Keywords: $

# Core
import os
import logging
import subprocess
import tempfile

# Local
from coords import *
import raster_func as ra

"""
NHI online modelling input/output functions
- create ouputs
- connect to GeoServer
"""

class onttrekking_RUN():

    # Create runner with configuration
    def __init__(self, c): 
        self.config = c   
      
    # Run model via Process
    def runModel(self, csvfile, tmpdir):        
        exedir = os.path.dirname(self.config['ONTSCRIPT'])
        args = ['python.exe', self.config['ONTSCRIPT'], tmpdir]

        # Change directory
        try:
            os.chdir(exedir)
        except:
            logging.error('Cannot change directory to specified location {}'.format(exedir))

        # Run model
        logging.info('''EXEC [cmd]: {}'''.format(args))
        pro = subprocess.Popen(args,                                 
                             bufsize=0,
                             universal_newlines=True,                             
                             cwd=tmpdir,
                             stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT)

        while pro.poll() is None:
            line = pro.stdout.readline()
            if line != "": logging.info(line)

        return os.path.join(tmpdir, 'output.tif') # the folder name is unique, outputs fixed
        
    # Temporary dir setup
    def getTempDir(self):
        # Temporary folder setup
        tmpdir=tempfile.mkdtemp()
        return tmpdir

    # Define extraction file
    def setupInputCSV(self, tmpdir, x, y, t, Q, Tf, Lf, Ss, Sy, z):
       # User inputs
        content = 'horizontal coordinate (RD);vertical coordinate (RD);time;volumetric discharge rate;top filter relative to ground level; length of the filter; (elastic) specific storage ;specific yield\n' 
        content+= 'm NAP;m;m;d;m^3/d;m;m;m^-1;-\n' 
        content+= 'x;y;t;Q;Tf;Lf;Ss;Sy;z\n' 
        content+= '{};{};{};{};{};{};{};{}\n'.format(x, y, t, Q, Tf, Lf, Ss, Sy, z)

        # Write run file
        csvfile = os.path.join(tmpdir, 'input.csv')
        logging.info('''WRITING [csvfile]: {}'''.format(csvfile))
        with open(csvfile, "w") as csv:
            csv.write(content)
        return csvfile      
