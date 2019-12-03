"""
Tidal prediction tool 
"""

from pywps.Process import WPSProcess                                
import netCDF4
import matplotlib.pyplot as plt
import numpy as np
import pandas
import datetime
import scipy.interpolate 
import pytz
import dateutil.parser
from types import FloatType, IntType, StringType
import cStringIO


class Process(WPSProcess):
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
            identifier = "tidal_predict_graph",
            title="Tidal prediction tool with the option of requesting a range in time",
            abstract="""Tidal prediction tool can be used for different 
                tidal prediction requests. Starting date at latest is 2000-01-01 00:00:00.
                Prediction is calculated from Topex/Poseidon dataset.""",
            version = "0.1",
            storeSupported = True,
            statusSupported = True)

        ##
        # Adding process inputs
        
        self.lonIn   = self.addLiteralInput(identifier="lon",
                       title="Longitude for tidal prediciton in WGS84",
                       type = FloatType)
                    
        self.latIn   = self.addLiteralInput(identifier="lat",
                       title = "Lattitude for tidal prediciton in WGS84",
                       type = FloatType)

        self.yearIn  = self.addLiteralInput(identifier="year",
                       title = "Starting date and time for prediction",
                       type = IntType,
                       default = 2000)

        self.monthIn = self.addLiteralInput(identifier="month",
                       title = "Starting date and time for prediction",
                       type = IntType,
	                default = 1)        

        self.dayIn   = self.addLiteralInput(identifier="day",
                       title = "Starting date and time for prediction",
                       type = IntType,
                       default = 1)

        self.hourIn  = self.addLiteralInput(identifier="hour",
                       title = "Starting date and time for prediction",
                       type = IntType,
                       default = 0)

        self.minuteIn= self.addLiteralInput(identifier="minute",
                       title = "Starting date and time for prediction",
                       type = IntType,
                       default = 0)

        self.rangeIn = self.addLiteralInput(identifier="range",
                       title = "Give requested periods from start date in hours",
                       type = IntType, 
                       default = 1)
                
        ##
        # Adding process outputs

        self.tideout = self.addComplexOutput(identifier = "tideout",
                       title = "Calculated water level for requested location and date",
                       formats = [{"mimeType":"image/png"}])

    ##
    # Execution part of the process
    def execute(self):

                #dataset
        ds = netCDF4.Dataset(r'//home/boerboom/checkout/wps_processes/data/h_tpxo7.2.nc')

        #define constituents from dataset
        const = netCDF4.chartostring(ds.variables['con'][:])
        constituents = [x.strip().upper() for x in const]

        #define starting data and conversion of calendars
        def julian_hours(my_date):
            """Returns the Julian day number of a date."""
            hours_since_2000 = (my_date - datetime.datetime(2000,1,1)).total_seconds()/3600.0
            julian_hours = hours_since_2000 + 2451545*24
            return julian_hours

        #library for constituent periods
        freqs = {
            'M2':(28.984104252/360)*(2*np.pi),
            'S2':(30.0000000/360)*(2*np.pi),
            'N2':(28.439729568/360)*(2*np.pi),
            'K2':(30.0821373/360)*(2*np.pi),
            'K1':(15.041068632/360)*(2*np.pi),
            'O1':(13.943035584/360)*(2*np.pi),
            'P1':(14.9589314/360)*(2*np.pi),
            'Q1':(13.3986609/360)*(2*np.pi),
            'MF':(1.0980331/360)*(2*np.pi),
            'MM':(0.5443747/360)*(2*np.pi),
            'M4':(57.968208468/360)*(2*np.pi),
            'MS4':(58.984104240/360)*(2*np.pi),
            'MN4':(57.423833820/360)*(2*np.pi)
            }

        Lon = ds.variables['lon_z'][:]
        Lat = ds.variables['lat_z'][:]
        # we only need the first row and column
        lon = Lon[:,0]
        lat = Lat[0,:]

        lon_index, = np.where(lon == 3)
        lat_index, = np.where(lat == 52)

        lat_index, lon_index
        amp = ds.variables['ha'][0,lon_index, lat_index][0]

        lat_index, lon_index
        phase = ds.variables['hp'][0,lon_index, lat_index][0]

        rows = []
        class AngularInterp(object):
            def __init__(self, interpx, interpy):
                self.interpx = interpx
                self.interpy = interpy
            def __call__(self, *args, **kwargs):
                """call with grid"""
                return np.arctan2(self.interpy(*args, **kwargs), self.interpx(*args, **kwargs))
            def ev(self, *args, **kwargs):
                """call with points"""
                return np.arctan2(self.interpy.ev(*args, **kwargs), self.interpx.ev(*args, **kwargs))
                
        for i, constituent in enumerate(constituents):
            row ={}
            row['index'] = i
            row['constituent'] = constituent
            row['amplitude'] = scipy.interpolate.RectBivariateSpline(lon, lat, ds.variables['ha'][i], kx=2, ky=2, s=0)
            phase_rad = np.deg2rad(ds.variables['hp'][i])
            
            #split phases in x and y components
            pr_x = np.cos(phase_rad)
            pr_y = np.sin(phase_rad)
            
            #interpolate x and y phases seperatly for given location
            int_pr_x = scipy.interpolate.RectBivariateSpline(lon, lat, pr_x, kx=2, ky=2, s=0)
            int_pr_y = scipy.interpolate.RectBivariateSpline(lon, lat, pr_y, kx=2, ky=2, s=0)
            
            #calculate phase from split interpolation functions
            intphase = AngularInterp(int_pr_x, int_pr_y)
            row['phase'] = intphase
            rows.append(row)
        interps = pandas.DataFrame.from_records(rows, index='constituent')

        def h(lon, lat, t):
            """only works for vectors"""
            # start at a waterlevel of 0
            h = np.zeros(np.asarray(lon).shape)
            try:
                t_vector = np.asarray([julian_hours(t_i) for t_i in t])
            except TypeError as e:
                t_vector = np.asarray([julian_hours(t)])
                
            # loop over constituents and corresponding interpolation functions
            for constituent, row in interps.iterrows():
                # lookup amplitude 
                amp = row['amplitude'].ev(lon, lat)
                # and phase
                phase = row['phase'].ev(lon, lat)
                # lookup angular frequency
                freq = freqs[constituent]
                # add waterlevel of this constituent
                h = h + amp*np.cos(freq*t_vector+phase)
                #print h
            return h
        
        dates = [datetime.datetime(self.yearIn.getValue(),self.monthIn.getValue(),self.dayIn.getValue(),self.hourIn.getValue(),self.minuteIn.getValue()) + datetime.timedelta(minutes=i) for i in range(self.rangeIn.getValue()*60*24)]
        output = h(self.lonIn.getValue(),self.latIn.getValue(), dates)
        fig,ax = plt.subplots(1,1)
        outplot = pandas.Series(data=output, index=dates).plot(ax=ax)
        f = cStringIO.StringIO()
        
        fig.savefig(f)
        f.seek(0)
        
        self.tideout.setValue(f)
        return
