__version__ = "$Revision: 10985 $"

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Gerben J. de Boer
#
#       gerben.deboer@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: odv2timeseries.py 10985 2014-07-23 12:45:50Z boer_g $
# $Date: 2014-07-23 14:45:50 +0200 (Wed, 23 Jul 2014) $
# $Author: boer_g $
# $Revision: 10985 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2timeseries.py $
# $Keywords: $

## make PNG timeseries view

import numpy as np
# http://matplotlib.org/faq/howto_faq.html#howto-webapp
import matplotlib
matplotlib.use('Agg') # use non-interactive plot window on server
import matplotlib.pyplot as plt
# # for time limits:
from matplotlib.dates import date2num
import datetime

import logging

def odv2timeseries_allinrange(pngFilepath,ODV,cname,zname=[],clims=[],zlims=[],times=[],cmapstr="jet",log10=0,colorvalue="blue",markertype="o",markersizevalue=6,alphavalue=1): # matplotlib
    "plot ODV object to timeseries"
    
    cname = cname.replace(' ','_') # same as pandas does for all spaces.
    ic = []

    for i,l in enumerate(ODV.pandas_name):
        if ODV.pandas_name[i] in cname:
           ic = i
           break

    # this is for the z (useful for the colorbar)       
    if len(zname)==0:
        z = range(len(ODV.data))
        zlabel = 'index [#]'
    else:
        zname = zname.replace(' ','_')
        iz = []
        for i,l in enumerate(ODV.pandas_name):
        
            if ODV.pandas_name[i] in zname:
               iz = i
               z  = ODV.data[zname]
               zlabel = ODV.sdn_name[iz] + ' [' + ODV.sdn_units[iz] + ']'
               break  

    c    = ODV.data[cname]
    if isinstance(c[0],str):
       c    = None
       print('warning odv2timeseries: nu numeric data for ' + cname )
       return
    else:
       c    = np.ma.masked_invalid(np.array(c.as_matrix(),'float')) # np.log10 can't handle pandas arrays
    
    #logging.info('got all needed variables. start for loop to append stuff')
    # logging.info(ODV.data[ODV.time_column])
    # as long as pandas column is not datetime yet
    t = []
    for s in ODV.data[ODV.time_column]:
      t.append(s) # s is already datetime object

    # color limits autoscale (use np to be nan-safe)
    # clims = getclims(clims,ODV.data[cname])
    
    # from matplotlib import gridspec
    # 1. create colorbar
    fig1=plt.figure()
    ax1=plt.axes([0.1,0.1,0.8,0.8], axisbg='w')
    Z=z.as_matrix().astype(float)
    
    # this bit is for pure odv plotting (no wps)
    if zlims==[]:
        zlims=[np.finfo('single').min,np.finfo('single').max]
    if clims==[]:
        clims=[np.finfo('single').min,np.finfo('single').max]
    if times==[]:
        times=["1970-01-01T00:00:00Z","2020-01-01T00:00:00Z"]

        
    Zlims = [[],[]]
    if np.logical_and(zlims[0]==np.finfo('single').min,zlims[1]==np.finfo('single').max):
        Zlims = [np.min(Z), np.max(Z)]
    elif zlims[0] == np.finfo('single').min:
        Zlims[0] = np.min(Z)
        Zlims[1] = zlims[1]
    elif zlims[1] == np.finfo('single').max:
        Zlims[1] = np.max(Z)
        Zlims[0] = zlims[0]
    if np.logical_and(zlims[0]!=np.finfo('single').min,zlims[1]!=np.finfo('single').max):
        Zlims = [zlims[0],zlims[1]]    
    
    if zlims==None:
       scp = plt.scatter(t,c,c=Z, cmap=cmapstr, alpha=alphavalue) # use the z values
       sco = plt.colorbar(scp)
    else:
       scp = plt.scatter(t,c,c=Z, cmap=cmapstr, alpha=alphavalue, vmin=Zlims[0], vmax=Zlims[1]) # use zlims
       sco = plt.colorbar(scp)
    
    fig1.delaxes(ax1)
        
    # 2. Real plot
    # fig = plt.figure(); ax = plt.axes([0.1,0.1,0.8,0.8], axisbg='w')
    fig, ax = plt.subplots()
    
    # _allinrange option
    z_allinrange_ind = np.where(np.logical_and(Z>=Zlims[0], Z<=Zlims[1]))
    t_allinrange = np.asarray(t)[z_allinrange_ind]
    c_allinrange = c[z_allinrange_ind]
    z_allinrange = Z[z_allinrange_ind]
    
    if log10:
       plt.hold('true')
       for i in range(0,len(t_allinrange)):
          plt.plot_date(t_allinrange[i],np.log10(c_allinrange[i]), color=sco.to_rgba(z_allinrange[i],alpha=alphavalue), markersize=markersizevalue, marker=markertype)
       plt.colorbar(scp).set_label(zlabel)
       
       # ax.set_ylabel('log10(' + ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + ']))')
       ax.set_ylabel(ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + ']')
       # set axes limits
       odv2timeseriesaxes(ax,times,np.log10(clims),t_allinrange,np.log10(c_allinrange))
       
       # ticks and labels for log10 = 1
       yticks = ax.yaxis.get_majorticklocs()
       yticklabels = []
       for y in yticks:
          yticklabels.append( '%.2g' % 10**y)
       ax.set_yticklabels(yticklabels);
       
    else:
       plt.hold('true')
       # for i in range(0,len(t_allinrange)):
       #    plt.plot_date(t_allinrange[i],c_allinrange[i],color=sco.to_rgba(z_allinrange[i],alpha=alphavalue), markersize=markersizevalue, marker=markertype) #,color=sco.to_rgba(Z[i],alpha=alphavalue)); #logging.info(t,c,sco.to_rgba(Z[i],alpha=alphavalue))
       # try to change the plot_date to a scatter... time issues!
       plt.scatter(t_allinrange,c_allinrange,color=sco.to_rgba(z_allinrange,alpha=alphavalue), s=markersizevalue*10, marker=markertype, edgecolor='k', linewidth = 0.5)
       plt.colorbar(scp).set_label(zlabel)
       ax.set_ylabel(ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + ']')
       # set axes limits
       odv2timeseriesaxes(ax,times,clims,t_allinrange,c_allinrange)
       
    # http://stackoverflow.com/questions/13515471/matplotlib-how-to-prevent-x-axis-labels-from-overlapping-each-other
    fig.autofmt_xdate(rotation=45) # puts ticks at 45 deg
    plt.savefig(pngFilepath, fontsize=7) # this single one costs ~900ms! 
    plt.close("all") # prevent memory crash issues
    return pngFilepath
    
    # can also be plotted with pandas
    # http://pandas.pydata.org/pandas-docs/stable/visualization.html

