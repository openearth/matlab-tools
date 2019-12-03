# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
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

# core 
import os
import configparser

# modules
import time

# Read default configuration from file
def readConfig():
	# Default config file (relative path)
	cfile=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pt_config.txt')
	cf = configparser.RawConfigParser()
	cf.read(cfile)
	plots_dir = cf.get('Bokeh', 'plots_dir')
	piwebservice_url = cf.get('PIService', 'host') # default is 'local'
	return plots_dir, piwebservice_url

# Get a unique temporary file
def GetTempFile(tempdir, typen='plot', extension='.html'):
    fname = typen + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)