# -*- coding: utf-8 -*-
"""
Created on Tue Aug 11 16:23:53 2015

Populate Infoline read netcs
"""
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares
#       Gerrit Hendriksen,Maarten Pronk, Edwin Bos
#
#       gerrit.hendriksen@deltares.nl, maarten.pronk@deltares.nl, edwin.bos@deltares.nl
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

# $Id: infoline_wps.py 12378 2015-11-25 15:10:18Z hendrik_gt $
# $Date: 2015-11-25 07:10:18 -0800 (Wed, 25 Nov 2015) $
# $Author: hendrik_gt $
# $Revision: 12378 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/infoline/infoline_wps.py $
# $Keywords: $

"""
Infoline WPS start script

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=infoline_wps 
execute:          http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=infoline_wps&datainputs=[project='SoilRisk';x_rd=148879;y_rd=456710;z_depth=47.5]
"""

import logging
from pywps.Process import WPSProcess
from GeoTop import GeoTopOnOpendap
from ahn2 import ahn
from opendap_nhi import nhi_invoer, zoetzout, regiswps
import getpass


class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="infoline_wps",
                            title="Infoline",
                            version="0.9",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Infoline WPS gets data from various online subsurface resources in order to give information
                                        about status of subsurface in the Netherlands.
                                        Contributing to Infoline and Soilrisk are NHI (http://nhi.nu), Dinoloket (http://www.dinoloket.nl).
                                        See describeprocess for input and output parameters""",
                            grassLocation=False)

        self.project = self.addLiteralInput(identifier="project",
                                            title="Client project: Infoline or SoilRisk.",
                                            type=type(''),
                                            default='Infoline')
        self.x = self.addLiteralInput(identifier="x_rd",
                                      title="X coordinate in RD-New (EPSG28992)",
                                      type=type(0.0),
                                      default=148879)
        self.y = self.addLiteralInput(identifier="y_rd",
                                      title="Y coordinate in RD-New (EPSG28992)",
                                      type=type(0.0),
                                      default=456710)
        self.z = self.addLiteralInput(identifier="z_depth",
                                      title="Depth below surface layer",
                                      type=type(0.0),
                                      default=47.5)
        self.Output1 = self.addLiteralOutput(identifier="values",
                                             title="Returns list of values (lithology in case of Geotop in m below surface level) for specified xy",
                                             abstract="""For every geotop lithology top, bottom, lithology and hex colour is given. Origin of Geotop is http://www.dinodata.nl/opendap/""")
        self.Output2 = self.addLiteralOutput(identifier="maaiveld",
                                             title="Returns surface level in m - NAP",type=float,
                                             abstract="""Returns surface level in m - NAP from PDOK WCS layer http://geodata.nationaalgeoregister.nl/ahn2/ows""")
        self.Output3 = self.addLiteralOutput(identifier="nhi",
                                             title="""Returns several parameters per NHI model layer.""",
                                             type=str,
                                             abstract="""For each layer following parameters are returned: 
                                                         vertical resistance (m2/day),
                                                         Mean Highest Groundwater level (m-NAP),
                                                         Mean Lowest Ground water Level (m-NAP),
                                                         Top of layer (m-NAP), 
                                                         Bottom of layer (m-NAP) are returned""")
        self.Output4 = self.addLiteralOutput(identifier="zoetzout",
                                             title="Returns level of 1000 mg/l concentration Chloride",type=float,
                                             abstract="""The level of 1000 mg/l concentration Chloride is given in several classes.""")
        self.Output5 = self.addLiteralOutput(identifier="regis",
                                             title="Returns levels of REGIS 2.1 layers with colors",type=str,
                                             abstract="""Returns tops, bottoms (m-NAP) and hex color value for each REGIS layer encountered""")

    def execute(self):
        project = self.project.getValue()
        aX = self.x.getValue()
        aY = self.y.getValue()
        aZ = self.z.getValue()
#        logging.debug('user =' + str(getpass.getuser()))
        logging.debug('project =' + str(self.project.getValue()))
        logging.debug('x =' + str(self.x.getValue()))
        logging.debug('y =' + str(self.y.getValue()))
        logging.debug('z =' + str(self.z.getValue()))
        if project == 'Infoline':
            lstvals = GeoTopOnOpendap('d:\\data\\geotop.nc').get_all_layers(aX, aY)
            hoogte = ahn(aX, aY)
            logging.debug(hoogte)
            self.Output1.setValue(lstvals)
            self.Output2.setValue(hoogte)
            self.Output3.setValue(str(nhi_invoer(aX, aY)))
            self.Output4.setValue(str(zoetzout(aX, aY)))
            self.Output5.setValue(str(regiswps(aX, aY)))
        elif project == 'SoilRisk':
            lstvals = GeoTopOnOpendap('d:\\data\\geotop.nc').get_layers(aX, aY, aZ)
            self.Output1.setValue(lstvals)
            self.Output2.setValue(hoogte)
            self.Output3.setValue([])
            self.Output4.setValue([])
            self.Output5.setValue([])
        return