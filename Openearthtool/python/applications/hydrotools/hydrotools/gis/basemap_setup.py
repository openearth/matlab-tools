# -*- coding: utf-8 -*-
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius

$Id: basemap_setup.py 11950 2015-05-20 09:57:22Z winsemi $
$Date: 2015-05-20 02:57:22 -0700 (Wed, 20 May 2015) $
$Author: winsemi $
$Revision: 11950 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/basemap_setup.py $
$Keywords: $

"""

from mpl_toolkits.basemap import Basemap
import numpy as np
import matplotlib.pyplot as plt


def basemap_setup(xmin, xmax, ymin, ymax, projection='cyl',
                  resolution='c', drawcoastlines=True, drawrivers=True,
                  drawcountries=True, coastlinescolor='k',
                  riverscolor='b', countriescolor='gray', linewidth=0.5,
                  meridian_dist=30, parallel_dist=30, fig_title='',
                  title_fontsize=10, shapefile=None, shapeattr=None,
                  shapecolor='k', shapewidth=0.5):
    """
    basemap_setup(xmin, xmax, ymin, ymax, projection='cyl', \
                resolution='c', drawcoastlines=True, drawrivers=True, drawcountries=True, \
                linewidth=0.5, meridian_dist=30, parallel_dist=15, fig_title='', \
                shapefile=None, shapeattr=None, shapecolor='k', shapewidth=0.5):

    Setup a Basemap object with a number of predefined settings. A Basemap
    object is a nicely looking geographical map with coordinates and shapes
    
    Input:
        xmin, xmax...   -- float:               map boundaries
        projection      -- string:              map projection (see 
                                                mpl_toolkits.basemap.supported_projections)
        resolution      -- string               either 'c' (coarse), 'l' (low) or 'h' (high)
        draw...         -- boolean              select whether to draw or not
        linewidth       -- float                linedidth
        ..._dist        -- float                select distance between 
                                                meridian/parallel markers
        fig_title       -- string               Title of figure
        title_fontsize  -- float:               font size of title
        shapefile       -- string               path to shapefile
        shapeattr       -- string               attribute that will be plotted
        shapecolor      -- string               color of shape boundaries
        shapewidth      -- float                width of shape lines
    Output:
        m:              -- handle               handle to basemap figure
    """
    # prepare Basemap object
    m = Basemap(projection=projection, llcrnrlon=xmin, urcrnrlon=xmax,
                llcrnrlat=ymin, urcrnrlat=ymax, resolution=resolution)
    # draw additional features from Basemap atlas
    if drawcoastlines:
        m.drawcoastlines(linewidth=linewidth, color=coastlinescolor)
    if drawrivers:
        m.drawrivers(linewidth=linewidth, color=riverscolor)
    if drawcountries:
        m.drawcountries(linewidth=linewidth, color=countriescolor)
    # map boundaries and grid lines
    m.drawmapboundary(linewidth=linewidth)
    m.drawmeridians(np.flipud(np.arange(np.round(xmax), np.round(xmin), -meridian_dist)), labels=[1,0,0,1], linewidth=0, fontsize=12)
    m.drawparallels(np.flipud(np.arange(np.round(ymax), np.round(ymin), -parallel_dist)), labels=[1,0,0,1], linewidth=0, fontsize=12)
    # plot the shapefile if user wants to
    if shapefile:
        m.readshapefile(shapefile, shapeattr, color=shapecolor,
                        linewidth=shapewidth)

    plt.title(fig_title, fontsize=title_fontsize)
    return m

