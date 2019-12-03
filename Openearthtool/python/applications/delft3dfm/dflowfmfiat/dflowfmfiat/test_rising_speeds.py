import netCDF4 as nc, numpy as np
import risingspeeds
import sys

try:
    ds = nc.Dataset(sys.argv[1],"r")
    ncvar = ds.variables[sys.argv[2]]
    nctim = ds.variables["time"]
except:
    sys.stderr.write("Something went wrong somehow...\n")
    sys.exit()
rising_speed_calc = risingspeeds.IncrementalConverter(ncvar, nctim, 0.02, 1.5)
rising_speeds = rising_speed_calc.getRisingSpeeds(verbose=True)
print (len(rising_speeds))
sys.exit()    
