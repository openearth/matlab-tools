__version__ = "$Revision: 10965 $"

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

# $Id: odv2profile.py 10965 2014-07-16 15:19:07Z boer_g $
# $Date: 2014-07-16 17:19:07 +0200 (Wed, 16 Jul 2014) $
# $Author: boer_g $
# $Revision: 10965 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2profile.py $
# $Keywords: $

## make PNG profile view

import numpy as np
# http://matplotlib.org/faq/howto_faq.html#howto-webapp
import matplotlib
matplotlib.use('Agg') # use non-interactive plot window on server
import matplotlib.pyplot as plt
from matplotlib.dates import date2num, num2date
import datetime

import logging

def odv2profile_allinrange(pngFilepath,ODV,cname,zname=[],clims=[],zlims=[],times=[],cmapstr="jet",log10=0,colorvalue='blue',markertype="o",markersizevalue=6,linestylevalue='solid',linewidthvalue=1,alphavalue=1): # matplotlib
    "plot ODV object to profile (scatter of 2 columns)"
    
    cname = cname.replace(' ','_') # same as pandas does for all spaces.
    ic = []
    for i,l in enumerate(ODV.pandas_name):
        
        if ODV.pandas_name[i] in cname:
           ic = i
           break
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
       print('warning odv2profile: nu numeric data for ' + cname )
       return
    else:
       c    = np.ma.masked_invalid(np.array(c.as_matrix(),'float')) # np.log10 can't handle pandas arrays
    
    # color limits autoscale (use np to be nan-safe)
    if len(clims)==0:
       clims    = [0,0]
       clims[0] = np.min(c)
       clims[1] = np.max(c)
    if clims[0]== np.finfo('single').min:
       clims[0] = np.min(c)
    if clims[1]== np.finfo('single').max:
       clims[1] = np.max(c)

    
    # as long as pandas column is not datetime yet
    t = []
    for s in ODV.data[ODV.time_column]:
       t.append(s) # s is already datetime object
    
    
    # 1. create colorbar
    fig1=plt.figure()
    ax1=plt.axes([0.1,0.1,0.8,0.8], axisbg='w')
    #T=t.as_matrix().astype(float)

    # this bit is for pure odv plotting (no wps)
    if zlims==[]:
        zlims=[np.finfo('single').min,np.finfo('single').max]
    if clims==[]:
        clims=[np.finfo('single').min,np.finfo('single').max]
    if times==[]:
        times=["1970-01-01T00:00:00Z","2020-01-01T00:00:00Z"]
    
    Z=z.as_matrix().astype(float)
        
    T=[x.to_datetime().toordinal() for x in t]
    #logging.info(T)
    Tlims = [[],[]]
    #logging.info(times)
    if np.logical_and(times[0] == "1970-01-01T00:00:00Z",times[1] == "2020-01-01T00:00:00Z"):
        Tlims = [np.min(T), np.max(T)]
    elif times[0] == "1970-01-01T00:00:00Z":
        Tlims[0] = np.min(T)
        Tlims[1] = date2num(datetime.datetime.strptime(times[1], "%Y-%m-%dT%H:%M:%SZ"))
    elif times[1] == "2020-01-01T00:00:00Z":
        Tlims[1] = np.max(T)
        Tlims[0] = date2num(datetime.datetime.strptime(times[0], "%Y-%m-%dT%H:%M:%SZ"))
    if np.logical_and(times[0] != "1970-01-01T00:00:00Z",times[1] != "2020-01-01T00:00:00Z"):
        Tlims = [date2num(datetime.datetime.strptime(times[0], "%Y-%m-%dT%H:%M:%SZ")),
                date2num(datetime.datetime.strptime(times[1], "%Y-%m-%dT%H:%M:%SZ"))]
    
    if times==None:
       scp = plt.scatter(c,z,c=T, cmap=cmapstr, alpha=alphavalue) # use the t values
       sco = plt.colorbar(scp)
       for i in sco.ax.get_yticklabels():
          clab = float(i.get_text())
          label_list.append(clab)
    else:
       #logging.info(Tlims)
       scp = plt.scatter(c,z,c=T, cmap=cmapstr, alpha=alphavalue, vmin=Tlims[0], vmax=Tlims[1]) # use times
       sco = plt.colorbar(scp)
#      # scp.ticklabel_format(useOffset=False)
       # logging.info(len(sco.ax.yaxis.get_offset_text().get_text()))
       label_list = []
       for i in sco.ax.get_yticklabels():
          clab = float(i.get_text())
          label_list.append(clab)
       label_list = np.interp(sco.ax.get_yticks(), sco.ax.get_ylim(), sco.get_clim())   
       #logging.info(label_list)
