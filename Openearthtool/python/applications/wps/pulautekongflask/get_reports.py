# -*- coding: utf-8 -*-
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#       Nena Vandebroek
#       nena.vandebroek@deltares.nl
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

# modules
import os

# project specific functions
from pt_utils import *


# List a directory
def list_directory(path, dirname, reports_url):
    reports = []    
    for r in os.listdir(path):
        reports.append({'name': os.path.splitext(r)[0], 'url': reports_url+'/'+dirname+'/'+r })
    return reports

# the main should be handling the input
def get_reports():
    
    # Read configuration
    reports_dir, reports_url, plots_dir, plots_url, piwebservice_url = readConfig()

    reports = []
    for root, subdirs, files in os.walk(reports_dir):
    	for folder in subdirs:
        	reports.append({
        		'name': os.path.splitext(folder)[0], 
        		'children': list_directory(os.path.join(root, folder), folder, reports_url) 
        		})

    return reports