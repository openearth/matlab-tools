from numpy import any, all, ma, apply_along_axis, nonzero, array, isnan
from scipy.interpolate import interp1d
from functools import partial
class Transect(object):
    def __init__(self, id):
        self.id = id
        self.x = array([])
        self.y = array([])
        self.z = array([])
        self.t = array([])
        self.cross_shore = array([])

    def begindates(self):
        return [date for date in self.t]
    def enddates(self):
        return [date.replace(year=date.year+1) for date in self.t]

    def interpolate_z(self):
        """interpolate over missing z values"""
        if not self.z.any():
            return self.z
        def fillmissing(x,y):
            """fill nans in y using linear interpolation"""
            f = interp1d(x[~isnan(y)], y[~isnan(y)], kind='linear',bounds_error=False, copy=True)
            new_y = f(list(x)) #some bug causes it not to work if x is passed directly
            return new_y
        # define an intorpolation for a row by partial function application
        rowinterp = partial(fillmissing, self.cross_shore)
        # apply to rows (along columns)
        z = apply_along_axis(rowinterp, 1, self.z)
        # mask missings
        z = ma.masked_array(z, mask=isnan(z))
        return z
class PointCollection(object):
    def __init__(self):
        self.id = array([])
        self.x = array([])
        self.y = array([])
        self.z = array([])
