__version__ = "$Revision:$"

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares for EMODnet Chemistry
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

# $Id:$
# $Date:$
# $Author:$
# $Revision:$
# $HeadURL:$
# $Keywords:$

import numpy as np
import json
from matplotlib.dates import date2num, num2date
import datetime

import logging

def odv2edmocdi(ODV,cname,zname=[],clims=[],zlims=[],times=[],plot_type=[]):

    # this bit is for pure odv plotting (no wps)
    if zlims==[]:
        zlims=[np.finfo('single').min,np.finfo('single').max]
    if clims==[]:
        clims=[np.finfo('single').min,np.finfo('single').max]
    if times==[]:
        times=["1970-01-01T00:00:00Z","2020-01-01T00:00:00Z"]
    
    # come up with proper ranges
    # c limits
    cname = cname.replace(' ','_')
    c = ODV.data[cname]
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
       
    # T limits
    t = []
    for s in ODV.data[ODV.time_column]:
       t.append(s) # s is already datetime object
    T=[x.to_datetime().toordinal() for x in t]
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
                
    # z limits
    zname = zname.replace(' ','_')
    z = ODV.data[zname]
    Z=z.as_matrix().astype(float)
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
    
    # get indices for values within the range
    if plot_type=='profile':
        o_c = np.where(np.logical_and(c>=Clims[0], c<=Clims[1]))
        o_z = np.where(np.logical_and(z>=Zlims[0], z<=Zlims[1]))
        indrng = np.intersect1d(o_z[0],o_c[0])
        
    elif plot_type=='timeseries':
        o_c = np.where(np.logical_and(c>=Clims[0], c<=Clims[1]))
        o_t = np.where(np.logical_and(np.asarray(T)>=Tlims[0], np.asarray(T)<=Tlims[1]))
        indrng = np.intersect1d(o_t[0],o_c[0])
        
    elif plot_type=='timeprofile':
        o_z = np.where(np.logical_and(z>=Zlims[0], z<=Zlims[1]))
        o_t = np.where(np.logical_and(np.asarray(T)>=Tlims[0], np.asarray(T)<=Tlims[1]))
        indrng = np.intersect1d(o_z[0],o_t[0])
        
    elif plot_type=='map':
        return '[]'
    
    # get the values in common for edmo and cdi
    edmo = np.array(ODV.data['EDMO_CODE']).astype(int)
    cdi = np.array(ODV.data['LOCAL_CDI_ID'])
    
    # get indices
    o_edmo = edmo[indrng]; o_cdi = cdi[indrng]
    dum, indices_edmo = np.unique(o_edmo, return_index=True)
    dum, indices_cdi = np.unique(o_cdi, return_index=True)
    inds = np.union1d(indices_edmo,indices_cdi)
    #inds = np.intersect1d(indrng,indnam)
    edmo_code = o_edmo[inds]
    local_cdi = o_cdi[inds]
    
    jsonfile = json.dumps(zip(edmo_code,local_cdi))
    
    return jsonfile
               