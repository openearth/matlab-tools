import re
import csv
import time
import pytz
import urllib
import codecs
import timetuple
import lxml.html
import netCDF4
import numpy as np
import pandas as pd
import scipy.signal
from datetime import datetime, timedelta

class Waterbase:
  '''Class to access waterbase resources.
  
     Usage:
        myWaterbase = Waterbase(language='en')
        myWaterbase.get_themes()
        myWaterbase.search_observations('Flow', theme='Discharge')
        myWaterbase.get_locations('Water height in cm with respect to normal amsterdam level in surface water')
        myWaterbase.get_locations(1)
        myWaterbase.get_data(1,'Bath',time.now(),time.now())
        print myWaterbase
     
     See also: http://live.waterbase.nl/
  '''
  
  host          = ''
  language      = ''
  
  themes        = []
  observations  = []
  
  def __init__(self, host='http://live.waterbase.nl/', language='en'):
    'Initialisation function to set host and language and retrieve available themes and observations'
    
    self.host     = host
    self.language = language
    
    self.get_themes()
    self.get_observations()

  def __str__(self):
    s = ''
    s += '%-15s: %s\n' % ('Host', self.host)
    s += '%-15s: %s\n' % ('Language', self.language)

    for i, (t, c) in enumerate(zip(*self.themes)):
      if i == 0:
        s += '%-15s: %-6s %s\n' % ('Themes', c, t)
      else:
        s += '%-15s  %-6s %s\n' % ('', c, t)

    for i, (o, c) in enumerate(zip(*self.observations)):
      if i == 0:
        s += '%-15s: %-6s %s\n' % ('Observations', c, o)
      else:
        s += '%-15s  %-6s %s\n' % ('', c, o)

    return s

  def __repr__(self):
    return self.__str__()
    
  def get_themes(self):
    'Retrieve list of themes'
    
    host        = self._get_host('observation')
    self.themes = self._get_coded_options(host, 'wbthemas')
    
    return self.themes
    
  def get_observations(self):
    'Retrieve list of observations'
    
    host              = self._get_host('observation')
    self.observations = self._get_coded_options(host, 'wbwns1')
    
    return self.observations
    
  def search_observations(self, search='', theme=''):
    'Literal string search on observations, possibly given a theme. Can also retrieve all observations in a theme'
    
    host = self._get_host('observation', search=search, wbthemas=self._get_theme_id(theme))
    
    return self._get_coded_options(host, 'wbwns2')
    
  def get_locations(self, observation):
    'Retrieve list of locations for a given observation'
    
    host = self._get_host('location', whichform=1, wbwns1=self._get_observation_id(observation))
    
    return self._get_coded_options(host, 'loc')
  
  def get_periods(self, observation, location):
    """
    Get available time periods for given observation and location
    """
    
    locations = self.get_locations(observation)
        
    oid  = self._get_observation_id(observation)
    lid  = self._get_id(locations, location)
    
    host = self._get_host('period', ggt='id%s' % oid, loc=lid)
    
    contents = urllib.urlopen(host).read()
    
    root = lxml.html.fromstring(contents)
    ps = root.getchildren()[0].getchildren()[0].getchildren()
    t = []
    for p in ps:
        t.append(time.strptime(p.attrib['from'], '%Y%m%d%H%M'))
        t.append(time.strptime(p.attrib['to'], '%Y%m%d%H%M'))
    if len(t)>2:
        # in case of multiple periods, reduce it to one period covering all
        t.sort()
        t = [t[0], t[-1]]
    return t
    
  def get_data(self, observation, location, datefrom, dateto, consolidate=True):
    'Get CSV data for given observation, location and time period'
    
    locations = self.get_locations(observation)
    
    oid  = self._get_observation_id(observation)
    lid  = self._get_id(locations, location)
    
    host = self._get_host('data', ggt='id%s' % oid, loc=lid)
    
    #host = host + '&from=%s' % time.strftime('%Y%m%d%H%M', self._get_timelist(datefrom))
    #host = host + '&to=%s' % time.strftime('%Y%m%d%H%M', self._get_timelist(dateto))
    
    df = self._get_timelist(datefrom)
    dt = self._get_timelist(dateto)
    
    host = host + '&from=%04d%02d%02d%02d%02d' % tuple(df[:5])
    host = host + '&to=%04d%02d%02d%02d%02d'   % tuple(dt[:5])
    
    #print host
    
    f        = urllib.urlopen(host)
    contents = csv.reader(codecs.iterdecode(f, 'iso-8859-1'), delimiter=';');
    header   = []
    data     = []
    
    for line in contents:
        if contents.line_num > 4:
            data.append(line)
        else:
            header.append(line)

    f.close()
    
    if consolidate:
      data = self._consolidate(data, header[-1])
    
    return data

  @staticmethod
  def interpolate(wl1, wl2, frac=0.5):
    '''Spatially interpolate two tidal time series using their phase difference

    Parameters
    ----------
    wl1 : dict
        Dictionary returned from the Waterbase.get_data function for station #1
    wl2 : dict
        Dictionary returned from the Waterbase.get_data function for station #2
    frac : float or list
        Averaging weight for station #1, the weight for station #2 will be 1-frac. If
        frac is iterable, all values are computed and returned.

    Returns
    -------
    pandas.DataFrame
        Pandas DataFrame with datetime axis containing the original two time series
        (s1 and s2) and the interpolated time series (interp_%f0.2).

    Notes
    -----
    Time shift is computed using a unnormalized cross-correlation of the original
    two time series.

    Examples
    --------

    >>> wl1 = w.get_data('1', 'Hoek van Holland', datetime(2014, 9, 1), datetime(2014, 11, 1))
    >>> wl2 = w.get_data('1', 'Scheveningen',     datetime(2014, 9, 1), datetime(2014, 11, 1))
    >>> df = w.interpolate(wl1, wl2, frac=[0.25, 0.5, 0.75])
    >>> df.plot(xlim=(datetime(2014, 9, 10), datetime(2014, 9, 10, 6)))
    '''

    if not hasattr(frac, '__getitem__'):
      frac = [frac]
    
    # determine time step of time series
    s1 = np.median([x.seconds for x in np.diff(wl1['datetime'])])
    s2 = np.median([x.seconds for x in np.diff(wl2['datetime'])])
    s = np.min((s1, s2))

    # built dataframe with common time axis
    s1 = pd.Series(wl1['value'], index=wl1['datetime'], name='s1')
    s2 = pd.Series(wl2['value'], index=wl2['datetime'], name='s2')
    df = pd.concat([s1, s2], axis=1).resample('%dS' % s).interpolate()

    # correlate signals
    xcorr = scipy.signal.correlate(df['s1'], df['s2'])

    # determine time shift
    n = len(df)
    dt = np.linspace(-(n-1)*s, (n-1)*s, 2*n-1)
    dt = dt[xcorr.argmax()]

    # shift time axes and average
    df = df.resample('S').interpolate()
    for f in frac:
      df['interp_%0.2f' % f] = (f * df['s2'].shift(dt) + (1-f) * df['s1']).shift(-f*dt)

    return df.resample('%dS' % s)
  
  def _consolidate(self, data, header):
    
    consolidated = {'_length':-1}
    
    data = np.array(data)
    for i, col in enumerate(header):
    
      col = self._normalize_name(col)
      
      if data.shape[1] > i:
        values = np.unique(data[:,i])
      
        if len(values) == 1 and col not in ('date','time','value'):
          if re.match('^\s*[-\+]?[\.\d]+\s*$', values[0]):
            consolidated[col] = self._str2num(values[0])
          else:
            consolidated[col] = values[0]
        else:
          consolidated[col] = data[:,i]
          if consolidated['_length'] < 0:
            consolidated['_length'] = data.shape[0]
          else:
            consolidated['_length'] = min(consolidated['_length'], data.shape[0])
            
    consolidated['_length'] = max(consolidated['_length'], 1)

    # convert value arrays to numbers/datetimes
    tz = pytz.timezone('MET')
    consolidated['value'] = np.asarray([float(x) for x in consolidated['value']])
    consolidated['datetime'] = [tz.localize(datetime.strptime('%s %s' % (d, t), '%Y-%m-%d %H:%M')) \
                                for d, t in zip(consolidated['date'], consolidated['time'])]
      
    return consolidated
    
  def _get_coded_options(self, host, name):
    'Read options and extract identifiers'
    
    values, texts = self._get_select_options(host, name)
    codes, names = [],[]
    for i in range(len(values)):
        value = values[i]
        text  = texts[i]
        
        if value:
            # we should be able to get an id and the name
            idtxt = value.split('|')[0]
        else:
            continue
            
        codes.append(idtxt)
        names.append(text)    
    
    return (names, codes)
    
  def _get_select_options(self, host, name):
    'Read options'
    
    contents = urllib.urlopen(host).read()
    
    root = lxml.html.fromstring(contents)
    
    values,texts = [],[]
    
    for el in list(root.cssselect("select[name=%s]>option"%name)):
        # get the value that contains the id and the text
        value = el.attrib.get('value')
        text  = el.text
        if text:
            # strip string in order to remove possible newlines and leading or trailing spaces
            text = text.strip()
        values.append(value)
        texts.append(text)
    
    return (values, texts)
    
  def _get_theme_id(self, theme):
    'Get theme identifier based on either name, id or index'
    
    return self._get_id(self.themes, theme)
  
  def _get_observation_id(self, observation):
    'Get observation identifier based on either name, id or index'
    
    return self._get_id(self.observations, observation)
  
  def _get_id(self, arr, item):
    'Get identifier based on either name, id or index'
    
    id = ''
    
    try:
      idx = arr[0].index(item)
    except:
      try:
        idx = arr[1].index(item)
      except:
        if type(item) == int:
          idx = item
        else:
          idx = -1
          if len(str(item)) > 0:
            raise Exception('Item not found: %s' % str(item))
    
    if idx >= 0:
      id = arr[1][idx]
    
    return id
  
  def _get_host(self, typ, **args):
    'Construct hostname based on type and get parameters'
    
    host = self.host
    
    if typ == 'observation':
      host = host + 'waterbase_wns.cfm?taal=%s' % self.language
    elif typ == 'location':
      host = host + 'waterbase_locaties.cfm?taal=%s' % self.language
    elif typ == 'data':
      host = host + 'wswaterbase/cgi-bin/wbGETDATA?&lang=%s&a=getData&gaverder=GaVerder&fmt=text' % self.language
    elif typ == 'period':
      host = host + 'wswaterbase/cgi-bin/wbGETPERIODS?a=getInfo&m=periods&lang=%s' % self.language
    else:
      raise Exception('Unknown host type: %s' % str(typ))
        
    for k,v in args.iteritems():
      host = host + '&%s=%s' % (k, str(v))
      
    return host
    
  def _get_timelist(self, tm):
    'Get vectorial representation of time given a struct, string, number or vector'
    
    if type(tm) is list:
      return tm
    elif type(tm) is time.struct_time:
      return list(tm)
    elif type(tm) is datetime:
      return list(tm.utctimetuple())
    elif type(tm) is str:
      return list(time.strptime(tm))
    elif type(tm) is float or type(tm) is int or type(tm) is long:
      return list(timetuple.epoch2timetuple(tm))
    else:
      print type(tm)
      raise Exception('Unknown time type: %s' % type(tm).__name__)
      
  def _normalize_name(self, name):
    'Returns a normalized variable name suitable for the use within netCDF files'
    
    return re.sub('[^\w\d]+','_',name).lower()
    
  def _str2num(self, value):
    try:
      return int(value)
    except:
      return float(value)
  
    
