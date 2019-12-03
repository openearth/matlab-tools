# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

# system modules
import os
import sys
import logging
import itertools

# shortcuts by convention
import numpy as np
import matplotlib
# Choose non gui backend if non is chosen...
if not matplotlib.get_backend():
    matplotlib.use('Agg')
import matplotlib.pyplot as plt


# geometry intersection
import shapely
import shapely.geometry
# optional for debugging geoms
import descartes      


# for tables
import pandas
import pandas.io

# distributions
import scipy.stats


# <codecell>

def hairplot(df):
    # Group by events for plotting
    df = df.groupby(['eventyear'])
    
    # define a plot function per event
    def plotsomething(df, ax):
        ax.plot(df['day_from_event'], df['discharge'], 'k-', alpha=0.004)
    
    # setup the axes    
    fig, ax = plt.subplots(1,1, figsize=(10,6))
    print ax
    ax.set_xlabel('Days from event')
    ax.set_ylabel('Discharge [m^3/s]')
    # call all the plot functions..
    something = df.apply(plotsomething, ax)
    return fig, ax

# <codecell>

store = pandas.io.pytables.HDFStore('store.h5')
df = store['annual_maxima']
GROUPS = [0] + range(1500,3250,250) + [4500]

# <codecell>


def bydayplot(df, ax, subtitle="",parametric=True, color='#348ABD'):
    """compute and plot percentiles"""
    # Reorganize data, use day_from_event as columns
    piv = df.pivot(index='eventyear', columns='day_from_event', values='discharge')
    
    # Gumbel
    def fit(x):
        return scipy.stats.gumbel_r.fit(x[~np.isnan(x)])
    def ppf(*args,**kwargs):
        return scipy.stats.gumbel_r.ppf(*args, **kwargs)
    
    # Log Normal
    def fit(x):
        return scipy.stats.lognorm.fit(x[~np.isnan(x)])
    def ppf(*args,**kwargs):
        return scipy.stats.lognorm.ppf(*args, **kwargs)

    
    # Now we can assume a parametric or non parametric distribution
    if parametric == True:
        # apply the distribution function over all day_from_event
        # Better would be to use the genextreme, but this is broken in scipy..
        # http://projects.scipy.org/scipy/ticket/1553
        pivfit = piv.apply(fit) # key, (shape=1, location, scale)
        # convert back to aray
        perc25 = [ppf(0.025, *args) for day_from_event, args  in pivfit.iterkv()]
        perc32 = [ppf(0.32, *args) for day_from_event, args  in pivfit.iterkv()]
        perc50 = [ppf(0.5, *args) for day_from_event, args  in pivfit.iterkv()] # logmean
        perc68 = [ppf(0.68, *args) for day_from_event, args  in pivfit.iterkv()]
        perc975 = [ppf(0.975, *args) for day_from_event, args  in pivfit.iterkv()]
    else:
        # just lookup the percentiles for non parametric
        # we of course could put this in a loop, but it's not worth the effort.
        perc25 = piv.apply(lambda x:scipy.stats.scoreatpercentile(sorted(x),2.5))
        perc32 = piv.apply(lambda x:scipy.stats.scoreatpercentile(sorted(x),32.0))
        perc50 = piv.apply(lambda x:scipy.stats.scoreatpercentile(sorted(x),50.0))
        perc68 = piv.apply(lambda x:scipy.stats.scoreatpercentile(sorted(x),68.0))
        perc975 = piv.apply(lambda x:scipy.stats.scoreatpercentile(sorted(x),97.5))
    
    
    # confidence bands of 1 and 2 sigma, creates a bit of a distribution feeling
    ax.fill_between(piv.columns, perc25, perc975, alpha=0.3, color=color)
    ax.fill_between(piv.columns, perc32, perc68, alpha=0.3, color=color)
    # store the line, because we need it for the legend
    line, = ax.plot(piv.columns, perc50, linewidth=2, color=color)
    
    # Set labels and title...
    title = 'Conditional probability density function (y|x)'
    subtitle = subtitle + 'parametric' if parametric else 'non-parametric'
    ax.set_title(title + '\n' + subtitle)
    ax.set_xlabel('Days from event')
    ax.set_ylabel('Discharge [m^3/s]')
    
    # Create a legend. Fill_between is a complex function, so we need http://matplotlib.org/users/legend_guide.html#using-proxy-artist
    # Create 2 proxy artists for a legend
    p1 = Rectangle((0, 0), 1, 1, alpha=0.3, color=color)
    p2 = Rectangle((0, 0), 1, 1, alpha=0.6, color=color)
    # use the proxies to generate a box label
    ax.legend([p1, p2, line], ['2.5-97.5%', '32-68%', '50%'], loc='best')

# <codecell>

piv = df.pivot(index='eventyear', columns='day_from_event', values='discharge')

def fit(x):
    return scipy.stats.gumbel_r.fit(x[~np.isnan(x)])
def ppf(*args,**kwargs):
    return scipy.stats.gumbel_r.ppf(*args, **kwargs)
def fit(x):
    return scipy.stats.lognorm.fit(x[~np.isnan(x)])
def ppf(*args,**kwargs):
    return scipy.stats.lognorm.ppf(*args, **kwargs)

    
