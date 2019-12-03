# coding=latin-1
"""
Create pluvial rainfall GeoTiff from total water minus fluvial, using a mask
 for the river locations.

usage:

    createPluvial.py [-I inifile] [-L level] [-T total] [-O output] [-R size] [-C offset]

    -C offset   : extra offset to subtract (meters)
    -I inifile  : ini file with settings which data to get
    -L loglevel : DEBUG, INFO, WARN, ERROR
    -O output   : Name of output GeoTiff file
    -R size     : Resample to new grid size
    -T total    : Total water input (NetCDF)

Copyright (c) Deltares 2016. All rights reserved.

-------------------------------------------------------------------------------
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
This program uses routines from the earth2observe utility e2o_utils, which is
licensed under the Creative Commons Attribution-ShareAlike 4.0 International
Public License. The full license text of this license is available at
<http://creativecommons.org/licenses/by-sa/4.0/legalcode>
-------------------------------------------------------------------------------
"""

import os
import stat
import sys
import shutil
import struct

import getopt
import time
import logging
import logging.handlers
import math
import numpy as np
import netCDF4 as nc
from utils import configGet, iniFileSetUp, setLogger
from osgeo import gdal


def computePluvial(logger, setTotWat, setT2,
        mapRivers, outputFile,
        offset, resampleSize):
    """
    Compute pluvial rainfall NetCDF dataset from inputs.

    Parameters
    ----------
    logger           : log file
    setTotWat        : input NetCDF dataset total water
    setT2            : input NetCDF dataset with T2 flooding
    mapRivers        : input river mask grid (gdal dataset)
    outputFile       : Output Geo tiff file name
    offset           : offset correction to apply to results.
    resampleSize     : if not none, resample output grid size
    """

    logger.info("Start computing...")

    minVal =  3E+38
    maxVal = -3E-38
    noData = -999.9

    totWat = setTotWat.variables["waterlevel"]
    logger.debug(totWat.dtype)
    logger.debug(totWat.shape)
    sizeX = totWat.shape[2]
    sizeY = totWat.shape[1]
    sizeT = totWat.shape[0]
    logger.debug("  Total water: {} * {} * {} grid..".format(sizeX, sizeY, sizeT))
    totDat = totWat[:][:][:]

    t2Wat = setT2.variables["waterlevel"]
    t2Dat = t2Wat[:][:][:]

    band = mapRivers.GetRasterBand(1)
    mapDat = band.ReadAsArray(0, 0, mapRivers.RasterXSize, mapRivers.RasterYSize).astype(np.float)
    outDat = np.full(mapDat.shape, noData)

    for y in range(sizeY):
        y2 = sizeY - y - 1
        for x in range(sizeX):
            if (math.isnan(float(totDat[0, y2, x])) or \
                math.isnan(float(t2Dat [0, y2, x])) or \
                math.isnan(float(mapDat[y, x]))):
                value = 0.0  #noData
            elif (float(mapDat[y, x]) > 0.0):
                value = 0.0  #noData
            else:
                value = float(totDat[0, y2, x]) - \
                        float(t2Dat[ 0, y2, x]) - offset
                if (value < minVal): minVal = value
                if (value > maxVal): maxVal = value
                if (value < 0.0): value = 0.0
            outDat[y, x] = value

    logger.info("  Min value:  {}".format(minVal))
    logger.info("  Max value:  {}".format(maxVal))
    #logger.info("  No value:   {}".format(noData))

    logger.info("  Start writing GTiff file '{}'".format(outputFile))
    geotransform = mapRivers.GetGeoTransform()
    driver = gdal.GetDriverByName("GTiff")
    mapOut = driver.Create(outputFile, outDat.shape[1], outDat.shape[0], 1, gdal.GDT_Float32)
    mapOut.SetGeoTransform(geotransform)
    mapOut.SetProjection(mapRivers.GetProjection())
    mapOut.GetRasterBand(1).WriteArray(outDat)
    mapOut.GetRasterBand(1).ComputeRasterMinMax(1)
    mapOut.GetRasterBand(1).SetNoDataValue(noData)
    logger.info("  Geotransform {}".format(mapOut.GetGeoTransform()))

    if (not (resampleSize is None)):
        resample_to(logger, outputFile.replace(".tif", "_res.tif"), driver,
                    mapOut, resampleSize, mapDat.shape[0], mapDat.shape[1])
    mapOut = None

    logger.info("Done computing...")
    return


