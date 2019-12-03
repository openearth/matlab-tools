import opendata
import netcdf
import locations
import opendap

import pandas
import logging

logging.basicConfig(level=logging.DEBUG)

logging.info('===================================')
logging.info('Updating RWS OpenData netCDF mirror')
logging.info('===================================')

logging.info('Download locations...')

df_locations = locations.get_locations()

logging.info('Download observations...')

df_opendata = opendata.get_observations()

logging.info('Appending observations to netCDF...')

df = pandas.merge(df_opendata, df_locations, how='left', on='location_name', suffixes=('','_donar'))
n = netcdf.append_netcdf(df)

logging.info('Added %d records to netCDF files' % n)
logging.info('Transferring files to OpenDAP server...')

files = opendap.transfer_netcdf()

logging.info('Transferred the following files:')

for f in files:
    logging.info('    %s' % f)
