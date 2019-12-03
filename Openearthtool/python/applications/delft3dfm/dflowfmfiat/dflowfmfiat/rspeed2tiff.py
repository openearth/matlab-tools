#/usr/bin/env python
import numpy as np
import math
import os, sys
import ugfile as uf
import tiffwriter as tw
import output_settings as c
import risingspeeds

my_varname = 'mesh2d_waterdepth' 

# Open classmap file and derive rising speeds
fnin = sys.argv[1]
ds = uf.DatasetUG(fnin,'r')
bbox, polygons, coords = ds.get_polygons(my_varname) 
ncvar = ds.variables[my_varname]
nctim = ds.variables["time"]
rising_speed_calc = risingspeeds.IncrementalConverter(ncvar, nctim, 0.02, 1.5)
rising_speeds = rising_speed_calc.getRisingSpeeds(verbose=True)

#bbox, polygons, coords = ds.get_polygons(my_varname) 
bbox[0] = np.floor((bbox[0]-c.lower_left[0])/c.xres)*c.xres + c.lower_left[0]
bbox[1] = np.floor((bbox[1]-c.lower_left[1])/c.yres)*c.yres + c.lower_left[1]


# Write calculated rising speeds to tiff
my_vardata = rising_speeds    
tiffname   = 'rising_speeds.tif'
nband = 1

sys.stderr.write("\n")
sys.stderr.write("Opening new TIFF:\n")
my_tiff = tw.tiffwriter(tiffname, bbox, [c.xres, c.yres], nband, c.nptype, c.epsg, flipped=True)

sys.stderr.write("Filling pixels:\n")
pixels = my_tiff.from_polygons(polygons, my_vardata, c.nodata)

sys.stderr.write("Writing Band 1 .... \n")
my_tiff.fillband(1, pixels, c.nodata)

my_tiff.close()
ds.close()
sys.exit()    








