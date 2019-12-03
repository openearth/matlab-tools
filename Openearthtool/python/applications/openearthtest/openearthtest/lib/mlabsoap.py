# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 13:22:00 2011

@author: Wiebe de Boer
"""
import beaker.cache
cache = beaker.cache.CacheManager()
import pydap.client
import matplotlib.pyplot as plt
import cStringIO
import suds
@cache.cache('mycache')
def getdata(variable='sea_surface_height',tstart='20000101T010000',tstop='20010101T010000'):
    url = 'http://dtvirt13/BwnMatLab/BwnFunctions.asmx?wsdl'
    client = suds.client.Client(url)
    print client
    opendapurl = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-KATWK.nc'
    a = client.service.PlotTimeSeries(opendapurl, variable, tstart, tstop)
    return a
def plot(variable='sea_surface_height'):
    opendapurl = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-KATWK.nc'
    ds = pydap.client.open_url(opendapurl)
    z = ds[variable][:]
    plt.plot(z)
    s = cStringIO.StringIO()
    plt.savefig(s, format='png')
    # do this in controller
    # add content-type('png')
    s.seek(0)
    return s.read()
    
import Image
Image.open(cStringIO.StringIO(plot(variable='time'))).show()
