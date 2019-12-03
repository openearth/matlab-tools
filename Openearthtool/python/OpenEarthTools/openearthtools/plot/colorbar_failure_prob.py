# -*- coding: utf-8 -*-
"""
Created on Sat Sep 14 20:34:44 2013

$Id: colorbar_failure_prob.py 10979 2014-07-22 13:40:21Z heijer $
$Date: 2014-07-22 06:40:21 -0700 (Tue, 22 Jul 2014) $
$Author: heijer $
$Revision: 10979 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/colorbar_failure_prob.py $

@author: heijer
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl

# adjust padding for the tick labels
mpl.rcParams['xtick.major.pad']='0'
# define fontsize
fontsize = 11

# create colorbar on provided background

# read background image
im = plt.imread('KML_colorbar_template_vertical.png')
# derive figsize based on background image aspect ratio
figsize = tuple(np.asarray(im.shape[-2::-1]) / float(im.shape[0]) * 6)
# create figure
fig = plt.figure(figsize=figsize)

norm = mpl.colors.Normalize(vmin=-7,vmax=-1)
# define colors as list
colors = ['blue', 'cyan', 'lawngreen', 'yellow', 'orange', 'red']
# create colormap
cmap = mpl.colors.ListedColormap(colors)

# plot background image
axbg = fig.add_axes([0., 0., 1., 1.],
                    frameon=False,
                    xticks=[],
                    yticks=[])
axbg.imshow(im)
# create colorbar axis
cax = fig.add_axes([0.4, 0.2, 0.2, 0.72])
# define tick formatter
formatter = mpl.ticker.FuncFormatter(lambda x,pos: '10$^{%i}$'%x)
# plot colorbar
cb = mpl.colorbar.ColorbarBase(cax,
                               cmap=cmap,
                               norm=norm,
                               format=formatter,
                               ticks=[-6,-5,-4,-3,-2],
                               orientation='vertical')
# set axis label (negative padding is used to put the label left of the colorbar)
cb.set_label('Probability of failure [year$^{-1}$]',
                                      color='w',
                                      labelpad=-65,
                                      fontsize=fontsize)
# format ticklabels
cbytick_obj = plt.getp(cb.ax.axes, 'yticklabels')
plt.setp(cbytick_obj,
         color='w',
         fontsize=fontsize)

fig.savefig('colorbar_ver_lft.png', format='png', transparent=True, facecolor='none')
plt.close()