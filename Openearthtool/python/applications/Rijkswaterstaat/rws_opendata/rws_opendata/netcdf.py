import netCDF4
import os
import time
import numpy as np

import rws_opendata

def create_netcdf(df, l):
    '''Create a new netCDF file to be appended in the future'''

    # get unique values for each dimension
    sources = df['source'].drop_duplicates()
    locations = df['location_code'].drop_duplicates()
    parameters = df['parameter_code'].drop_duplicates()

    fname = '%s.nc' % locations.values[l]

    # create netCDF file
    nc = netCDF4.Dataset(fname,'w')

    # create dimensions
    nc.createDimension('source',sources.count())
    #nc.createDimension('location',locations.count())
    nc.createDimension('location',1)
    nc.createDimension('parameter',parameters.count())
    nc.createDimension('time',None)

    # create variables
    nc.createVariable('source',str,('source'))
    nc.createVariable('location_code',str,('location'))
    nc.createVariable('location_name',str,('location'))
    nc.createVariable('x',np.int32,('location'))
    nc.createVariable('y',np.int32,('location'))
    nc.createVariable('lat',np.float32,('location'))
    nc.createVariable('lon',np.float32,('location'))
    nc.createVariable('parameter_code',str,('parameter'))
    nc.createVariable('parameter_name',str,('parameter'))
    nc.createVariable('units',str,('parameter'))
    nc.createVariable('time',np.int32,('time'))
    nc.createVariable('value',np.float32,('time','parameter','location','source'))

    # fill static variables
    nc.variables['source'][:]         = sources.values
    nc.variables['location_code'][0]  = locations.values[l]
    nc.variables['location_name'][0]  = df['location_name'][locations.index].values[l]
    nc.variables['x'][0]              = df['x'][locations.index].values[l]
    nc.variables['y'][0]              = df['y'][locations.index].values[l]
    nc.variables['lat'][0]            = df['lat'][locations.index].values[l]
    nc.variables['lon'][0]            = df['lon'][locations.index].values[l]
    nc.variables['parameter_code'][:] = parameters.values
    nc.variables['parameter_name'][:] = df['parameter_name'][parameters.index].values
    nc.variables['units'][:]          = df['units'][parameters.index].values

    # add attributes
    nc.variables['x'].setncattr('EPSG',28992)
    nc.variables['y'].setncattr('EPSG',28992)
    nc.variables['lat'].setncattr('EPSG',4326)
    nc.variables['lon'].setncattr('EPSG',4326)

    # add global attributes
    nc.description  = '10 min interval measurements from Rijkswaterstaat Open Data: http://www.rws.nl/rws/opendata/'
    nc.inistitution = 'Rijkswaterstaat'
    nc.history      = 'Created ' + time.ctime(time.time())
    nc.source       = rws_opendata.URLS['measurements']
    nc.location     = df['location_name'][locations.index].values[l]

    return nc

def append_netcdf(df):
    '''Append new data to existing netCDF or create one if it doesn't exist'''

    # determine unique dimension values
    sources = df['source'].drop_duplicates()
    locations = df['location_code'].drop_duplicates()
    parameters = df['parameter_code'].drop_duplicates()
    tstamps = df['time'].drop_duplicates()

    # loop over locations and create a netCDF for each location
    n = 0
    for l, location in enumerate(locations):

        fname = '%s.nc' % location

        if not os.path.exists(fname):
            nc = create_netcdf(df, l)
        else:
            nc = netCDF4.Dataset(fname,'a')

        # add time steps that are not yet present in netCDF
        new_records = [(i,t) for i,t in enumerate(tstamps) if t not in nc.variables['time']]
        if len(new_records) > 0:
            idx, tstamps = zip(*new_records)
            nt = len(nc.dimensions['time'])
            nc.variables['time'][nt:nt+len(idx)] = tstamps

            # add data corresponding to new time steps
            for i, source in enumerate(nc.variables['source'][:]):
                for j, param in enumerate(nc.variables['parameter_code'][:]):
                    k = 0
                    df_select = df[(df['source'] == source) & (df['parameter_code'] == param)] # & (df['location_code'] == location)]
                    if len(df_select)>0:
                        nc.variables['value'][nt:nt+len(idx),j,k,i] = df_select['value'].values[list(idx)]

            n = n + len(new_records)

        nc.close()

    return n
