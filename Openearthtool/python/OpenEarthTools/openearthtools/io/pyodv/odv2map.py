__version__ = "$Revision: 11737 $"

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

# $Id: odv2map.py 11737 2015-02-24 16:20:51Z santinel $
# $Date: 2015-02-24 08:20:51 -0800 (Tue, 24 Feb 2015) $
# $Author: santinel $
# $Revision: 11737 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2map.py $
# $Keywords: $

# TODO: include cname within the list of odv2map function arguments

# for WPS: see http://matplotlib.org/faq/environment_variables_faq.html#envvar-MPLCONFIGDIR
# add to ..\apache\...\pywps.cgi: os.environ['MPLCONFIGDIR']='C:/Python27/Lib/site-packages/matplotlib/mpl-data' 
import os, netCDF4
import numpy as np
# http://matplotlib.org/faq/howto_faq.html#howto-webapp
import matplotlib
matplotlib.use('Agg') # use non-interactive plot window on server
import matplotlib.pyplot as plt

## local settings
ldbfile  = r'http:/opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc' # http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/*
ldbfile  = r'gshhs_i.nc' # cahced in to subfolder static
dxylim   = 2;

def odv2map(pngFilepath,ODV,cname,clims=[],log10=0,cmapstr="jet",markertype="o",alphavalue=1): # matplotlib
    "plot ODV object to png plan view"
    
    cname = cname.replace(' ','_') # same as pandas does for all spaces.
    ic = []
    
    for i,l in enumerate(ODV.pandas_name):
        if ODV.pandas_name[i] in cname:
           ic = i
           break  
    
    df = ODV.data

    N    = df.shape[0] # series length
    M    = df.shape[1] # parameter column
    lon  = df[df.columns[4]]
    lat  = df[df.columns[5]]
    
    c    = df[df.columns[ic]] # NB flags column ic+1
    
    if isinstance(c[0],str):
       c    = None
       print('warning odv2map: nu numeric data for ' + cname )
       return
    else:
       c    = np.ma.masked_invalid(np.array(c.as_matrix(),'float')) # np.log10 can't handle pandas arrays
    # color limits autoscale (use numpy to be nan-safe)
    if len(clims)==0:
       clims    = [0,0]
       clims[0] = np.min(ODV.data[cname])
       clims[1] = np.max(ODV.data[cname])       
    if clims[0]== np.finfo('single').max:
       clims[0] = np.min(ODV.data[cname])
    if clims[1]== np.finfo('single').min:
       clims[1] = np.max(ODV.data[cname])
        
    fig=plt.figure()
    ax=plt.axes([0.05,0.05,0.9,0.9], axisbg='w')
    
    ldb = os.path.join(os.path.split(__file__)[0], 'static', ldbfile)
    if os.path.isfile(ldb):
       tmp = netCDF4.Dataset(ldb); tmp.variables; L = {}
       L['lon'] = tmp.variables['lon'][:]
       L['lat'] = tmp.variables['lat'][:]
       tmp.close()
       plt.plot(L['lon'],L['lat'],color=[.0,.0,.0])

    if log10:
        img = plt.scatter(lon,lat,s=20,c=np.log10(c),cmap=cmapstr,marker=markertype,alpha=alphavalue)
        #clim = img.get_clim()
        img.set_clim(np.log10(clims)) # DO NOT USE plt.clim(np.log10(clim))
    else:
        img = plt.scatter(lon,lat,s=20,c=c,cmap=cmapstr,marker=markertype,alpha=alphavalue)
        #clim = img.get_clim()
        img.set_clim(clims) # DO NOT USE plt.clim(np.log10(clim))
    
    plt.axis([min(lon)-dxylim,max(lon)+dxylim,min(lat)-dxylim,max(lat)+dxylim])
    ax.set_aspect(1./np.cos(np.mean(plt.ylim())/180*np.pi),adjustable='box') # see Matlab axislat()
    plt.text(1, 0,'$^\circ$E' ,horizontalalignment='left' , verticalalignment='top'   ,transform=ax.transAxes, )
    plt.text(0, 1,'$^\circ$N ',horizontalalignment='right', verticalalignment='bottom',transform=ax.transAxes, )
    t0 = min(ODV.data[ODV.time_column])
    t1 = max(ODV.data[ODV.time_column])
    if t0==t1:
       ax.set_title(str(t0)) # t0 is already datetime object
    else:
       ax.set_title(str(t0) + ' - ' + str(t1))
    
    if log10:
        cticks = np.linspace(clims[0], clims[1], 8)
        cbar = plt.colorbar(ticks=np.log10(cticks))
        cticklabels = []
        for c in cticks:
           cticklabels.append( '%.2g' % c)
        cbar.set_ticklabels(cticklabels)
        cbar.ax.set_ylabel('log10(' + ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + '])')
    else:
        cbar = plt.colorbar()
        cbar.ax.set_ylabel(ODV.sdn_name[ic] + ' [' + ODV.sdn_units[ic] + ']')
    
    plt.savefig(pngFilepath, fontsize=7)
    plt.close("all") # prevent memory crash issues
    
    return pngFilepath
    

