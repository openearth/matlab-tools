import datetime
import pydap.client

from numpy import any, all, ma, apply_along_axis, nonzero, array, isnan, nan
from scipy.interpolate import interp1d
from functools import partial

url = '${config.get("jarkus.url")}'
# Create a dataset object.
ds = pydap.client.open_url(url)
transect_index = nonzero(ds['id'] == ${transect.id})[0][0]
#

# pydap returns altitude as a grid object, so we need to specify that we want only the values
z = ds['altitude']['altitude'][:,transect_index,:]
z[z==-9999] = nan
# read cross shore distance
cross_shore = ds['cross_shore'][:]
# read and convert time
time = ds['time'][:]
# you could convert these using: [datetime.timedelta(days=day) + datetime.date(1970,1,1) for day in ds['time'][:]]


# Fill missings to create a better plot
def fillmissing(x,y):
    """fill nans in y using linear interpolation"""
    f = interp1d(x[~isnan(y)], y[~isnan(y)], kind='linear',bounds_error=False, copy=True)
    new_y = f(list(x)) #some bug causes it not to work if x is passed directly
    return new_y
# define an interpolation for a row by partial function application
rowinterp = partial(fillmissing, cross_shore)
# apply to rows (along columns)
z = apply_along_axis(rowinterp, 1, z)

from enthought.mayavi import mlab
mlab.surf(z,mask=isnan(z), representation='wireframe')
mlab.show()
