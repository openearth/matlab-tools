# coding=latin-1
"""
Create rainfall IDF (Intensity-Duration-Frequency) curves from WATCH data.

usage:

    create_IDF.py -I inifile [-S start][-M month][-E end][-L loglevel] [-X
                              yes/no] [-D yes/no]

    -I inifile  - ini file with settings which data to get
    -S start    - start year (default is 1958)
    -M start    - start month of hydrological year (default is 1)
    -E end      - end year (default is 2001)
    -L loglevel - DEBUG, INFO, WARN, ERROR
    -D yes/no   - download yes/no (default is no)
    -X yes/no   - extract yes/no (default is no)

Copyright (c) Deltares 2015. All rights reserved.

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
The WATCH GPCC Forcing data is used. See
  <https://catalogue.ceh.ac.uk/documents/6b7caa4f-4e35-4c79-aa8e-2e065234a14a>
for a description.

For latitudes where snowfall may have a significant contribution to the total
precipitation, this program should be modified to add the Snowf data aswell.

"""

import os
import stat
import sys
import shutil

import getopt
import gzip
import logging
import logging.handlers
import math
import tarfile
import numpy as np
from utils import configGet, iniFileSetUp, setLogger
from netCDF4 import Dataset


def dummyLines(logger, startYear, endYear, returnPeriods, durations, maxima):
    """
    Return fixed dummy list of y values fitting the returnPeriods /
    durations.

    returnPeriods = [1, 2, 5, 10, 20, 50]
    durations     = [3, 6, 12, 24, 48]
    """
    nrReturnPeriods = len(returnPeriods)
    nrDurations = len(durations)

    baseData = np.array([38.2, 33.4, 25.0, 13.8, 6.4])
    xT = np.zeros((nrDurations, nrReturnPeriods), np.float32)

    print baseData
    print xT

    for r in range(nrReturnPeriods):
        for d in range(nrDurations):
            xT[d, r] = baseData[d]
            baseData[d] = 1.3 * baseData[d]

    print xT

    return xT


def download(logger, url, folder, tarFileName, decadeStart, decadeEnd):
    """
    Create and download tar file with data for the period.

    Parameters
    ----------
        logger      : log writer
        folder      : working folder
        url         : the URL to download the requires data
        tarFileName : name of the tar file with the download
        decadeStart : first decade to get data for
        decadeEnd   : last decade to get data for + 1

    Returns
    -------
        none

    """
    if (os.path.isfile(folder + tarFileName)):
        logger.info("   Skipped download, '" + folder + tarFileName +
                    "' already present.")
    else:
        logger.info("   Downloading '" + folder + tarFileName + "' from '" +
                    url + "'...")
        logger.error("   NOT IMPLEMENTED YET")


def extractAll(logger, folder, tarFileName, template, decadeStart, decadeEnd):
    """
    Extract all files from main file.

    First unpack the main downloaded file to give decade files, then unpack
    each decade file to five year files and finally unpack those files to get
    the data file for each month and year.

    Parameters
    ----------
        logger      : log writer
        folder      : working folder
        tarFileName : name of the tar file with the download
        template    : template for filenames
        decadeStart : first decade to get data for
        decadeEnd   : last decade to get data for + 1

    Returns
    -------
        none
    """
    logger.info("   Extract archives from '" + folder + tarFileName + "'.")

    # extract decade files from main file.

    tar = tarfile.open(name=folder + tarFileName, mode="r")
    tar.extractall(path=folder)
    tar.close()

    # now loop over all decades and extract year files

    for decade in range(decadeStart, decadeEnd):
        extractDecade(logger, folder, template, decade)


