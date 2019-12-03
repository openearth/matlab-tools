# https://publicwiki.deltares.nl/display/OET/ ...TODO

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.


import base64
import logging
import cStringIO

from pywps.Process import WPSProcess
from pywps import config

import netCDF4
import matplotlib
# Don't plot on a screen on the web
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from statsmodels.graphics.gofplots import qqplot_2samples, ProbPlot

class DoubleMassProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="hymos_doublemass", # must be same, as filename
                            title="Double Mass Plot ",
                            version="$Id$",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="",
                            grassLocation=False)
        self.timeseries = self.addComplexInput(
            identifier="timeseries",
            title="Time Series",
            formats=[
                {"mimeType": "application/netcdf"}
            ])

        self.variable = self.addLiteralInput(
            identifier="variable",
            title="name of variable that is used for analysis",
            type=str,
            default="Parameter"
        )
        self.x = self.addLiteralInput(
            identifier="x",
            title="x station index in second dimension of parameter",
            type=int
        )

        self.y = self.addLiteralInput(
            identifier="y",
            title="y station index in second dimension of parameter ",
            type=int
        )

        self.output = self.addComplexOutput(
            identifier="plot",
            title="Double Mass Plot",
            formats=[
                {"mimeType": "image/png"}
            ])

    def execute(self):
        # read netCDFfile
        # choose two parameters
        #
        # x = read data
        # y = read data
        ds = netCDF4.Dataset(self.timeseries.value)
        x = ds.variables[self.variable.getValue()][:, int(self.x.getValue())]
        y = ds.variables[self.variable.getValue()][:, int(self.y.getValue())]
        ds.close()
        pp_x = ProbPlot(x)
        pp_y = ProbPlot(y)
        fig, ax = plt.subplots()
        qqplot_2samples(pp_x, pp_y, ax=ax)
        f = cStringIO.StringIO()
        fig.savefig(f, format='png')
        f.seek(0)
        self.output.setValue(f)
