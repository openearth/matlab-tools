"""
Read and parse data from Rijkswaterstaat opendata.
These functions download and read the measurements.zip file, extract it and
convert it to a pandas dataframe.
The get function calls the other functions.
"""

import urllib2
from zipfile import ZipFile
import io
import time
import dateutil
import datetime
import functools
import logging
import contextlib

import pandas
import netCDF4
import requests

from . import URLS

def parse(header, data):
    '''Parse header and data CSV files and return as pandas DataFrame'''

    # data column definition
    names = ('source',
             'location_code',
             'empty',
             'parameter_code',
             'location_name',
             'parameter_name',
             'units',
             'date_start',
             'date_end',
             'format')

    # convert header and data to pandas DataFrame
    df_header = pandas.read_csv(io.BytesIO(header),names=names)
    df_data   = pandas.read_csv(io.BytesIO(data),names=range(6),index_col=False)

    # strip headers
    for k in df_header.keys():
        df_header[k] = df_header[k].apply(str.strip)

    # glue headers and data together and rearange data
    df = pandas.concat((df_data, df_header),axis=1)
    df_melted = pandas.melt(df,id_vars=names, value_vars=range(6), var_name='time_index')

    # parse dates and times
    # parse start and end date and compute time delta from time index
    # create a date field indicating the actual datetime
    # convert to unix epoch
    df_melted['date_start'] = df_melted['date_start'].apply(dateutil.parser.parse)
    df_melted['date_end'] = df_melted['date_end'].apply(dateutil.parser.parse)
    df_melted['time_delta'] = df_melted['time_index'].apply(lambda x: datetime.timedelta(minutes=int(x)*10))
    df_melted['date'] = df_melted['date_start'] + df_melted['time_delta']
    f = functools.partial(netCDF4.date2num, units="seconds since 1970-01-01")
    df_melted['time'] = df_melted['date'].apply(f)

    # strip data and convert None values
    df_melted['value'] = df_melted['value'].apply(str.strip)
    df_melted['value'] = df_melted['value'].replace(['f', 'n'], 'nan').astype('float')

    # remove left over column
    del df_melted['empty']

    return df_melted

def extract(zipfile):
    '''Download observations and convert to pandas DataFrame'''

    logging.info("got zipfile with {}".format(zipfile.namelist()))
    # unpack header and data
    header = zipfile.read('update.adm')
    data   = zipfile.read('update.dat')
    return header, data


def download(url=URLS['measurements']):
    """download opendata measurements and return the zipfile (in memory)"""
    with contextlib.closing(requests.get(url)) as response:
        bytes = io.BytesIO(response.content)
    zipfile = ZipFile(bytes)
    return zipfile

def get():
    """download and extract measurements from RWS opendata"""
    zipfile = download()
    header, data = extract(zipfile)
    df = parse(header, data)
    return df
