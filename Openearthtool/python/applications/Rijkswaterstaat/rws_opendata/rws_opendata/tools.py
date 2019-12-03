import logging
import argparse

import pandas

from . import locations
from . import measurements
from . import netcdf
def update_netcdf():
    logging.basicConfig(level=logging.DEBUG)
    logging.info('Updating RWS OpenData netCDF mirror')

    logging.info('Download locations...')
    df_locations = locations.get()
    logging.info('Download observations...')
    df_measurements = measurements.get()

    logging.info('Appending observations to netCDF...')

    df = pandas.merge(df_measurements, df_locations, how='left', on='location_name', suffixes=('','_donar'))
    n = netcdf.append_netcdf(df)
    logging.info('Added %d records to netCDF files' % n)


