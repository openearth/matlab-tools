"""
Statistical methods
"""

import logging
log = logging.getLogger(__name__)

from threading import Lock
# shapely is not thread safe, so implement a lock
shapelock = Lock()
    
def procrustes(X,Y):
    """
    perform a simple procrustes analysis: rotating Y to X
    returns a dictionary with the rotated matrix and transformation parameters.
    """
    import numpy as np
    import numpy.linalg as la
    
    # see:
    # Commandeur, J.J.F (1991) Matching configurations.DSWO press, Leiden University.
    # Seber, G.A.F., Multivariate Observations, Wiley, New York, 1984.

    # compute the mean
    mu_x = np.mean(X, 0)
    mu_y = np.mean(Y, 0)

    # normalize x and y
    x0 = X - mu_x
    y0 = Y - mu_y
    
    # calculate sum of squares
    ss_x = sum(x0**2)
    ss_y = sum(y0**2)

    # compute the Hilbert-Schmidt/ Frobenius norm     
    normx = np.sqrt(sum(ss_x))
    normy = np.sqrt(sum(ss_y))

    x0 /= normx
    y0 /= normy

    XY = np.dot(x0.T,y0)
    U, d, V = la.svd(XY)
    # compute the rotation matrix
    R = np.dot(V,U.T) 
    # sum(s) should be the same as the trace of sqrt(XY'*XY)
    fit = 1 - np.sum(d)**2

    # compute transformed Y
    Y_new = np.dot(normx*np.sum(d)*y0, R) + mu_x

    # compute the scale
    s = np.sum(d) * normx / normy
    
    # compute the translation 
    u = mu_x - s*np.dot(mu_y,R)
    result = {'Y_rotated': Y_new,
              'rotation': R,
              'scale': s,
              'translation': u,
              'fit': fit}
    return result
def hshift(X, Y, y0=3, y1=6, ydiff=0.1):
    """
    compute an average horizontal shift between 2 vertical reference levels
    """
    import shapely.geometry
    import numpy

    # convert to geos objects
    geom_x = shapely.geometry.asLineString(X.tolist()) # some precision problem
    geom_y = shapely.geometry.asLineString(Y.tolist())
    # store the shifts
    shifts = []
    for level in numpy.arange(y0,y1,ydiff):
        hline = shapely.geometry.asLineString([[X[:,0].min(), level], [X[:,0].max(), level]])
        # compute intersections between the line and the new profile
        intersect_x = numpy.asarray(geom_x.intersection(hline))
        # compute the inersection between the line and the old profile
        intersect_y = numpy.asarray(geom_y.intersection(hline))
        
        if intersect_x.ndim == 1:
            pass
        elif intersect_x.ndim == 2:
            intersect_x = intersect_x.max(0)
        else:
            raise ValueError('got incompatible array')

        if intersect_y.ndim == 1:
            pass
        elif intersect_y.ndim == 2:
            intersect_y = intersect_y.max(0)
        else:
            raise ValueError('got incompatible array')

        # caclulate the shift
        shift = intersect_x[0] - intersect_y[0]
        # store it
        shifts.append(shift)
    if shifts:
        mean = numpy.asarray(shifts).mean()
        std = numpy.asarray(shifts).std()
    else:
        mean = 0
        std = 0
    return {'mean': mean, 'std': std}
# calculate mkl
# shift 1 mm to avoid intersection errors
def mkl(x, z, upper=3, lower=5):
    """
    calculate the mkl of a transect
    the swb argument allows to choose the 
    - most seaward intersection between the transect the upper/lower boundary: max
    - most landward intersection between the transect and the upper/lower boundary: min
    """
    
    import numpy
    from numpy import asarray
    from shapely.geometry import asShape 
    import shapely.geometry
    from scipy.interpolate import interp1d
    
    try:
        shapelock.acquire()
        # look up coordinates
        X = numpy.c_[x, z]

        # define an interpolation function
        f = interp1d(x, z, kind='linear',bounds_error=False, copy=True)

        # convert them to a shape
        # look up the bounds of the profile
        min_x = X[:,0].min()
        min_z = X[:,1].min()
        max_x = X[:,0].max()
        max_z = X[:,1].max()

        # we do not want any double points, cause that invalidates a polygon (SFS)
        # go down one extra, because we don't want to go backward through the same points
        coords = numpy.r_[X,[[max_x, min_z-1],[min_x, min_z-1], X[0,:]]]
        # poly_x = asShape(shapely.geometry.asPolygon(coords))
        poly_x = shapely.geometry.Polygon(coords.filled().astype('float'))
        assert poly_x.is_valid

        # look up the lower intersections with the lower and upper boundary
        # lower
        line_lower = asShape(shapely.geometry.asLineString([[min_x, lower], [max_x, lower]]))
        assert line_lower.is_valid
        intersects_lower = (line_lower.intersection(poly_x))
        assert intersects_lower.is_valid 
        # upper
        line_upper = asShape(shapely.geometry.asLineString([[min_x, upper], [max_x, upper]]))
        assert line_upper.is_valid
        intersects_upper = (line_upper.intersection(poly_x))
        assert intersects_upper.is_valid

        if intersects_lower.is_empty or intersects_upper.is_empty:
            return None

        # we have multiple intersections in the lower let's go through them
        if intersects_lower.type in ('MultiLineString', 'GeometryCollection'):
            intersects = []
            for intersect_lower in intersects_lower.geoms:
                if intersect_lower.type == 'Point':
                    intersect = asarray(asShape(intersect_lower))
                else:
                    intersect = asarray(asShape(intersect_lower)).max(0)
                intersects.append(intersect)
            intersects = asarray(intersects)
            # we take the maximum one, some other approaches can be used here...
            swb = intersects.max(0)[0]
        else:
            swb = asarray(intersects_lower).max(0)[0]

        # we have multiple intersections with the upper let's go through them
        if intersects_upper.type in ('MultiLineString', 'GeometryCollection'):
            intersects = []
            for intersect_upper in intersects_upper.geoms:
                if intersect_upper.type == 'Point':
                    intersect = asarray(asShape(intersect_upper))
                else:
                    intersect = asarray(asShape(intersect_upper)).max(0)
                intersects.append(intersect)
            intersects = asarray(intersects)
            # we take the maximum one
            lwb = intersects.max(0)[0]
        else:
            lwb = asarray(intersects_upper).max(0)[0]

        # calculate mkl using maximum method
        boundary_box = shapely.geometry.asPolygon([[lwb,upper], [lwb, lower], [swb,lower], [swb, upper], [lwb,upper]])
        mkl_volume = boundary_box.intersection(poly_x)
        mkl_x = lwb + (swb-lwb)*(mkl_volume.area/(boundary_box.area+mkl_volume.area))
        mkl_y = f(mkl_x)

        result = {}

        result['mkl'] = asarray([mkl_x, mkl_y])
        result['lwb'] = asarray([lwb, upper])
        result['swb'] = asarray([swb, lower])
        result['mkl_volume'] = mkl_volume

        result['X'] = X
    finally:
        shapelock.release()
    return result