def extractDecade(logger, folder, template, decade):

    """See extractAll()"""

    decadeTarName = (folder +
                     template.format("_" + "{0:0>3}".format(decade)) +
                     "0s.tar")
    if (os.path.isfile(decadeTarName)):
        logger.info("      Now extract '" + decadeTarName + "'.")
        dTar = tarfile.open(name=decadeTarName, mode="r")
        names = dTar.getnames()
        dTar.extractall(path=folder)
        dTar.close()

        # Move to folder

        for name in names:
            try:
                shutil.move(folder + name, folder)
                logger.debug("move " + name)
            except:
                logger.debug("move skipped: " + name)

        # now loop over all year files

        for year in range(10 * decade, 10 * decade + 10):
            extractYear(logger, folder, template, year)

    logger.info("            Delete '" + decadeTarName + "'.")
    os.chmod(decadeTarName, stat.S_IWRITE)
    os.remove(decadeTarName)


def extractYear(logger, folder, template, year):

    """See extractAll()"""

    yearTarName = (folder +
                   template.format("_" + "{0:0>4}".format(year)) +
                   ".tar")
    if (os.path.isfile(yearTarName)):
        logger.info("         Now extract '" + yearTarName + "'.")
        yTar = tarfile.open(name=yearTarName, mode="r")
        names = yTar.getnames()
        yTar.extractall(path=folder)
        yTar.close()

        # Move to folder
        for name in names:
            try:
                shutil.move(folder + name, folder)
                logger.debug("move " + name)
            except:
                logger.debug("move skipped: " + name)

        # Now extract monthly nc.gz files to nc files

        for month in range(1, 13):
            extractMonth(logger, folder, template, year, month)

        logger.info("            Delete '" + yearTarName + "'.")
        os.chmod(yearTarName, stat.S_IWRITE)
        os.remove(yearTarName)


