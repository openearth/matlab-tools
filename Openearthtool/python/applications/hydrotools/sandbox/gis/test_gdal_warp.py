#!/usr/bin/env python
from hydrotools import gis
import matplotlib.pyplot as plt
from osgeo import gdalconst
import numpy as np
import time
src_file = r'd:\temp\inun_dynRout_RP_00100\inun_dynRout_RP_00100_masked.tif'
dst_file = r'd:\temp\curacao_inun.tif'
#dst_file = r'd:\temp\Serb.tif'
clone_file = r'd:\projects\1208848-Curacao\DEM\curacao_dem_UTM19N.tif'
# clone_file = r'd:\projects\Serbia\Serbia_cut_UTM34N_highres.tif'
#clone_file = r'd:\projects\Serbia\Serbia_cut_UTM34N.tif'
a = time.time()
gis.gdal_warp(src_file, clone_file, dst_file, format='GTiff', gdal_interp=gdalconst.GRA_Bilinear)
b = time.time()
print('Took {:f} seconds').format(b-a)

x, y, data, fill_value = gis.gdal_readmap(dst_file, 'GTiff')
data_masked = np.ma.masked_equal(data, fill_value)
plt.imshow(data_masked)
plt.show()