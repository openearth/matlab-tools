from __future__ import print_function
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

# base modules
# TODO use more selective imports where possible
from builtins import str
from builtins import next
from builtins import range
from builtins import object
from past.utils import old_div
import hashlib
import itertools
import logging
import os.path
import re
import shutil
import sys
from time import time

# installed modules
import numpy as np
from osgeo import gdal
from multiprocess import Pool

# local modules
import grid_utilities
import inc_file_converter
import shape_statistics
from evacuation_module import Evacuation_module
from png_generation import PngGenerator, Background
from reporting import ReportGenerator


def read_damage_step_function(filepath):
    # TODO Start using pandas or similar to have better parsing.
    # TODO Why does this return the two halves of a dictionary?
    """Read the task's damage table into a lookup table.

    Returns the largest key and the lookup table.
    """
    logging.debug('Entry.')
    function_keys = []
    function_values = []
    with open(filepath, 'r') as f:
        lines = f.readlines()
        # Skip blank lines

        def not_blank(x): return len(x) > 0
        data_lines = iter(filter(not_blank, lines))
        # Use the header line to determine the decimal separator.
        try:
            line = next(data_lines)
            if line.count(',') == 1:
                column_separator = ','
            elif line.count('.') == 1:
                column_separator = '.'
            else:
                raise RuntimeError("Damage function " + filepath + " header line is invalid: missing column separator.")
        except StopIteration:
            raise RuntimeError("Damage function " + filepath + " is empty.")
        # Read the data columns.
        for line in data_lines:
            if line.count(column_separator) > 1:
                raise RuntimeError("Damage function " + filepath + " uses a digit grouping symbol in: " + line.strip())
            if column_separator == '.':
                parts = [part.replace(',', '.') for part in line.split(column_separator)]
            else:
                parts = line.split(column_separator)
            function_keys.append(int(round(100. * float(parts[0]))))
            function_values.append(float(parts[1]))
    # Ensure that the function keys consist of a uniform set.
    function_values = np.array(function_values)
    for i in range(len(function_keys)):
        if i not in function_keys:
            raise RuntimeError("Damage function " + filepath + " is not uniform.")
    logging.debug('Exit.')
    return max(function_keys), function_values


def read_mortality_function(filepath):
    """Read the task's mortality lookup array from disk.

    This is a 1001x351 float32 array, where the axes are:
        waterdepth (1001) from 0.01m to 10m
        rise_rate (351) from 0.50m/h to 4.00m/h

    The values itself are percentages used to calculate mortality.
    Values are used as fractions and thus scaled by 0.01.
    """
    # TODO Don't replace filepath, have it correct from the get go
    if "interpolated" not in filepath:
        filepath = filepath.replace(".csv", "_interpolated.npy")
    data = np.load(filepath) * 0.01
    if np.shape(data) != (1001, 351):
        raise RuntimeError("Mortality lookup array has invalid shape.")
    return data


def construct_mortality_function(dictionary):
    """Construct a vectorizable mortality function."""
    logging.info('Entry.')


