# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
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

# $Id: emisk_geology.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-29 23:21:10 -0800 (Mon, 29 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/emisk_geology.py $
# $Keywords: $

import logging
import pyodbc

# Color array
colorscheme =  ['#966A2B', '#F00FFF', '#FFFF00', '#FFA54F', '#63B8FF', '#00868B'] # fred's email

# Layers versus name
titlescheme = {
    'Geological_Model:KGdry_1_utm38n': "Top_Kuwait_group_dry",
    'Geological_Model:UKG_2_utm38n': "Top_Upper_Kuwait_group",
    'Geological_Model:LKG_3_utm38n': "Top_Lower_Kuwait_group",
    'Geological_Model:DM3_4_utm38n': "Top_Upper_Dammam_Formation",
    'Geological_Model:DM2_5_utm38n': "Top_Lower_Dammam_Formation"
} 

# Layers versus name
titlescheme_inv = {
    "Top_Kuwait_group_dry": 'Geological_Model:KGdry_1_utm38n',
    "Top_Upper_Kuwait_group": 'Geological_Model:UKG_2_utm38n',
    "Top_Lower_Kuwait_group": 'Geological_Model:LKG_3_utm38n',
    "Top_Upper_Dammam_Formation": 'Geological_Model:DM3_4_utm38n',
    "Top_Lower_Dammam_Formation": 'Geological_Model:DM2_5_utm38n' 
}

# Layers versus color
colorscheme = {
    'Geological_Model:KGdry_1_utm38n': "#F00FFF",
    'Geological_Model:UKG_2_utm38n': "#FFFF00",
    'Geological_Model:LKG_3_utm38n': "#FFA54F",
    'Geological_Model:DM3_4_utm38n': "#63B8FF",
    'Geological_Model:DM2_5_utm38n': "#00868B"
}

# Lithology color table
colorLookupTable_Lithology = {
    'Black': "#000000",
    'Blue': "#0000FF",
    'Brown': "#A52A2A",
    'Dark brown': "#8B3626",
    'Dark grey': " #828282",
    'Green': "#228B22",
    'Grey': "#B0B0B0",
    'Light brown': "#CD853F",
    'Light grey': "#F5F5F5",
    'Red': "#FF0000",
    'White': "#FFFFFF",
    'Yellow': "#FFFF00",
    'Yellowish-grey': "#EEDD82",
    'Bluish-grey': "#9AC0CD",
    'Salmon': "#FA8072"
}

# Geological layers order
orderednames = [ 
    'Top_Kuwait_group_dry',
    'Top_Upper_Kuwait_group',
    'Top_Lower_Kuwait_group',
    'Top_Upper_Dammam_Formation',
    'Top_Lower_Dammam_Formation'
]

# Geological layers order
orderedtitles = [ 
    'Geological_Model:KGdry_1_utm38n', 
    'Geological_Model:UKG_2_utm38n', 
    'Geological_Model:LKG_3_utm38n', 
    'Geological_Model:DM3_4_utm38n',
    'Geological_Model:DM2_5_utm38n'
]