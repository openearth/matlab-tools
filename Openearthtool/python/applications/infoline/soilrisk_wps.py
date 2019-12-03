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
# $Date: 2015-11-25 16:10:18 +0100 (Wed, 25 Nov 2015) $
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
from soilrisk_model import risk1
# from GeoTop import GeoTopOnOpendap
# from ahn2 import ahn
# from opendap_nhi import nhi_invoer, zoetzout, regiswps
# import getpass


class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="soilrisk_wps",
                            title="Infoline",
                            version="0.9",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Infoline WPS gets data from various online subsurface resources in order to give information
                                        about status of subsurface in the Netherlands.
                                        Contributing to Infoline and Soilrisk are NHI (http://nhi.nu), Dinoloket (http://www.dinoloket.nl).
                                        See describeprocess for input and output parameters""",
                            grassLocation=False)


        self.x = self.addLiteralInput(identifier="x_rd",
                                      title="X coordinate in RD-New (EPSG28992)",
                                      type=type(0.0),
                                      default=148879)
        self.y = self.addLiteralInput(identifier="y_rd",
                                      title="Y coordinate in RD-New (EPSG28992)",
                                      type=type(0.0),
                                      default=456710)
        self.zbuis = self.addLiteralInput(identifier="zbuis",
                                      title="Pipe below surface layer",
                                      type=type(0.0),
                                      default=15)
        self.dbuis = self.addLiteralInput(identifier="dbuis",
                                      title="Diameter of pipe",
                                      type=type(0.0),
                                      default=0.4)
        self.mbuis = self.addLiteralInput(identifier="mbuis",
                                      title="Material of pipe",
                                      type=type(""),
                                      default="Staal")
        self.lbuis = self.addLiteralInput(identifier="lbuis",
                                      title="Length of pipe",
                                      type=type(0.0),
                                      default=300)
        self.zwater = self.addLiteralInput(identifier="zwater",
                                      title="Groundwater level below surface layer",
                                      type=type(0.0),
                                      default=3)
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
        self.Output6 = self.addLiteralOutput(identifier="risico",
                                             title="Returns risk",type=str,
                                             abstract="""Returns risk of blowout""")
    def execute(self):
        x = self.x.getValue()
        y = self.y.getValue()

        p_min, p_max, SF, risico, regislagen = risk1((x, y))

        self.Output1.setValue(regislagen)
        self.Output2.setValue(2)
        self.Output3.setValue([])
        self.Output4.setValue([])
        self.Output5.setValue([])
        self.Output6.setValue("SF is {}, Risco is ".format(SF)+risico[0])
        logging.info(regislagen)
        # print regislagen
        return

if __name__ == "__main__":
    a = Process()
    a.execute()
