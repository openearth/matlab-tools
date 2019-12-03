import netCDF4 as nc
import numpy as np
import output_settings as c
import sys
import re

timefactor = {}
timefactor['seconds']  = 1.0
timefactor['minutes'] = 60.0
timefactor['hours'] = 3600.0
timefactor['days'] = 86400.0

class IncrementalConverter(object):
    """Construct the triplet of grid files from an incremental file.""" 

    def __init__(self, ncvar, nctim, lower, upper): 
        self.__ncvar = ncvar
        self.__nctim = nctim
        self.__classes = {} 
        self.__lower_threshold = lower 
        self.__upper_threshold = upper 
        self.__parse_classes()

    def __fill_classes(self):
        units = self.__ncvar.getncattr('units')
        regexp_midcls   = '([-\d\.]+)'+units+'_to_([-\d\.]+)'+units  # intermediate class search regular expression
        regexp_topcls   = 'above_([-\d\.]+)'+units                   # top class search regular expression
        regexp_btmcls   = 'below_([-\d\.]+)'+units                   # bottom class search regular expression
        
        clsvalstr = self.__ncvar.getncattr('flag_values')
        clsvalues = clsvalstr.split()
        clsdefstr = self.__ncvar.getncattr('flag_meanings')
        clsdefs   = clsdefstr.split()
        
        ncls = len(clsvalues)
        # Create translation table for the classes, stores the LOWER bound of the class !!
        for icls in range(ncls):
            m = re.search(regexp_btmcls,clsdefs[icls])
            if m:
                cls = np.nan
            m = re.search(regexp_topcls,clsdefs[icls])
            if m:
                cls = float(m.group(1))
            m = re.search(regexp_midcls,clsdefs[icls])
            if m:
                cls = float(m.group(1))
            self.__classes[int(clsvalues[icls])] = cls

    def __parse_classes(self):
        # Find the number of the first class >= 0.02 
        self.__fill_classes()
        for class_number in sorted(self.__classes.keys()):
            if self.__classes[class_number] >= 0.02: 
                self.__lower_threshold = class_number 
                break 
            if self.__lower_threshold is None: 
                raise RuntimeError('No class exceeds 0.02 m.')
        # Find the number of the first class >= 1.5 
        for class_number in sorted(self.__classes.keys()): 
            if self.__classes[class_number] >= 1.5: 
                self.__upper_threshold = class_number 
                break 
            if self.__upper_threshold is None: 
                raise RuntimeError('No class exceeds 1.5 m.')

    def getRisingSpeeds(self,**kwargs): 
        # Inspect the data to construct the rise rate grid.
        global timefactor
        verbose = False
        if 'verbose' in kwargs:
            verbose = kwargs['verbose']
        else:
            verbose = False
        npoly = self.__ncvar.shape[1]
        rise_speeds = np.ma.zeros(npoly)
        rise_speeds.mask = True
        times  = self.__nctim[:]
        timeunit = self.__nctim.getncattr('units').split()[0]
        tfact = timefactor[timeunit]/timefactor[c.timeunit] 

        for ipoly in range(npoly):
            tseries= self.__ncvar[:,ipoly]
            lts = None
            prev_class = -1
            for time, class_ in list(zip(times,tseries)):
                if class_ >= self.__lower_threshold:
                    if lts is None:
                        lts = (time, class_)
                    elif class_ >= self.__upper_threshold:
                        dh = self.__classes[class_] - 0.02
                        dt = (time - lts[0]) * tfact
                        if dh > 0. and dt > 0.:
                            rise_speeds[ipoly] = dh/dt
                            break
            prev_class = class_
            if (verbose):
                sys.stderr.write("Calculating rising speed Node : %8.8d, %6.1d%%\r"%(ipoly,round(ipoly*100.0/npoly)))
        return rise_speeds








