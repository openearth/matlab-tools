# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
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
# OpenEarthTools is an online collaboration to share andmanage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.
# $Keywords: $

from EMODNET_Client import EMODNET_WFS_query
import json, os
from pprint import pprint

# Output directory
output_dir = './windmills_downloaded_data/emodnet'
endangered_json=r"D:\sala\Documents\EMODNET-OpenSeaLab\opensealab\windmills_downloaded_data\endangered_species\endangered.json"
data = json.load(open(endangered_json))
bbox = (7.55, 56.99, 12.09, 58.05)

ids = []
for d in data:
    for child in d["Attributes"][0]["children"]:
        if child["measurementValue"] == "Endangered" or child["measurementValue"] == "Vulnerable":
            print d["AphiaID"]
            ids.append(d["AphiaID"])

#
# Endangered species - Emodnet
url_wfs = 'http://geo.vliz.be/geoserver/Dataportal/ows'
layer_wfs = 'Dataportal:eurobis'

for id in ids:
    url = "curl -X GET \"http://geo.vliz.be/geoserver/Dataportal/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal:eurobis&viewParams=where:aphiaidaccepted="+str(id)+"&outputformat=shape-zip\" > "+str(id)+".zip"
    print url
