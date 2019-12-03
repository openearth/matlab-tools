# -*- coding: utf-8 -*-
"""
Created on Wed Jul 08 16:12:29 2015

@author: winsemi

$Id: run_osm2dh.py 13262 2017-04-18 19:13:21Z winsemi $
$Date: 2017-04-18 12:13:21 -0700 (Tue, 18 Apr 2017) $
$Author: winsemi $
$Revision: 13262 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/sandbox/osmmodelbuilding/run_osm2dh.py $
$Keywords: $

"""

# import admin packages
from optparse import OptionParser
from configobj import ConfigObj
import sys
import os
import copy
import logging
import logging.handlers
# import ConfigParser
import datetime as dt

# import general packages
import numpy as np
import fiona, fiona.crs
import shapely, shapely.geometry, shapely.wkt
import gdal
# import specific packages
import osm2dh
import DFlowFM_tools as df
import pyproj
import shutil

def configget(config, section, var, default, datatype='str'):
    """
    Gets a string from a config file (.ini) and returns a default value if
    the key is not found. If the key is not found it also sets the value
    with the default in the config-file

    Input:
        - config - python ConfigObj object
        - section - section in the file
        - var - variable (key) to get
        - default - default value
        - datatype='str' - can be set to 'boolean', 'int', 'float' or 'str'

    Returns:
        - value (str, boolean, float or int) - either the value from the config file or the default value
    """

    try:
        if datatype == 'int':
            ret = int(config[section][var])
        elif datatype == 'float':
            ret = float(config[section][var])
        elif datatype == 'boolean':
            ret = bool(config[section][var])
        else:
            ret = config[section][var]
    except:
        ret = default

    return ret

# def configget_old(config, section, var, default, datatype='str'):
#
#     """
#     Gets a string from a config file (.ini) and returns a default value if
#     the key is not found. If the key is not found it also sets the value
#     with the default in the config-file
#
#     Input:
#         - config - python ConfigParser object
#         - section - section in the file
#         - var - variable (key) to get
#         - default - default value
#         - datatype='str' - can be set to 'boolean', 'int', 'float' or 'str'
#
#     Returns:
#         - value (str, boolean, float or int) - either the value from the config file or the default value
#     """
#
#     try:
#         if datatype == 'int':
#             ret = config.getint(section, var)
#         elif datatype == 'float':
#             ret = config.getfloat(section, var)
#         elif datatype == 'boolean':
#             ret = config.getboolean(section, var)
#         else:
#             ret = config.get(section, var)
#     except:
#         ret = default
#
#     return ret


def configget_list(config, section, var, dtype='float'):
    str = configget(config, section, var, '')
    if type(str).__name__ != 'list' and len(str) > 0:
        # make it a list!
        str = [str]
    if len(str) > 0:
        # str = str.split(split_sign)
        if dtype == 'float':
            return [float(str_part) for str_part in str]
        elif dtype == 'int':
            return [int(str_part) for str_part in str]
        else:
            return [str_part for str_part in str]
    else:
        return []

# def configget_list_old(config, section, var, split_sign, dtype='float'):
#     str = configget(config, section, var, '').replace(' ', '')
#     if len(str) > 0:
#         str = str.split(split_sign)
#         if dtype == 'float':
#             return [float(str_part) for str_part in str]
#         elif dtype == 'int':
#             return [int(str_part) for str_part in str]
#         else:
#             return [str_part for str_part in str]
#     else:
#         return []


def setlogger(logfilename, logReference, verbose=True):
    """
    Set-up the logging system. Exit if this fails
    """
    try:
        #create logger
        logger = logging.getLogger(logReference)
        logger.setLevel(logging.DEBUG)
        ch = logging.handlers.RotatingFileHandler(logfilename, maxBytes=10*1024*1024, backupCount=5)
        console = logging.StreamHandler()
        console.setLevel(logging.DEBUG)
        ch.setLevel(logging.DEBUG)
        #create formatter
        formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        #add formatter to ch
        ch.setFormatter(formatter)
        console.setFormatter(formatter)
        #add ch to logger
        logger.addHandler(ch)
        logger.addHandler(console)
        logger.debug("File logging to " + logfilename)
        return logger, ch
    except IOError:
        print "ERROR: Failed to initialize logger with logfile: " + logfilename
        sys.exit(1)


