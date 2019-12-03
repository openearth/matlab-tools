#!/usr/bin/env python
sys.path.append('.')
sys.path.append('../lib')
import itertools
import random
import matplotlib
import time
matplotlib.use('MacOSX')
import matplotlib.pyplot as plt
import matplotlib.patches
import numpy
import shapely.geometry

# 
from shapely.geometry import asShape
from numpy import asarray
from scipy.interpolate import interp1d
import fixtures
import sys
transect = fixtures.localtransect(7003500)
import stats




upper=transect.mhw
lower=transect.mlw
result = stats.mkl(transect,upper=upper, lower=lower)
a = locals()
a.update(result)
del a
colors = itertools.cycle(['red', 'orange', 'green', 'blue', 'red', 'yellow'])
plt.clf()
#(poly_lower, above_lower, poly_upper, above_upper, lower_upper)
for poly in (mkl_volume, ):
    if poly.type == 'MultiPolygon':
        coordinate_arrays = [asarray(asShape(geom).exterior) for geom in poly.geoms]
        for coords in coordinate_arrays:
            plt.fill(coords[:,0], coords[:,1],color=colors.next(), alpha=0.1)
    else:
        coords = asarray(poly.exterior)
        plt.fill(coords[:,0], coords[:,1],color=colors.next(), alpha=0.1)

#plt.fill(b[:,0], b[:,1], color='blue', alpha=0.3)
#plt.plot(intersect_x[0], intersect_x[1], 'go', alpha=0.5)
plt.plot(X[:,0], X[:,1], color=(0,0,0))
plt.plot(lwb[0],lwb[1], 'go')
plt.plot(swb[0], swb[1], 'go')
plt.plot(mkl[0], mkl[1], 'bo')
plt.grid(True)
