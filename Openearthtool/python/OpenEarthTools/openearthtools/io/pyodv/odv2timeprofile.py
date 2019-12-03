__version__ = "$Revision$"

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Giorgio Santinelli
#
#       giorgio.santinelli@deltares.nl
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

# $Id$
# $Date$
# $Author$
# $Revision$
# $HeadURL$
# $Keywords$

## make PNG timeseries profiles view

import numpy as np
# http://matplotlib.org/faq/howto_faq.html#howto-webapp
import matplotlib
matplotlib.use('Agg') # use non-interactive plot window on server
import matplotlib.pyplot as plt
# # for time limits:
from matplotlib.dates import date2num
import datetime

import logging

def odv2timeprofile(pngFilepath,ODV,cname,zname=[],clims=[],zlims=[],times=[],cmapstr="jet",log10=0,colorvalue="blue",markertype="o",markersizevalue=6,alphavalue=1): # matplotlib
    "plot ODV object to timeprofile"
    
    zname = zname.replace(' ','_') # same as pandas does for all spaces.
    iz = []
    
    for i,l in enumerate(ODV.pandas_name):
        if ODV.pandas_name[i] in zname:
           iz = i
           break

    # this is for the c (useful for the colorbar)       
    if len(cname)==0:
        c = range(len(ODV.data))
        clabel = 'index [#]'
    else:
        cname = cname.replace(' ','_')
        ic = []
        for i,l in enumerate(ODV.pandas_name):
        
            if ODV.pandas_name[i] in cname:
               ic = i
               c  = ODV.data[cname]
               clabel = ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + ']'
               break

#    c    = ODV.data[cname]
#    if isinstance(c[0],str):
#       c    = None
#       print('warning odv2timeseries: nu numeric data for ' + cname )
#       return
#    else:
#       c    = np.ma.masked_invalid(np.array(c.as_matrix(),'float')) # np.log10 can't handle pandas arrays
    
    z    = ODV.data[zname]
    if isinstance(z[0],str):
        z    = None
        print('warning odv2timeseries: nu numeric data for ' + zname )
        return
    else:
        z    = np.ma.masked_invalid(np.array(z,'float')) # np.ma.masked_invalid(np.array(z.as_matrix(),'float')) # np.log10 can't handle pandas arrays


    # as long as pandas column is not datetime yet
    t = []
    for s in ODV.data[ODV.time_column]:
      t.append(s) # s is already datetime object

#    # introduce mins and maxs in the array, in order to avoid concatenation of profiles
#    # The following, though a nice scipy method, fails with consecutive equal values.
#    _, minimaud = np.unique(ODV.data["LOCAL_CDI_ID"], return_index=True)
#    minima = np.sort(minimaud).astype(int)
#    # minima = np.flipud(minimaud).astype(int)
#    minima1 = minima-1
#    maxima = np.hstack((minima1[1:],len(z.as_matrix()))).astype(int)

#    logging.info(minima)
#    logging.info(maxima)
    
    # color limits autoscale (use np to be nan-safe)
    # clims = getclims(clims,ODV.data[cname])

    # from matplotlib import gridspec
    # 1. create colorbar
    fig1=plt.figure()
    ax1=plt.axes([0.1,0.1,0.8,0.8], axisbg='w')
    
    # this bit is for pure odv plotting (no wps)
    if zlims==[]:
        zlims=[np.finfo('single').min,np.finfo('single').max]
    if clims==[]:
        clims=[np.finfo('single').min,np.finfo('single').max]
    if times==[]:
        times=["1970-01-01T00:00:00Z","2020-01-01T00:00:00Z"]

    
    C=c.as_matrix().astype(float)
    Clims = [[],[]]
    if np.logical_and(clims[0]==np.finfo('single').min,clims[1]==np.finfo('single').max):
        Clims = [np.min(C), np.max(C)]
    elif clims[0] == np.finfo('single').min:
        Clims[0] = np.min(C)
        Clims[1] = clims[1]
    elif clims[1] == np.finfo('single').max:
        Clims[1] = np.max(C)
        Clims[0] = clims[0]
    if np.logical_and(clims[0]!=np.finfo('single').min,clims[1]!=np.finfo('single').max):
        Clims = [clims[0],clims[1]]
       
    if clims==None:
       scp = plt.scatter(t,z,c=C, cmap=cmapstr, alpha=alphavalue) # use the z values
       sco = plt.colorbar(scp)
    else:
       logging.info(clims)
       scp = plt.scatter(t,z,c=C, cmap=cmapstr, alpha=alphavalue, vmin=Clims[0], vmax=Clims[1]) # use clims
       sco = plt.colorbar(scp)
    
    fig1.delaxes(ax1)
        
    # 2. Real plot
    fig = plt.figure(); ax = plt.axes([0.1,0.1,0.8,0.8], axisbg='w')
    fig, ax = plt.subplots()
    if log10:
       # TODO!!! log10 has to be applied to the colorbar!!
       for i in range(0,len(t)):
          plt.plot_date(t[i],z[i], color=sco.to_rgba(C[i],alpha=alphavalue), markersize=markersizevalue, marker=markertype)
       plt.colorbar(scp).set_label(clabel)
       
       odv2timeseriesaxes(ax,times,zlims,t,z)

       ax.set_ylabel(ODV.sdn_name[iz] + ' [' + ODV.sdn_units[iz] + ']')
       ax.invert_yaxis()
       
       # ticks and labels for log10 = 1
       #yticks = ax.yaxis.get_majorticklocs()
       #yticklabels = []
       #for y in yticks:
       #   yticklabels.append( '%.2g' % 10**y)
       #ax.set_yticklabels(yticklabels);
       
    else:
        for i in range(0,len(t)):
            plt.plot_date(t[i],z[i],color=sco.to_rgba(C[i],alpha=alphavalue), markersize=markersizevalue, marker=markertype)
            
        # for i in np.arange(len(minima)):
        # plt.plot_date(t[minima[i]:maxima[i]+1],z[minima[i]:maxima[i]+1],color=sco.to_rgba(C[i],alpha=alphavalue), markersize=markersizevalue, marker=markertype, alpha=alphavalue)
        # logging.info(minima[i]); logging.info(maxima[i]); logging.info(t[minima[i]:maxima[i]+1]), logging.info(z[minima[i]:maxima[i]+1]); logging.info(C[minima[i]:maxima[i]+1])

        plt.colorbar(scp).set_label(clabel)
        
        #scon=plt.colorbar(scp)
        #scon.set_label("value")
       
        odv2timeseriesaxes(ax,times,zlims,t,z)
        logging.info(iz)
        ax.set_ylabel(ODV.sdn_name[iz] + ' [' + ODV.sdn_units[iz] + ']')
        ax.invert_yaxis()

    
