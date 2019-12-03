# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

filename = '/Users/fedorbaart/Documents/checkouts/cases_unstruc/e00_unstruc/f03_advection/c020_Waalgrof/input/WAALGROF_net.nc'

filename = '/Users/fedorbaart/Downloads/wa01/r07e_net.nc'

# <codecell>

import netCDF4
import numpy as np
import ogr
import osr
from openearthtools.io.dflowfm import UGrid
import vtk
import matplotlib.collections

# <codecell>

grid = UGrid.fromfile(filename)
cellcoords = [xy[:,:2] for xy in grid.cellcoords()]

# <codecell>

fig, ax = plt.subplots(1,1)
ax.plot(grid.netnodex ,grid.netnodey,'k.')
cells = matplotlib.collections.PolyCollection(cellcoords)
ax.add_collection(cells)
ax.autoscale()
#ax.set_ylim(4185000, 4190000)
#ax.set_xlim(560000, 562000)

# <codecell>

matplotlib.patches.Path(cellcoords[0])

# <codecell>

grid = UGrid.fromfile(filename)
# add the coordinate of the orgin

# The coordinates are in some local system... Let's shift to RD
rd = osr.SpatialReference()
rd.ImportFromEPSG(28992)
wgs = osr.SpatialReference()
wgs.ImportFromEPSG(4326)
transform = osr.CoordinateTransformation(wgs,rd)

lat, lon = (51.802458, 5.35)

x,y,z = transform.TransformPoint(lon,lat)
x0, y0 = grid.netnodex[np.argmin(grid.netnodey)]  , grid.netnodey[np.argmin(grid.netnodey)] 
xt, yt = x-x0, y-y0
print xt, yt, x0, y0, x,y, np.argmin(grid.netnodey)

grid.netnodex += xt
grid.netnodey += yt
# transform to latlon
transform = osr.CoordinateTransformation(rd, wgs)
lonlats = np.array(transform.TransformPoints(np.c_[grid.netnodex, grid.netnodey]))
grid.netnodex, grid.netnodey = lonlats[:,:2].T

grid.cellcoords()
with open('grid.json', 'w') as f:
    f.write(grid.export())
#grid.export(drivername='GeoJSON', filename='gridogr.json')


# <codecell>

#triang = matplotlib.tri.Triangulation(grid.netnodex, grid.netnodey)
grid.netnodex.shape

# <codecell>

fig, ax = plt.subplots(1,1)
ax.add_collection(matplotlib.collections.PolyCollection([xyz[:,:2] for xyz in grid.cellcoords()]))
ax.autoscale()


# <codecell>

for i in range(ogr.GetDriverCount()):
    driver = ogr.GetDriver(i)
    print(driver.GetName())
    

# <codecell>


# <codecell>


