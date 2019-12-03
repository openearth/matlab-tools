# -*- coding: utf-8 -*-
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib import cm

def basemap_imshow(x, y, data, xmin, xmax, ymin, ymax, projection='cyl', \
                resolution='c', vmin=None, vmax=None, norm=None, cmap=cm.jet, \
                drawcoastlines=True, drawrivers=True, drawcountries=True, \
                linewidth=0.5, meridian_dist=30, parallel_dist=15, figTitle='', \
                shapefile=None, shapeattr=None, shapecolor='k', shapewidth=0.5):
    """
    basemap_imshow(x, y, data, xmin, xmax, ymin, ymax, projection='cyl',
                resolution='c', vmin=None, vmax=None, norm=None, cmap=cm.jet,
                drawcoastlines=True, drawrivers=True, drawcountries=True,
                linewidth=0.5, meridian_dist=30, parallel_dist=15, figTitle='',
                shapefile=None, shapeattr=None, shapecolor='k', shapewidth=0.5)
    Plot a gridded dataset (in spherical coordinates) in a geographical formatted figure
    You can control the resolution of the atlas files used (rivers, countries and coasts)
    You can add a shapefile of your liking to the plot. This can be a point, 
    line or polygon file.
    
    Input:
        x               -- 1D np-array:         x-axis
        y               -- 1D np-array:         y-axis
        data            -- 2D np-array:         data to be plotted
        xmin, xmax...   -- float:               map boundaries
        projection      -- string:              map projection (see 
                                                mpl_toolkits.basemap.supported_projections)
        resolution      -- string               either 'c' (coarse), 'l' (low) or 'h' (high)
        vmin/vmax       -- float                colorbar scale
        norm            -- carray               discrete color scales
        cmap            -- cm object            colormap
        draw...         -- boolean              select whether to draw or not
        linewidth       -- float                linedidth
        ..._dist        -- float                select distance between 
                                                meridian/parallel markers
        figTitle        -- string               Title of figure
        shapefile       -- string               path to shapefile
        shapeattr       -- string               attribute that will be plotted
        shapecolor      -- string               color of shape boundaries
        shapewidth      -- float                width of shape lines
        
    """
    # prepare Basemap object
    m           = Basemap(projection=projection, llcrnrlon=xmin, \
            urcrnrlon=xmax, llcrnrlat=ymin, urcrnrlat=ymax, resolution=resolution)
    # prepare coordinate mesh
    xi, yi      = np.meshgrid(x, y)
    # transform data to selected projection
    data_trans  = m.transform_scalar(data,xi[0,:],yi[:,0],xi.shape[1],yi.shape[0], order=0)
    # plot
    m.imshow(data_trans,cmap,vmin=vmin,vmax=vmax, norm=norm, interpolation='nearest')
    # draw additional features from Basemap atlas
    if drawcoastlines:
        m.drawcoastlines(linewidth=linewidth)
    if drawrivers:
        m.drawrivers(color='b', linewidth=linewidth)
    if drawcountries:
        m.drawcountries(linewidth=linewidth)
    # map boundaries and grid lines
    m.drawmapboundary(linewidth=linewidth)
    m.drawmeridians(np.arange(xmin,xmax+1,meridian_dist),labels=[1,0,0,1],linewidth=linewidth, fontsize=8)
    m.drawparallels(np.arange(ymin,ymax+1,parallel_dist),labels=[1,0,0,1],linewidth=linewidth, fontsize=8)
    # plot the shapefile if user wants to
    if shapefile:
        m.readshapefile(shapefile, shapeattr, color=shapecolor, linewidth=shapewidth)

    plt.title(figTitle, fontsize=10)
    return m