def extractMonth(logger, folder, template, year, month):

    """See extractAll()"""

    monZipFile = (folder +
                  template.format("_" + "{0:0>4}{1:0>2}".format(
                                      year, month)) +
                  ".nc.gz")
    if (os.path.isfile(monZipFile)):
        monNcFile = (folder +
                     template.format("_" + "{0:0>4}{1:0>2}".format(
                                         year, month)) +
                     ".nc")
        logger.info("            Now extract '" +
                    monZipFile + "'.")

        with gzip.open(monZipFile,
                       "rb") as f_in, open(monNcFile,
                                           "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)

        logger.info("            Delete '" + monZipFile + "'.")
        os.chmod(monZipFile, stat.S_IWRITE)
        os.remove(monZipFile)


def fitIDF(logger, startYear, endYear, returnPeriods, durations, maxima):
    """
    Return list of y values fitting the returnPeriod/duration data.

    Parameters
    ----------
    startYear        : first hydrological year to consider
    endYear          : last year to consider
    returnPeriods    : array with return periods (in years) for which we
                       want data, e.g. [1, 2, 5, 10, 20, 50]
    durations        : an array with used durations (in hours).
                       e.g. [3, 6, 12, 24, 48]
    maxima           : array with maximum intensities for each year between
                       startYear and endYear (maxima[d, y])

    """

    nrDurations = len(durations)
    nrReturnPeriods = len(returnPeriods)
    nrYears = endYear - startYear
    logger.debug("nrDur = {:2d}".format(nrDurations))
    logger.debug("nrRet = {:2d}".format(nrReturnPeriods))
    logger.debug("nrYrs = {:2d}".format(nrYears))
    logger.debug("shape = {}".format(maxima.shape))

    # compute kT values for each return period, using a Gumbel distribution
    # (see Mujumdar, lecture 29:
    #  http://nptel.ac.in/courses/105108079/module6/lecture29.pdf)

    kT = np.zeros(nrReturnPeriods, np.float32)
    xT = np.zeros((nrDurations, nrReturnPeriods), np.float32)
    c1 = -math.sqrt(6.0) / math.pi
    c2 = 0.5772

    for r in range(nrReturnPeriods):
        T = 1.0 * returnPeriods[r]
        Tm = T - 1.0
        if (Tm <= 0.0):
            Tm = 1.0E-100
            logger.warning("T too small. Set T-1 to {:10.2e}".format(Tm))

        logger.debug("T     = {:7.5f}".format(T))
        logger.debug("Tm    = {:7.5f}".format(Tm))
        logger.debug("T/Tm  = {:7.5f}".format(T/Tm))
        kT[r] = c1 * (c2 + math.log(math.log(T/Tm)))
        logger.debug("k({:2.0f}) = {:7.5f}".format(T, kT[r]))

    # compute mean

    for d in range(nrDurations):

        # compute mean

        nr = 0
        sumVal = 0.0
        for y in range(nrYears):
            if (maxima[d, y] >= 0.0):
                sumVal = sumVal + maxima[d, y]
                nr = nr + 1

        mean = sumVal / nr

        # compute st.dev for the location

        nr = 0
        sumErr = 0.0
        for y in range(nrYears):
            if (maxima[d, y] >= 0.0):
                sumErr = sumErr + (maxima[d, y] - mean) * (maxima[d, y] -
                                                           mean)
                nr = nr + 1

        var = sumErr / (nr - 1)
        stdev = math.sqrt(var)
        logger.debug("mean {:7.3f} stdev {:7.3f}".format(mean, stdev))

        # compute intensity for each return period

        for r in range(nrReturnPeriods):
            xT[d, r] = mean + kT[r] * stdev

    for r in range(nrReturnPeriods):
        logger.debug("{}: {}".format(returnPeriods[r],
                                     formattedList(xT[:, r], "{:7.3f}")))

    return xT


def formatLatLon(latitude, longitude):
    """Nicely format a lat/long pair."""
    sLa = ""
    sLo = ""
    # grd = "Â°"
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


def getLandIndex(logger, fileName, longitude, latitude):

    """Get index in 1D arrays for given lat/long."""

    logger.info("Get land index for {}".format(formatLatLon(latitude,
                                                            longitude)))

    # Dataset is the class behavior to open the file
    # and create an instance of the ncCDF4 class

    ncFile = Dataset(fileName, "r")
    nrLand = len(ncFile.dimensions["land"])
    coordLon = ncFile.variables["Longitude"][:]
    coordLat = ncFile.variables["Latitude"][:]
    landMask = ncFile.variables["land"][:]
    gridLong = ncFile.variables["Grid_lon"][:]
    gridLati = ncFile.variables["Grid_lat"][:]

    landIndex = -1

    for index in range(nrLand):
        if (((coordLon[index] - longitude) >= -0.25) and
                ((coordLon[index] - longitude) < 0.25) and
                ((coordLat[index] - latitude) >= -0.25) and
                ((coordLat[index] - latitude) < 0.25)):
            landIndex = index
            break

    if (landIndex >= 0):
        logger.info("   land index : {} = {}".format(landIndex,
                                                     formatLatLon(
                                                         coordLat[landIndex],
                                                         coordLon[landIndex])))
        logger.debug("   land({}) = {} = {} {}".format(
            landIndex, landMask[landIndex],
            gridLong[landIndex], gridLati[landIndex]))

    return landIndex


def getMax(logger, startYear, startMonth, endYear, template,
           durations, landIndex, location, fileCummYear, fileCummMonth):
    """
    Get average cumm. intensity [mm/hr] for each duration and year.

    Reads variable Rainf from the NetCDF files for the given hydrological
    year. This variable is assumed to contain the rainfall over the
    next 3 hours in kg m-2 s-1

    At 4°C water density is 1000 kg/m3, at 20°C 998.2 kg/m3, which
    differs < 0.2%.

    So to convert to mm/hr we need to multiply by 3600 (4°C) to 3606.5 (20°C).
    For simplicity"s sake we use 3600.

    For the different durations we want to have the accumulated rainfall in the
    preceding X hours, so we have to work with sliding windows
    """

    logger.info("Getting maximum from '{}' starting {} {}".format(
        template.format("*"), startYear, startMonth))

    nrDurations = len(durations)
    nrYears = endYear - startYear
    maximumFound = np.zeros((nrDurations, nrYears), np.float32)
    stepsBack = [durations[d] / durations[0] for d in range(nrDurations)]
    maxBack = stepsBack[nrDurations-1]

    yearCummFile = open(fileCummYear.format(location), "w")
    yearCummFile.write("{};{}\n".format("year", "mm(cumm)"))

    monthCummFile = open(fileCummMonth.format(location), "w")
    monthCummFile.write("{};{};{}\n".format("year", "month", "mm(cumm)"))

    # initialize sliding window

    if (startMonth == 1):
        window = getWindow(logger, startYear - 1, 12, maxBack,
                           template, landIndex)
    else:
        window = getWindow(logger, startYear, startMonth - 1, maxBack,
                           template, landIndex)

    # loop over period

    year = startYear
    yearCumm = [-1.0]
    for y in range(nrYears):

        yearCumm[0] = 0.0
        for month in range(startMonth, min(13, startMonth + 12)):
            updateAverageCumm(logger, maximumFound, template, year, month,
                              startYear, landIndex, window, stepsBack, maxBack,
                              yearCumm, monthCummFile)

        year = year + 1
        for month in range(1, startMonth):
            updateAverageCumm(logger, maximumFound, template, year, month,
                              startYear, landIndex, window, stepsBack, maxBack,
                              yearCumm, monthCummFile)

        yearCummFile.write("{:04d};{:8.3f}\n".format(
                           year, yearCumm[0]))

    # The numbers found now are the average cumm. intensity in [kg m-2 s-1]
    # over a number of steps, return mm/hr

    for d in range(len(durations)):
        for y in range(nrYears):
            maximumFound[d, y] = 3600.0 * maximumFound[d, y] / stepsBack[d]

    yearCummFile.close()
    monthCummFile.close()

    return maximumFound


def getWindow(logger, year, month, maxBack, template, landIndex):

    global variable

    window = []
    fileName = template.format("_{:04d}{:02d}.nc".format(year, month))

    if (os.path.isfile(fileName)):
        logger.debug("Getting window from '{}' in {} {}".format(
                     fileName, year, month))

        ncFile = Dataset(fileName, "r")
        nrSteps = len(ncFile.dimensions["tstep"])
        rainFall = ncFile.variables[variable][:]

        for step in range(nrSteps - maxBack, nrSteps):
            window.append(rainFall[step, landIndex])
    else:
        logger.warning("Using default window for {} {}".format(year, month))
        for step in range(nrSteps - maxBack, nrSteps):
            window.append(0.0)

    return window


def plotIDF(logger, durations, returnPeriods, lines, titles, outputFile):
    """
    Create plot of the IDF curves.

    parameters
    ----------
        logger          : log writer
        durations       : the durations in all data
        returnPeriods   : list with return periods in years
        lines
        titles
        outputFile      : name of output file (csv)
    """
    logger.info("Plotting IDF graph")

    import matplotlib.pyplot as plt
    plt.style.use("ggplot")

    #define plot size in inches (width, height) & resolution(DPI)
    fig = plt.figure(figsize=(12.0, 6.0))

    nrReturnPeriods = len(returnPeriods)

    durationNames = ["{:2d} hr".format(dur) for dur in durations]
    maxVal = math.ceil(np.amax(lines))

    doWriteFile = not ((outputFile is None) or (outputFile == ""))
    if (doWriteFile):
        tmp = "t_return"
        for name in durationNames:
            tmp = tmp + ";{}".format(name)
        outputFile = open(outputFile.format(titles[3]), "w")
        outputFile.write("{}\n".format(tmp))

    for r in range(nrReturnPeriods):

        retPer = returnPeriods[r]
        seriesTitle = titles[4].format(retPer)
        line, = plt.plot(durations, lines[:, r], linewidth=2.0,
                         label=seriesTitle, marker="o", markersize=8)
        if (doWriteFile):
            tmp = str(retPer)
            for val in lines[:, r]:
                tmp = tmp + ";{:6.1f}".format(val)
            outputFile.write("{}\n".format(tmp))

    if (doWriteFile):
        outputFile.close()

    xMin = 0.5 * durations[0]
    xMax = 3.0 * durations[len(durations) - 1]   # leave some space for legend

    plt.semilogx()
    plt.xticks(durations, durationNames)
    plt.xlabel(titles[0])
    plt.xlim(xMin, xMax)

    plt.ylabel(titles[1])
    plt.ylim(0, maxVal)

    plt.title("IDF curves for {}".format(titles[3]))
    x = durations[0]
    y = 0.1 * maxVal
    plt.text(x, y, titles[5])
    plt.legend(loc="upper right", frameon=True, title="Return period")

    # adjust plot
    plt.subplots_adjust(left=0.15, bottom=0.15)

    plt.savefig("idf_{}.png".format(titles[3]), dpi=300)
    plt.show()


def plotMaxima(logger, maxima, durations, startYear, location, latlon,
               outputFile):
    """
    Create plot with found maxima per year.

    Parameters
    ----------
        logger     : log file
        maxima     : 2D array with maximum values found for each hydrological
                     year (maxima[d, y])
        durations  : the durations in all data
        startYear  : first year to process (from the hydrological start
                     month on)
        location   : location description
        latlon     : location in decimal degrees
        outputFile : name of output file (csv)
    """
    logger.info("Plotting graph of maxima")

    import matplotlib.pyplot as plt
    plt.style.use("ggplot")

    fig = plt.figure(figsize=(12.0, 6.0))

    nrYears = maxima.shape[1]
    years = [startYear + yr for yr in range(nrYears)]
    yearNames = ["{:04d}".format(y) for y in years]
    maxVal = np.amax(maxima)

    doWriteFile = not ((outputFile is None) or (outputFile == ""))
    if (doWriteFile):
        tmp = "duration"
        for name in yearNames:
            tmp = tmp + ";{}".format(name)
        outputFile = open(outputFile.format(location), "w")
        outputFile.write("{}\n".format(tmp))


    for d in range(len(durations)):

        seriesTitle = "{:2d} hours".format(durations[d])

        yValues = maxima[d, :]

        line, = plt.plot(years, yValues, linewidth=2.0, label=seriesTitle)

        if (doWriteFile):
            tmp = seriesTitle
            for value in yValues:
                tmp = tmp + ";{:6.2f}".format(value)
            outputFile.write("{}\n".format(tmp))

    if (doWriteFile):
        outputFile.close()

    maxVal = 10 * math.ceil(0.1 * maxVal)

    plt.xlabel("year")
    plt.xticks(years, yearNames, rotation=45)

    plt.ylabel("max. rain [mm/hr]")
    plt.ylim(0, maxVal)

    plt.title("Yearly maxima for mean rainfall {} ({})".format(location,
                                                               latlon))

    plt.legend(loc="upper right", frameon=True, title="Duration")

    #adjust plot
    plt.subplots_adjust(left=0.15, bottom=0.15)

    plt.savefig("max_{}.png".format(location), dpi=300)

    plt.show()


def sumFlux(window, stepsBack):
    """
    Sum fluxes for various durations from sliding window with data.

    Parameters
    ----------
        windows   : sliding window, most recent value first. So window[0]
                    contains the value for stepsBack[0]
        stepsBack : duration array in steps, ascending order.

    Returns
    -------
        list with fluxes for the specified durations. If all goes well this
        list has the same length as stepsBack.
    """
    flux = []
    sumF = 0.0
    index = 0
    for j in range(len(window)):
        sumF = sumF + window[j]
        if (stepsBack[index] == (j + 1)):
            flux.append(float(sumF))
            index = index + 1

    return flux


def updateAverageCumm(logger, maximumFound, template, year, month,
                      startYear, landIndex, window, stepsBack, maxBack,
                      yearCumm, monthCummFile):
    """

    """
    global variable

    ncFileName = template.format("_{:04d}{:02d}.nc".format(year, month))

    if (os.path.isfile(ncFileName)):

        logger.info("Update max in {}-{}".format(year, month))
        logger.debug("   from '{}'".format(ncFileName))

        # Read NetCDF

        ncFile = Dataset(ncFileName)
        nrSteps = len(ncFile.dimensions["tstep"])
        rainFall = ncFile.variables[variable][:]

        #

        nrDurations = len(stepsBack)
        monthCumm = 0.0
        y = year - startYear

        for step in range(nrSteps):

            currentFluxes = sumFlux(window, stepsBack)

            for d in range(nrDurations):
                if (currentFluxes[d] > maximumFound[d, y]):
                    maximumFound[d, y] = currentFluxes[d]

            # Add the value to the start (!) of the window and remove last
            # element

            valueForNextPeriod = rainFall[step, landIndex]
            window.insert(0, valueForNextPeriod)
            window.pop()
            monthCumm = monthCumm + 3.0 * 3600.0 * valueForNextPeriod

        yearCumm[0] = yearCumm[0] + monthCumm

        monthCummFile.write("{:04d};{:02d};{:8.3f}\n".format(
                        year, month, monthCumm))

    return  # void


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
    print __doc__               # the lines 2 - 43 of this file
    sys.exit(0)


# #### MAIN #### #


def main(argv=None):
    """Entry point of application"""

    # --------------------------------------
    # Create a logger for run-time messages
    # --------------------------------------

    loglevel = logging.INFO
    logger = setLogger("create_IDF.log", "create_IDF", level=loglevel)
    logger.info("Create_IDF\n")

    # --------------------------------------
    # Constants
    # --------------------------------------

    latLongMap = "WFD-land-lat-long-z.nc"
    returnPeriods = [2, 5, 10, 20, 50]
    durations = [3, 6, 12, 24, 48]
    global variable
    variable = "Rainf"

    # --------------------------------------
    # Defaults
    # --------------------------------------

    startYear = 1958
    startMonth = 1
    endYear = 2001
    location = "somewhere"
    longitude = 0.0
    latitude = 0.0

    inputFolder = "D:/Projects/1220353 RASOR Malawi/RASOR/"
    template = "Rainf_WFD_GPCC{}"
    doDownload = False
    doExtract = False

    outputFolder = "D:/Projects/1220353 RASOR Malawi/RASOR/"
    fileCummYear = "values_year_{}.csv"
    fileCummMonth = "values_month_{}.csv"
    fileYearMaxima = "intens_year_{}.csv"
    fileIDF = "idf_{}.csv"

    # --------------------------------------
    # Get command-line arguments
    # --------------------------------------

    if argv is None:
        argv = sys.argv[1:]
        if len(argv) == 0:
            usage()
            exit()
    try:
        opts, args = getopt.getopt(argv, "D:E:I:L:M:S:X:")
    except getopt.error, msg:
        usage(msg)

    # --------------------------------------
    # Read ini file
    # --------------------------------------

    inifile = "create_IDF.ini"
    # is the standard name overridden on the command line?
    for o, a in opts:
        if o == "-I":
            inifile = a

    logger.info("Reading settings from ini: '{}'".format(inifile))
    configuration = iniFileSetUp(inifile)

    # Period

    startYear = int(configGet(logger, configuration,
                              "selection", "startYear",
                              str(startYear)))
    startMonth = int(configGet(logger, configuration,
                               "selection", "startMonth",
                               str(startMonth)))
    endYear = int(configGet(logger, configuration,
                            "selection", "endYear",
                            str(endYear)))

    nrReturnPeriods = len(returnPeriods)
    tmpRT = configGet(logger, configuration,
                      "selection", "returnPeriods", None)
    if not (tmpRT is None):
        returnPeriods = [float(s) for s in tmpRT.split(',')]
        nrReturnPeriods = len(returnPeriods)

    # Remaining settings

    longitude = float(configGet(logger, configuration,
                                "selection", "longitude", str(longitude)))
    latitude = float(configGet(logger, configuration,
                               "selection", "latitude", str(latitude)))
    location = configGet(logger, configuration,
                         "selection", "location", location)

    template = configGet(logger, configuration,
                         "input", "template", template)
    inputFolder = configGet(logger, configuration,
                       "input", "folder", inputFolder)

    outputFolder = configGet(logger, configuration,
                            "output", "folder", outputFolder)
    fileCummYear = configGet(logger, configuration,
                             "output", "csvCummPerYear", fileCummYear)
    fileCummMonth = configGet(logger, configuration,
                             "output", "csvCummPerMonth", fileCummMonth)
    fileYearMaxima = configGet(logger, configuration,
                               "output", "csvYearMaxima", fileYearMaxima)
    fileIDF = configGet(logger, configuration,
                        "output", "csvIDF", fileIDF)

    # --------------------------------------
    # Now check if any variables are overriodden by command-line arguments
    # --------------------------------------

    for o, a in opts:
        if o == "-D":
            doDownload = (a.lower() == "yes")
        if o == "-E":
            endYear = int(a)
        if o == "-M":
            startMonth = int(a)
        if o == "-L":
            exec "loglevel = logging." + a
            logger.level = loglevel
        if o == "-S":
            startYear = int(a)
        if o == "-X":
            doExtract = (a.lower() == "yes")

    # --------------------------------------
    # Do some checks
    # --------------------------------------

    if not inputFolder.endswith("/"):
        inputFolder = inputFolder + "/"

    if not os.path.isfile(inputFolder + latLongMap):
        logger.error("Cannot find essential input '{}'".format(inputFolder +
                     latLongMap))
        sys.exit(1)

    if ((endYear - startYear) < 0):
        logger.error("Invalid year range: {} to {}".format(startYear,
                     endYear))
        sys.exit(2)

    if ((durations is None) or (len(durations) < 1)):
        logger.error("Invalid duration range")
        sys.exit(3)

    for r in returnPeriods:
        if (r < 1.5):
            logger.error("Invalid returnPeriod : {:6.2f} <= 1.5 !".format(r))
            sys.exit(4)

    # --------------------------------------
    # Download archives for the relevant decades
    # --------------------------------------

    decadeStart = int(math.floor(startYear / 10.0))
    decadeEnd = int(math.ceil((endYear - 1) / 10.0))

    logger.info("Will start {:04d}, decade {:03d}0".format(startYear,
                                                           decadeStart))
    logger.info("Will stop  {:04d}, decade {:03d}0".format(endYear,
                                                           decadeEnd))

    if doDownload:
        download(logger, "", inputFolder, template.format(""),
                 decadeStart, decadeEnd)
    else:
        logger.warning("Skipping download")

    # and extract them

    if doExtract:
        extractAll(logger, inputFolder, template.format("") + ".tar", template,
                   decadeStart, decadeEnd)
    else:
        logger.warning("Skipping extraction of files")

    # --------------------------------------
    # Extract yearly (hydrological year) maxima
    # --------------------------------------

    landIndex = getLandIndex(logger, inputFolder + latLongMap, longitude, latitude)

    if (landIndex < 0):
        logger.error("Coordinates not found in land array!")
        sys.exit(2)

    # The array maxima will contain for each duration the
    # the yearly maxima (maxima[d, y])

    maxima = getMax(logger, startYear, startMonth, endYear, inputFolder + template,
                    durations, landIndex, location,
                    fileCummYear, fileCummMonth)

    plotMaxima(logger, maxima, durations, startYear,
               location, formatLatLon(latitude, longitude),
               fileYearMaxima)

    # --------------------------------------
    # Compute the parameters for the distribution
    # --------------------------------------

    # lines = dummyLines(logger, startYear, endYear,
    #                    returnPeriods, durations, maxima)
    lines = fitIDF(logger, startYear, endYear,
                   returnPeriods, durations, maxima)

    # --------------------------------------
    # Plot the IDF curve
    # --------------------------------------

    titles = ["Duration [hr]",
              "Intensity [mm/hr]",
              formatLatLon(latitude, longitude),
              location,
              "{} year",
              "based on the period {} to {}".format(startYear, endYear)]

    plotIDF(logger, durations, returnPeriods, lines, titles, fileIDF)

    logger.info("Done.")

    sys.exit(0)

if __name__ == "__main__":
    main()
