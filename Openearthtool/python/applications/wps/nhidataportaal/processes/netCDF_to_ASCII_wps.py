import netCDF4
import numpy as np
import time
import sys
import os
from os.path import dirname, realpath, join

dir_path = dirname(realpath(__file__))
path = join(dir_path, "../data")

SOURCE = "http://www.dinodata.nl:80/opendap/REGIS/REGIS.nc"
LAYERS = ['kD', 'kh']


def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:28992'):
    from pyproj import Proj, transform
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)


def calcdimensions(bbox, cs, x, y):
    xmin, ymin = change_coords(bbox[0], bbox[1])
    xmax, ymax = change_coords(bbox[2], bbox[3])
    xmin = round((xmin-cs)/cs) * cs
    ymin = round((ymin-cs)/cs) * cs
    xmax = round((xmax+cs)/cs) * cs
    ymax = round((ymax+cs)/cs) * cs
    BB = dict(x=[xmin, xmax],
              y=[ymin, ymax])
    bbidx = calcindx(BB, x, y)
    HEADER = [('NCOLS', (xmax-xmin)/cs),
              ('NROWS', (ymax-ymin)/cs),
              ('XLLCORNER', xmin),
              ('YLLCORNER', ymin),
              ('CELLSIZE', 100),
              ('NODATA_VALUE', -9999)]
    return HEADER, bbidx


def calcindx(BB, x, y):
    #(yidx1,yidx2) = np.logical_and(y >= BB['y'][0], y < BB['y'][1]).nonzero()
    #(xidx1,xidx2) = np.logical_and(x >= BB['x'][0], x < BB['x'][1]).nonzero()
    xidx1 = list(x.data).index(BB['x'][0])
    yidx1 = list(y.data).index(BB['y'][0])
    xidx2 = list(x.data).index(BB['x'][1])
    yidx2 = list(y.data).index(BB['y'][1])
    bbidx = (xidx1, xidx2, yidx1, yidx2)
    return bbidx


bbox = (621446, 6707268, 630757, 6730545)

# Open netCDF
nc = netCDF4.Dataset(SOURCE)
cs = 100
x = nc.variables['x'][:]  # lists with lat lon coordinates
y = nc.variables['y'][:]

HEADER, bbidx = calcdimensions(bbox, cs, x, y)


# Initialize program
print("Start of program...")
start_time = time.time()


"""naming convention
[layer][i]_parameter

where parameter is:
- kD (transmissivity)
- t (top)
- b (bottom)
- kh (horizontal transmissivity)
etc
"""

forms = []
formations = nc.variables['layer'][:]
for formation in formations:
    form = "".join(formation)
    forms.append(form)

# Retrieve data
num = 0
for layer in LAYERS:
    for idx, form in zip(range(0, 132), forms):
        # Record progress
        progress = float(num)/(len(LAYERS)*132)*100
        sys.stdout.write("\rProgress: {:5.2f}%".format(progress))

        # Check if formation folder already exists
        folder = os.path.join(path, 'output/{0}'.format(form))
        if not(os.path.isdir(folder)):
            os.makedirs(folder)

        # Create file
        if (len(layer) > 2):
            filename = os.path.join(
                path, 'output/{0}/{0}_{1}.asc'.format(form, layer[0]))
        else:
            filename = os.path.join(
                path, 'output/{0}/{0}_{1}.asc'.format(form, layer))

        # Add headers
        content = []
        with open(filename, 'w') as f:
            for (name, value) in HEADER:
                content.append(" ".join([name, str(value)]))
            header = "\n".join(content) + "\n"
            f.write(header)

        # Retrieve data
        with open(filename, 'ab') as f:
            data = np.flip(
                nc.variables[layer][idx, bbidx[2]:bbidx[3], bbidx[0]:bbidx[1]], 0)
            np.savetxt(f, data, delimiter=' ', fmt='%d')

        # Proceed
        num += 1

sys.stdout.write("\rProgress: 100.00%\n")

# Close netCDF
nc.close()

# Finalize program
print("End of program...")
end_time = time.time()
duration = end_time - start_time
mins = int(duration/60)
secs = int(duration % 60)
print(("Execution time: {:02d}:{:02d} mins".format(mins, secs)))