# log normal percentiles
# apply the log normal distribution function over all day_from_event
# Better would be to use the genextreme, but this is broken in scipy..
# http://projects.scipy.org/scipy/ticket/1553
pivfit = piv.apply(fit) # key, (shape=1, location, scale)
# convert back to aray
perc25 = [ppf(0.025, *args) for day_from_event, args  in pivfit.iterkv()]
perc32 = [ppf(0.32, *args) for day_from_event, args  in pivfit.iterkv()]
perc50 = [ppf(0.5, *args) for day_from_event, args  in pivfit.iterkv()] # logmean
perc68 = [ppf(0.68, *args) for day_from_event, args  in pivfit.iterkv()]


# <codecell>


# <codecell>

fig, axes = plt.subplots(1,2, figsize=(16,5), sharey=True, sharex=True)
# generate the unconditional (on discharge) plot
bydayplot(df, axes[0], subtitle='all non parametric', parametric=False, color='#7A68A6')
bydayplot(df, axes[1], subtitle='all parametric', parametric=True, color='#1A68A6')
axes[0].set_xlim(-15,15)

# <codecell>

# Categorize the water levels
# make a copy because we're remerging and modifying
peaks = df[df['day_from_event']==0][['eventyear', 'discharge']].copy() 
# create a factor of the discharges
binnedpeaks, bins = pandas.cut(peaks['discharge'], GROUPS, retbins=True)
# store it in the dataframe
peaks['klass'] = binnedpeaks
# mergeback with the orignal data (so we can group)
dfextra = df.merge(peaks, on='eventyear', suffixes=('', '_peak'))
# group the data
grouped = dfextra.groupby('klass')

# combine axes and dataframe to make plots
# generate an overview plot
fig, axes = plt.subplots(4,4,figsize=(30,16), sharex=True, sharey=True)
for (ax, (name, dfsel)) in zip(axes[:2,:].flat, grouped):
    bydayplot(dfsel, ax, name, parametric=False, color='#7A68A6')
for (ax, (name, dfsel)) in zip(axes[2:,:].flat, grouped):
    bydayplot(dfsel, ax, name, parametric=True, color='#1A68A6')

fig.savefig('vertical.png')

# <codecell>

daysoverdf = store['daysover']

# <codecell>

# Define percentile functions
def count(x):
    return len(x)
def perc25(x):
    return scipy.stats.scoreatpercentile(sorted(x),2.5)
def perc32(x):
    return scipy.stats.scoreatpercentile(sorted(x),32.0)
def perc50(x):
    return scipy.stats.scoreatpercentile(sorted(x),50.0)
def perc68(x):
    return scipy.stats.scoreatpercentile(sorted(x),68.0)
def perc975(x):
    return scipy.stats.scoreatpercentile(sorted(x),97.5)

# Compute percentils
daysoverfit = daysoverdf[['start', 'left', 'right']].groupby('start').agg([count, np.mean, perc25, perc32, perc50, perc68, perc975])
# toss out the all 0's, for better looking plots
daysoverfit = daysoverfit[(daysoverfit[[('left','perc975'), ('right','perc975')]] > 0).all(axis=1)]

fig, ax = plt.subplots(1,1)

# styles
color='#7A68A6'
props = dict(edgecolor='none', alpha=0.3, color=color)
# confidence band (horizontal)
ax.fill_betweenx(daysoverfit.index, -daysoverfit[('left','perc975')]/100, -daysoverfit[('left','perc25')]/100,**props)
ax.fill_betweenx(daysoverfit.index, -daysoverfit[('left','perc68')]/100, -daysoverfit[('left','perc32')]/100,**props)
ax.fill_betweenx(daysoverfit.index, daysoverfit[('right','perc25')]/100, daysoverfit[('right','perc975')]/100,**props)
ax.fill_betweenx(daysoverfit.index, daysoverfit[('right','perc32')]/100, daysoverfit[('right','perc68')]/100,**props)
# median
line, = ax.plot(-daysoverfit[('left','perc50')]/100, daysoverfit.index, color=color)
ax.plot(daysoverfit[('right','perc50')]/100, daysoverfit.index, color=color)
# labels
ax.set_xlabel('Days from event')
ax.set_ylabel('Discharge [m3/s]')

# Create a legend. Fill_between is a complex function, so we need http://matplotlib.org/users/legend_guide.html#using-proxy-artist
# Create 2 proxy artists for a legend
p1 = Rectangle((0, 0), 1, 1, alpha=0.3, color=color)
p2 = Rectangle((0, 0), 1, 1, alpha=0.6, color=color)
# use the proxies to generate a box label
ax.legend([p1, p2, line], ['2.5-97.5%', '32-68%', '50%'], loc='best')
ax.set_xlim(-15,15)
plt.savefig('horizontal.png')

# <codecell>


fig, ax = plt.subplots(1,1)
n, disch = np.histogram(df[df['day_from_event']==0]['discharge'], bins=50)
ncum = n.cumsum()
x = np.array([0]+list(1-(ncum/20000.0)))
y = np.array([0]+list(disch[:-1]))
ax.plot(x,y, '-', linewidth=3)
ax.semilogx()
# Somehow we plot this in the wrong order...
ax.set_xlim(ax.get_xlim()[::-1]) 
ax.set_xlabel('Exceedance probability')
ax.set_ylabel('Discharge [m3/s]')
plt.savefig('cumulative.png')

# <codecell>


# <codecell>

a, 