class Calculator(object):
    """Default calculator for the FIAT computational kernel."""

    def __init__(self, configuration):
        logging.debug('Entry.')
        self.configuration = configuration
        self.hazard_grid = None  # Open GDAL raster file.
        self.rise_rate_grid = None  # Open GDAL raster file.
        self.arrival_time_grid = None  # Open GDAL raster file.
        self.flow_speed_grid = None  # Open GDAL raster file.
        self.exposure_grids = {}  # Open GDAL raster files.
        self.total_damage_grid = None  # Open GDAL raster file.
        self.total_damage_grid_png = None  # Open GDAL raster file.
        self.hazard_grid_png = None  # Open GDAL raster file.
        self.slachtoffers_png = None  # Open GDAL raster file.
        self.exposure_damage_grids = {}  # Open GDAL raster files.
        self.fdf_dicts = {}
        self.sdf_dicts = {}
        self.output_driver = gdal.GetDriverByName('GTiff')
        self.output_driver.Register()
        self.png_driver = gdal.GetDriverByName('PNG')
        self.png_driver.Register()
        self.mem_driver = gdal.GetDriverByName('MEM')
        self.mem_driver.Register()
        self.rapport = {}
        self.pattern = re.compile(r'[\s\\/:]+')

        # Use Exceptions instead of failing silently
        # gdal.UseExceptions()

        logging.debug('Exit.')

    def __open_hazard_grid(self):
        """Open a grid which contains the hazard."""
        logging.debug('Entry.')
        self.hazard_grid = grid_utilities.open_gdal_grid(self.configuration['hazard grid filepath'])
        logging.debug('Exit.')

    def __open_inc_grids(self):
        """Open the grids, produced from an inc file."""
        logging.debug('Entry.')
        if 'inc filepath' in self.configuration:
            # 3 inc derived files created in output directory
            with inc_file_converter.IncrementalConverter(self.configuration['inc filepath'],
                                                         self.configuration['outdir']) as incremental_converter:
                if 'inc_delta_t0' in self.configuration:
                    incremental_converter.set_delta_t0(self.configuration['inc_delta_t0'])
                dh_filepath, ta_filepath, td_filepath = incremental_converter.convert()
                # Allow the user to specify both inc and dh/ta.
                if 'rise rate filepath' not in self.configuration:
                    self.configuration['rise rate filepath'] = dh_filepath
                if 'arrival time filepath' not in self.configuration:
                    self.configuration['arrival time filepath'] = ta_filepath

        if 'rise rate filepath' in self.configuration:
            self.rise_rate_grid = grid_utilities.open_gdal_grid(self.configuration['rise rate filepath'])
        if 'arrival time filepath' in self.configuration:
            self.arrival_time_grid = grid_utilities.open_gdal_grid(self.configuration['arrival time filepath'])
        if 'flow speed filepath' in self.configuration:
            self.flow_speed_grid = grid_utilities.open_gdal_grid(self.configuration['flow speed filepath'])
        logging.debug('Exit.')

    def __open_exposure_grids(self):
        """Open all exposure grids."""
        logging.debug('Entry.')
        for name, task in self.configuration['tasks'].items():
            self.exposure_grids[name] = grid_utilities.open_gdal_grid(task['exposure grid filepath'])
        logging.debug('Exit.')

    def __align_grid(self, _grid):
        """Apply a global translation to a grid to match the reference grid."""
        logging.debug('Entry.')
        grid_utilities.align_grids(_grid, self.exposure_grids[next(iter(self.exposure_grids.keys()))])
        logging.debug('Exit.')

    def __open_output_grids(self):
        """Create and open grid files for storing the calculation results."""
        logging.debug('Entry.')

        # Background filepath
        self.configuration["background_fn"] = os.path.join(os.path.split(
            self.configuration['output grid filepath'])[0], "Studiegebied.png")

        # Estimate the wms factor (between grid and best wms resolution)
        rows = self.hazard_grid.RasterYSize
        cols = self.hazard_grid.RasterXSize
        pngGen = PngGenerator(self, self.configuration, self.hazard_grid)
        self.wms_factor = pngGen.get_max_wms_factor(rows, cols)
        self.wms_rows = int(round(self.wms_factor * rows))
        self.wms_columns = int(round(self.wms_factor * cols))

        # The total damage grid.
        gt = self.hazard_grid.GetGeoTransform()
        raster = self.output_driver.Create(self.configuration['output grid filepath'],
                                           cols, rows, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])
        raster.SetGeoTransform(gt)
        raster.GetRasterBand(1).SetNoDataValue(0.)
        self.total_damage_grid = raster

        if "png" in self.configuration and self.configuration["png"] == "1":

            # Download WMS background async
            pool = Pool(processes=2)
            logging.info("Async?")
            bg = Background(gt, rows, cols)
            self.res = pool.apply_async(bg.get_background, (self.configuration["background_fn"],))
            logging.info("Async!")

            # The total damage for png grid.
            raster = self.mem_driver.Create("", self.wms_columns, self.wms_rows, 3, gdal.GDT_Byte)
            raster.SetGeoTransform(gt)
            raster.GetRasterBand(1).SetNoDataValue(0)
            raster.GetRasterBand(2).SetNoDataValue(0)
            raster.GetRasterBand(3).SetNoDataValue(0)
            self.total_damage_grid_png = raster

            # The waterdepth for png grid.
            raster = self.mem_driver.Create("", self.wms_columns, self.wms_rows, 3, gdal.GDT_Byte)
            raster.SetGeoTransform(gt)
            raster.GetRasterBand(1).SetNoDataValue(0)
            raster.GetRasterBand(2).SetNoDataValue(0)
            raster.GetRasterBand(3).SetNoDataValue(0)
            self.hazard_grid_png = raster

            if 'Slachtoffers' in self.configuration['tasks']:
                # The slachtoffers for png grid.
                raster = self.mem_driver.Create("", self.wms_columns, self.wms_rows, 3, gdal.GDT_Byte)
                raster.SetGeoTransform(gt)
                raster.GetRasterBand(1).SetNoDataValue(0)
                raster.GetRasterBand(2).SetNoDataValue(0)
                raster.GetRasterBand(3).SetNoDataValue(0)
                self.slachtoffers_png = raster

        # The category damage grids.
        for name, task in self.configuration['tasks'].items():
            if 'output grid filepath' in task and task['map'] == 1:
                # The name can contain characters which are illegal in a filepath: replace by underscore
                raster = self.output_driver.Create(task['output grid filepath'],
                                                   cols, rows, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])
                raster.SetGeoTransform(gt)
                raster.GetRasterBand(1).SetNoDataValue(0.)
                self.exposure_damage_grids[name] = raster
            # Always write out the mortality grids. Use the total damage grid location for output location determination.
            if (task['map'] == 1) and (os.path.split(task['damage function filepath'])[1].startswith('2_') or (
                    os.path.split(task['damage function filepath'])[1].startswith('3_'))):
                # The name can contain characters which are illegal in a filepath: replace by underscore
                dir_, _ = os.path.split(self.configuration['output grid filepath'])
                fn = self.pattern.sub('_', name) + '_mortaliteit.tif'
                raster = self.output_driver.Create(os.path.join(dir_, fn),
                                                   cols, rows, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])
                raster.SetGeoTransform(gt)
                raster.GetRasterBand(1).SetNoDataValue(0.)
                self.exposure_damage_grids['maximum_' + name] = raster
                # Write out person exposure grids.
                dir_, _ = os.path.split(self.configuration['output grid filepath'])
                fn = self.pattern.sub('_', name) + '_getroffenen.tif'
                raster = self.output_driver.Create(os.path.join(dir_, fn),
                                                   cols, rows, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])
                raster.SetGeoTransform(gt)
                raster.GetRasterBand(1).SetNoDataValue(0.)
                self.exposure_damage_grids['blootstelling_' + name] = raster
        logging.debug('Exit.')

    def produce_shapefile(self):
        """Each feature in the shapefile must be rasterized. Store this result and re-use when possible."""
        # -1- Construct a hashcode.
        hasher = hashlib.md5()
        hg_gt = self.hazard_grid.GetGeoTransform()
        for component in hg_gt:
            hasher.update(str(component).encode('utf-8'))
        hasher.update(str(self.hazard_grid.RasterXSize).encode('utf-8'))
        hasher.update(str(self.hazard_grid.RasterYSize).encode('utf-8'))
        hashcode = hasher.hexdigest()

        # -2- Construct the shapefile rasters directory.
        source_dir, source_filename = os.path.split(self.configuration['shape filepath'])
        shape_grids_dir = os.path.join(source_dir, 'feature2grid_' + str(hashcode))
        if not os.path.isdir(shape_grids_dir):
            os.mkdir(shape_grids_dir)
            # -3- Convert each feature in the shapefile into a raster.
            shape_statistics.rasterize_shapefile(self.configuration['shape filepath'], self.hazard_grid,
                                                 shape_grids_dir)
        # -4- Copy all files comprising a shapefile to the output directory.
        name, _ = os.path.splitext(source_filename)
        target_dir, _ = os.path.split(self.configuration['output grid filepath'])
        for filename in os.listdir(source_dir):
            if os.path.splitext(filename)[0] == name:
                shutil.copy(os.path.join(source_dir, filename),
                            os.path.join(target_dir, 'Overzichtperdijkring' + os.path.splitext(filename)[1]))
        output_shape_filepath = os.path.join(target_dir, 'Overzichtperdijkring' + os.path.splitext(source_filename)[1])

        # -5- Write damage and mortality fields in the copied shapefile for each task which exports its own damage grid.
        subset = [k for k in list(self.configuration['tasks'].keys()) if k in self.exposure_damage_grids]
        if len(subset) > 0:
            with shape_statistics.ShapefileFields(output_shape_filepath, shape_grids_dir, subset) as shapefile_fields:
                for name, task in self.configuration['tasks'].items():
                    if name in subset:
                        if os.path.split(task['damage function filepath'])[1].startswith('2_') or \
                                os.path.split(task['damage function filepath'])[1].startswith('3_'):
                            shapefile_fields.update_fields(name, self.exposure_damage_grids[name], 'mortaliteit')
                        else:
                            if 'bu damage function filepath' in task:
                                shapefile_fields.update_fields(name, self.exposure_damage_grids[name], 'bedrijfsuitval')
                            else:
                                shapefile_fields.update_fields(name, self.exposure_damage_grids[name], 'direct')
                                # The shape rapport file is written automatically upon leaving the WITH construct.

    def update_rapport(self, name, task, damage_grid, arrival_time_data, hazard_data, exposure_data, chunk):
        """ -3- Update results for the rapport."""
        dmg = np.einsum('ij->', damage_grid)
        self.rapport[name]["damage"] += dmg
        if self.rapport[name]["isMortality"] and "arrival time filepath" in self.configuration:
            ltd_mask = np.ma.masked_greater_equal(arrival_time_data, 24.)
            dmg12 = np.ma.array(damage_grid, mask=(ltd_mask.mask)).sum()

            ltd_mask = np.ma.masked_outside(arrival_time_data, 24., 48.)
            dmg1224 = np.ma.array(damage_grid, mask=(ltd_mask.mask)).sum()

            ltd_mask = np.ma.masked_less_equal(arrival_time_data, 48.)
            dmg24 = np.ma.array(damage_grid, mask=(ltd_mask.mask)).sum()

            if dmg12 is not np.ma.masked:
                self.rapport[name]["<24h"][0] += dmg12
            if dmg1224 is not np.ma.masked:
                self.rapport[name][">24h<48h"][0] += dmg1224

            if dmg24 is not np.ma.masked:
                self.rapport[name][">48h"][0] += dmg24

        hd_mask = np.ma.masked_less(hazard_data, 0.01)
        maximum_exposure = np.ma.array(exposure_data, mask=(hd_mask.mask), dtype=np.float32)  # FLOAT32
        number = maximum_exposure.sum()
        maximum_exposure_unmasked = np.ma.filled(maximum_exposure, 0.)
        if os.path.split(task['damage function filepath'])[1].startswith('2_') or \
                os.path.split(task['damage function filepath'])[1].startswith('3_'):
            if 'blootstelling_' + name in self.exposure_damage_grids:
                self.exposure_damage_grids['blootstelling_' + name].GetRasterBand(1).WriteArray(
                    maximum_exposure_unmasked, chunk[0], chunk[1])
        if number is not np.ma.masked:
            self.rapport[name]["objects"] += number
        if self.rapport[name]["isMortality"] and "arrival time filepath" in self.configuration:
            ltd_mask = np.ma.masked_outside(arrival_time_data, 0.00001, 24.)
            new_mask = np.ma.mask_or(ltd_mask.mask, hd_mask.mask)
            number12 = np.ma.array(exposure_data, mask=(new_mask)).sum()

            ltd_mask = np.ma.masked_outside(arrival_time_data, 24., 48.)
            new_mask = np.ma.mask_or(ltd_mask.mask, hd_mask.mask)
            number1224 = np.ma.array(exposure_data, mask=(new_mask)).sum()

            ltd_mask = np.ma.masked_less_equal(arrival_time_data, 48.)
            new_mask = np.ma.mask_or(ltd_mask.mask, hd_mask.mask)
            number24 = np.ma.array(exposure_data, mask=(new_mask)).sum()

            if number12 is not np.ma.masked:
                self.rapport[name]["<24h"][1] += number12
            if number1224 is not np.ma.masked:
                self.rapport[name][">24h<48h"][1] += number1224

            if number24 is not np.ma.masked:
                self.rapport[name][">48h"][1] += number24

    def calculate_mortality(self, lookup, flow_speed_data, rise_rate_data, hazard_keys):
        """Calculate mortality as a fraction based on a hazard, rise_rate and optionally flow
        speed data. Lookup is used as a lookup array.
        """

        # create coordinate pairs for lookup into 1001 (hazard) * 351 (rise_rate) sized array
        # the hazard axis runs from 0.01 to 10 and hazard_keys are already scaled by 100
        clipped_hazard_keys = np.clip(hazard_keys, 0, 1000)  # clip out of bounds values

        # the rise rate axis runs from 0.5 to 4.0, so we multiply by 100 and shift back with 50 to zero.
        rise_rate_data = np.rint(rise_rate_data * 100.).astype(int) - 50
        np.clip(rise_rate_data, 0, 350, out=rise_rate_data)  # clip out of bounds values
        output_grid = lookup[clipped_hazard_keys, rise_rate_data]

        # If flow speed is taken into account, some cases will have
        # heightened mortality.
        if 'flow speed filepath' in self.configuration:
            logging.debug("Using flow speed in mortality calculation.")
            # Standaardmethode 20015 paragraaf 6.2.1: Slachtofferfuncties
            # Flow speed >= 2 m/s => mortality = 1
            # Hazard * flow speed >= 7 => mortality = 1
            condition1 = flow_speed_data >= 2.
            condition2 = (hazard_keys / 100.0 * flow_speed_data) >= 7.
            output_grid[condition1 * condition2] = 1.

        return output_grid

    def get_exposure(self, name, chunk, all_extents):
        exposure_band = grid_utilities.get_first_rasterband(self.exposure_grids[name])
        exposure_frame = grid_utilities.clip_grid_using_extent(self.exposure_grids[name], all_extents)
        exposure_data = grid_utilities.get_data_block(exposure_band,
                                                      chunk[0] + exposure_frame[0],
                                                      chunk[1] + exposure_frame[1],
                                                      chunk[2],
                                                      chunk[3])
        return exposure_data

    def calculate(self):
        """"""
        logging.debug('Entry.')

        # Open all input grids.
        self.__open_hazard_grid()
        self.__open_inc_grids()
        self.__open_exposure_grids()
        self.__open_output_grids()

        # Align the input grids to the exposure grids (those are assumed share a single geometry).
        self.__align_grid(self.hazard_grid)
        if 'rise rate filepath' in self.configuration:
            self.__align_grid(self.rise_rate_grid)
        if 'arrival time filepath' in self.configuration:
            self.__align_grid(self.arrival_time_grid)
        if 'flow speed filepath' in self.configuration:
            self.__align_grid(self.flow_speed_grid)
        # Progress log
        self.progress_step(3)

        # Determine the extent of the intersection of all input grids.
        all_extents = {'xmin': [], 'xmax': [], 'ymin': [], 'ymax': []}
        grid_utilities.add_extent(all_extents, self.hazard_grid)
        if 'rise rate filepath' in self.configuration:
            grid_utilities.add_extent(all_extents, self.rise_rate_grid)
        if 'arrival time filepath' in self.configuration:
            grid_utilities.add_extent(all_extents, self.arrival_time_grid)
        if 'flow speed filepath' in self.configuration:
            grid_utilities.add_extent(all_extents, self.flow_speed_grid)
        grid_utilities.add_extent(all_extents, self.exposure_grids[next(iter(self.exposure_grids.keys()))])
        all_extents['xmin'] = max(all_extents['xmin'])
        all_extents['xmax'] = min(all_extents['xmax'])
        all_extents['ymin'] = max(all_extents['ymin'])
        all_extents['ymax'] = min(all_extents['ymax'])
        # Progress log
        self.progress_step(7)

        # Get bands
        hazard_band = grid_utilities.get_first_rasterband(self.hazard_grid)
        if 'rise rate filepath' in self.configuration:
            rise_rate_band = grid_utilities.get_first_rasterband(self.rise_rate_grid)
            rise_rate_frame = grid_utilities.clip_grid_using_extent(self.rise_rate_grid, all_extents)
        if 'arrival time filepath' in self.configuration:
            arrival_time_band = grid_utilities.get_first_rasterband(self.arrival_time_grid)
            arrival_time_frame = grid_utilities.clip_grid_using_extent(self.arrival_time_grid, all_extents)
        if 'flow speed filepath' in self.configuration:
            flow_speed_band = grid_utilities.get_first_rasterband(self.flow_speed_grid)
            flow_speed_frame = grid_utilities.clip_grid_using_extent(self.flow_speed_grid, all_extents)

        lower_bound = 0.01  # Conventie: 1 cm; Bepaald met D. Wagenaar d.d. 29 September 2014.

        # Initialize the rapport.
        for name, task in self.configuration['tasks'].items():
            self.rapport[name] = {}
            self.rapport[name]["category"] = name
            self.rapport[name]["damage"] = 0.
            self.rapport[name]["objects"] = 0.
            self.rapport[name]["units"] = task['units']
            self.rapport[name]["isMortality"] = False
            self.rapport[name]["<24h"] = [0., 0.]
            self.rapport[name][">24h<48h"] = [0., 0.]
            self.rapport[name][">48h"] = [0., 0.]

        # Construct the damage functions. (weight+20%)
        step = 0.0
        tasks = float(len(self.configuration['tasks']))

        for name, task in self.configuration['tasks'].items():
            # Progress log
            self.progress_step(10 + int(step * 20.0 / tasks))
            step += 1.

            if os.path.split(task['damage function filepath'])[1].startswith('2_'):
                self.fdf_dicts[name] = read_mortality_function(task['damage function filepath'])
            else:
                self.fdf_dicts[name] = read_damage_step_function(task['damage function filepath'])
            if 'bu damage function filepath' in task:
                if os.path.split(task['bu damage function filepath'])[1].startswith('2_'):
                    self.sdf_dicts[name] = read_mortality_function(task['bu damage function filepath'])
                else:
                    self.sdf_dicts[name] = read_damage_step_function(task['bu damage function filepath'])

        # Process data (weight+60%)
        step = 0.0
        total_steps = len(self.configuration['tasks']) * \
            len(list(grid_utilities.grid_chunks_from_raster(self.hazard_grid, all_extents)))
        dt = time()

        for chunk in grid_utilities.grid_chunks_from_raster(self.hazard_grid, all_extents):

            # Water depth load
            hazard_data = grid_utilities.get_data_block(hazard_band,
                                                        chunk[0],
                                                        chunk[1],
                                                        chunk[2],
                                                        chunk[3],
                                                        lb=lower_bound)

            # Skip this block if there's no data here
            # TODO Instead of knowing that all nodata values are replaced by 0.
            # in get_data_block, generate masked arrays and utilze those.
            if np.all(hazard_data == 0.):
                logging.debug("Skipping empty water depth chunk.")
                step += len(self.configuration['tasks'])
                continue

            hazard_keys = np.rint(hazard_data * 100.).astype(int)

            # Rise rate load
            if 'rise rate filepath' in self.configuration:
                rise_rate_data = grid_utilities.get_data_block(rise_rate_band,
                                                               chunk[0] + rise_rate_frame[0],
                                                               chunk[1] + rise_rate_frame[1],
                                                               chunk[2],
                                                               chunk[3])
            else:
                # Use a rise rate of zero.
                rise_rate_data = np.zeros_like(hazard_data, dtype=np.float32)

            # Arrival time load
            if 'arrival time filepath' in self.configuration:
                arrival_time_data = grid_utilities.get_data_block(arrival_time_band,
                                                                  chunk[0] + arrival_time_frame[0],
                                                                  chunk[1] + arrival_time_frame[1],
                                                                  chunk[2],
                                                                  chunk[3])
            else:
                arrival_time_data = None

            # Flow speed load
            if 'flow speed filepath' in self.configuration:
                flow_speed_data = grid_utilities.get_data_block(flow_speed_band,
                                                                chunk[0] + flow_speed_frame[0],
                                                                chunk[1] + flow_speed_frame[1],
                                                                chunk[2],
                                                                chunk[3])
            else:
                flow_speed_data = None

            total_damage_array = None

            for name, task in self.configuration['tasks'].items():

                # Progress log, only log again after a second
                if (time() - dt > 1):
                    progress = 30 + int(50 * (old_div(step, total_steps)))
                    self.progress_step(progress)
                    dt = time()
                step += 1.

                exposure_data = self.get_exposure(name, chunk, all_extents)

                if os.path.split(task['damage function filepath'])[1].startswith('2_') or \
                        os.path.split(task['damage function filepath'])[1].startswith('3_'):
                    self.rapport[name]["isMortality"] = True

                # Calculate the factor grid.
                if os.path.split(task['damage function filepath'])[1].startswith('2_'):
                    # Mortality function
                    factor_grid = self.calculate_mortality(
                        self.fdf_dicts[name], flow_speed_data, rise_rate_data, hazard_keys)
                else:
                    fdf_max, fdf_lut = self.fdf_dicts[name]
                    clipped_hazard_keys = np.minimum(hazard_keys, fdf_max)
                    # factor_grid = np.take(fdf_lut, clipped_hazard_keys)
                    factor_grid = fdf_lut[clipped_hazard_keys]

                # Calculate MaxDam.
                if 'bu damage function filepath' in task:
                    # MaxDam is a grid.
                    if os.path.split(task['bu damage function filepath'])[1].startswith('2_') or \
                            os.path.split(task['damage function filepath'])[1].startswith('3_'):
                        # Mortality function
                        max_dam = self.calculate_mortality(
                            self.fdf_dicts[name], flow_speed_data, rise_rate_data, hazard_keys)
                    else:
                        sdf_max, sdf_lut = self.sdf_dicts[name]
                        clipped_hazard_keys = np.minimum(hazard_keys, sdf_max)
                        # max_dam = np.take(sdf_lut, clipped_hazard_keys)
                        max_dam = sdf_lut[clipped_hazard_keys]
                    md = task['maximum damage']
                    bumd = task['bu maximum damage']
                    diff = bumd - md
                    max_dam *= diff
                    max_dam += md
                else:
                    # MaxDam is a number.
                    max_dam = task['maximum damage']

                # Calculate the maximum potential damage grid.
                maximum_damage_grid = max_dam * factor_grid

                # Apply the weight factor.
                weight = task['weight']
                if weight != 1.0:
                    maximum_damage_grid *= weight

                # Store the maximum potential mortality.
                if 'maximum_' + name in self.exposure_damage_grids:
                    self.exposure_damage_grids['maximum_' + name].GetRasterBand(1).WriteArray(maximum_damage_grid,
                                                                                              chunk[0], chunk[1])

                # Calculate the damage grid.
                damage_grid = maximum_damage_grid * exposure_data

                # Store the results.
                # -1- Store the damage grid per category.
                if name in self.exposure_damage_grids:
                    self.exposure_damage_grids[name].GetRasterBand(1).WriteArray(damage_grid, chunk[0], chunk[1])

                # -2- Store the damage as an addition to the total damage grid.
                if not os.path.split(task['damage function filepath'])[1].startswith('2_') or \
                        os.path.split(task['damage function filepath'])[1].startswith('3_'):
                    if name not in ["OverstroomdOppervlak", "droge_plekken1", "droge_plekken2", "droge_plekken3"]:
                        if total_damage_array is None:
                            total_damage_array = np.copy(damage_grid)
                        else:
                            total_damage_array += damage_grid

                # -3- Update results for the rapport.
                self.update_rapport(name, task, damage_grid, arrival_time_data, hazard_data, exposure_data, chunk)

            # Write the total damage grid.
            if total_damage_array is not None:
                self.total_damage_grid.GetRasterBand(1).WriteArray(total_damage_array, chunk[0], chunk[1])

        # Fill the damage shape file.
        self.progress_step(80)
        if "shape filepath" in self.configuration:
            self.produce_shapefile()

        # Evacuation calculation (if needed)
        ev = None
        if self.configuration["nt"] != None and self.configuration["binnendijks"]:
            ev = Evacuation_module(self.rapport, self.configuration["nt"],
                                   os.path.join(self.configuration['damage function dir'], 'evacuatie'))

        # Report generation
        repGen = ReportGenerator(self, self.rapport, self.configuration, ev)
        if 'txt rapport filepath' in self.configuration:
            repGen.write_text_rapport()
        if 'xls rapport filepath' in self.configuration:
            repGen.write_excel_rapport()
        # Progress log
        self.progress_step(85)

        # PNG generation (optional)
        if "png" in self.configuration and self.configuration["png"] == "1":
            successful, message = self.res.get()  # ensure background download finishes
            if not successful:
                raise Exception(message)
            else:
                logging.info(message)
            pngGen = PngGenerator(self, self.configuration, self.total_damage_grid)
            pngGen.run()
        # Progress log finish
        self.progress_step(100)

        logging.debug('Exit.')

    def progress_step(self, val):
        print('Progress: ' + str(val) + '%')
        sys.stdout.flush()

    def finish(self):
        logging.debug('Entry.')
        self.configuration = None
        self.hazard_grid = None
        self.rise_rate_grid = None
        self.arrival_time_grid = None
        self.flow_speed_grid = None
        for key in list(self.exposure_grids.keys()):
            self.exposure_grids[key] = None
        self.total_damage_grid = None
        self.total_damage_grid_png = None
        self.hazard_grid_png = None
        self.slachtoffers_png = None
        for key in list(self.exposure_damage_grids.keys()):
            self.exposure_damage_grids[key] = None
        self.output_driver = None
        # for key in self.rapport.keys():
        #    self.rapport[key] = None
        logging.debug('Exit.')


