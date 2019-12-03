#setup a transect... 
# Some fixtures which can be used for testing
import cStringIO
import matplotlib
# use in memory backend
matplotlib.use('Agg')

from matplotlib import pyplot as p
from matplotlib import text
import kmldap.model


def remotetransect(id=7003800):
    '''remote'''
    import pydap.client
    import kmldap.model
    dataset =  pydap.client.open_url('http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/jarkus/profiles/transect.nc')
    transect = kmldap.model.makejarkustransect(id)
    return transect
def localtransect(id=7003800):
    '''local'''
    url = '/Users/fedorbaart/Documents/checkouts/OpenEarthRawData/trunk/rijkswaterstaat//jarkus/scripts/jarkus23-Jul-2009.nc'
    import netCDF4
    import netcdftime
    import datetime
    from numpy import nonzero, nan
    dataset = netCDF4.Dataset(url)
    transect = kmldap.model.transect.Transect(id)
    # convert to datetime and add an hour
    years = dataset.variables['time'][:]
    id = dataset.variables['id'][:]
    alongshoreindex = nonzero(id == transect.id)
    x = dataset.variables['lon'][alongshoreindex].squeeze() #?
    y = dataset.variables['lat'][alongshoreindex].squeeze() #?
    #filter out the missing to make it a bit smaller
    dataset.variables['altitude'].set_auto_maskandscale(True)
    z= dataset.variables['altitude'][:,alongshoreindex[0],:].squeeze()
    z.set_fill_value(nan)
    t = dataset.variables['time']
    t = netcdftime.utime(t.units).num2date(t[:]) + datetime.timedelta(hours=1)

    cross_shore = dataset.variables['cross_shore'][:]
    # leave out empty crossections and empty dates
    transect.x = x[(~z.mask).any(0)]
    transect.y = y[(~z.mask).any(0)]
    # keep what is not filtered in 2 steps 
    #         [over x            ][over t            ]
    transect.t = t[(~z.mask).any(1)]
    transect.cross_shore = cross_shore[(~z.mask).any(0)]
    transect.z = z[:,(~z.mask).any(0)][(~z.mask).any(1),:].filled()
    
    transect.mhw = dataset.variables['mean_high_water'][alongshoreindex].squeeze()
    transect.mlw = dataset.variables['mean_low_water'][alongshoreindex].squeeze()
    return transect



# interpolation function, interpolate of area without missing, using a linear function.

import kmldap.lib.plots
from numpy import newaxis, zeros, hstack, isnan

from matplotlib.dates import mx2num, date2num
#kmldap.lib.plots.eeg(transect)



