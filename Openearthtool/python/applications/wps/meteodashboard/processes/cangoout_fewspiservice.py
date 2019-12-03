"""
CanGoOutFewsPiservice
Author: Joan Sala Calero
Usage: http://aw-tc003.xtr.deltares.nl/cgi-bin/pywps.cgi?service=wps&request=Execute&Identifier=cangoout_fewspiservice&version=1.0.0&dataInputs=[url=http%3A%2F%2Ftl-ng021.xtr.deltares.nl%3A8080%2FFewsPiService%2Ffewspiservice;threshold=1.5;tolerance=0.0;period=1;filterId=MDRWE.All;parameterIds=Wave.hm0.voorspeld]
"""
import json
import logging
from datetime import datetime, tzinfo, timedelta
import requests
from urllib.parse import unquote
import xml.etree.ElementTree as ET

from pywps import Process, LiteralInput, LiteralOutput
from pywps.inout.literaltypes import AllowedValue


class CanGoOutFewsPiservice(Process):
    def __init__(self):

        inputs = [
            LiteralInput("threshold", "Threshold number", data_type='float', default=1.5),
            LiteralInput("tolerance", "Tolerance number", data_type='float', default=0.00),
            LiteralInput("period", "Period number", data_type='integer'),#, allowed_values=[[1, 4]], default=1),
            LiteralInput("url", "fewspiservice query url", data_type='string'),
        ]
        outputs = [LiteralOutput("outcome",
                                 "outcome in format [{'id': 'X', 'status': 'yes/no/nearly'}, ...]",
                                 data_type='string')]

        super(CanGoOutFewsPiservice, self).__init__(
            self._handler,
            identifier='cangoout_fewspiservice',
            version='0.1',
            title='Can Go Out?',
            abstract="'Can Go Out' determines exceeding threshold during indicated period. 3 inputs, threshold, period and features" +
            "containing timeseries for turbines and returns the result yes/no/nearly for each turbine",
            inputs=inputs,
            outputs=outputs,
            store_supported=True,
            status_supported=True
        )

    def _handler(self, request, response):

        threshold = request.inputs["threshold"][0].data
        tolerance = request.inputs["tolerance"][0].data
        period = request.inputs["period"][0].data
        url = request.inputs["url"][0].data

        piservice_url = unquote(url)
        startdate, enddate = periodDatetimes(period)
        logging.info('INPUT period = {} ({} - {}), threshold = {}, tolerance = {}'.format(
                     period, startdate, enddate, threshold, tolerance))
        logging.info('INPUT piservice_url = {}'.format(piservice_url))

        # Query fewspiservice
        allseries = fewspirequest(piservice_url)

        # Analyse all tseries per location
        res = {}
        for location, tseries in allseries.items():
            try:
                stats = '[{}, {}]'.format(min(tseries['val']), max(tseries['val']))
                if max(tseries['val']) > (threshold + tolerance):
                    res[location] = 'no, minmax=' + stats
                elif max(tseries['val']) > threshold:
                    res[location] = 'nearly, minmax=' + stats
                else:
                    res[location] = 'yes, minmax=' + stats
            except:
                res[location] = 'nodata'

        # output knowledge rule outcome
        response.outputs['outcome'].data = str(res)
        return response

# -----------------------------------------
# Aux functions
# -----------------------------------------

# NEW / Forward a request to REST FewsPIService [url built on the frontend]


def fewspirequest(piservice_url):
    # Read response
    response = requests.get(url=piservice_url)
    data = response.text

    # Data [return dictionary with tseries]
    alltseries = {}
    if data is not None:
        # Namespace
        default_ns = "http://www.wldelft.nl/fews/PI"

        # Parse xml response
        root = ET.fromstring(data)

        # Get all time-series per location
        series_list = root.findall('{' + default_ns + '}series')
        for serie in series_list:
            header = serie.find('{' + default_ns + '}header')
            locId = header.findtext('{' + default_ns + '}locationId')
            event_list = serie.findall('{' + default_ns + '}event')
            if event_list == []:
                continue  # some locations appear twice / ask FEWS people
            # There is data
            ts_dict = {"date": [], "val": []}
            for event in event_list:
                date_str = " ".join([event.get("date"), event.get("time")])
                val_str = event.get("value")
                ts_dict["date"].append(date_str)
                ts_dict["val"].append(float(val_str))
            # Store all values
            alltseries[locId] = ts_dict

    return alltseries


# Convert a Datetime object to string
def convertDatetime(datetime_string):
    tz_offset_str = datetime_string[-5:]
    tz_offset_min = int(tz_offset_str[-4:-2]) * 60 + int(tz_offset_str[-2:])
    if tz_offset_str[0] == "-":
        tz_offset_min = -tz_offset_min
    datetimestamp = datetime.strptime(datetime_string[:-5], '%Y-%m-%dT%H:%M:%S')
    return datetimestamp.replace(tzinfo=FixedOffset(tz_offset_min, 'GMT'))


# Establish start/end dates
def periodDatetimes(period):

    startdate = datetime.today()
    enddate = datetime.today()
    if period == 1:     # Morning (06:00 - 12:00)
        startdate = startdate.replace(hour=6, minute=0, second=0, microsecond=0, tzinfo=FixedOffset(0, 'GMT'))
        enddate = enddate.replace(hour=12, minute=0, second=0, microsecond=0, tzinfo=FixedOffset(0, 'GMT'))
    elif period == 2:   # Afternoon (12:00 - 18:00)
        startdate = startdate.replace(hour=12, minute=0, second=0, microsecond=0, tzinfo=FixedOffset(0, 'GMT'))
        enddate = enddate.replace(hour=18, minute=0, second=0, microsecond=0, tzinfo=FixedOffset(0, 'GMT'))
    elif period == 3:  # period 3 or 4, All day (06:00 - 18:00)
        startdate = startdate.replace(hour=6, minute=0, second=0, microsecond=0, tzinfo=FixedOffset(0, 'GMT'))
        enddate = enddate.replace(hour=18, minute=0, second=0, microsecond=0, tzinfo=FixedOffset(0, 'GMT'))
    elif period == 4:  # All day Tomorrow
        startdate += timedelta(days=1)
        enddate += timedelta(days=1)
    else:
        pass

    # to simulate another period adjust the dates:
    #startdate -= timedelta(days=7)
    #enddate   -= timedelta(days=7)

    logging.warning('startdate: %s, enddate: %s', (str(startdate), str(enddate)))
    return startdate, enddate


class FixedOffset(tzinfo):
    """Fixed offset in minutes east from UTC."""

    def __init__(self, offset, name):
        self.__offset = timedelta(minutes=offset)
        self.__name = name

    def utcoffset(self, dt):
        return self.__offset

    def tzname(self, dt):
        return self.__name

    def dst(self, dt):
        return 0
