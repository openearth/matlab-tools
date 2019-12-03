# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
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

# $Id: lineSlice.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-29 23:21:10 -0800 (Mon, 29 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/lineSlice.py $
# $Keywords: $

import logging
import simplejson as json
import math
from pyproj import Proj, transform

# Change XY coordinates general function
def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:32638'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj,outProj,px,py)

# Slice a line by start/end + sampling
class lineSlice:
    # Featurecollection with linestring + grid size
    def __init__(self, json_data, json_data_subset, grid_size):
        self.coords = []
        self.data = json_data
        self.databounds = json_data_subset
        self.gridsize = grid_size

        # Automatic sampling
        self.datasampled = self.linesampling(grid_size)
        self.datafinal, self.coordsfinal = self.slicebyTwoPoints()

    # Modulus of vector        
    def modulus_segment(self, x1, x2, y1, y2):
        return float(math.sqrt((y2-y1)**2 + (x1-x2)** 2))        
        
    # Slice a vector given a distance
    def linesampling(self, grid_size):
        # Prepare output
        outdata = self.data.copy()
        # Get new coords
        for feature in outdata['features']:
            line = feature['geometry']['coordinates']
            if len(line) > 1: # A linestring feature has more than 1 point
                # Begin point
                xbeg=float(line[0][0])
                ybeg=float(line[0][1])
        
                # Intermediate points according to grid size
                for xend, yend in line:
                    mod=self.modulus_segment(xbeg, xend, ybeg, yend)
                    pieces= int(mod/grid_size)
                    
                    # Segment can or cannot be divided into grid_size
                    if pieces == 0:
                        self.coords.append([xbeg, ybeg])
                    else:
                        for i in range(0, pieces+1):
                            # Unitary vector and subparts
                            uni = [(xend - xbeg) / mod * grid_size, (yend - ybeg) / mod * grid_size]
                            self.coords.append([xbeg + i*uni[0], ybeg + i*uni[1]])
                   
                    # next segment
                    xbeg = xend
                    ybeg = yend
                    
                # Last point
                self.coords.append([xend, yend])        

            # New coords
            feature['geometry']['coordinates']=self.coords
        
        return outdata
        
    # Slice a vector given a distance
    def getOrientation(self):
        # Get new coords        
        ax=self.coords[-1][0] - self.coords[0][0]
        ay=self.coords[-1][1] - self.coords[0][1]

        if ((ax < 0) and (ay < 0)): return "South - West"
        if ((ax < 0) and (ay > 0)): return "North - West"
        if ((ax > 0) and (ay < 0)): return "South - East"        
        if ((ax > 0) and (ay > 0)): return "North - East"

        if ((ax == 0) and (ay < 0)): return "South"
        if ((ax == 0) and (ay > 0)): return "North"
        if ((ax > 0) and (ay == 0)): return "East"        
        if ((ax > 0) and (ay == 0)): return "West"
 
    # Get closest line point to point [same epsg]
    def getClosestPoint(self, line, point):
        # Init search
        selected_dist = 999999999999
        selected = None
        # Get closest point
        for feature in line['features']:
            ind = 0
            selected_ind = -1
            for p in feature['geometry']['coordinates']:
                dist = self.modulus_segment(p[0], point[0], p[1], point[1]) # x1,x2,y1,y2
                if dist < selected_dist:
                    selected = p
                    selected_dist = dist
                    selected_ind = ind
                ind+=1
        return selected_ind

    # Slice a line by two points
    def slicebyTwoPoints(self):
        # Empty selection is equal to full selection
        outdata = self.datasampled.copy()
        if len(self.databounds) == 0:
            coordsfinal = self.coords
        else:
            # Get closests points to begin and end
            beg_end = []
            for feature in self.databounds['features']:
                for p in feature['geometry']['coordinates']:
                    beg_end.append(self.getClosestPoint(self.datasampled, p))

            # Cut line by those points        
            beg_end.sort()
            if beg_end[0] == beg_end[1]:
                if beg_end[1] < len(self.coords)-1:    
                    beg_end[1]+=1 # avoid the same point, also array out of bounds
                elif beg_end[0] > 0:                   
                    beg_end[0]-=1 # avoid the same point, also array out of bounds
                else:                                  
                    beg_end[0]=0
                    beg_end[1]=len(self.coords)-1   # total segment


            logging.info('BEGIN/END = {}/{}'.format(beg_end[0], beg_end[1]))
            coordsfinal = self.coords[beg_end[0]:beg_end[1]]

            # New coords replace
            for feature in outdata['features']:
                feature['geometry']['coordinates'] = coordsfinal

        return outdata, coordsfinal