def closeLogger(logger, ch):
    logger.removeHandler(ch)
    ch.flush()
    ch.close()
    return logger, ch


def close_with_error(logger, ch, msg):
    logger.error(msg)
    logger, ch = closeLogger(logger, ch)
    del logger, ch
    sys.exit(1)


def get_gdal_geotransform(filename, logger=logging):
    """Return geotransform of dataset"""
    ds = gdal.Open(filename, gdal.GA_ReadOnly)
    if ds is None:
        logger.warning('Could not open {:s} Shutting down'.format(filename))
        sys.exit(1)
    # Retrieve geoTransform info
    gt = ds.GetGeoTransform()
    ds = None  # close dataset
    return gt


def get_gdal_axes(filename, logger=logging):
    # TODO: check logger not used ?
    geotrans = get_gdal_geotransform(filename, logger=logger)
    # Retrieve geoTransform info
    originX = geotrans[0]
    originY = geotrans[3]
    resX = geotrans[1]
    resY = geotrans[5]

    ds = gdal.Open(filename, gdal.GA_ReadOnly)
    if ds is None:
        logger.warning('Could not open {:s} Shutting down'.format(filename))
        sys.exit(1)
    cols = ds.RasterXSize
    rows = ds.RasterYSize
    x = np.linspace(originX+resX/2, originX+resX/2+resX*(cols-1), cols)
    y = np.linspace(originY+resY/2, originY+resY/2+resY*(rows-1), rows)
    ds = None  # close dataset
    return x, y

def write_obs(options, objects, logger=logging):
    """
    Write the observation stations to a xyz file (FM compatible)
    Args:
        options:
        objects:
        logger:

    Returns:

    """
    if os.path.isfile(options.observations_xyz):
        os.unlink(options.observations_xyz)

    logger.info('Writing observation points to {:s}'.format(options.observations_xyz))
    [o.to_dh(options.observations_xyz, append=True) for o in objects]

def write_fm_domain(options, objects, objects_bnd, logger=logging):
    """
    Write the FM domain to a spline file (FM compatible)
    Args:
        options: options from osm2dh
        objects: domain boundary lines to write to spl file (format same as pli)
        logger: logger object for printing information

    Returns:

    """
    # purge if existing
    if os.path.isfile(options.forcing_file):
        os.unlink(options.forcing_file)
    if os.path.isfile(options.bbox_spl_fn):
        os.unlink(options.bbox_spl_fn)


    logger.info('Writing domain boundary to {:s}'.format(options.bbox_spl_fn))
    [o.to_dh(options.bbox_spl_fn, append=True) for o in objects]

    logger.info('Writing 2D boundaries to {:s}'.format(options.forcing_file))

    [o.to_dh(options.forcing_file, options.bnd_path, append=True)
     for o in objects_bnd if o.type != 'discharge']

    if os.path.isfile(options.rainfall['file']):
        logger.info('Writing rainfall forcing to {:s}'.format(options.forcing_file))
        # TODO: make forcing a separate type of object
        def to_dh_rainfall(fn, rainfall_fn, append=True):
            """write boundary condition D-Flow FM files for 1D elements
            per boundary condition append .ext file and write .pli and .cmp file"""
            # file names administration
            root_path = os.path.split(fn)[0]
            # write boundary conditions (.ext) file
            if append:
                write_mode = 'a'
            else:
                write_mode = 'w'
            bnd_cnds_fmt = """QUANTITY={:s}\nFILENAME={:s}\nFILETYPE=1\nMETHOD=1\nOPERAND=O\n\n""".format
            with open(fn, write_mode) as text_file:
                text_file.write(bnd_cnds_fmt('rainfall', os.path.split(rainfall_fn)[1]))
                shutil.copy(rainfall_fn, os.path.join(root_path, os.path.split(rainfall_fn)[1]))
        to_dh_rainfall(options.forcing_file, options.rainfall['file'], append=True)
    else:
        logger.info('No valid rainfall file found')

