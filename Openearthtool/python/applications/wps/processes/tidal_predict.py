"""
Tidal prediction tool
"""
import cStringIO
import logging
import datetime

from types import FloatType, IntType, StringType

import dateutil.parser
from dateutil.rrule import YEARLY, MONTHLY, WEEKLY, DAILY, HOURLY, MINUTELY, SECONDLY

rrules_freqs = {
    "YEARLY":YEARLY,
    "MONTHLY": MONTHLY,
    "WEEKLY": WEEKLY,
    "DAILY": DAILY,
    "HOURLY": HOURLY,
    "MINUTELY": MINUTELY,
    "SECONDLY": SECONDLY
}
import pytz

import openearthtools.physics.tide
import numpy as np

import pywps.utils
from pywps.Process import WPSProcess

# http://localhost:8000/?
# request=Execute&
# identifier=tidal_predict&
# service=wps&
# version=1.0.0&
# datainputs=location=LINESTRING(2%2052,3%2053);startdate=2020-01-01;enddate=2020-01-02&
# responsedocument=tide=@mimetype=application/json

class Process(WPSProcess):
    def __init__(self):
        # Process initialization
        WPSProcess.__init__(self,
            identifier = "tidal_predict",
            title="Tidal prediction tool",
            abstract="""
Tidal prediction tool can be used for different tidal prediction requests.
Prediction is calculated from Topex/Poseidon dataset.
Constitutuents provided by OSU TPXO.
""",
            version = "0.1",
            storeSupported = True,
            statusSupported = True)

        ##
        # Adding process inputs
        # TODO replaccy by normal types
        self.location = self.addComplexInput (identifier = "location",
                                              title = "Input vector (point, linestring) in format geojson, well known text or gml",
                                              formats = [
                                                 {'mimeType': 'text/plain', 'encoding': 'UTF-8'},
                                                 {'mimeType': 'application/xml', 'schema': 'http://schemas.opengis.net/gml/2.1.2/feature.xsd', 'encoding': 'UTF-8'},
                                                 {'mimeType': 'application/json'}
                                              ])
        self.startdate = self.addLiteralInput(identifier="startdate",
                                              title="date for prediction",
                                              abstract="prediction date in iso date format",
                                              type=datetime.datetime,
                                              default=datetime.datetime.now().isoformat())
        self.enddate = self.addLiteralInput  (identifier="enddate",
                                              title="date for prediction",
                                              type=datetime.datetime,
                                              default="startdate")
        self.frequency = self.addLiteralInput(identifier="frequency",
                                              title="date resolution",
                                              allowedValues=list(rrules_freqs.keys()),
                                              type=StringType,
                                              default="HOURLY")
        self.tide = self.addComplexOutput    (identifier = "tide",
                                              title = "Calculated water level for requested locations and date",
                                              formats = [
                                              {"mimeType": "text/csv"},
                                              {"mimeType": "application/json"}
                                          ])



    ##
    # Execution part of the process
    def execute(self):

        startdate = dateutil.parser.parse(self.startdate.getValue())
        if self.enddate.getValue() == "startdate":
            enddate = startdate
        else:
            enddate = dateutil.parser.parse(self.enddate.getValue())

        freq = self.frequency.getValue()
        assert freq in rrules_freqs.keys(), "Expected freq as one of %s" % (rrules_freqs.keys())
        dates = dateutil.rrule.rrule(rrules_freqs[freq], dtstart=startdate, until=enddate)[:]

        location = self.location.getValue()
        geom = pywps.utils.decode(location)
        assert geom.type in ('Point', 'LineString'), "expected point or linestring input"
        points = np.atleast_2d(np.asarray(geom))
        assert points.shape[1] == 2, "Expected array of 2d points, or point"

        df = openearthtools.physics.tide.predict(points, dates=dates)

        f = cStringIO.StringIO()
        if self.tide.format['mimetype'] == 'text/csv':
            df.to_csv(f, index=False)
        elif self.tide.format['mimetype'] == 'application/json':
            df.to_json(f, orient='records')
        f.seek(0) # rewind
        self.tide.setValue(f)

        return
