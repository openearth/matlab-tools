#!/usr/bin/env python
"""
Created on sep 20, 2017
@author: Dirk Eilander (dirk.eilander@deltares.nl)
"""

import rasterio
import geopandas as gp
import pandas as pd
import shapely
from shapely.geometry import Point, LineString
import numpy as np
import os
import sys
import click
import logging

@click.command(short_help="Sample a dataset at points or a profile defined by a fiona readible vector layer.")
@click.argument('source', nargs=1, required=True, metavar='<RASTER FILENAME>')
@click.argument('vector_file', nargs=1, required=True, metavar='<VECTOR FILENAME>')
@click.argument('out', nargs=1, required=True, metavar='<OUTPUT CSV/SHP FILENAME>')
@click.option('-i', '--bidx', default=1, type=int, help="Band index number. Defaults to 1.")
@click.option('-b', '--buf', default=np.nan, type=float,
    help="""Buffer length in crs projection units. If vector type is 'points': Samples from window around each point. If vector type is line: samples all from transects at <sample_interval> distance.""")
@click.option('-s', '--sample_interval', default=np.nan, type=float,
    help="Sample interval along profile / transect (if vector type is line). Defaults to raster resolution.")
@click.option('-t', '--transect_interval', default=np.nan, type=float,
    help="Interval between transect (if vector type is line and buffer is specified). Defaults to <sample_interval>.")

@click.pass_context
def sample(ctx, source, vector_file, out, bidx,
            buf, sample_interval, transect_interval):
    """Sample a raster dataset (e.g.: GeoTIFF) using a point or line vector layer
    (e.g.: shapefile). The output is written to a csv file or shapefile format.
    So far only sampling from a single band indicated with band no <bidx> has been
    implemented.

    \b
    csv columns:
    x:  global x coordinate sample point;
    y:  global y coordinate sample point;
    z:  raster value at sample point;
    xs: global x coordinate of sample cell center;
    ys: global y coordinate of sample cell center;
    --- optional columns ---
    l:  position along line (if line vector type);
    p:  no. of point sample in window around point (if point vector type and buffer);
    lt: position along transect (if line vector type and buffer);

    \b
    --Default usage:
    python sampling_tool.py raster.tif points.shp sample.csv

    \b
    --For sampling along a profile with 10m intervals, assuming metric crs units, use:
    python sampling_tool.py raster.tif lines.shp sample.csv --sample_interval 10

    \b
    --For sampling with a buffer of 20m around the points, assuming metric crs units, use:
    python sampling_tool.py raster.tif points.shp sample.csv --buf 20

    \b
    --For sampling with a buffer (i.e.: transect) of 20m lenght around a line
    at 100m intervals, assuming metric crs units, use:
    python sampling_tool.py raster.tif points.shp sample.csv --buf 20 --transect_interval 100
    """
    logger = set_logger('sampling_tool')
    buf = buf if np.isfinite(buf) else None
    sample_interval = sample_interval if np.isfinite(sample_interval) else None
    transect_interval = transect_interval if np.isfinite(transect_interval) else None

    try:
        gdf = gp.read_file(vector_file)
        geoms = gdf.geometry
    except IOError, v:
        logger.exception("Exception caught during reading vector file: {:s}".format(str(v)))
        raise click.Abort()

    try:
        with rasterio.open(source) as src:
            assert src.crs == gdf.crs, "crs of shape and raster file are not the same"
            df = sample_geoms(src, geoms, buf, sample_interval, transect_interval, bidx)
    except Exception, v:
        logger.exception("Exception caught during processing: {:s}".format(v))
        raise click.Abort()

    try:
        if out is not None:
            if out.endswith('.csv'):
                df.to_csv(out)
            elif out.endswith('.shp'):
                gdf_points = df2gdf(df.reset_index(), gdf.crs)
                gdf_points.to_file(out)
            else:
                raise NotImplementedError('only .shp and .csv output implemented')
    except IOError, v:
        logger.exception("Exception caught during writing output: {:s}".format(v))
        raise click.Abort()

    close_logger(logger)

########### FUNCTIONS #########################
## sampling functions
def sample_gen(dataset, xy, buf=0, indexes=None):
    """"function to yield sample data at xy coordinates from raster dataset
    args
    dataset     rasterio dataset
    xy          list with xy tuples
    buf         buf in no. of cells around the point to sample from
    indexes     band number

    adapted from https://mapbox.github.io/rasterio/_modules/rasterio/sample.html#sample_gen
    """
    index = dataset.index
    read = dataset.read
    nrows,ncols = dataset.shape

    if isinstance(indexes, int):
        indexes = [indexes]

    for x, y in xy:
        r, c = index(x, y)
        if buf > 0:
            window = ((max(0,r-buf), min(nrows, r+1+buf)), (max(0,c-buf), min(ncols, c+1+buf)))
            data = read(indexes, window=window, masked=False, boundless=True).squeeze()
            dy, dx = window
            my, mx = np.meshgrid(range(*dy), range(*dx))
            rc = (mx.flatten(), my.flatten())
            coords= ds.xy(*rc)
        else:
            window = ((r, r+1), (c, c+1))
            data = float(read(indexes, window=window, masked=False, boundless=True))
            coords = ds.xy(r, c)
        yield data, coords