def write_fm_channels(options, channel_objects, bnd_objects, logger=logging):
    """

    Args:
        options: options from osm2dh
        objects: channel objects to write to pli, xyz and boundary condition files
        logger: logger object for printing information
    Returns:
        None
    """
    # purge files
    if os.path.isfile(options.channel_pli_fn):
        os.unlink(options.channel_pli_fn)
    if os.path.isfile(options.channel_lbd_fn):
        os.unlink(options.channel_lbd_fn)
    if os.path.isfile(options.channel_dtm_xyz_fn):
        os.unlink(options.channel_dtm_xyz_fn)
    if os.path.isfile(options.channel_profloc_xyz_fn):
        os.unlink(options.channel_profloc_xyz_fn)
    if os.path.isfile(options.channel_profdef_txt_fn):
        os.unlink(options.channel_profdef_txt_fn)

    basedir = os.path.basename(options.channel_pli_fn)

    # write to D-Flow FM files
    logger.info('Writing channel section data to and terrain data to {:s}'.format(basedir))
    [o.to_dh(options.channel_pli_fn, options.channel_lbd_fn, options.channel_dtm_xyz_fn, append=True)
     for o in channel_objects]

    logger.info('Writing channel profile and location definitions to {:s}'.format(basedir))
    [o.profile_definition.to_dh(options.channel_profdef_txt_fn, options.channel_profloc_xyz_fn, append=True)
     for o in channel_objects]

    if len(bnd_objects) > 0:
        logger.info('Writing forcing data to {:s}'.format(options.channel_profdef_txt_fn))
        [o.to_dh(options.forcing_file, options.bnd_path, append=True)
         for o in bnd_objects]
    pass


def write_fm_culverts(options, culvert_objects, gate_objects, logger=logging):
    """
    Args:
        options: options from osm2dh
        objects: channel objects to write to pli, xyz and boundary condition files
    Returns:
        None
    """
    if os.path.isfile(options.culverts_pli_fn):
        os.unlink(options.culverts_pli_fn)
    if os.path.isfile(options.culverts_gates_fn):
        os.unlink(options.culverts_gates_fn)

    logger.info('Writing culvert data to {:s}'.format(options.culverts_pli_fn))
    [o.to_dh(options.culverts_pli_fn, append=True) for o in culvert_objects]

    logger.info('Writing culvert gate data to {:s}'.format(options.culverts_gates_fn))
    [o.to_dh(options.culverts_gates_fn, options.culverts_gates_path, append=True) for o in gate_objects]
    pass


