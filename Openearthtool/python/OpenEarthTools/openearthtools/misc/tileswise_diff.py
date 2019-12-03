# -*- coding: utf-8 -*-
"""
Created on Fri Jul 11 10:18:46 2014

@author: heijer
"""

from netCDF4 import Dataset,num2date
import numpy as np
import glob
import matplotlib.pyplot as plt
import matplotlib as mpl
import os
try:
    from mpl_toolkits.basemap import Basemap
    makemap = True
except:
    makemap = False


def readnc(fname, i0=None, i1=None):
    try:
        ds = Dataset(fname)
        z = ds.variables['z']
        t = ds.variables['time']
        dt = num2date(t[:], t.units)
        if i1 != None:
            Z = z[i0:i1,]
            DT = dt[i0:i1]
        else:
            Z = z[-5:,]
            DT = dt[-5:]
    
    finally:
        ds.close()
    return Z,DT

def readtyx(fname):
    try:
        ds = Dataset(fname)
        x = ds.variables['x'][:]
        y = ds.variables['y'][:]
        lat = ds.variables['lat']
        lon = ds.variables['lon']
        indices = [(0,0), (0,-1), (-1,-1), (-1,0), (0,0)]
        poly = [(lon[idx[0],idx[1]],lat[idx[0],idx[1]]) for idx in indices]
        t = ds.variables['time']
        dt = num2date(t[:], t.units)
    finally:
        ds.close()
    return x,y,dt,poly
    

def plotmap(ax=None, kbname='', poly=None):
    ax.set_title(kbname, fontsize=50)
    
    m = Basemap(projection='stere', lat_0=52.0922178,lon_0=5.23155,\
     llcrnrlon=2.9, llcrnrlat=51.1, urcrnrlon=4.5, urcrnrlat=51.9, resolution = 'i')
    m.drawcoastlines()
    m.fillcontinents(color='0.9')
    m.drawcountries()
    m.drawmapboundary(fill_color='aqua')
    if poly != None:
        lon,lat = zip(*poly)
        x, y = m(lon, lat)
        m.plot(x,y, linewidth=2)

def makeplot(X,Y,z,dt,dpi=100, figdir='.', makemap=False, poly=None):
    n = len(dt)
    fig,axes = plt.subplots(nrows=n, ncols=n,
                            sharex=True, sharey=True,
                            figsize=(2*n*X.shape[1]/dpi,n*X.shape[0]/dpi))
    fig.subplots_adjust(left=.4, bottom=0, right=.9, top=1,
                    wspace=0, hspace=0)
    axes[0,0].set_xlim(np.min(X), np.max(X))
    axes[0,0].set_ylim(np.min(Y), np.max(Y))
    axes[0,0].set_xticks([])
    axes[0,0].set_yticks([])
    levels = [-1,-.7,-.5,-.3,-.1,.1,.3,.5,.7,1]
    kbname = vaklodingen_coords2kb(X[0,0], Y[0,0], prefix='KB')
    cmap = plt.cm.jet
    cmap.set_under("blue")
    cmap.set_over("red")
    norm = mpl.colors.Normalize(vmin=-1, vmax=1, clip=True)
    maxpeq = 0
    maxcov = 0
    for row,axr in enumerate(axes):
        for col,ax in enumerate(axr):
            dz = z[row,] - z[col,]
            CS = ax.contourf(X,Y,dz, levels=levels, cmap=cmap, norm=norm)
            if row == col:
                if row == 0:
                    s = '%s\n%s'%(dt[row].year,kbname)
                    cax = fig.add_axes([.93,.1,.02,.8])
                    cb = fig.colorbar(CS, cax=cax, extend='both')
                    cb.ax.tick_params(labelsize=30) 
                else:
                    s = '%s'%(dt[row].year)
                ax.text(0.5, 0.5, s,
                        horizontalalignment='center',
                        verticalalignment='center',
                        fontsize=50,
                        transform=ax.transAxes)
            else:
                cov = float(np.count_nonzero(dz.mask==False))
                if cov>0:
                    peq = float(np.count_nonzero(np.logical_and(dz.data==0, dz.mask==False))) / cov
                else:
                    peq = 0.
                if peq > .5:
                    print '%i - %i: %.1f %% equal'%(dt[row].year, dt[col].year, peq*100)
                #print peq,maxpeq
                maxpeq = np.max((peq,maxpeq))
                maxcov = np.max((cov/np.prod(dz.shape),maxcov))
                ax.text(0.5, 0.5, '%.1f %% equal'%(peq*100),
                        horizontalalignment='center',
                        verticalalignment='center',
                        fontsize=50,
                        transform=ax.transAxes)
                
    if makemap:
        mapax = fig.add_axes([.05,.1,.3,.8])
        plotmap(ax=mapax,kbname=kbname, poly=poly)
    #print maxpeq, maxcov
    figname = '%s_%i-%i.png'%(kbname, min(dt).year, max(dt).year)
    if maxpeq > .5:
        subdir = 'highlight'
    elif maxcov < .2:
        subdir = 'sparse'
    else:
        subdir = '.'
        
    fig.savefig(os.path.join(figdir, subdir, figname), dpi=dpi)
    plt.close(fig)

def vaklodingen_coords2kb(x, y, prefix='KB'):
    # convert x,y to the lower left corner coordinates x0,y0
    x0 = x - np.mod(x, 500*20);
    y0 = y - np.mod(y, 625*20);
    
    # derive code in two directions
    xcode = x0/1e4 + 111;
    ycode = np.round(11008 + ((y0+20) * -.01616));
    
    # create kaartblad name string
    kbname = '%s%03.0f_%04.0f'%(prefix, xcode, ycode)
    
    return kbname

if __name__ == '__main__':
    figdir = '.'
    ncfiles = glob.glob('./*.nc')
    ncfiles.sort()
    for fname in ncfiles:
        print fname
        x,y,dt,poly = readtyx(fname)
        if len(dt) == 1:
            continue
        [X,Y] = np.meshgrid(x,y)
        for i0 in np.arange(0, len(dt), 3):
            #print i0, dt[i0]
            i1 = i0+5
            if i1 < len(dt):
                #Z = z[i0:i1,]
                Z,DT = readnc(fname, i0=i0, i1=i1)
            else:
                #Z = z[-5:,]
                Z,DT = readnc(fname, i0=i0)
            makeplot(X,Y,Z,DT,dpi=100, figdir=figdir, makemap=makemap, poly=poly)