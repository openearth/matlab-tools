from threading import Lock

# Make matlabwrap a bit more threadsafe
def synchronized(lock):
    """ Synchronization decorator. """

    def wrap(f):
        def newFunction(*args, **kw):
            lock.acquire()
            try:
                return f(*args, **kw)
            finally:
                lock.release()
        return newFunction
    return wrap
    
lock = Lock()

#@synchronized(lock)
def getmlab(instance={}):
    if "mlab" not in instance:
        from mlabwrap import mlab
        # This should be True (default)
        # use this getattr approach because I think the __getattr__ is overwritten
        # assert(getattr(mlab, '_autosync_dirs', True))
        setattr(mlab, '_autosync_dirs', False)
        mlab.addpath(mlab.genpath(r'd:\Repositories\oetools\python\applications\openearthtest'))
        #mlab.addpath(r'd:\Repositories\oetools\websites')
        mlab.addpath(mlab.genpath(r'd:\Repositories\oetools\matlab'))
        mlab.addpath(r'd:\Repositories\oetools\websites\dataviewer\tools\Tool_Giorgio')
        mlab.oetsettings()
        #mlab.addpath(r'd:\Repositories\oetools\python')
        instance['mlab'] = mlab
    return instance['mlab']
# def getinterpolatedata():
#    import pydap.client
#    url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/tno/ahn100m/mv250.nc'
#    ds = pydap.client.open_url(url)
#    lon = ds['longitude_cen']['longitude_cen'][:]
#    lat = ds['latitude_cen']['latitude_cen'][:]
#    z = ds['AHN250']['AHN250'][:]
#    return lon, lat, z