def proj_geom(geom, src, trg, rounding=0., round_x='up', round_y='up'):
    def roundup(x, rounding=0.):
        if rounding == 0.:
            return x
        else:
            return-(-x // rounding) * rounding  # ceil division

    def rounddown(x, rounding=0.):
        if rounding == 0.:
            return x
        else:
            return (x // rounding) * rounding  # floor division

    def proj_coordinate(src, trg, x, y, round_x='up', round_y='up', rounding=0.):
        x_proj, y_proj = pyproj.transform(src, trg, x, y)
        if round_x == 'up':
            x_proj_round = roundup(x_proj, rounding=rounding)
        else:
            x_proj_round = rounddown(x_proj, rounding=rounding)
        if round_y == 'up':
            y_proj_round = roundup(y_proj, rounding=rounding)
        else:
            y_proj_round = rounddown(y_proj, rounding=rounding)
        return x_proj_round, y_proj_round

    # make a copy to make sure
    new_geom = copy.deepcopy(geom)
    geom_type = new_geom['type']
    if geom_type == 'Point':
        _x, _y = new_geom['coordinates']
        x, y = proj_coordinate(src, trg, _x, _y, round_x=round_x, round_y=round_y, rounding=rounding)
        # make geom
        new_geom['coordinates'] = (x, y)
    elif geom_type == 'LineString':
        line_coords = []
        for n, (_x, _y) in enumerate(new_geom['coordinates']):
            x, y = proj_coordinate(src, trg, _x, _y, round_x=round_x, round_y=round_y, rounding=rounding)
            line_coords.append((x, y))
        new_geom['coordinates'] = tuple(line_coords)
    elif geom_type == 'Polygon':
        pol_coords = []
        for m, pol in enumerate(new_geom['coordinates']):
            line_coords = []
            for n, (_x, _y) in enumerate(pol):
                x, y = proj_coordinate(src, trg, _x, _y, round_x=round_x, round_y=round_y, rounding=rounding)
                line_coords.append((x, y))
            pol_coords.append(tuple(line_coords))
        new_geom['coordinates'] = tuple(pol_coords)

    else:
        return None

    return new_geom

def main():
    ### Read input arguments #####
    if len(sys.argv) == 1:
        print('No arguments given. Please run with option "-h" for help')
        sys.exit(0)
    usage = "usage: %prog [options]"
    cur_path = os.path.abspath(os.path.split(sys.argv[0])[0])
    parser = OptionParser(usage=usage)
    parser.add_option('-q', '--quiet',
                      dest='verbose', default=True, action='store_false',
                      help='do not print status messages to stdout')
    parser.add_option('-o', '--osm_download',
                      dest='osm_download', default=False, action='store_true',
                      help='retrieve osm data over bounding box and store in osm_file in .ini file')
    parser.add_option('-i', '--ini', dest='inifile',
                      default='osm2dhydro.ini', nargs=1,
                      help='ini configuration file')
    parser.add_option('-d', '--destination',
                      dest='dest_path', default='',
                      help='Destination folder for parsing')
    (options, args) = parser.parse_args()
    if len(args) != 0:
        print('Incorrect number of arguments given. Please run with option "-h" for help')
        sys.exit(0)

    if not os.path.exists(options.inifile):
        print('path to ini file {:s} cannot be found'.format(os.path.abspath(options.inifile)))
        sys.exit(1)

    # file names and directory bookkeeping
    options.dest_path = os.path.abspath(options.dest_path)
    logfilename = os.path.join(options.dest_path, 'OSM2DHydro.log')

    # create dir if not exist
    if not os.path.isdir(options.dest_path):
        os.makedirs(options.dest_path)
    # delete old destination and log files
    else:
        if os.path.isfile(logfilename):
            os.unlink(logfilename)
    # set up the logger
    logger, ch = setlogger(logfilename, 'OSM2DHydro', options.verbose)
    logger.info('$Id: run_osm2dh.py 13262 2017-04-18 19:13:21Z winsemi $')

    ### READ CONFIG FILE
    # open config-file
    config = ConfigObj(options.inifile)

    # read settings
    options.osm_fn = configget(config, 'input_data', 'osm_file', None)
    if options.osm_fn is None:
        raise ValueError('OSM file name not found in ini file, check [input_data] -> osm_file')
    options.dtm_fn = configget(config, 'input_data', 'dem_file', None)
    if options.dtm_fn is None:
        raise ValueError('DTM file name not given in ini file, check [input_data] -> dem_file')

    options.fm_exe = os.path.abspath(configget(config, 'input_data', 'fm_exe', ''))
    options.observations_fn = os.path.abspath(configget(config, 'input_data', 'observation_file', ''))
    proj_model = configget(config, 'settings', 'proj_model', None, 'int')
    options.crs = fiona.crs.from_epsg(proj_model)
    options.crs_in = fiona.crs.from_epsg(configget(config, 'settings', 'proj_user', proj_model, 'int'))
    options.rounding = configget(config, 'settings', 'bbox_rounding', 1000., 'float')

    options.model_name = configget(config, 'settings', 'model_name', 'model')
    options.xmin = configget(config, 'settings', 'xmin', None, 'float')
    options.xmax = configget(config, 'settings', 'xmax', None, 'float')
    options.ymin = configget(config, 'settings', 'ymin', None, 'float')
    options.ymax = configget(config, 'settings', 'ymax', None, 'float')
    options.cell_size = configget(config, 'settings', 'cell_size', 100., 'float')
    options.layer_index = configget(config, 'settings', 'line_layer_index', 1, 'int')
    options.domain_buffer = configget(config, 'settings', 'domain_buffer', 10, 'float')
    options.start_time = dt.datetime.strptime(configget(config, 'settings', 'start_time', '2017-01-01 00:00:00'), '%Y-%m-%d %H:%M:%S')
    options.duration = configget(config, 'settings', 'duration', 12, 'float')

    # read channel settings
    options.channels = {}
    options.channels['key'] = configget(config, 'channels', 'key', None)
    options.channels['values'] = configget_list(config, 'channels', 'values', dtype='str')
    options.channels['widths'] = configget_list(config, 'channels', 'widths', dtype='float')
    options.channels['depths'] = configget_list(config, 'channels', 'depths', dtype='float')
    options.channels['min_width'] = configget(config, 'channels', 'min_width', 0., 'float')
    options.channels['proftypes'] = configget_list(config, 'channels', 'proftypes', dtype='int')

    # read culvert settings
    options.culverts = {}
    options.culverts['key'] = configget(config, 'culverts', 'key', None)
    options.culverts['value'] = configget(config, 'culverts', 'value', None)
    options.culverts['width'] = configget(config, 'culverts', 'width', 0., 'float')
    options.culverts['depth'] = configget(config, 'culverts', 'depth', 0., 'float')
    options.culverts['min_length'] = configget(config, 'culverts', 'min_length', 0., 'float')
    options.culverts['id_blocked'] = configget_list(config, 'culverts', 'id_blocked', dtype='str')
    options.culverts['block_factor'] = configget_list(config, 'culverts', 'block_factor', dtype='float')

    # read bridge settings
    options.bridges = {}
    options.bridges['key'] = configget(config, 'bridges', 'key', None)
    options.bridges['values'] = configget_list(config, 'bridges', 'values', None)
    options.bridges['id_blocked'] = configget_list(config, 'bridges', 'id_blocked', dtype='str')
    options.bridges['block_factor'] = configget_list(config, 'bridges', 'block_factor', dtype='float')

    # read boundary condition settings
    options.boundary_1d = {}
    options.boundary_1d['ids'] = configget_list(config, 'boundary_1d', 'ids', dtype='str')
    options.boundary_1d['types'] = configget_list(config, 'boundary_1d', 'types', dtype='str')
    options.boundary_1d['files'] = configget_list(config, 'boundary_1d', 'files', dtype='str')

    # save rainfall forcing (only .tim file for now)
    options.rainfall = {}
    options.rainfall['file'] = configget(config, 'rainfall', 'file', '')
    # save boundary conditions in the order 'west', 'south', 'east', 'north'
    options.boundary_2d = {}
    options.boundary_2d['type'] = []
    options.boundary_2d['value'] = []

    for dir in ['west', 'south', 'east', 'north']:
        options.boundary_2d['type'].append(configget(config, 'boundary_{:s}'.format(dir), 'type', 'discharge', datatype='str'))
        options.boundary_2d['value'].append(configget(config, 'boundary_{:s}'.format(dir), 'value', 0., datatype='float'))
    # make some more option entries based on path and model name
    options.fm_path = os.path.join(options.dest_path, 'fm_model')
    options.gis_path = os.path.join(options.dest_path, 'gis_files')
    options.bnd_path = os.path.join(options.fm_path, 'bnd_files')
    options.mdu_template = os.path.join(cur_path, 'mdu_template.mdu')
    options.mdu_fn = os.path.join(options.fm_path, '{:s}.mdu'.format(options.model_name))
    options.mesh_2d_fn = os.path.join(options.fm_path, '{:s}_2d_net.nc'.format(options.model_name))
    options.observations_xyz = os.path.join(options.fm_path, '{:s}_obs.xyn'.format(options.model_name))
    options.bbox_spl_fn = os.path.join(options.fm_path, '{:s}_bbox.spl'.format(options.model_name))
    options.SQLite_fn = os.path.join(options.dest_path, 'gis_files', '{:s}.shp'.format(options.model_name))
    options.channel_pli_fn = os.path.join(options.fm_path, '{:s}_channels.pli'.format(options.model_name))
    options.channel_lbd_fn = os.path.join(options.fm_path, '{:s}_channels.ldb'.format(options.model_name))
    options.channel_dtm_xyz_fn = os.path.join(options.fm_path, '{:s}_channels_dtm.xyz'.format(options.model_name))
    options.channel_profloc_xyz_fn = os.path.join(options.fm_path, '{:s}_channels_profloc.xyz'.format(options.model_name))
    options.channel_profdef_txt_fn = os.path.join(options.fm_path, '{:s}_channels_profdef.txt'.format(options.model_name))
    options.culverts_pli_fn = os.path.join(options.fm_path, '{:s}_culverts.pliz'.format(options.model_name))
    options.culverts_gates_fn = os.path.join(options.fm_path, '{:s}_structures.ini'.format(options.model_name))
    options.culverts_gates_path = os.path.join(options.fm_path, 'structures')
    options.forcing_file = os.path.join(options.fm_path, '{:s}_forcing.ext'.format(options.model_name))
    if not(os.path.isdir(options.fm_path)):
        os.makedirs(options.fm_path)
    if not(os.path.isdir(options.gis_path)):
        os.makedirs(options.gis_path)
    if not(os.path.isdir(options.bnd_path)):
        os.makedirs(options.bnd_path)
    if not(os.path.isdir(options.culverts_gates_path)):
        os.makedirs(options.culverts_gates_path)

    if np.logical_and(options.xmin is None, options.xmax is None):
        logger.error('Either xmin or xmax is not given')
        sys.exit(1)
    if np.logical_and(options.ymin is None, options.ymax is None):
        logger.error('Either ymin or ymax is not given')
        sys.exit(1)
    # required input
    if not options.dest_path:   # if destination is not given
        logger.error('destination path not given')
    if not os.path.exists(options.dtm_fn):
        logger.error('path to dem file {:s} cannot be found'.format(options.dtm_fn))
        sys.exit(1)
    if not(os.path.exists(options.osm_fn)) and not options.osm_download:
        logger.error('path to osm database (SQLite) {:s} cannot be found'.format(options.osm_fn))
        sys.exit(1)

    # write info to logger
    logger.info('Destination path: {:s}'.format(options.dest_path))
    logger.info('DEM file: {:s}'.format(options.dtm_fn))
    logger.info('OSM file: {:s}'.format(options.osm_fn))
    logger.info('Model name: {:s}'.format(options.model_name))
    logger.info('Minimum x-coordinate: {:.2f}'.format(options.xmin))
    logger.info('Maximum x-coordinate: {:.2f}'.format(options.xmax))
    logger.info('Minimum y-coordinate: {:.2f}'.format(options.ymin))
    logger.info('Maximum y-coordinate: {:.2f}'.format(options.xmax))
    logger.info('Channels are processed with the following key/value/width/depth default values:')
    for value, width, depth in zip(options.channels['values'],
                                   options.channels['depths'],
                                   options.channels['widths'],
                                   ):
        logger.info('key: {:s}; value: {:s}; width: {:.2f}; depth: {:.2f}'.format(options.channels['key'], value, width, depth))
    logger.info('Culverts are processed with the following key/value/width/depth default values:')
    logger.info('key: {:s}; value: {:s}; width: {:.2f}; depth: {:.2f}'.format(options.culverts['key'],
                                                                              options.culverts['value'],
                                                                              options.culverts['width'],
                                                                              options.culverts['depth']))
    logger.info('Blockage at bridges is processed for the following key/value pairs:')
    logger.info('key: {:s}; value(s): {:s}'.format(options.bridges['key'], ', '.join(options.bridges['values'])))

    try:
        x, y = get_gdal_axes(options.dtm_fn, logger=logger)
    except:
        msg = 'Input file {:s} not a gdal compatible file'.format(options.dtm_fn)
        close_with_error(logger, ch, msg)
        sys.exit(1)

    check_fields = {
        'width': float,
        'depth': float
    }

    #### PREPARE THE DOMAIN FILES (shp and FM, inc boundary conditions) ################
    domain_id = '001'
    domain = shapely.geometry.Polygon([(options.xmin, options.ymax),
                                       (options.xmin, options.ymin),
                                       (options.xmax, options.ymin),
                                       (options.xmax, options.ymax)])
    # save polygon to shape
    domain_data = osm2dh.create_feature(domain, id=domain_id)
    df.write_layer(os.path.join(options.gis_path, 'domain.shp'), 'domain', [domain_data],
                   write_mode='w', crs=options.crs, logger=logger)
    geom = shapely.geometry.mapping(domain)
    geom_proj = proj_geom(geom,
                          pyproj.Proj(fiona.crs.to_string(options.crs_in)),
                          pyproj.Proj(fiona.crs.to_string(options.crs)),
                          rounding=options.rounding
    )
    geom_latlon = proj_geom(geom,
                            pyproj.Proj(fiona.crs.to_string(options.crs_in)),
                            pyproj.Proj("+init=EPSG:4326"),
                            )
    bbox_latlon = shapely.geometry.shape(geom_latlon).bounds
    # download OSM data if appropriate
    if options.osm_download:
        logger.info('Downloading OSM data to {:s}'.format(options.osm_fn))
        if os.path.isfile(options.osm_fn):
            logger.warning('File {:s} already exists, assuming download of OSM data is not necessary...'.format(options.osm_fn))
        else:
            osm2dh.download_overpass('{:s}.tmp'.format(options.osm_fn), bbox_latlon)
            os.rename('{:s}.tmp'.format(options.osm_fn),
                      options.osm_fn)

    # create Domain objects and write to dh file
    logger.info('Preparing domain bbox and 2D mesh')
    domain_objects, domain_bnd = df.polygon2domain(domain, domain_id, options.boundary_2d)

    write_fm_domain(options, domain_objects, domain_bnd, logger=logger)
    if os.path.isfile(options.fm_exe):
        osm2dh.generate_mesh(options.mesh_2d_fn,
                             shapely.geometry.shape(geom).bounds,
                             options.cell_size,
                             fm_exe=options.fm_exe,
                             logger=logger)
    else:
        logger.warning('Skipping 2D network, DFLOWFM executable is not available at {:s}'.format(options.fm_exe))

    # create observation file from observations_fn (if available)
    if os.path.isfile(options.observations_fn):
        # try:
        obs_objects = osm2dh.generate_obs(options.observations_fn,
                                          options.observations_xyz)
        write_obs(options, obs_objects, logger)
        # except:
        #     logger.error('Something wrong with shapefile {:s}. It should contain "id" and "name" attributes'.format(options.observations_fn))
        #     sys.exit(1)

    #### PREPARE THE CHANNEL FILES (shp and FM, inc boundary conditions) ################
    if np.logical_and(options.channels['key'] is not None, options.channels['values'] is not None):
        logger.info('Preparing channel sections, profiles and boundary conditions...')
        channel_objects, bnd_objects = osm2dh.osm2channel(options.osm_fn,
                                                          check_fields,
                                                          options.dtm_fn,
                                                          values=options.channels['values'],
                                                          depths=options.channels['depths'],
                                                          widths=options.channels['widths'],
                                                          min_width=options.channels['min_width'],
                                                          proftypes=options.channels['proftypes'],
                                                          ids_bnd=options.boundary_1d['ids'],
                                                          types_bnd=options.boundary_1d['types'],
                                                          files_bnd=options.boundary_1d['files'],
                                                          layer_index=options.layer_index,
                                                          bbox=domain,
                                                          bbox_buffer=options.domain_buffer,
                                                          key=options.channels['key'],
                                                          max_snap_dist=1.5,
                                                          logger=logger)  # properties

        write_fm_channels(options, channel_objects, bnd_objects, logger=logger)

        channel_features = [c.feature() for c in channel_objects]
        df.write_layer(os.path.join(options.gis_path, 'channels.shp'), 'channels', channel_features,
                       write_mode='w', crs=options.crs, logger=logger)
        profile_features = [c.profile_definition.feature() for c in channel_objects]
        df.write_layer(os.path.join(options.gis_path, 'profiles.shp'), 'profiles', profile_features,
                       write_mode='w', crs=options.crs, logger=logger)
        bnd_cnd_features = [c.feature() for c in bnd_objects]
    else:
        bnd_cnd_features = []
    for bnd_2d in domain_bnd:
        # write the four 2D boundaries to shape
        bnd_cnd_features.append(bnd_2d.feature())
    if len(bnd_cnd_features) > 0:
        df.write_layer(os.path.join(options.gis_path, 'boundaries.shp'), 'boundaries', bnd_cnd_features,
                           write_mode='w', crs=options.crs, logger=logger)

    #### PREPARE THE CULVERT FILES (shp and FM) ################
    if np.logical_and(options.culverts['key'] is not None, options.culverts['value'] is not None):
        logger.info('Preparing culverts...')
        culvert_objects, gate_objects = osm2dh.osm2culvert(options.osm_fn,
                                                           check_fields,
                                                           layer_index=options.layer_index,
                                                           bbox=domain,
                                                           key=options.culverts['key'],
                                                           value=options.culverts['value'],
                                                           depth=options.culverts['depth'],
                                                           width=options.culverts['width'],
                                                           min_length=options.culverts['min_length'],
                                                           id_blocked=options.culverts['id_blocked'],
                                                           block_factor=options.culverts['block_factor'],
                                                           dtm_fn=options.dtm_fn,
                                                           bbox_buffer=-100,
                                                           logger=logger)

        write_fm_culverts(options, culvert_objects, gate_objects, logger=logger)

        culvert_features = [c.feature() for c in culvert_objects]
        df.write_layer(os.path.join(options.gis_path, 'culverts.shp'), 'culverts', culvert_features,
                       write_mode='w', crs=options.crs, logger=logger)

        # write gates to shapefile if exist
        if len(gate_objects) > 0:
            df.write_layer(os.path.join(options.gis_path, 'culverts_blocked.shp'), 'culverts_blocked',
                           [c.feature() for c in gate_objects],
                           write_mode='w', crs=options.crs, logger=logger)

    #### PREPARE THE BRIDGE FILES (FM only) ################
    if options.bridges['key'] is not None:
        logger.info('Preparing bridges...')
        gate_at_bridge_objects = osm2dh.osm2blocked_bridge(options.osm_fn,
                                                           check_fields,
                                                           dtm_fn=options.dtm_fn,
                                                           id_blocked=options.bridges['id_blocked'],
                                                           block_factor=options.bridges['block_factor'],
                                                           key=options.bridges['key'],
                                                           values=options.bridges['values'],
                                                           bbox=domain,
                                                           layer_index=1,
                                                           logger=logger)

        if len(gate_at_bridge_objects) > 0:
            # write to dhydro culvert file
            logger.info('Writing data for blocked bridges to {:s}'.format(options.culverts_gates_fn))
            [o.to_dh(options.culverts_gates_fn, options.culverts_gates_path, append=True) for o in gate_at_bridge_objects]

            # write to shapefile
            df.write_layer(os.path.join(options.gis_path, 'bridges_blocked.shp'), 'bridges_blocked',
                           [c.feature() for c in gate_at_bridge_objects],
                           write_mode='w', crs=options.crs, logger=logger)

    df.write_mdu(options)#### PREPARE THE MDU FILE

    #### END PROGRAM  #######
    # close logger
    logger, ch = closeLogger(logger, ch)
    del logger, ch
    sys.exit(0)

if __name__ == "__main__":
    main()
