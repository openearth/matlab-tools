#!/usr/bin/env python
"""
Function to read raw yamazaki data in memory"""

import numpy as np
import os

def read_raw_yama(filename, nr_outputs, datatype, nrrows, nrcols):
    f = open(filename, 'rb')
    data = np.fromfile(f, dtype=datatype, count=nrrows*nrcols)
    # reshape to a grid and flip the y-axis. This is because GIS people are
    # used to first write the upper row, while NetCDF people (CF-convention)
    # starts with the lower row.
    
    array = np.flipud(np.reshape(data, (nrrows, nrcols)))
    # establish an x and y-axis based on the file name
    filestring = os.path.split(filename)[1]
    if filestring[0] == 's':
        lly = -float(filestring[1:3])
    else:
        lly = float(filestring[1:3])
    if filestring[3] == 'w':
        llx = -float(filestring[4:7])
    else:
        llx = float(filestring[4:7])
    # make an axis
    x = np.linspace(llx+1./2400, llx+5.-1./2400, 6000)
    y = np.linspace(lly+1./2400, lly+5.-1./2400, 6000)
    return llx, lly, x, y, array
   
# Ther data naming convention is giving the lower left corner

## TESTED, river widths should be read as given below
#filename = r'd:\data\GlobalWidthDatabase\n00e005_wth.bin'
#datatype = '<f4'
#llx, lly, x, y, data = read_raw_yama(filename, 1, datatype, 6000, 6000)

### TESTED, up areas should be read as given below
#filename = r'd:\data\GlobalWidthDatabase\n00e005_upa.bin'
#datatype = '<f4'
#llx, lly, x, y, data = read_raw_yama(filename, 1, datatype, 6000, 6000)

## TESTED flow directions are D8 and follow the following numbering convention:
# 1:N, 2:NE, 3:E, 4:SE, 5:S, 6:SW, 7:W, 8:NW, 0:River Mouth, -1: Inland River Endpoint
filename = r'd:\data\GlobalWidthDatabase\n00e005_dir.bin'
datatype = '<i1'
llx, lly, x, y, data = read_raw_yama(filename, 1, datatype, 6000, 6000)
