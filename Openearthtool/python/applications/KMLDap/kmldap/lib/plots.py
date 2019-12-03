#!/usr/bin/env python
import itertools
import cStringIO
import functools
import logging
from threading import Lock

import numpy
from numpy import ma
from numpy import isnan, hstack, newaxis, zeros

import scipy.interpolate

import matplotlib
# use in memory backend
matplotlib.use('Agg')

from matplotlib import pyplot as p
from matplotlib import text
from matplotlib.dates import mx2num, date2num
import matplotlib.ticker
import matplotlib.collections
import matplotlib.cm as cm

import extra_cm
import stats

log = logging.getLogger(__name__)
pylablock = Lock()

def jarkustimeseries(transect, plotproperties={}):
    """create a timeseries plot for a transect"""
    f = cStringIO.StringIO()
    
    # interpolation function
    z = transect.interpolate_z()
    # create the plot
    if len(z.shape) != 2:
        raise ValueError('Z should be of dim 2')
    # use a fixed min, max for color interpolation, we have no green on beaches but it shows a lot of contrast
    # pylab is stateful, we don't want to call it from multiple threads at the same time
    pylablock.acquire()
    try:
        p.figure(figsize=(3, 2))
        fig = p.pcolor(transect.cross_shore, date2num(transect.t), z, vmin=-20, vmax=20, cmap=extra_cm.GMT_drywet_r)
        p.colorbar()
        # setup date ticks, maybe this can be done shorter
        datelocator = matplotlib.dates.AutoDateLocator()
        dateformatter = matplotlib.dates.AutoDateFormatter(datelocator)
        fig.axes.yaxis.set_major_formatter(dateformatter)
        fig.axes.set_xlabel('Cross shore distana.set_colorbarce [m]')
        fig.axes.set_ylabel('Measurement time [y]')
        for o in fig.axes.findobj(text.Text):
            o.set_size('xx-small')
        for o in fig.colorbar[1].findobj(text.Text):
            o.set_size('xx-small')
        p.savefig(f, **plotproperties)
    finally:
        pylablock.release()
    f.seek(0)
    return f

def eeg(transect, plotproperties={}):
    """plot eeg like plot of transects"""
    # from http://matplotlib.sourceforge.net/examples/pylab_examples/mri_with_eeg.html
    # get axes
    try:
        t = mx2num(transect.t)
    except:
        t = date2num(transect.t)
    x = transect.cross_shore
    # and data
    z = transect.interpolate_z()
    nrows, nsamples = z.shape

    # create a line for each timeseries
    segs = []
    ticklocs = []
    for i, row in enumerate(z):
        # add a line, scale it by the y axis each plot has a range of de elevation divided by 7.5 (~2 years up and down)
        segs.append(hstack((x[:,newaxis], z[i,:,newaxis]*365.0/7.5)))
        ticklocs.append(t[i]) # use date for yloc
    # create an offset for each line
    offsets = zeros((nrows,2), dtype=float)
    offsets[:,1] = ticklocs
    # create the lines
    lines = matplotlib.collections.LineCollection(segs, offsets=offsets)
    # create a new figure
    pylablock.acquire()
    try:
        f = p.figure(figsize=(3, 2))
        # and axes
        ax = p.axes()
        # add the lines
        ax.add_collection(lines)
        # set the x axis
        p.xlim(transect.cross_shore.min(), transect.cross_shore.max())
        # set the y axis (add a bit of room cause the wiggles go over a few years)
        p.ylim(t.min()-730,t.max()+730)
        for o in ax.axes.findobj(text.Text):
            o.set_size('xx-small')
        datelocator = matplotlib.dates.AutoDateLocator()
        dateformatter = matplotlib.dates.AutoDateFormatter(datelocator)
        ax.axes.yaxis.set_major_formatter(dateformatter)
        f = cStringIO.StringIO()

        p.savefig(f, **plotproperties)
    finally:
        pylablock.release()
    f.seek(0)
    #cleanup
    #p.clf()
    return f
    
def alphahistory(transect, plotproperties={}):
    """plot with a blurred history"""
    f = cStringIO.StringIO()

    z = transect.interpolate_z()
    
    nprofiles = z.shape[0]
    pylablock.acquire()
    try:
        fig = p.figure(figsize=(3, 2))
        # draw a blue horizontal line at 0
        p.hlines([0], [transect.cross_shore.min()], [transect.cross_shore.max()], color="blue")
        # plot the profiles over the years
        for i in range(nprofiles-1):
            alpha = (float(i+1)/nprofiles)*(0.2) # gradually increase alpha over time from 0.0something to 0.5
            p.plot(transect.cross_shore, z[i,:], alpha=alpha, lw=1, color='#967117')
        # plot the latest
        p.plot(transect.cross_shore, z[nprofiles-1,:], alpha=1, lw=1, color=(0,0,0))
        # create smaller letters
        axes = p.axes() # why can't we do fig.axes?
        for o in axes.findobj(text.Text):
            o.set_size('xx-small')
        p.savefig(f, **plotproperties)
    finally:
        pylablock.release()
    f.seek(0)
    return f

