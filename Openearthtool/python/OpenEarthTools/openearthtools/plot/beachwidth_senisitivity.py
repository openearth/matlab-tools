# -*- coding: utf-8 -*-
"""
Created on Fri Mar 25 15:55:14 2016

$Id: beachwidth_senisitivity.py 12643 2016-03-25 15:16:34Z heijer $
$Date: 2016-03-25 08:16:34 -0700 (Fri, 25 Mar 2016) $
$Author: heijer $
$Revision: 12643 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/beachwidth_senisitivity.py $

@author: heijer
"""

import logging
logging.basicConfig(level=logging.DEBUG, format='%(levelname)s: %(filename)s line %(lineno)d: %(message)s')


import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import qrcode
import numpy as np
import os

def add_qrcode2fig(fig, ax=None, size=.1):
    keywords = ['$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/beachwidth_senisitivity.py $', '$Revision: 12643 $', ]
    for i,keyword in enumerate(keywords):
        keywords[i] = keyword.replace('$', '').replace('Revision: ', '').replace('HeadURL: ', '').strip()
    img = qrcode.make('%s?p=%s' % (keywords[0], keywords[1]))
    figaspect = fig.get_figheight() / fig.get_figwidth()
    hsize = size
    vsize = size / figaspect
    logging.info('figure size: %g, %g' % (hsize, vsize))
    if ax is None:
        ax = fig.add_axes([1-hsize, 1-vsize, hsize, vsize], frameon=False)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.imshow(img)


x0 = np.array([0, 0, 45, 50, 80, 280, 680])
z0 = np.array([-5, 0, 15, 15, 3, -1, -5])

x1,z1 = np.copy(x0), np.copy(z0)
x1[4] = 75
x1[5:] += 95
z1[4] = 5

x2,z2 = np.copy(x0), np.copy(z0)
x2[4] = 81.25
x2[5:] -= 23.75
z2[4] = 2.5

x = {0:x0, 1:x1, 2:x2}
z = {0:z0, 1:z1, 2:z2}

lang = 'dutch'
xlabel = {'dutch': 'kustdwarse afstand [m]', 'english': 'cross-shore distance [m]'}
ylabel = {'dutch': 'hoogte [m] t.o.v. NAP', 'english': 'heigth [m] w.r.t. NAP'}

fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(14,3), sharey=True, sharex=True,
    subplot_kw=dict(xlim=(799,0), ylim=(-5,16), xlabel=xlabel[lang]))
axes[0].set_ylabel(ylabel[lang])
fig.subplots_adjust(left=.04, right=.98, bottom=.14, wspace=.02)

titles = {'dutch': ('a) gevoeligheid waterlijn', 'b) gevoeligheid duinvoet bij hoog strand', 'c) gevoeligheid duinvoet bij laag strand'),
          'english': ('a) sensitivity waterline', 'b) sensitivity dune foot for high beach', 'c) sensitivity dune foot for low beach')}

for i, ax in enumerate(axes):
    ax.set_title(titles[lang][i])
    ax.add_patch(mpatches.Polygon(np.vstack([x[i], z[i]]).T, fc='yellow', ec='orange'))

for i, ax in enumerate(axes):
    xlim = ax.get_xlim()
    ax.hlines(3, xmin=xlim[0], xmax=xlim[1], linestyle=':')
    ax.add_patch(mpatches.Rectangle([0,-5], -np.diff(xlim), 4, alpha=.3, zorder=-10))
    ax.add_patch(mpatches.Rectangle([0,-5], -np.diff(xlim), 6, alpha=.3, zorder=-10))

axes[0].annotate("", xy=(230, 2), xytext=(230, 0), arrowprops=dict(arrowstyle="<->"))
axes[0].annotate("", xy=(230, 2), xytext=(130, 2), arrowprops=dict(arrowstyle="<->"))

axes[1].annotate("", xy=(175, 5), xytext=(175, 3), arrowprops=dict(arrowstyle="<->"))
axes[1].annotate("", xy=(75, 5), xytext=(175, 5), arrowprops=dict(arrowstyle="<->"))

axes[2].annotate("", xy=(85, 4), xytext=(85, 2), arrowprops=dict(arrowstyle="<->"))
axes[2].annotate("", xy=(85, 4), xytext=(78.75, 4), arrowprops=dict(arrowstyle="<->"))

figname = os.path.splitext(__file__)[0] + '.png'

size = .4
figaspect = fig.get_figheight() / fig.get_figwidth()
vsize = size
hsize = size * figaspect

qrax = fig.add_axes([.05, .45, hsize, vsize], frameon=False)
add_qrcode2fig(fig, ax=qrax, size=.18)

fig.savefig(figname, dpi=600)