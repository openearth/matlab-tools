#/usr/bin/env python
import numpy as np
import math
import os, sys
import pprint as pp
import ugfile as uf
import tiffwriter as tw
import output_settings as c

fnin       = sys.argv[1]
my_varname = sys.argv[2]
tiffname   = my_varname+'.tif'
nband = 1

if len(sys.argv) > 3:
    itim = sys.argv[3] # optional, for time-dependent map output, select which time frame.
else:
    itim = None

ds = uf.DatasetUG(fnin,'r')
bbox, polygons, coords = ds.get_polygons(my_varname) 
bbox[0] = np.floor((bbox[0]-c.lower_left[0])/c.xres)*c.xres + c.lower_left[0]
bbox[1] = np.floor((bbox[1]-c.lower_left[1])/c.yres)*c.yres + c.lower_left[1]

if my_varname in ds.variables.keys():
    if itim is None:
        my_vardata = ds.variables[my_varname][:]
    else:
        my_vardata = ds.variables[my_varname][itim,:]
else:
    sys.stderr.write("Variable "+my_varname+" not found!\n")
    sys.exit(1)

sys.stderr.write("\n")

sys.stderr.write("Opening new TIFF:\n")
my_tiff = tw.tiffwriter(tiffname, bbox, [c.xres, c.yres], nband, c.nptype, c.epsg, flipped=True)

sys.stderr.write("Filling pixels:\n")
pixels = my_tiff.from_polygons(polygons, my_vardata, c.nodata)

sys.stderr.write("Writing Band 1 .... \n")
my_tiff.fillband(1, pixels, c.nodata)

my_tiff.close()
ds.close()








