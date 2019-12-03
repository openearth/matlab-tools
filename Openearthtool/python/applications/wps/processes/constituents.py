# -*- coding: utf-8 -*-
"""
Created on Tue Apr 09 15:40:46 2013

@author: boerboom
"""
import pdb
from types import StringType, FloatType, BooleanType

import dateutil
import pytz

from pywps.Process import WPSProcess
#import json

import openearthtools.physics.tide


class Process(WPSProcess):
    def __init__(self):
         # init process
         WPSProcess.__init__(self,
                             identifier = "constituents", # must be same, as filename
                             title="Lookup constituents based on their short name",
                             version = "1",
                             storeSupported = False,
                             statusSupported = False,
                             abstract="Lookup the speed of the constiuent based on the name of the constituent (following Doodson).")
         self.constituent = self.addLiteralInput(
             identifier = "constituent",
             title = "Name of the constituent to look up (M2,...)",
             type = StringType
         )
         self.nodal = self.addLiteralInput(
             identifier = "nodal",
             title = "Calculate nodal factors",
             type = BooleanType,
             default = False
         )
         self.date = self.addLiteralInput(
             identifier = "date",
             title = "Date for which to calculate the nodal factors",
             type = StringType,
             default = ""
         )
         self.speed = self.addLiteralOutput(
             identifier="speed",
             title="Speed of the constituent (radians per hour)",
             uoms="rad/hr",
             type = FloatType
         )
         self.vau = self.addLiteralOutput(
             identifier="VAU",
             title="V+u taken from Schureman",
             type=FloatType,
             default=0
         )
         self.u = self.addLiteralOutput(
             identifier="u",
             title="u taken from Schureman",
             type=FloatType,
             default=0
         )
         self.ff = self.addLiteralOutput(
             identifier="FF",
             title="FF nodal factor, taken from Schureman",
             type=FloatType,
             default=1.0
         )

    def execute(self):
        constituent = self.constituent.getValue()
        datestr = self.date.getValue()
        date = dateutil.parser.parse(datestr)
        if date.tzinfo is None:
            dateutc = pytz.utc.fromutc(date)
        else:
            dateutc = date.astimezone(pytz.utc)
        if not self.nodal.getValue():
            val = openearthtools.tide.constituents([dateutc])[constituent]
        else:
            val = openearthtools.tide.nodalconstituents([dateutc])[constituent]
        self.speed.setValue(val['ospeed'])
        if val.has_key('u'):
            self.u.setValue(val['u'][0])
        if val.has_key('FF'):
            self.ff.setValue(val['FF'][0])
        if val.has_key('VAU'):
            self.vau.setValue(val['VAU'][0])
        return