def odv2timeseriesaxes(tax,tlim,clim,tlist,clist):
    limits = tax.axis()
    #logging.info(tlim[1])
    if np.logical_and(tlim[0] != "1970-01-01T00:00:00Z",tlim[1] != "2020-01-01T00:00:00Z"):
        # set x-axis
        tlim = [date2num(datetime.datetime.strptime(tlim[0], "%Y-%m-%dT%H:%M:%SZ")), 
                date2num(datetime.datetime.strptime(tlim[1], "%Y-%m-%dT%H:%M:%SZ"))]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        tnum = [date2num(t.to_datetime()) for t in tlist]
        clist_visible = clist[np.logical_and(np.array(tnum)>=tlim[0], np.array(tnum)<=tlim[1])]
        cvisible_lims = getclims(clim,clist_visible)
        tax.set_ylim(cvisible_lims[0],cvisible_lims[1])
        
    if np.logical_and(tlim[0] == "1970-01-01T00:00:00Z",tlim[1] == "2020-01-01T00:00:00Z"):
        # set x-axis
        tlim = [limits[0],limits[1]]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        cvisible_lims = getclims(clim,clist)
        tax.set_ylim(cvisible_lims[0],cvisible_lims[1])
        
    elif tlim[0] == "1970-01-01T00:00:00Z":
        # set x-axis
        tlim = [limits[0], date2num(datetime.datetime.strptime(tlim[1], "%Y-%m-%dT%H:%M:%SZ"))]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        tnum = [date2num(t.to_datetime()) for t in tlist]
        clist_visible = clist[np.logical_and(np.array(tnum)>=tlim[0], np.array(tnum)<=tlim[1])]
        cvisible_lims = getclims(clim,clist_visible)
        tax.set_ylim(cvisible_lims[0],cvisible_lims[1])
        
    elif tlim[1] == "2020-01-01T00:00:00Z":
        # set x-axis
        tlim = [date2num(datetime.datetime.strptime(tlim[0], "%Y-%m-%dT%H:%M:%SZ")), limits[1]]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        tnum = [date2num(t.to_datetime()) for t in tlist]
        clist_visible = clist[np.logical_and(np.array(tnum)>=tlim[0], np.array(tnum)<=tlim[1])]
        cvisible_lims = getclims(clim,clist_visible)
        tax.set_ylim(cvisible_lims[0],cvisible_lims[1])

def getclims(lims,data):
    if len(lims)==0:
       lims    = [0,0]
       lims[0] = np.min(data)
       lims[1] = np.max(data)
    if lims[0]== np.finfo('single').min:
       lims[0] = np.min(data)
    if lims[1]== np.finfo('single').max:
       lims[1] = np.max(data)
    return lims
