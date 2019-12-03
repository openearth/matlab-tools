# -*- coding: utf-8 -*-
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius
"""

from mpl_toolkits.basemap import Basemap
import numpy as np
import matplotlib.pyplot as plt

def basemap_setup(xmin, xmax, ymin, ymax, projection='cyl', \
                resolution='c', drawcoastlines=True, drawrivers=True, drawcountries=True, \
                coastlinescolor='k', riverscolor='b',countriescolor='gray', linewidth=0.5, \
                meridian_dist=30, parallel_dist=30, figTitle='', \
                shapefile=None, shapeattr=None, shapecolor='k', shapewidth=0.5):
    """
    basemap_setup(xmin, xmax, ymin, ymax, projection='cyl', \
                resolution='c', drawcoastlines=True, drawrivers=True, drawcountries=True, \
                linewidth=0.5, meridian_dist=30, parallel_dist=15, figTitle='', \
                shapefile=None, shapeattr=None, shapecolor='k', shapewidth=0.5):

    Setup a Basemap object with a number of predefined settings
    
    Input:
        xmin, xmax...   -- float:               map boundaries
        projection      -- string:              map projection (see 
                                                mpl_toolkits.basemap.supported_projections)
        resolution      -- string               either 'c' (coarse), 'l' (low) or 'h' (high)
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
    # draw additional features from Basemap atlas
    if drawcoastlines:
        m.drawcoastlines(linewidth=linewidth, color=coastlinescolor)
    if drawrivers:
        m.drawrivers(linewidth=linewidth, color=riverscolor)
    if drawcountries:
        m.drawcountries(linewidth=linewidth, color=countriescolor)
    # map boundaries and grid lines
    m.drawmapboundary(linewidth=linewidth)
    m.drawmeridians(np.arange(xmin,xmax+1,meridian_dist),labels=[1,0,0,1],linewidth=0, fontsize=12)
    m.drawparallels(np.arange(ymin,ymax+1,parallel_dist),labels=[1,0,0,1],linewidth=0, fontsize=12)
    # plot the shapefile if user wants to
    if shapefile:
        m.readshapefile(shapefile, shapeattr, color=shapecolor, linewidth=shapewidth)

    plt.title(figTitle, fontsize=10)
    return m

