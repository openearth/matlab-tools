# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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

'''
http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=GetCapabilities
http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=DescribeProcess&identifier=hymos_wps_availability
http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=Execute&identifier=hymos_wps_availability&datainputs=[parameterid=P.obs;locations=M_AZ_001;startdate=20090101;enddate=20100101]

Repository information:
Date of last commit:     $Date: 2017-02-27 10:14:07 -0800 (Mon, 27 Feb 2017) $
Revision of last commit: $Revision: 13191 $
Author of last commit:   $Author: hendrik_gt $
URL of source:           $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/sandbox/HYMOS/hymos_wps_availability.py $
CodeID:                  $ID$

'''


import logging
from pywps.Process import WPSProcess
import bokeh_plots


class Process(WPSProcess):
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
                            identifier="hymos_wps_availability",
                            title="""Data availability""",
                            abstract="""Get time series from database and
                            determine the availability of a certain parameter
                            at a certain location
                            Returns the availability of a certain
                            parameter for a given location""",
                            version="1.1",
                            storeSupported=True,
                            statusSupported=True)

        self.parameterID = self.addLiteralInput(
            identifier="parameterid",
            title="Parameter ID",
            abstract="input=dropdownmenu",
            type=type(""),
            default="P.obs")

        self.locations = self.addLiteralInput(
            identifier="locations",
            title="Locations selected for data availability check",
            abstract="input=mapselection",
            type=type(""),
            uoms=["point"],
            default="Select a location on the map")

        self.sdate = self.addLiteralInput(
            identifier="startdate",
            title="Start date for data collection",
            abstract="input=dateObject",
            type=type(""),
            default="19800101")

        self.edate = self.addLiteralInput(
            identifier="enddate",
            title="End date for data collection",
            abstract="input=dateObject",
            type=type(""),
            default="20170101")

        self.multiplier = self.addLiteralInput(
            identifier="multiplier",
            title="Multiplier of time step unit (e.g. number of days)",
            abstract="input=textInput",
            type=type(1),
            default=1)

        self.time_unit = self.addLiteralInput(
            identifier="time_unit",
            title="Time step unit (e.g. D = day, M = month)",
            abstract="input=textInput",
            type=type(""),
            default="D")

        ##
        # Adding process outputs

        self.Output1 = self.addComplexOutput(
            identifier="timeseries",
            title="Time series for specified parameter and locationid",
            formats=[{"mimeType": "text/plain"},  # 1st is default
                     {'mimeType': "text/html"}])

    ##
    # Execution part of the process
    def execute(self):
        logging.info('parameterID %s', self.parameterID.getValue())
        logging.info('locations   %s', self.locations.getValue())
        arg_dict = bokeh_plots.read_config()
        if self.sdate.getValue() == 'NoneType':
            logging.info('start date is null ')
        if len(self.sdate.getValue()) < 8:
            logging.info('start date if null ' + self.sdate.getValue())
            if len(self.edate.getValue()) < 8:
                logging.info('end date if null ' + self.edate.getValue())
                io = bokeh_plots.bokeh_availability(
                    self.parameterID.getValue(),
                    self.locationID.getValue(),
                    '19810101', '19820101', **arg_dict)
        else:
            io = bokeh_plots.bokeh_availability(self.parameterID.getValue(),
                                                self.locations.getValue(),
                                                self.sdate.getValue(),
                                                self.edate.getValue(),
                                                self.multiplier.getValue(),
                                                self.time_unit.getValue(),
                                                **arg_dict)
            logging.info('start date  ' + self.sdate.getValue())
            logging.info('end date    ' + self.edate.getValue())

        if not io:
            self.Output1.setValue('no data retrieved')
        else:
            self.Output1.setValue(io)
            io.close()
        return