# #      plt.hold('true')
# #      for i in range(0,len(t)):
# #         plt.plot_date(t[i],c[i],color=sco.to_rgba(Z[i],alpha=alphavalue), markersize=markersizevalue, marker=markertype) #,color=sco.to_rgba(Z[i],alpha=alphavalue)); #logging.info(t,c,sco.to_rgba(Z[i],alpha=alphavalue))
# #      plt.colorbar(scp).set_label(zlabel)
       
# #     ax.set_ylabel(ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + ']')
       # set axes limits
# #     odv2timeseriesaxes(ax,times,clims,t,c)
       
    # http://stackoverflow.com/questions/13515471/matplotlib-how-to-prevent-x-axis-labels-from-overlapping-each-other
    fig.autofmt_xdate(rotation=45) # puts ticks at 45 deg
    plt.savefig(pngFilepath, fontsize=7)
    plt.close("all") # prevent memory crash issues
    return pngFilepath
    
    # can also be plotted with pandas
    # http://pandas.pydata.org/pandas-docs/stable/visualization.html

def odv2timeseriesaxes(tax,tlim,zlim,tlist,zlist):
    limits = tax.axis()
    logging.info(tlim[1])
    if np.logical_and(tlim[0] != "1970-01-01T00:00:00Z",tlim[1] != "2020-01-01T00:00:00Z"):
        # set x-axis
        tlim = [date2num(datetime.datetime.strptime(tlim[0], "%Y-%m-%dT%H:%M:%SZ")), 
                date2num(datetime.datetime.strptime(tlim[1], "%Y-%m-%dT%H:%M:%SZ"))]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        tnum = [date2num(t.to_datetime()) for t in tlist]
        zlist_visible = zlist[np.logical_and(np.array(tnum)>=tlim[0], np.array(tnum)<=tlim[1])]
        zvisible_lims = getzlims(zlim,zlist_visible)
        tax.set_ylim(zvisible_lims[0],zvisible_lims[1])
        
    if np.logical_and(tlim[0] == "1970-01-01T00:00:00Z",tlim[1] == "2020-01-01T00:00:00Z"):
        # set x-axis
        tlim = [limits[0],limits[1]]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        zvisible_lims = getzlims(zlim,zlist)
        tax.set_ylim(zvisible_lims[0],zvisible_lims[1])
        
    elif tlim[0] == "1970-01-01T00:00:00Z":
        # set x-axis
        tlim = [limits[0], date2num(datetime.datetime.strptime(tlim[1], "%Y-%m-%dT%H:%M:%SZ"))]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        tnum = [date2num(t.to_datetime()) for t in tlist]
        zlist_visible = zlist[np.logical_and(np.array(tnum)>=tlim[0], np.array(tnum)<=tlim[1])]
        zvisible_lims = getzlims(zlim,zlist_visible)
        tax.set_ylim(zvisible_lims[0],zvisible_lims[1])
        
    elif tlim[1] == "2020-01-01T00:00:00Z":
        # set x-axis
        tlim = [date2num(datetime.datetime.strptime(tlim[0], "%Y-%m-%dT%H:%M:%SZ")), limits[1]]
        tax.set_xlim(tlim[0],tlim[1])
        # set y based on x-axis
        tnum = [date2num(t.to_datetime()) for t in tlist]
        zlist_visible = zlist[np.logical_and(np.array(tnum)>=tlim[0], np.array(tnum)<=tlim[1])]
        zvisible_lims = getzlims(zlim,zlist_visible)
        tax.set_ylim(zvisible_lims[0],zvisible_lims[1])

def getzlims(lims,data):
    if len(lims)==0:
       lims    = [0,0]
       lims[0] = np.min(data)
       lims[1] = np.max(data)
    if lims[0]== np.finfo('single').min:
       lims[0] = np.min(data)
    if lims[1]== np.finfo('single').max:
       lims[1] = np.max(data)
    return lims
