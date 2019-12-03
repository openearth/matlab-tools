# -*- coding: utf-8 -*-
"""
Created on Mon Oct 14 15:00:33 2013

@author: hendrik_gt

# ---------------------------------------------------------------------------
# Created by Gerrit Hendriksen (gerrit.hendriksen@deltares.nl)
# v1.0 created on 14-10-2013 (ddmmyyyy)
#
# Description: Open netCDF4 on OPeNDAP for reading, querying and display time
#              series on via matplotlib specifically for netCDF's from the ECOHAM model from University of Hamburg
#              The UHAM nc's are organized in a different way then the Delwaq nc's. For every specie a seperate nc's is created
#              with the species name in the filename
#              Also the structure is a little bit different, shape is (time, depth,lat, lon)
"""

import itertools
import numpy as np

import netCDF4
import netcdftime

import pandas

from shapely.geometry import Polygon,Point
from beaker.cache import cache_region

import openearthtools.io.opendap.catalog

#"""test"""
#
#url = r'D:\projecten\EU\VECTORS\repos\trunk\northsea\ecoham\D093_2003_PO4.nc'
#
#url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/uham/D093_2003_PO4.nc'
#
#dataset = netCDF4.Dataset(url)
#
#times =  netcdftime.num2date(dataset.variables['time'][:], dataset.variables['time'].units)
#depth = dataset.variables['depth'][:]
#aspecies = 'PO4'
#
#lon = dataset.variables["longitude"][:]
#lat = dataset.variables["latitude"][:]
#
#conc = dataset.variables[aspecies][:,0,:,:]
#
#apoly = get_ices_polygon()
#
#indices = []
# speed this up....
# Match up the latitude longitudes with the polygon...
# I don't understand why we're using a polygon


#indices = np.array(indices)


def UHAM_species():
    # Namen van Delwaq parameters ter vergelijking:
    #Delwaq name:Long name,Unit,CF-name
    dctspecies = {'NH4':['Ammonium (NH4)','gN/m3','mass_concentration_of_ammonium_in_sea_water',''],
                  'NO3':['Nitrate (NO3)','gN/m3','mass_concentration_of_nitrate_in_sea_water',''],
                  'PO4':['Ortho-Phosphate (PO4)','gP/m3','mass_concentration_of_phosphate_in_sea_water',''],
                  'Si':['dissolved Silica (Si)','gSi/m3','mass_concentration_of_silicate_in_sea_water',''],
                  'ExtVl':['total extinction coefficient visible light','1/m','volume_attenuation_coefficient_of_downwelling_radiative_flux_in_sea_water',''],
                  'Temp':['ambient water temperature','degrees C','sea_water_temperature_expressed_as_degrees_celsius',''],
                  'fPPtot':['total net primary production','gC/m2/d','tendency_of_mass_concentration_of_particulate_organic_matter_expressed_as_carbon_in_sea_water_due_to_net_primary_production',''],
                  'Phyt':['total carbon in phytoplankton','gC/m3','mass_concentration_of_phytoplankton_expressed_as_carbon_in_sea_water',''],
                  'Chlfa':['Chlorophyll-a concentration','g/m3','mass_concentration_of_chlorophyll_in_sea_water',''],
                  'Chlfa2':['Chlorophyll-a concentration','g/m2','mass_of_chlorophyll_in_sea_water_per_unit_area','']
                 }
    return dctspecies


@cache_region('long_term')
def get_arrays(url,aspecies='PO4'):
   # print url,aspecies
    aspecies = 'PO4'
    dataset = netCDF4.Dataset(url)
    times =  netcdftime.num2date(dataset.variables['time'][:], dataset.variables['time'].units)
    conc = dataset.variables[aspecies][:,0,:,:]
    # lookup space for the first dataset
    lon = dataset.variables["longitude"][:]
    lat = dataset.variables["latitude"][:]
    dataset.close()
    return {'lat': lat, 'lon': lon, 'times': times, 'conc':conc}


# Define a function that we can run in parallel
def mean_concentration(data_indices):
    """compute the mean concentration for a url"""
    data, indices = data_indices
    # this is the slow part, reading all concentrations, takes
    rows = []
    # I think this is slow
    for tidx, t in enumerate(data['times']):
        if indices.shape[0] < 1:
            continue
        arrconc = data['conc'][tidx,indices[:,0], indices[:,1]]
        rows.append((t, pandas.Period(t.strftime('%Y-%m'),'M'), arrconc.mean()))
    return list(sorted(rows))


def species(apoly=Polygon(), aspecies='PO4'):
    """Lookup the species in a polygon"""
    catalogurl = 'http://opendap.deltares.nl/thredds/catalog/opendap/uham/catalog.xml'
    urls = list(openearthtools.io.opendap.catalog.getchildren(catalogurl))

    # Filter by aspecies...
    urls = [url for url in urls if '_' + aspecies in url and not '_2008_' in url]


#    urls = ['../../data/D093_2003_PO4.nc',
#            '../../data/D093_2004_PO4.nc',
#            '../../data/D093_2005_PO4.nc',
#            '../../data/D093_2006_PO4.nc',
#            '../../data/D093_2007_PO4.nc',
#            '../../data/D093_2008_PO4.nc']

    
    #the only a range of latlons have to be given.
    data = get_arrays(urls[0],aspecies)
    lon = data['lon']
    lat = data['lat']

    indices = []
    for m in range(len(lon)):
        for n in range(len(lat)):
            pt=Point(lon[m],lat[n])
            if apoly.contains(pt):
                indices.append((m,n))

    indices = np.array(indices)
    #print 'uham',indices

    # compute the mean of each polygon intersect
    datas = map(get_arrays, urls, aspecies)
    listofrows = map(mean_concentration, [(data, indices) for data in datas])
    #pool.close()
    # reduce the list
    # See http://stackoverflow.com/questions/952914/making-a-flat-list-out-of-list-of-lists-in-python
    allrows = list(itertools.chain.from_iterable(listofrows))

    # create dataframe of vals and datetime index
    if allrows:
        df = pandas.DataFrame(allrows, columns=["time", "yearmonth", "concentration"])
    else:
        df = pandas.DataFrame(columns=["time", "yearmonth", "concentration"])
    # don't group here, because df may be empty...
    return df