def sample_geoms(ds, geoms,
                buf=None, sample_interval=None, transect_interval=None, bidx=1):
    """create points along line or transects, then apply sample_gen to get
    raster valeus at predifined points

    return
    pandas DataFrame with global coordinates and (for lines) location along lines
    and transects for each sample point with value of raster in z column"""
    res = ds.res[0]
    # generate all sampling points for different cases
    if np.all([geom.type in ['LineString', 'MultiLineString'] for geom in geoms]):
        sample_interval = res if sample_interval is None else float(sample_interval)
        if buf is None: # profile
            df = line_sampler(geoms, sample_interval)
        else: # profile with transects
            transect_interval = sample_interval if transect_interval is None else min(float(transect_interval), buf)
            df = tline_sampler(geoms, sample_interval, transect_interval, buf, res)
            buf = None # turn off, otherwise for each point a window will be sampled
    elif np.all([geom.type in ['Point'] for geom in geoms]):
        df = point_sampler(geoms) # points
    else:
        raise ValueError('All geometries in vector file should be either be of (Multi)LineString or Point type')

    # create dataframe with all points to sample from
    df = sample_pointdf(ds, df, buf, indexes=bidx)
    return df

def sample_pointdf(ds, df, buf, indexes=1):
    z, cellxy = sample_gen(ds, zip(df['x'], df['y']), buf=buf, indexes=1)
    if buf is None:
        df['z'] = list(z)
    else: # for each row return np samples (from window)
        idx_names = df.index.names
        df.reset_index(inplace=True)
        df_out = pd.DataFrame(columns=df.columns.values.tolist() + ['p', 'z'])
        for i, zi in zip(df.index, z):
            dfi = pd.DataFrame.from_dict({'p':range(zi.size), 'z':zi.flatten})
            for col in df.columns:
                dfi[col] = df.loc[i, col]
            df_out = df_out.append(dfi)
        df = df_out.set_index(idx_names)
    df['xs'], df['ys'] = cellxy
    return df

def tline_sampler(lines, sample_interval, trans_interval, buf, res):
    """create points at <sample_interval> along transects
    transects are created at <trans_interval> along <lines> with 2*<buf> length
    return
    pandas DataFrame with global coordinates and location along lines and transects
    for each point"""
    df_out = pd.DataFrame(columns=['igeom', 'x','y','l','lt'])
    for igeom, line in enumerate(lines):
        llist, transects = transect_at_reg_intervals(line, trans_interval, 2*buf, res)
        for l, tline in zip(llist, transects):
            lt, pnts = pnts_at_reg_intervals(tline, sample_interval)
            df = point_sampler(pnts).reset_index()
            df['l'], df['lt'], df['igeom'] = l, lt-buf, igeom
            df_out = df_out.append(df, ignore_index=True)
    return df_out.set_index(['igeom', 'l', 'lt'])

def line_sampler(lines, sample_interval):
    """create points at <sample_interval> along <lines>
    return
    pandas DataFrame with global coordinates and location along lines for each point"""
    df_out = pd.DataFrame(columns=['igeom','x','y','l'])
    for igeom, line in enumerate(lines):
        l, pnts = pnts_at_reg_intervals(line, sample_interval)
        df = point_sampler(pnts).reset_index()
        df['l'], df['igeom'] = l, igeom
        df_out = df_out.append(df, ignore_index=True)
    return df_out.set_index(['igeom', 'l'])

def point_sampler(pnts):
    """create pandas DataFrame from points
    return
    pandas DataFrame with global coordinates and location along lines for each point"""
    xy = [p.coords[:][0] for p in pnts]
    x, y = map(list, zip(*xy))
    df = pd.DataFrame.from_dict({'igeom':range(len(x)), 'x':x, 'y':y})
    return df.set_index(['igeom'])

def df2gdf(df, crs, xname='x', yname='y'):
    points = [Point(xy) for xy in zip(df[xname], df[yname])]
    return gp.GeoDataFrame(df.copy(), crs=crs, geometry=points)

# util functions
def perpendicular_line(l1, length):
    """Create a new LineString perpendicular to <l1> with length <length>."""
    dx = l1.coords[1][0] - l1.coords[0][0]
    dy = l1.coords[1][1] - l1.coords[0][1]

    p = Point(l1.coords[0][0] + 0.5*dx, l1.coords[0][1] + 0.5*dy)
    x, y = p.coords[0][0],  p.coords[0][1]

    if (dy == 0) or (dx == 0):
        a = length / l1.length
        l2 = LineString([(x - 0.5*a*dy, y - 0.5*a*dx),
                         (x + 0.5*a*dy, y + 0.5*a*dx)])

    else:
        s = -dx/dy
        a = ((length * 0.5)**2 / (1 + s**2))**0.5
        l2 = LineString([(x + a, y + s*a),
                         (x - a, y - s*a)])

    return l2

def pnts_at_reg_intervals(line, interval):
    """get points at regular <interval> along <line>"""
    intervals = np.arange(0, line.length, interval)
    return intervals, [line.interpolate(dist) for dist in intervals]

def transect_at_reg_intervals(line, interval, trans_length, res):
    """get perpendicular lines (transects) at regular <interval> along line
    (shapely LineString/MultiLineString)"""
    dl = max(res/2., 0.5) # res argument required to determin length of tangent lines
    intervals = np.arange(dl, line.length, interval)
    tangent_lines = [LineString(line.interpolate(dist-dl).coords[:] + line.interpolate(dist+dl).coords[:])
                      for dist in intervals+dl]
    return intervals, [perpendicular_line(l1, trans_length) for l1 in tangent_lines]

## logging
def set_logger(name):
    "simple console logger"
    # create logger with 'name'
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    # create console handler with a higher log level
    ch = logging.StreamHandler()
    ch.setLevel(logging.ERROR)
    # create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    ch.setFormatter(formatter)
    # add the handlers to the logger
    logger.addHandler(ch)
    return logger

def close_logger(logger):
    handlers = logger.handlers[:]
    for handler in handlers:
        handler.close()
        logger.removeHandler(handler)

if __name__ == '__main__':
    sample()
