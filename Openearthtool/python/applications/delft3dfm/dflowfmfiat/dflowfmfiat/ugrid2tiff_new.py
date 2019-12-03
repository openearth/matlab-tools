#/usr/bin/env python
import numpy as np
import math
import os, sys
import argparse
import pprint as pp
import ugfile as uf
import tiffwriter as tw
import output_settings as c

# argparser
def parse_args():
    """
    Parse the command line arguments
    """
    argumentparser = argparse.ArgumentParser(
        description='Create TIFF from UGRID nc-file')
    argumentparser.add_argument('-i', '--input',
                                dest='fnin',
                                help='NC-filename, input')
    argumentparser.add_argument('-v', '--variable',
                                 dest='variable',
                             help='Variable name')
    argumentparser.add_argument('-ts', '--time-single',
                                 dest='time_request',
                             help='Single Time Index')
    argumentparser.add_argument('-tl', '--time-list',
                                 dest='time_list_file',
                             help='File with a list of time indices')
    argumentparser.add_argument('-minx', '--min-x',
                                 dest='minx',
                             help='West edge')
    argumentparser.add_argument('-maxx', '--max-x',
                                 dest='maxx',
                             help='East edge')
    argumentparser.add_argument('-miny', '--min-y',
                                 dest='miny',
                             help='South edge')
    argumentparser.add_argument('-maxy', '--max-y',
                                 dest='maxy',
                             help='North edge')
    argumentparser.add_argument('-res', '--resolution',
                                 dest='xres',
                             help='Pixel size')
    arguments = argumentparser.parse_args()
    return arguments


# read times from a file
args = parse_args()
if args.time_request is not None:
   itimes = [int(args.time_request)]				# time index from an argument
else:
   if args.time_list_file is not None:
       ftimes = open(args.time_list_file,"r") 
       itimes = [int(s) for s in ftimes.readlines()]		# times indices from file
   else:
       pass ! Todo: handle exception

my_varname = args.variable
tiffname   = my_varname+'.tif'
nband = 1

ds = uf.DatasetUG(fnin,'r')
bbox, polygons, coords = ds.get_polygons(my_varname) 
bbox[0] = np.floor((xmin-c.lower_left[0])/c.xres)*c.xres + c.lower_left[0]
bbox[1] = np.floor((ymin-c.lower_left[1])/c.yres)*c.yres + c.lower_left[1]

if not my_varname in ds.variables.keys():
    sys.stderr.write("Variable "+my_varname+" not found!\n")
    sys.exit(1)
my_varobj = ds.variables[my_varname]
if 'time' in list(my_varobj.dimensions):
    for itim in itimes:
        tiffname = "%s_%08d.tif"%(my_varname,itim) 
        sys.stderr.write("Opening new TIFF: %s\n"%tiffname)
        my_vardata = ds.variables[my_varname][itim,:]
        my_tiff = tw.tiffwriter(tiffname, bbox, [c.xres, c.yres], nband, c.nptype, c.epsg, flipped=True)
        pixels = my_tiff.from_polygons(polygons, my_vardata, c.nodata)
        my_tiff.fillband(1, pixels, c.nodata)
        my_tiff.close()
else:
    tiffname = "%s.tif" 
    sys.stderr.write("Opening new TIFF: %s\n"%tiffname)
    my_vardata = ds.variables[my_varname][:]
    my_tiff = tw.tiffwriter(tiffname, bbox, [c.xres, c.yres], nband, c.nptype, c.epsg, flipped=True)
    pixels = my_tiff.from_polygons(polygons, my_vardata, c.nodata)
    my_tiff.fillband(1, pixels, c.nodata)
    my_tiff.close()
ds.close()