def procrustes(transect, plotproperties={}, **kwargs):
    z = transect.interpolate_z()
    x = transect.cross_shore
    log.info('Plotting procrustes for %s' % transect.id)
    results = []
    t = []
    for i in range(1,z.shape[0]):
        z_new = z[i,:]
        z_old = z[i-1,:]
        index = ~(z_new.mask | z_old.mask)

        X = numpy.c_[x[index], z_new[index]]
        Y = numpy.c_[x[index], z_old[index]]
        if X.any() and Y.any():
            result = stats.procrustes(X, Y)
            # store result
            mkl = stats.mkl(X[:,0], X[:,1], lower=3-((3-transect.mlw)*2), upper=3)
            if mkl is not None:
                result.update(mkl)
            t.append(transect.t[i])
            results.append(result)

    f = cStringIO.StringIO()
    pylablock.acquire()
    try:
        x_ylabel = -0.1
        #formatter = matplotlib.ticker.ScalarFormatter()
        datelocator = matplotlib.dates.AutoDateLocator()
        dateformatter = matplotlib.dates.AutoDateFormatter(datelocator)

        fig = p.figure(figsize=(3, 5))
        y = numpy.array([result['translation'][0] for result in results])
        ax1 = p.subplot(411)
        p.plot(date2num(t), y)
        p.ylabel('X shift')
        ax1.yaxis.set_label_coords(x_ylabel, 0.5)
        #ax1.yaxis.set_major_formatter(formatter)
        p.grid(True)

        y = numpy.array([result['translation'][1] for result in results])
        ax2 = p.subplot(412)
        p.plot(date2num(t), y)
        p.ylabel('Z shift')
        ax2.yaxis.set_label_coords(x_ylabel, 0.5)
        #ax2.yaxis.set_major_formatter(formatter)
        p.grid(True)

        y = numpy.array([(numpy.arcsin(result['rotation'][1,0])/(2*numpy.pi))*360 for result in results]) 
        ax3 = p.subplot(413)
        p.plot(date2num(t), y)
        p.ylabel('Angle shift')
        ax3.yaxis.set_label_coords(x_ylabel, 0.5)
        #ax3.yaxis.set_major_formatter(formatter)
        p.grid(True)

        # any?
        y = numpy.array([result.get('mkl', (numpy.nan, numpy.nan))[0] for result in results]) 
        if not isnan(y).all():
            ax4 = p.subplot(414)
            p.plot(date2num(t), y)
            p.ylabel('MKL')
            ax4.yaxis.set_label_coords(x_ylabel, 0.5)
            #ax4.yaxis.set_major_formatter(formatter)
            p.grid(True)
            ax4.xaxis.set_major_formatter(dateformatter)
            for o in ax4.findobj(text.Text):
                o.set_size('xx-small')

        #p.ylim(min(y), max(y))
        # create smaller letters
        ax1.xaxis.set_major_formatter(dateformatter)
        ax2.xaxis.set_major_formatter(dateformatter)
        ax3.xaxis.set_major_formatter(dateformatter)
        for o in ax1.findobj(text.Text):
            o.set_size('xx-small')
        for o in ax2.findobj(text.Text):
            o.set_size('xx-small')
        for o in ax3.findobj(text.Text):
            o.set_size('xx-small')

        p.savefig(f, **plotproperties)
    finally:
        pylablock.release()
    f.seek(0)

    return f

def mkl(transect, plotproperties={}, **kwargs):
    results = []
    t = []
    Z = transect.interpolate_z()
    log.info('Plotting mkl for %s' % transect.id)
    for i in range(Z.shape[0]):
        z = Z[i,:]
        x = transect.cross_shore
        index = ~(z.mask)
        # add 0.1 mm to avoid errors in matching shapes:
        # See: http://lists.gispython.org/pipermail/community/2010-July/002638.html
        result = stats.mkl(x[index], z[index]+0.0001, lower=3-((3-transect.mlw)*2), upper=3)
        results.append(result)
    f = cStringIO.StringIO()
    pylablock.acquire()
    try:
        fig = p.figure(figsize=(4, 3))
        p.hlines([3], [transect.cross_shore.min()], [transect.cross_shore.max()], color="green")
        p.hlines([transect.mlw], [transect.cross_shore.min()], [transect.cross_shore.max()], color="blue")
        p.hlines([3-((3-transect.mlw)*2)], [transect.cross_shore.min()], [transect.cross_shore.max()], color="green")
        colors = itertools.cycle(['red', 'orange', 'green', 'blue', 'red', 'yellow'])
        for result in results:
            if result is None:
                continue
            poly = result['mkl_volume']
            if poly.type in  ('MultiPolygon', 'GeometryCollection'):
                # TODO: geom can be a point
                coordinate_arrays = []
                for geom in poly.geoms:
                    if geom.type == 'Point':
                        coords = numpy.asarray(geom)
                        p.plot(coords[0], coords[1], '.',color="#967117", alpha=0.1)
                    elif geom.type == 'LineString':
                        coords = numpy.asarray(geom)
                        p.plot(coords[0], coords[1], '.',color="#967117", alpha=0.1)
                    else:
                        coords = numpy.asarray(geom.exterior)
                        p.fill(coords[:,0], coords[:,1], color='#967117', alpha=0.1)
            else:
                coords = numpy.asarray(poly.exterior)
                p.fill(coords[:,0], coords[:,1],color='#967117', alpha=0.1)
            p.plot(x[index], z[index], color=(0,0,0))
            p.plot(result['lwb'][0], result['lwb'][1], 'go', alpha=0.2)
            p.plot(result['swb'][0], result['swb'][1], 'go', alpha=0.2)
            p.plot(result['mkl'][0], result['mkl'][1], 'bo', alpha=0.6)
        p.grid(True)
        p.savefig(f, **plotproperties)
    finally:
        pylablock.release()
    f.seek(0)

    return f

        
