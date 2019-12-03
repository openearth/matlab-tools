# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

# system modules
import os
import sys
import logging
import itertools

# shortcuts by convention
import numpy as np
import matplotlib
#matplotlib.use('Agg')
import matplotlib.pyplot as plt

import shapely
import shapely.geometry
# for tables
import pandas
import pandas.io

# Use mx.DateTime objects because it can handle years 0<->200000, we can't use datetime, datetime64, time_struct's
import mx.DateTime 

# There's a few issues with the other date modules

# years > 9999, don't fit in the posix spec, thus don't work with python time_struct and datetime, which are built on posix

# Another issue is with the calendar, the Julian -> Gregorian switch.
# years where year % 100 == 0 and year <= 1500 did have a leap year (assuming you switch to julian calendar)
# The Gregorian calendar began by skipping 10 calendar days, to restore March 21 as the date of the vernal equinox.
# The Dutch provinces of Brabant, Zeeland and the Staten-Generaal also adopted it on 25 December 1582
# Southern Netherlands (Limburg?) switched on 1 January 1583, the province of Holland followed switched on 12 January 1583

# the only date type that handles this is mx.DateTime.JulianDate
# If you use the gregorian calendar you'd have to go use non-leap year for 1500
# So, because the input has dates like 1500-2-29, we have to assume that we're still using the Julian calendar.
# Let's reset our clocks
print 'Today is', mx.DateTime.now().Julian(), 'in the Julian calendar, which we are using here.'



# <codecell>

# the time horizon
horizon = 15

# Dataset for caching
# use hdf5 here (faster than csv, no metadata)
store = pandas.io.pytables.HDFStore('store.h5')
print store.keys()

# <codecell>

# The input file
filename = 'invoer/2000012310000_BorgharenHBV_Glue50.XML'
#filename = 'sample.txt'
# show the header
with open(filename) as f:
    for i, line in enumerate(f):
        print line,
        if i>2:
            break

# <codecell>


def read_file(filename):
    """Read the file, assuming the format YYYY[Y]? MM DD HH MM VALUE, yield years"""
    # Creating an array of 2 ints and 1 double for 20k year is about 500MB of memory.
    # Normaly you would just read everything in memory. But with an estimate of 50k year memory would be full. 
    # So we do a running mean. For convenience we generate data grouped by years.
    with open(filename) as f:
        f.next()
        f.next()
        # Keep a moving year in memory, yield 3 years (old, current, next)
        currentyear = 0
        for line in f:
            # This is the most cpu expensive part. 
            # Data is in a mixed format so there is no easy way to do this....
            row = line.split()
            # No time, just dates, should be enough
            date = mx.DateTime.JulianDate(int(row[0]), int(row[1]), int(row[2]))
            
            value = float(row[-1])
            yield (date.year, date.day_of_year, value)

def groupyears(data):
    """goup years in data"""
    keyfunc = lambda x:x[0]
    for year, daysvalues in itertools.groupby(data, keyfunc):
        # return a tuple of all year data...
        yield list(daysvalues)

def two(iterator):
    """yield a running window of three elements"""
    # generalize to n using stack pop, append
    
    # default to returning an empty list, assuming that elements are iterable
    old = []
    current = []
    for item in iterator:
        old = current
        current = item
        yield (old,current)

# more generic.... but missing the first and last element
# this would start at year 2 and end at year 19999
def window(seq, n=3):
    "Returns a sliding window (of width n) over data from the iterable"
    "   s -> (s0,s1,...s[n-1]), (s1,s2,...,sn), ..."
    # we're using iterators
    it = iter(seq)
    # take the first n elements
    result = tuple(itertools.islice(it, n))
    # and return it, except if len(result) < n
    if len(result) == n:
        yield result
    # now loop over all the elements, rolling th window
    for elem in it:
        result = result[1:] + (elem,)
        yield result

# <codecell>