def formatLatLon(latitude, longitude):
    """Nicely format a lat/long pair."""
    sLa = ""
    sLo = ""
    # grd = "°"
    grd = " "

    if (latitude < 0):
        sLa = "{:5.2f}{}S".format(-latitude, grd)
    else:
        sLa = "{:5.2f}{}N".format(latitude, grd)

    if (longitude < 0):
        sLo = "{:6.2f}{}W".format(-longitude, grd)
    else:
        sLo = "{:6.2f}{}E".format(longitude, grd)

    return sLa + ", " + sLo


def formattedList(list, fmt):
    """Format list"""
    str = "["
    for j in range(len(list)):
        if (j == 0):
            str = str + fmt.format(list[j])
        else:
            str = str + ", " + fmt.format(list[j])
    str = str + "]"
    return str


def getGrid(logger, inputFile):
    """
    Return gdal raster dataset

    Parameters
    ----------
    logger           : log file
    inputFile        : PCRaster map file

    """
    logger.info("Start reading map file '{}'".format(inputFile))

    # x, y, map, fill_value = gis.gdal_readmap(inputFile)
    # map = np.ma.masked_where(map == fill_value, map)
    map = gdal.Open(inputFile, gdal.GA_ReadOnly)
    print '  Size is ', map.RasterXSize,'x', map.RasterYSize, 'x', map.RasterCount
    print '  Projection is ', map.GetProjection()

    return map


def getNCdata(logger, inputFile):
    """
    Return NetCDF dataset.

    Parameters
    ----------
    logger           : log file
    inputFile        : NetCDF file

    """
    logger.info("Start reading NetCDF file '{}'".format(inputFile))

    set = nc.Dataset(inputFile, 'r')
    return set


def resample_to(logger, outputFile, driver,
                mapIn, resampleSize, orgX, orgY):
    """
    """
    logger.info("  Start writing GTiff file '{}'".format(outputFile))
    fromExample = True
    if (fromExample):
        example = gdal.Open("flooding/inun_100m_RP_00100.tif", gdal.GA_ReadOnly)
        geotransform = example.GetGeoTransform()
        newY = example.RasterXSize
        newX = example.RasterYSize
    else:
        geotransform = mapIn.GetGeoTransform()
        factor = int(float(geotransform[1]) / float(resampleSize))
        rXS = geotransform[1] / factor
        rYS = geotransform[5] / factor
        geotransform = (geotransform[0], rXS, geotransform[2],
                        geotransform[3], geotransform[4], rYS)
        newX = orgX * factor
        newY = orgY * factor
        logger.info("  Resample output grid by a factor {}".format(factor))
    logger.info("  Resized cells: {} * {}".format(geotransform[1], -geotransform[5]))
    logger.info("  Resized grid: {} * {}".format(newX, newY))
    logger.info("  Geotransform {}".format(geotransform))
    mapOut = driver.Create(outputFile, newY, newX, 1, gdal.GDT_Float32)
    mapOut.SetGeoTransform(geotransform)
    mapOut.SetProjection(mapIn.GetProjection())

    res = gdal.ReprojectImage(mapIn, mapOut, None, None, gdal.GRA_Bilinear )
    if (res != 0):
        logger.warning("Reprojection failed.")
    mapOut = None


def usage(*args):
    """
    Print usage information

    Parameters
    ----------
    *args : string array, command line arguments given

    Returns
    -------
    res : none
    """

    sys.stdout = sys.stderr
    for msg in args:
        print msg
    print __doc__               # the lines 2 - 34 of this file
    sys.exit(0)


##### MAIN #####

