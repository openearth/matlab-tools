# -*- coding: utf-8 -*-
"""

$Id: zandmotor_bathy.py 14143 2018-02-02 14:14:08Z heijer $
$Date: 2018-02-02 06:14:08 -0800 (Fri, 02 Feb 2018) $
$Author: heijer $
$Revision: 14143 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/zandmotor_bathy.py $

@author: heijer
"""

import netCDF4
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import qrcode

from colormap_vaklodingen import vaklodingen_colormap

# https://doi.org/10.4121/uuid:c40da555-3eff-4c3c-89d6-136994a07120
nc_url = 'http://opendap.tudelft.nl/thredds/dodsC/data2/zandmotor/morphology/JETSKI/gridded/jetskikb118_3736.nc'
tidx = -1


def label(netcdf_var):
    longname = netcdf_var.long_name
    units = netcdf_var.units
    return '%s (%s)' % (longname, units)


def add_qrcode2fig(fig, size=.18):
    keywords = ['$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/zandmotor_bathy.py $', '$Revision: 14143 $', ]
    for i,keyword in enumerate(keywords):
        keywords[i] = keyword.replace('$', '').replace('Revision: ', '').replace('HeadURL: ', '').strip()
    img = qrcode.make('%s?p=%s' % (keywords[0], keywords[1]))
    figaspect = fig.get_figheight() / fig.get_figwidth()
    hsize = size
    vsize = size / figaspect
    ax = fig.add_axes([1-hsize, 1-vsize, hsize, vsize], frameon=False)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.imshow(img)

# get data from netCDF
with netCDF4.Dataset(nc_url) as ds:
    x = ds.variables['x'][:]
    xlabel = label(ds.variables['x'])
    y = ds.variables['y'][:]
    ylabel = label(ds.variables['y'])
    Z = ds.variables['z'][tidx, :, :]
    zlabel = label(ds.variables['z'])
    time = ds.variables['time']
    T = netCDF4.num2date(time[tidx], units=time.units)
    id = ds.id

# convert data and define plotting area
[X, Y] = np.meshgrid(x,y)
x0, y0 = 70000, 450500
dx, dy = 4500, 4500

# plot
fig, ax = plt.subplots(nrows=1, ncols=1)
p = ax.pcolor(X, Y, Z, cmap=vaklodingen_colormap(), vmin=-50, vmax=25)
ax.axis([x0, x0+dx, y0, y0+dy])
ax.set_aspect('equal')
ax.set_xlabel(xlabel)
ax.set_ylabel(ylabel)
ax.set_title(T.strftime('%Y-%m-%d'))
cb = fig.colorbar(p, ax=ax)
cb.set_label(zlabel)
fig.subplots_adjust(right=.85)
plt.text(0.99, 0.01, id,
         horizontalalignment='right',
         verticalalignment='bottom',
         rotation=90,
         transform = ax.transAxes,
         fontsize=9)
add_qrcode2fig(fig)
# save
fig.savefig('zandmotor_%s.png' % T.strftime('%Y-%m-%d'))


