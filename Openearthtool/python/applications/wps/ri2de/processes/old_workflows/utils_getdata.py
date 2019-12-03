# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares on behalf of RI2DE H2020 project
#       Sandra Gaytan Aguilar
#       Gerrit Hendriksen
#       sandra.gaytan@deltares.nl
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

import os
from utils import *
from utils_wcs import *
import shutil
from getdataviawcs import * 

#complete list of datasources from ISRIC can be found at http://data.isric.org/geonetwork/
#url = url to wcs (for ISRIC soilgrids250 layers http://data.isric.org/geoserver/sg250m/ows?
#layer = layer of the wcs (layer 1 silt content is SLTPPT_M_sl1_250m)
#rbbox = xmin,ymin,xmax,ymax
#name = variable name of the downloaded gtiff
#
#layername ='sg250m:CLYPPT_M_sl7_250m'
#xst = 19.833
#yst = 41.607
#xend = 20.996
#yend = 42.494
#wrkfolder = "D:\micha\Documents\Data\soil"
                                                                                                                                                                  

def getdata_soil(xst, yst, xend, yend, wrkfolder, crs=4326):
    
    geoserver_url = 'http://data.isric.org/geoserver/ows?'
    soillayer = ["CLYPPT", "SLTPPT", "SNDPPT"]
    for ly in range(3):
        for nl in range(7):
            layer = soillayer[ly] + '_M_sl' + str(nl+1) +'_250m'
            layername = 'sg250m:' + layer
            temfile = getDatafromWCS(geoserver_url, layername, xst, yst, xend, yend,crs, all_box=False)
            
            fileout = wrkfolder + '\\' + layer +'.tif'
            
            
            shutil.copy(temfile, fileout)            
    return wrkfolder



