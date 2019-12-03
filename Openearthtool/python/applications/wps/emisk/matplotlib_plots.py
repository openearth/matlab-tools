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

# $Id: matplotlib_plots.py 14132 2018-01-30 19:06:23Z sala $
# $Date: 2018-01-30 11:06:23 -0800 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14132 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/matplotlib_plots.py $
# $Keywords: $

import json
import logging

# Plots
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import numpy as np

# Geology legends
import emisk_geology as eg

# CLASS to generate bokeh plots for eMisk
class matplotlib_Plot:
    def __init__(self, datain, titlein, outp):        
        self.data = datain
        self.title = titlein
        self.output_png = outp

    # Simple Time-Series plot XY
    def plot_3dsurface(self, resolution=100):
        # Define 3dplot
        fig = plt.figure(figsize=(8, 6))
        ax = fig.gca(projection='3d')        
        plt.rcParams.update({'font.size': 9})

        # Plot the surface.
        legend_vals = []
        xv = []
        yv = []
        zv = []               
        for layername in eg.orderedtitles:
            # Color and label
            col=eg.colorscheme[layername]     
            lab=eg.titlescheme[layername]       
            values=self.data[layername]
            # X and Y
            logging.info('[plot_3dsurface] -> shape plot[{}] = {}'.format(layername, values.shape))
            nx = range(0, values.shape[1]*resolution, resolution)  ## Number of points x resolution
            ny = range(0, values.shape[0]*resolution, resolution)  ## Number of points x resolution        
            X, Y = np.meshgrid(nx,ny)  
            Z = np.asarray(values).astype(int).tolist()
            X = np.asarray(X).astype(int).tolist()
            Y = np.asarray(Y).astype(int).tolist()    
            ax.plot_wireframe(X, Y, Z, color=col, label=lab, alpha=0.6, rstride=2, cstride=2)
            legend_vals.append(mpatches.Patch(color=col, label=lab))

            # Record max and min values
            xv.append(X)
            yv.append(Y)
            zv.append(Z)

        # Maxs and mins
        maxvy = np.max(Y) 
        maxvx = np.max(X)
        minvz = np.min(Z)
        maxvz = np.max(Z)
        
        # Customize axis.
        ax.set_zlabel('depth [meters-MSL]')    
        ax.view_init(30, 45)        
        ax.set_xlim(0-maxvx*0.15, maxvx*1.15)
        ax.set_ylim(0-maxvy*0.15, maxvy*1.15)
        #ax.set_zlim(minvz*1.25, maxvz*1.25)
        
        # Add legend
        ax.legend(handles=legend_vals, fontsize=9, loc=2, ncol=len(eg.orderedtitles)/2+1, frameon=False)
        plt.tight_layout()

        # Save figure
        plt.savefig(self.output_png, bbox_inches='tight', pad_inches=0.0)

        return len(ny), len(nx), Z