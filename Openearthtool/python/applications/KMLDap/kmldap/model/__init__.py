from pylons import config

from pylons.decorators import cache

from numpy import nonzero, array

import datetime
from transect import Transect, PointCollection

import pydap.model

def pydaptonetcdf(dataset):
    """make a pydap dataset look and quack like a netcdf4 dataset"""
    assert isinstance(dataset, pydap.model.DatasetType)
    dataset.variables = {}
    for variable in dataset.keys():
        if isinstance(dataset[variable], pydap.model.GridType):
            dataset.variables[variable] = dataset[variable][variable]
            dataset.variables[variable].attributes.update(dataset[variable].attributes)
        else:
            dataset.variables[variable] = dataset[variable]
        
    return dataset

def opendap(url):
    """return the dataset"""
    if config.get('opendap.client') == 'netCDF4':
        import netCDF4
        dataset = netCDF4.Dataset(url)
    else:
        import pydap.client
        dataset = pydaptonetcdf(pydap.client.open_url(url))

    # These should not be set in this function but in the controller, or through perhaps through **kwargs
    # for example dataset.attributes.update(kwargs)
    # 
    params = {}
    params.update({'coordsys':config.get('operational.coordsys'),
                   'xori':int(config.get('operational.xori',0)),
                   'yori':int(config.get('operational.yori',0))})
    if config.get('operational.refdate'):
        refdate = datetime.datetime.strptime(config['operational.refdate']+config['operational.reftime'],'%Y%m%d%H%M%S')
    else:
        refdate = datetime.datetime.now()
    params['refdate'] = refdate
    dataset.attributes['PARAMS'] = params
    return dataset
        


@cache.beaker_cache('id', expire=60)
def makejarkustransect(id):
    url = config.get('jarkus.url', '/Users/fedorbaart/Documents/checkouts/OpenEarthRawData/trunk/rijkswaterstaat/jarkus/scripts/jarkus23-Jul-2009.nc') # TODO: change this
    if not config.has_key('jarkus.client'):
        config['jarkus.client'] = 'netcdf4' # TODO:remove this
    if config['jarkus.client'] == 'pydap':
        import pydap.client
        import pydap.model
        dataset = pydap.client.open_url(url)
        # make pydap consistent with the netcdf 4 interface
        dataset.variables = {
            'time': dataset['time'],
            'id': dataset['id'],
            'lon': dataset['lon']['lon'],
            'lat': dataset['lat']['lat'],
            'altitude': dataset['altitude']['altitude'],
            'cross_shore': dataset['x']['cross_shore'],
            'alongshore': dataset['x']['alongshore'],
            'rsp_lat': dataset['rsp_lat'],
            'rsp_lon': dataset['rsp_lon'],
            'mean_high_water': dataset['mean_high_water'],
            'mean_low_water': dataset['mean_low_water']
            }
        dataset.variables['altitude'].attributes.update(dataset['altitude'].attributes)
    elif config['jarkus.client'] == 'netcdf4':
        import netCDF4
        dataset = netCDF4.Dataset(url)
    tr = Transect(id)

    # we're just gonna get some simple dataset
    # url = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'
    # dataset = dap.client.open(url, verbose=True)
    # these are the variables we use in the template.  It's better to use objects here (for example transect)
    # but to make it look a bit like matlab we use a dictionary
    
    years = dataset.variables['time'][:]
    id = dataset.variables['id'][:] 
    alongshoreindex = nonzero(id == tr.id)
    alongshoreindex = alongshoreindex[0][0]
    lon = dataset.variables['lon'][alongshoreindex,:] 
    lat = dataset.variables['lat'][alongshoreindex,:] 
    #filter out the missing to make it a bit smaller
    z = dataset.variables['altitude'][:,alongshoreindex,:]
    filter = z == dataset.variables['altitude']._FillValue # why are missings not taken into account?
    z[filter] = None
    t = array([datetime.datetime.fromtimestamp(days*3600*24) for days in years])
    cross_shore = dataset.variables['cross_shore'][:]
    # leave out empty crossections and empty dates
    tr.lon = lon[(~filter).any(0)]
    tr.lat = lat[(~filter).any(0)]
    # keep what is not filtered in 2 steps 
    #         [over x            ][over t            ]
    tr.z = z[:,(~filter).any(0)][(~filter).any(1),:] 
    tr.t = t[(~filter).any(1)]
    tr.cross_shore = cross_shore[(~filter).any(0)]

    # get the water level variables
    mhw = dataset.variables['mean_high_water'][alongshoreindex]
    mlw = dataset.variables['mean_low_water'][alongshoreindex]
    tr.mhw = mhw.squeeze()
    tr.mlw = mlw.squeeze()

    if hasattr(dataset, 'close'):
        dataset.close()
    return tr

@cache.beaker_cache(None, expire=600)
def makejarkusoverview():
    url = config['jarkus.url']
    if config['jarkus.client'] == 'pydap':
        import pydap.client
        import pydap.model
        dataset = pydap.client.open_url(url)
        # make pydap consistent with the netcdf 4 interface
        dataset.variables = {
            'time': dataset['time'],
            'id': dataset['id'],
            'lon': dataset['lon']['lon'],
            'lat': dataset['lat']['lat'],
            'altitude': dataset['altitude']['altitude'],
            'cross_shore': dataset['x']['cross_shore'],
            'alongshore': dataset['x']['alongshore'],
            'rsp_lat': dataset['rsp_lat'],
            'rsp_lon': dataset['rsp_lon']
            }
        dataset.variables['altitude'].attributes.update(dataset['altitude'].attributes)
    elif config['jarkus.client'] == 'netcdf4':
        import netCDF4
        dataset = netCDF4.Dataset(url)
    points = PointCollection()
    # we're just gonna get some simple dataset
    #url = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'
    #dataset = dap.client.open(url, verbose=True)
    # these are the variables we use in the template.  It's better to use objects here (for example points)
    # but to make it look a bit like matlab we use a dictionary
    id = dataset.variables['id'][:] # ? why
    #cross_shore = dataset.variables['cross_shore'][:] # look up index of 0
    #rsp = nonzero(cross_shore==0)[0] #find location of rijks strand paal
    lon = dataset.variables['rsp_lon'][:] #[:,rsp] #? can this be done simpler?
    lat = dataset.variables['rsp_lat'][:] #[:,rsp] #?
    points.id = id
    points.lon = lon
    points.lat = lat
    if hasattr(dataset, 'close'):
        dataset.close()
    return points
    

