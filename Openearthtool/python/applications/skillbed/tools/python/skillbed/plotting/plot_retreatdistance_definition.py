# -*- coding: utf-8 -*-
"""
Created on Thu Jan 17 10:32:13 2013

@author: heijer

$Id: plot_retreatdistance_definition.py 9226 2013-09-17 10:40:20Z heijer $
$Date: 2013-09-17 03:40:20 -0700 (Tue, 17 Sep 2013) $
$Author: heijer $
$Revision: 9226 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/skillbed/tools/python/skillbed/plotting/plot_retreatdistance_definition.py $

"""

import matplotlib.pyplot as plt
from matplotlib.patches import Polygon,Rectangle
from matplotlib.lines import Line2D
import numpy as np
import os

def get_parabola(Hsig_t, w, x, extension = 'plus'):
    if extension == 'plus':
        c_tp = 12
        cp_tp = .45            
    c_1 = .4714
    c_hs = 7.6
    c_w = .0268
    cp_hs = 1.28
    cp_w = .56
    two = c_1*np.sqrt(18) # term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)

    y = (c_1*np.sqrt((c_hs/Hsig_t)**cp_hs*(w/c_w)**cp_w*x+18)-two) / (c_hs/Hsig_t)
    
    return y

x_para = np.arange(150)
y_para = get_parabola(9, .0268, x_para)

x = [-100, -89.2, -61.7, -24.375, 5.625, 55.725, 230.625, 2780.63]

z = [3, 4, 15, 15, 3, 0, -3, -20]
z_water = np.tile(5, 8)

fig = plt.figure(figsize=(8,3))
ax = fig.add_subplot(111)

ax.plot(x,z,'k')

ax.plot(-40+np.append(np.array(-10), x_para), 5-np.append(np.array(-10), y_para), 'r')
ax.axhline(5, color='blue', lw=2, alpha=0.5)
ax.axvline(0.625, linestyle=':', color='black', lw=.5)
# negative additional erosion
#ax.add_patch(Polygon([[-40,5],[-30,5],[-40,15],[-50,15]], facecolor='green', alpha=.5))
# positive additional erosion
#ax.add_patch(Polygon([[-50,5],[-40,5],[-50,15],[-60,15]], facecolor='blue', alpha=.5))
# basic additional erosion
ax.add_patch(Polygon([[-40,5],[0.625,5],[-24.375,15],[-50,15]], fill=False, hatch='\\'))

#ax.arrow(0.625,15.5, -40,0, head_width=.8, head_length=3, length_includes_head=True, facecolor='green', alpha=.5, label='test')
ax.arrow(0.625,16, -50,0, head_width=.8, head_length=3, length_includes_head=True, facecolor='None', edgecolor='red')
#ax.arrow(0.625,16.5, -60,0, head_width=.8, head_length=3, length_includes_head=True, facecolor='blue', alpha=.5)

ax.text(0,17.2, 'Retreat distance', va='bottom', ha='left')
ax.invert_xaxis()
ax.set_xlim([50,-100])
ax.set_ylim([-5,17])
ax.set_xticks([-100, -50, 0,50])
ax.set_ylabel('height above MSL [m]')
ax.set_xlabel('cross-shore coordinate [m]')

ErSSL = Rectangle((0, 0), 1, 1, fill=False, hatch='\\')
#negAE=Rectangle((0, 0), 1, 1, fc="green", alpha=.5)
#posAE=Rectangle((0, 0), 1, 1, fc="blue", alpha=.5)
RDref=Line2D((0,1),(0,1), linestyle=':', color='black', lw=.5)
para=Line2D((0,1),(0,1), color='red')
prf = Line2D((0,1),(0,1), color='black')
ax.legend([prf,para,RDref,ErSSL], ('Initial profile', 'Model result', 'Cross-shore reference (MSL+5 contour)', 'Erosion above SSL'),bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.,prop={'size':10})

fig.subplots_adjust(left=.08,bottom=0.15, right=0.55, top=0.9)

figfilename = os.path.splitext(__file__)[0]
plt.savefig(figfilename + '.pdf', dpi=300)
plt.savefig(figfilename + '.png', dpi=300)