def main(argv=None):
    """Entry point of application"""

    # --------------------------------------
    # Create a logger for run-time messages
    # --------------------------------------

    loglevel  = logging.INFO
    localTime = time.localtime(time.time())
    logFile   = "createPluvial_{:0>4}{:0>2}{:0>2}_{:0>2}{:0>2}.log".format(
                                           localTime.tm_year,
                                           localTime.tm_mon,
                                           localTime.tm_mday,
                                           localTime.tm_hour,
                                           localTime.tm_min)
    logger    = setLogger(logFile, "createPluvial", level=loglevel)
    logger.info("createPluvial\n")

    # --------------------------------------
    # Defaults
    # --------------------------------------

    inputFolder       = "flooding/"
    ncTotalWater      = "max_WL_T10.nc"
    ncT2Flooding      = "max_WL_T2.nc"
    fileRivers        = "wflow_riverwidth.map"

    offset            = 0.0
    resampleSize      = None

    outputFolder      = "flooding/"
    filePluvial       = "max_flu_T10.tif"


    # --------------------------------------
    # Get command-line arguments
    # --------------------------------------

    if argv is None:
        argv = sys.argv[1:]
        if len(argv) == 0:
            usage()
            exit()
    try:
        opts, args = getopt.getopt(argv, "C:I:L:O:R:T:")
    except getopt.error, msg:
        usage(msg)

    # --------------------------------------
    # Read ini file
    # --------------------------------------

    iniFile = None
    # is the standard name overridden on the command line?
    for o, a in opts:
        if o == "-I":
            iniFile = a
        if o == "-L":
            logger.setLevel(a)

    if (not (iniFile is None)):
        logger.info("Reading settings from ini: '{}'".format(iniFile))
        configuration = iniFileSetUp(iniFile)

        # Input overrides

        inputFolder       = configGet(logger, configuration,
                                "input", "folder",
                                inputFolder)
        ncTotalWater      = configGet(logger, configuration,
                                "input", "totalWater",
                                ncTotalWater)
        ncT2Flooding      = configGet(logger, configuration,
                                "input", "t2Flooding",
                                ncT2Flooding)
        fileRivers        = configGet(logger, configuration,
                                "input", "mapRivers",
                                fileRivers)
        offset            = float(configGet(logger, configuration,
                                "settings", "offset",
                                str(offset)))
        resampleSize      = configGet(logger, configuration,
                                "settings", "resample",
                                resampleSize)
        outputFolder      = configGet(logger, configuration,
                                "output", "folder",
                                outputFolder)
        filePluvial       = configGet(logger, configuration,
                                "output", "filePluvial",
                                filePluvial)

    # command-line overrides
    for o, a in opts:
        if o == "-C":
            offset = float(a)
        if o == "-O":
            filePluvial = a
        if o == "-R":
            resampleSize = a
        if o == "-T":
            ncTotalWater = a

    if (not (resampleSize is None)): resampleSize = float(resampleSize)

    # --------------------------------------
    # Do some checks
    # --------------------------------------

    if not inputFolder.endswith("/"):  inputFolder = inputFolder + "/"
    if not outputFolder.endswith("/"): outputFolder = outputFolder + "/"
    if not os.path.isfile(inputFolder + ncTotalWater):
        logger.error("Cannot find input file '{}'".format(inputFolder +
                     ncTotalWater))
        sys.exit(1)
    if not os.path.isfile(inputFolder + fileRivers):
        logger.error("Cannot find input file '{}'".format(inputFolder +
                     fileRivers))
        sys.exit(1)

    # --------------------------------------
    # Print settings
    # --------------------------------------

    logger.info("Total water input: '{}'".format(inputFolder + ncTotalWater))
    logger.info("T2 subtract        '{}'".format(inputFolder + ncT2Flooding))
    logger.info("River map:         '{}'".format(inputFolder + fileRivers))
    logger.info("Offset:            {0:6.3f} m".format(offset))
    if (resampleSize is None):
        logger.info("No resampling")
    else:
        logger.info("Resample to:       {} m".format(resampleSize))
    logger.info("Output (pluvial):  '{}'".format(outputFolder + filePluvial))
    logger.info("Log level:         {}".format(logger.level))

    # --------------------------------------
    # Read and process
    # --------------------------------------

    setTotWat  = getNCdata(logger, inputFolder + ncTotalWater)
    setT2      = getNCdata(logger, inputFolder + ncT2Flooding)
    mapRivers  = getGrid(logger,   inputFolder + fileRivers)

    computePluvial(logger, setTotWat, setT2,
                   mapRivers, outputFolder + filePluvial,
                   offset, resampleSize)

    mapRivers = None
    mapPluvial = None

    # --------------------------------------
    # We are ready
    # --------------------------------------

    logger.info("Done.")

    sys.exit(0)

if __name__ == "__main__":
    main()
