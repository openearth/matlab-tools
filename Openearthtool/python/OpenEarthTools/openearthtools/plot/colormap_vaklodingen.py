# -*- coding: utf-8 -*-
"""
Created on Fri Apr 26 16:18:33 2013

$Id: colormap_vaklodingen.py 9221 2013-09-14 19:37:16Z heijer $
$Date: 2013-09-14 12:37:16 -0700 (Sat, 14 Sep 2013) $
$Author: heijer $
$Revision: 9221 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/colormap_vaklodingen.py $

@author: heijer
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
from matplotlib.colors import LinearSegmentedColormap

def vaklodingen_colormap():
    """
    create colormap
    """
    # colordict created based on https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/cpt-deltares/bathymetry_vaklodingen.cpt
    cdict = {'red': ((0.0000, 0.0392, 0.0392),
            (0.3333, 0.2784, 0.2784),
            (0.4000, 0.3961, 0.3961),
            (0.5067, 0.3725, 0.4667),
            (0.5600, 0.4431, 0.5529),
            (0.6000, 0.5176, 0.6745),
            (0.6267, 0.6314, 0.7843),
            (0.6533, 0.7255, 0.8863),
            (0.6667, 0.8627, 0.9412),
            (0.6800, 0.9804, 0.8902),
            (0.7067, 0.8706, 0.6667),
            (0.7333, 0.7059, 0.6275),
            (0.7733, 0.6667, 0.5686),
            (0.8267, 0.5882, 0.5490),
            (0.9333, 0.5961, 0.6235),
            (1.0000, 0.6235, 0.6235)),
        'green': ((0.0000, 0.1020, 0.1020),
            (0.3333, 0.5843, 0.5843),
            (0.4000, 0.6510, 0.6510),
            (0.5067, 0.6392, 0.6902),
            (0.5600, 0.6784, 0.7608),
            (0.6000, 0.7216, 0.8627),
            (0.6267, 0.8235, 0.9216),
            (0.6533, 0.8902, 0.9569),
            (0.6667, 0.9490, 0.8627),
            (0.6800, 0.9647, 0.8431),
            (0.7067, 0.8314, 0.7843),
            (0.7333, 0.8039, 0.7059),
            (0.7733, 0.7647, 0.6667),
            (0.8267, 0.6863, 0.6667),
            (0.9333, 0.6824, 0.7059),
            (1.0000, 0.7059, 0.7059)),
        'blue': ((0.0000, 0.2588, 0.2588),
            (0.3333, 0.8353, 0.8353),
            (0.4000, 0.8627, 0.8627),
            (0.5067, 0.8588, 0.8784),
            (0.5600, 0.8745, 0.9176),
            (0.6000, 0.8902, 0.9843),
            (0.6267, 0.9686, 1.0000),
            (0.6533, 1.0000, 0.9961),
            (0.6667, 0.9961, 0.7059),
            (0.6800, 0.8431, 0.6275),
            (0.7067, 0.6078, 0.4039),
            (0.7333, 0.4275, 0.3922),
            (0.7733, 0.4118, 0.4118),
            (0.8267, 0.3647, 0.4706),
            (0.9333, 0.4863, 0.6275),
            (1.0000, 0.6275, 0.6275))}
    
    vaklodingen = LinearSegmentedColormap('vaklodingen', cdict)
    
    return vaklodingen

def colorbar(vmin=-50, vmax=25, cmap=vaklodingen_colormap(), label='Altitude [m]', colobartemplate = 'KML_colorbar_template_vertical.png'):
    """
    create colorbar on provided background
    """
    # read background image
    im = plt.imread(colobartemplate)
    # derive figsize based on background image aspect ratio
    figsize = tuple(np.asarray(im.shape[-2::-1]) / float(im.shape[0]) * 6)
    # create figure
    fig = plt.figure(figsize=figsize)
    
    norm = mpl.colors.Normalize(vmin=vmin, vmax=vmax, clip=False)
    
    # plot background image
    axbg = fig.add_axes([0., 0., 1., 1.],
                        frameon=False,
                        xticks=[],
                        yticks=[])
    axbg.imshow(im)
    fontsize = 11
    # plot colorbar
    ax = fig.add_axes([0.4, 0.2, 0.2, 0.72])
    cb = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
                                       norm=norm,
                                       orientation='vertical')
    cb.set_label(label, color='w', labelpad=-70, fontsize=fontsize)
    # format ticklabels
    cbytick_obj = plt.getp(cb.ax.axes, 'yticklabels')
    plt.setp(cbytick_obj, color='w', fontsize=fontsize)
    
    return fig
    
if  __name__ == '__main__':
    fig = colorbar()
    # save result
    fig.savefig('colorbar_ver_lft.png', format='png', transparent=True, facecolor='none')
    plt.close()