def annualmaximum(annual, currentyear, horizon=15):
    """look up the annual maximum"""
    # find the maximum discharge
    idxmax = annual['discharge'].idxmax()
    # make a window (not bigger than what we have...)
    # some implicit assumptions, better check...
    window = slice(max(idxmax - horizon,annual.index.min().item()), min(idxmax + horizon,annual.index.max().item()))
    records = annual.ix[window]
    records['eventyear'] = currentyear
    # Create relative dates
    records['day_from_event'] = np.asarray(records.index) - idxmax

    # returns list of tuple instead of dataframe to reduce memory usage
    # drop the index (x[0])
    data = list(x[1:] for x in records[['eventyear','day_from_event','discharge']].itertuples())
    return data

# main loop to compute all the annual maxima
def compute_annualmaxima(data):
    allrecords = []
    yearsiter = two(groupyears(data))
    for i, (oldyear, currentyear) in enumerate(yearsiter):
        # We do need a currentyear...
        if not currentyear:
            continue
        # which year are we taking the max of
        df = pandas.DataFrame(oldyear + currentyear, columns=('year', 'day_of_year', 'discharge'))
        hydrologicyear = currentyear[0][0]-1
        # We use days of year here, 274 == October 1st in a leap year
        hydrologicyearfilter = np.logical_or(
            np.logical_and(df['year'] == hydrologicyear, df['day_of_year'] >= 274),
            np.logical_and(df['year'] == hydrologicyear+1, df['day_of_year'] < 274)
            )
        # Lookup the records surrounding the annual maximum
        records = annualmaximum(df[hydrologicyearfilter], currentyear=hydrologicyear)
        allrecords.extend(records)
    df = pandas.DataFrame.from_records(allrecords, columns=['eventyear', 'day_from_event', 'discharge'])
    return df

# <codecell>

def compute_daysover(df):
    grouped = df.groupby(['eventyear'])
    dayscum = []
    def count(x):
        return len(x)
    
    for year, event in iter(grouped):
        # let's do some geometry
        x = [-15] + list(event['day_from_event']) + [15, -15]
        y = [0] + list(event['discharge']) + [0, 0]
        poly = shapely.geometry.Polygon(np.c_[x,y].tolist())
        # let's start drawing
        # some arbitrary top, so we can do an intersection
        for low in range(0,5000,100):
            high = low+100
            # Create the left and right box
            lbox = shapely.geometry.Polygon([[-15, high], [0, high], [0,low], [-15,low],[-15, high]])
            rbox = shapely.geometry.Polygon([[0, high], [15, high], [15,low], [0,low],[0, high]])
            # store the intersection areas
            dayscum.append((low, high, lbox.intersection(poly).area, rbox.intersection(poly).area))
    dayscum = np.array(dayscum)
    daysoverdf = pandas.DataFrame(dict(start=dayscum[:,0], end=dayscum[:,1], left=dayscum[:,2], right=dayscum[:,3]))
    return daysoverdf

# <codecell>

# cache
# do we have data?
if 'data' in store.keys():
    data = store['data']
else:
    # store as a dataframe 
    # memory is about 250MB for 20k years
    # to save memory, pass read_file iterator to compute_annualmaximum
    data = pandas.DataFrame.from_records(list(read_file(filename)), columns=['year', 'day_of_year', 'discharge'])
    store['data'] = data
    store.flush()
    
# do we have the maxima?
# compute_annualmaxima is O(n) in CPU and memory.
# runtime +- 60ms per year (about 2m30 for 20k years)
# memory +- 100MB for 20k years, 20MB on disk
if 'annual_maxima' in store.keys():
    df = store['annual_maxima']
else:
    # pass the data as an array, looping over a dataframe is a bit annoying
    df = compute_annualmaxima(np.array(data))
    store['annual_maxima'] = df
    store.flush()

# do we have the daysover?
# Number of days over a certain discharge
if 'daysover' in store.keys():
    daysoverdf = store['daysover']
else:
    # pass the data as an array, looping over a dataframe is a bit annoying
    daysoverdf = compute_daysover(df)
    store['daysover'] = daysoverdf
    store.flush()

# <codecell>