class RiskCalculator(object):
    """Risk calculation."""

    def __init__(self, configuration):
        logging.debug('Entry.')
        self.configuration = configuration
        self.output_driver = gdal.GetDriverByName('GTiff')
        self.output_driver.Register()
        logging.debug('Exit.')

    def calculate(self):
        """"""
        logging.debug('Entry.')
        # Interpret 'hazard grid filepath' as a csv file containing risk specifications.
        risk_grids = []
        risk_periods = []
        risk_minimum = None
        risk_maximum = None
        #
        with open(self.configuration['hazard grid filepath'], 'r') as risk_input_file:
            lines = risk_input_file.readlines()
            for line in lines:
                line = line.strip()
                parts = line.split(',')
                if len(parts) == 2:
                    if risk_minimum is None:
                        risk_minimum = float(parts[0])
                        risk_maximum = float(parts[1])
                    else:
                        risk_grids.append(parts[0])
                        risk_periods.append(float(parts[1]))
        #
        category_output_grids = {}
        for name in self.configuration['tasks'].keys():
            category_output_grids[name] = []
        #
        for risk_grid in risk_grids:
            copy_of_configuration = {}
            copy_of_configuration.update(self.configuration)
            #
            _, risk_filename = os.path.split(risk_grid)
            risk_name, _ = os.path.splitext(risk_filename)
            dir_, filename_ = os.path.split(copy_of_configuration['output grid filepath'])
            new_dir = os.path.join(dir_, risk_name)
            try:
                os.mkdir(new_dir)
            except IOError:
                pass
            copy_of_configuration['output grid filepath'] = os.path.join(new_dir, filename_)
            #
            if 'txt rapport filepath' in copy_of_configuration:
                _, filename_ = os.path.split(copy_of_configuration['txt rapport filepath'])
                copy_of_configuration['txt rapport filepath'] = os.path.join(new_dir, filename_)
            #
            if 'xls rapport filepath' in copy_of_configuration:
                _, filename_ = os.path.split(copy_of_configuration['xls rapport filepath'])
                copy_of_configuration['xls rapport filepath'] = os.path.join(new_dir, filename_)
            #
            for name, task in copy_of_configuration['tasks'].items():
                _, filename_ = os.path.split(task['output grid filepath'])
                task['output grid filepath'] = os.path.join(new_dir, filename_)
                category_output_grids[name].append(task['output grid filepath'])
            #
            copy_of_configuration['hazard grid filepath'] = risk_grid
            #
            calculation_object = Calculator(copy_of_configuration)
            calculation_object.calculate()
            calculation_object.finish()
            #
        #
        rapport_text = []
        #
        rp = np.hstack((risk_minimum, np.array(risk_periods), 99900000))
        prob = np.flipud(old_div(1., rp))
        total_mortality_risk = 0.
        total_damage_risk = 0.
        for name, task in self.configuration['tasks'].items():
            totals = []
            totals_rasters = []
            dir_, _ = os.path.split(self.configuration['output grid filepath'])
            new_path = os.path.join(dir_, name + '_risk.tif')
            srs_raster = grid_utilities.open_gdal_grid(copy_of_configuration['tasks'][name]['output grid filepath'])
            integrated_damage = self.output_driver.CreateCopy(new_path, srs_raster, 0)
            srs_raster = None
            risk = 0.
            integrated_band = grid_utilities.get_first_rasterband(integrated_damage)
            for filename in category_output_grids[name]:
                raster = grid_utilities.open_gdal_grid(filename)
                totals_rasters.append(raster)
                band = grid_utilities.get_first_rasterband(raster)
                totals.append(band)
            for chunk in grid_utilities.grid_chunks(integrated_damage):
                blocks = [np.zeros((chunk[3], chunk[2]))]
                for rp_number, a_band in enumerate(totals, 1):
                    if rp[rp_number] < risk_minimum:
                        a_block = np.zeros((chunk[3], chunk[2]))
                    else:
                        a_block = grid_utilities.get_data_block(a_band, chunk[0], chunk[1], chunk[2], chunk[3], )
                    blocks.append(a_block)
                blocks.append(blocks[-1])
                stacked_blocks = np.dstack(tuple(blocks)).transpose((2, 0, 1))
                integrated_block = np.trapz(np.flipud(stacked_blocks), prob, axis=0)
                integrated_band.WriteArray(integrated_block, chunk[0], chunk[1])
                risk += integrated_block.sum()
            if os.path.split(task['damage function filepath'])[1].startswith('2_') or \
                    os.path.split(task['damage function filepath'])[1].startswith('3_'):
                total_mortality_risk += risk
            else:
                total_damage_risk += risk
            rapport_text.append('Risk for category ' + name + ' = ' + str(risk) + '\n')
            #
            integrated_band = None
            integrated_damage = None
            for i in range(len(totals_rasters)):
                totals_rasters[i] = None
            for i in range(len(totals)):
                totals[i] = None
        rapport_text.append('\n')
        rapport_text.append('Total mortality risk = ' + str(total_mortality_risk) + '\n')
        rapport_text.append('Total damage risk = ' + str(total_damage_risk) + '\n')
        #
        dir_, _ = os.path.split(self.configuration['output grid filepath'])
        new_path = os.path.join(dir_, 'Risk.txt')
        with open(new_path, 'w') as output_file:
            output_file.writelines(rapport_text)
        logging.debug('Exit.')
