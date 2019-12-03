# -*- coding: utf-8 -*-
"""
Created on Fri Dec  6 19:53:24 2013

@author: heijer
"""

from jarkus.transects import Transects
import numpy as np

Jk = Transects(url='http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect_r2013_filled.nc')
ids = Jk.get_data('id')
idxs = np.floor(ids/1e6) == 8
for idx in np.nonzero(idxs)[0]:
    Jk.set_filter(alongshore=idx)
    with open('transect_%i.jrk'%ids[idx], 'w') as f:
        f.write(Jk.get_jrk())