#       # sco.ax.set_yticklabels([datetime.datetime.strptime(times[0], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d"), datetime.datetime.strptime(times[1], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")]) #, ticks=[Tlims[0], Tlims[1]])
#       #sco.ax1.set_yticklabels([datetime.datetime.strptime(times[0], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d"), datetime.datetime.strptime(times[1], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")])
    
    fig1.delaxes(ax1)
    
    # 2. Real plot
    fig=plt.figure()
    ax=plt.axes([0.1,0.1,0.8,0.8], axisbg='w')
    
    # _allinrange option
    t_allinrange_ind = np.where(np.logical_and(np.asarray(T)>=Tlims[0], np.asarray(T)<=Tlims[1]))
    t_allinrange = np.asarray(T)[t_allinrange_ind]
    c_allinrange = c[t_allinrange_ind]
    z_allinrange = Z[t_allinrange_ind]
    
    # # Profiles are going to have lines, to be able recognize a profile from another:
    # introduce mins and maxs in the array, in order to avoid concatenation of profiles
    # The following, though a nice scipy method, fails with consecutive equal values.
    # from scipy.signal import argrelextrema
    # minima=np.hstack((0,argrelextrema(z.as_matrix(), np.less)[0])).astype(int)
    # maxima=np.hstack((argrelextrema(z.as_matrix(), np.greater)[0],len(z.as_matrix()))).astype(int)   
    # The discretization is based on Local_cdi_id
    cdi = np.array(ODV.data["LOCAL_CDI_ID"])
    cdi_allinrange = cdi[t_allinrange_ind]
    _, minimaud = np.unique(cdi_allinrange, return_index=True)
    minima = np.sort(minimaud).astype(int)
    # minima = np.flipud(minimaud).astype(int)
    minima1 = minima-1
    maxima = np.hstack((minima1[1:],len(z_allinrange))).astype(int)

    
    if log10:
        for i in np.arange(len(minima)):
            plt.plot(np.log10(c_allinrange[minima[i]:maxima[i]+1]),z_allinrange[minima[i]:maxima[i]+1],color=sco.to_rgba(t_allinrange[i],alpha=alphavalue),marker=markertype,markersize=markersizevalue,linestyle=linestylevalue,linewidth=linewidthvalue,alpha=alphavalue) # too many lines cover the points
            # plt.plot(np.log10(c),z,color=colorvalue,linestyle=linestylevalue,linewidth=linewidthvalue)
        ax.set_xlim(np.log10(clims))
        ax.set_xlabel('log10(' + ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + '])')
        # y axis
        limits = ax.axis()
        if len(zlims)==0:
            ax.set_ylim(limits[2,3])
        if zlims[0] == np.finfo('single').min:
            zlims[0] = limits[2]
        if zlims[1] == np.finfo('single').max:
            zlims[1] = limits[3]
        ax.set_ylim(zlims)
        # ticks and labels
        xticks = ax.xaxis.get_majorticklocs()
        xticklabels = []
        for x in xticks:
            xticklabels.append( '%.2g' % 10**x)
        ax.set_xticklabels(xticklabels);
        
    else:
        for i in np.arange(len(minima)):
            #logging.info((c[minima[i]:maxima[i]+1],z[minima[i]:maxima[i]+1]))
            # plt.plot(c[minima[i]:maxima[i]+1],z[minima[i]:maxima[i]+1],marker="o",color=colorvalue,linestyle=linestylevalue,linewidth=linewidthvalue)
            plt.plot(c_allinrange[minima[i]:maxima[i]+1],z_allinrange[minima[i]:maxima[i]+1],color=sco.to_rgba(t_allinrange[minima[i]],alpha=alphavalue),marker=markertype,markersize=markersizevalue,linestyle=linestylevalue,linewidth=linewidthvalue,alpha=alphavalue) # too many lines cover the points
            #logging.info(T[i])
            # take the first value for each timeseries, cause time is the same for a series: T[minima[i]
            #logging.info(T[minima[i]])
            
        scon=plt.colorbar(scp)
        #logging.info(scon.ax.yaxis.get_offset_text().get_text())
        scon.set_label("Time")
        scon.ax.set_yticklabels([num2date(x).strftime("%Y-%m-%d") for x in label_list])
        
        #scon.colorbar(scp, ticks=[Tlims[0], Tlims[1]]).set_label("Timer")
        #logging.info(dir(cbar))
        #logging.info(cbar)
       
        ax.set_xlim(clims)
        ax.set_xlabel(ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + ']')
        # y axis
        limits = ax.axis()
        if len(zlims)==0:
            ax.set_ylim(limits[2,3])
        if zlims[0] == np.finfo('single').min:
            zlims[0] = limits[2]
        if zlims[1] == np.finfo('single').max:
            zlims[1] = limits[3]
        ax.set_ylim(zlims)
           
    ax.set_ylabel(zlabel)
    ax.invert_yaxis()
    # # no title
    #t0 = min(ODV.data[ODV.time_column])
    #t1 = max(ODV.data[ODV.time_column])
    #if t0==t1:
    #   ax.set_title(str(t0)) # t0 is already datetime object
    #else:
    #   ax.set_title(str(t0) + ' - ' + str(t1))
    plt.savefig(pngFilepath, fontsize=7)
    plt.close("all") # prevent memory crash issues
    return pngFilepath
    
