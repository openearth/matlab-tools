from __future__ import division
# Copyright (c) 2017, Deltares
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
# following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
# disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# contact: joan.salacalero@deltares.nl

from builtins import next
from builtins import range
from builtins import object
from past.utils import old_div
from osgeo import gdal
import numpy
import os.path
import sys
import grid_utilities


class IncrementalConverter(object):
    """Construct the triplet of grid files from an incremental file."""

    def __init__(self, filepath, outdir):
        self.__inc_filepath = filepath
        self.__delta_t0 = 0
        self.__properties = {}
        self.__classes = {}
        self.__lower_threshold = None
        self.__upper_threshold = None
        self.__first_time = None
        self.__output_driver = gdal.GetDriverByName('GTiff')
        self.__output_driver.Register()
        self.__dh_filepath = os.path.join(outdir, os.path.splitext(os.path.basename(filepath))[0] + '_DH.tif')
        self.__ta_filepath = os.path.join(outdir, os.path.splitext(os.path.basename(filepath))[0] + '_TA.tif')
        self.__td_filepath = os.path.join(outdir, os.path.splitext(os.path.basename(filepath))[0] + '_TD.tif')
        self.__dh_raster = None
        self.__ta_raster = None
        self.__td_raster = None
        self.__dh_band = None
        self.__ta_band = None
        self.__td_band = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.__dh_band = None
        self.__ta_band = None
        self.__td_band = None
        self.__dh_raster = None
        self.__ta_raster = None
        self.__td_raster = None

    def set_delta_t0(self, delta_t0):
        self.__delta_t0 = delta_t0

    def __parse_header(self, lines):
        """Obtain the grid properties and increment classes."""
        # Read the line after "MAIN DIMENSIONS MMAX NMAX".
        for line in lines:
            if line.strip().lower().startswith('main dimensions'):
                self.__properties['ncols'], self.__properties['nrows'] = [int(float(x)) for x in next(lines).split()]
                break
        # Read the line after "GRID DX X0 Y0".
        # or
        # Read the line after " GRID DX DY X0 Y0".
        for line in lines:
            if line.strip().lower().startswith('grid'):
                parts = next(lines).split()
                if len(parts) == 3:
                    self.__properties['cellsize'] = float(parts[0])
                    self.__properties['xllcorner'] = float(parts[1])-0.5*self.__properties['cellsize']
                    self.__properties['yllcorner'] = float(parts[2])-0.5*self.__properties['cellsize']
                    break
                elif len(parts) == 4:
                    self.__properties['cellsize'] = float(parts[0])
                    self.__properties['xllcorner'] = float(parts[2])-0.5*self.__properties['cellsize']
                    self.__properties['yllcorner'] = float(parts[3])-0.5*self.__properties['cellsize']
                    break
        # Read the lines between "CLASSES OF INCREMENTAL FILE H C Z U V" and "ENDCLASSES".
        class_number = 1  # Fortran counts from 1, not 0.
        for line in lines:
            if line.strip().lower().startswith('classes'):
                break
        for line in lines:
            if line.strip().lower().startswith('endclasses'):
                break
            self.__classes[class_number] = float(line.split()[0])
            class_number += 1

    def __create_grids(self):
        """Construct the three grid files."""
        geo_transform = (
            self.__properties['xllcorner'],
            self.__properties['cellsize'],
            0.,
            self.__properties['yllcorner'] + self.__properties['nrows'] * self.__properties['cellsize'],
            0.,
            -self.__properties['cellsize']
        )

        self.__dh_raster = self.__output_driver.Create(self.__dh_filepath, self.__properties['ncols'],
                                                       self.__properties['nrows'],
                                                       1, gdal.GDT_Float32, ['COMPRESS=LZW'])
        self.__dh_raster.SetGeoTransform(geo_transform)
        self.__dh_band = self.__dh_raster.GetRasterBand(1)

        self.__ta_raster = self.__output_driver.Create(self.__ta_filepath, self.__properties['ncols'],
                                                       self.__properties['nrows'],
                                                       1, gdal.GDT_Float32, ['COMPRESS=LZW'])
        self.__ta_raster.SetGeoTransform(geo_transform)
        self.__ta_band = self.__ta_raster.GetRasterBand(1)

        self.__td_raster = self.__output_driver.Create(self.__td_filepath, self.__properties['ncols'],
                                                       self.__properties['nrows'],
                                                       1, gdal.GDT_Float32, ['COMPRESS=LZW'])
        self.__td_raster.SetGeoTransform(geo_transform)
        self.__td_band = self.__td_raster.GetRasterBand(1)

    def __parse_classes(self):
        # Find the number of the first class >= 0.02
        for class_number in sorted(self.__classes.keys()):
            if self.__classes[class_number] >= 0.02:
                self.__lower_threshold = class_number
                break
        if self.__lower_threshold is None:
            raise RuntimeError('No class exceeds 0.02 m.')

        # Find the number of the first class >= 1.5
        for class_number in sorted(self.__classes.keys()):
            if self.__classes[class_number] >= 1.5:
                self.__upper_threshold = class_number
                break
        if self.__upper_threshold is None:
            raise RuntimeError('No class exceeds 1.5 m.')

    def __parse_body(self, lines, chunk):
        """Calculate the three grids."""
        xoff, yoff, xsize, ysize = chunk
        # Read the data blocks into a dictionary.
        data = {}
        for col in range(xoff, xoff+xsize):
            data[col] = {}
            for row in range(yoff, yoff+ysize):
                data[col][row] = []
        zero = '0'
        time = None
        for line in lines:
            parts = line.split()
            if not parts:
                continue
            if parts[1] == zero:
                time = float(parts[0])
                if self.__first_time is None:
                    self.__first_time = time
                continue
            # Fortran counts from 1, Python from 0, so apply -1 to row and column indices.
            data[int(parts[0])-1][int(parts[1])-1].append((time, int(parts[2])))
            pass

        # Inspect the data to construct the rise rate grid.
        raster = numpy.zeros((ysize, xsize), dtype=numpy.float32)
        for col in range(xoff, xoff+xsize):
            for row in range(yoff, yoff+ysize):
                lts = None
                prev_class = -1
                for time, class_ in data[col][row]:
                    if class_ >= self.__lower_threshold:
                        if lts is None:
                            lts = (time, class_)
                        elif class_ >= self.__upper_threshold:
                            dh = self.__classes[class_] - 0.02
                            dt = time - lts[0]
                            if dh > 0. and dt > 0.:
                                # GDAL uses a negative cellsize in y, so fill the numpy raster with nrows-row-1.
                                raster[ysize-row-yoff-1][col-xoff] = old_div(dh, dt)
                                break
                        prev_class = class_
        self.__dh_band.WriteArray(raster, xoff, yoff)

        # re-use the raster; construct the ta grid
        raster.fill(-9999.)
        for col in range(xoff, xoff+xsize):
            for row in range(yoff, yoff+ysize):
                for time, class_ in data[col][row]:
                    if class_ >= self.__lower_threshold:
                        raster[ysize-row-yoff-1][col-xoff] = time - self.__first_time - self.__delta_t0
                        break
        self.__ta_band.WriteArray(raster, xoff, yoff)

        # re-use the raster; construct the td grid
        raster.fill(-9999.)
        for col in range(xoff, xoff+xsize):
            for row in range(yoff, yoff+ysize):
                for time, class_ in data[col][row]:
                    if class_ >= self.__upper_threshold:
                        raster[ysize-row-yoff-1][col-xoff] = time - self.__first_time
                        break
        self.__td_band.WriteArray(raster, xoff, yoff)

    def convert(self):
        """Construct the three grids from the inc file."""
        with open(self.__inc_filepath, 'r') as content:
            self.__parse_header(content)

        self.__parse_classes()
        self.__create_grids()

        for a_chunk in grid_utilities.grid_chunks(self.__dh_raster):
            with open(self.__inc_filepath, 'r') as content:
                self.__parse_header(content)  # In order to read past the header.
                self.__parse_body(content, a_chunk)

        return self.__dh_filepath, self.__ta_filepath, self.__td_filepath


if __name__ == "__main__":
    input_filepath = os.path.abspath(os.path.realpath(sys.argv[-1]))

    if not os.path.exists(input_filepath):
        sys.exit(1)

    with IncrementalConverter(input_filepath) as incremental_converter:
        incremental_converter.convert()
