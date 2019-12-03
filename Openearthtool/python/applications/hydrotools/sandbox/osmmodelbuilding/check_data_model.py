# -*- coding: utf-8 -*-
"""
Created on Wed Jul 08 16:12:29 2015

@author: winsemi

$Id: check_data_model.py 13726 2017-09-18 11:10:46Z hegnauer $
$Date: 2017-09-18 04:10:46 -0700 (Mon, 18 Sep 2017) $
$Author: hegnauer $
$Revision: 13726 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/sandbox/osmmodelbuilding/check_data_model.py $
$Keywords: $

"""

# import admin packages
from optparse import OptionParser
from configobj import ConfigObj
import sys
import os
import pandas as pd
import geopandas as gpd
import shapely
import numpy as np
from matplotlib import cm, patches
import matplotlib.pyplot as plt

# from branca.element import IFrame

# geographical packages
import fiona
import logging
import logging.handlers
#from osm2dh import filter_features, check_data_model, check_crossings, download_overpass, write_layer, check_connectivity
from osm2dh import filter_features, check_data_model, download_overpass, write_layer, check_connectivity, check_crossings


table = """
<!DOCTYPE html>
<html>
<head>
<style>
table {{
    width:100%;
}}
table, th, td {{
    border: 1px solid black;
    border-collapse: collapse;
}}
th, td {{
    padding: 5px;
    text-align: left;
}}
table#t01 tr:nth-child(odd) {{
    background-color: #eee;
}}
table#t01 tr:nth-child(even) {{
   background-color:#fff;
}}
</style>
</head>
<body>

<table id="t01">
<tr>
    <td>Property</td>
    <td>Value</td>
  </tr>
  <tr>
    <td>OSM-id</td>
    <td>{}</td>
  </tr>
  <tr>
    <td>Width</td>
    <td>{} (m)</td>
  </tr>
  <tr>
    <td>Depth</td>
    <td>{} (m)</td>
  </tr>
   <tr>
    <td>Diameter</td>
    <td>{} (m)</td>
  </tr>
  <tr>
    <td>Covered</td>
    <td>{}</td>
  </tr>
</table>
</body>
</html>
""".format
def create_options():
    if len(sys.argv) == 1:
        print('No arguments given. Please run with option "-h" for help')
        sys.exit(0)
    parser = create_parser()
    (options, args) = parser.parse_args()
    if len(args) != 0:
        print('Incorrect number of arguments given. Please run with option "-h" for help')
        sys.exit(0)

    if not os.path.exists(options.inifile):
        print('path to ini file {:s} cannot be found'.format(os.path.abspath(options.inifile)))
        sys.exit(1)
    # required input
    if not options.dest_path:  # if destination is not given
        print('destination path not given')

    # file names and directory bookkeeping
    options.dest_path = os.path.abspath(options.dest_path)
    logfilename = os.path.join(options.dest_path, 'osm_validation.log')
    # create dir if not exist
    if not os.path.isdir(options.dest_path):
        os.makedirs(options.dest_path)
    # delete old destination and log files
    else:
        if os.path.isfile(logfilename):
            os.unlink(logfilename)
    # set up the logger
    logger, ch = setlogger(logfilename, 'osm_validation', options.verbose)
    logger.info('$Id: check_data_model.py 13726 2017-09-18 11:10:46Z hegnauer $')

    options = add_ini(options)
    if not (os.path.exists(options.osm_fn)) and not options.osm_download:
        print('path to osm datafile {:s} cannot be found'.format(options.osm_fn))
        sys.exit(1)

    if not (os.path.isdir(options.gis_path)):
        os.makedirs(options.gis_path)
    if not (os.path.isdir(options.report_path)):
        os.makedirs(options.report_path)

    # write info to logger
    logger.info('Destination path: {:s}'.format(options.dest_path))
    logger.info('OSM file: {:s}'.format(options.osm_fn))
    return options, logger, ch

def create_parser():
    usage = "usage: %prog [options]"
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
    parser.add_option('-g', '--graph',
                      dest='plot_validation', default=False, action='store_true',
                      help='make graphs of validation flags (default False)')
    parser.add_option('-P', '--popup',
                      dest='popup', default=False, action='store_true',
                      help='add popups to the map (default False)')
    parser.add_option('-c', '--check', type='choice', action='store',
                      dest='check', choices=['data_model', 'connectivity', 'crossings'],
                      default=None,
                      help='which check to perform, can be: data_model, connectivity, crossings')
    # parser.add_option('-m', '--data_model',
    #                   dest='check_data_model', default=False, action='store_true',
    #                   help='check for data model (default False)')
    parser.add_option('-d', '--destination',
                      dest='dest_path', default='',
                      help='Destination folder for reporting')
    parser.add_option('-p', '--prefix',
                      dest='prefix', default='',
                      help='Prefix for reporting files')
    return parser

def add_ini(options, logger=logging):

    ### READ CONFIG FILE
    # open config-file
    config = ConfigObj(options.inifile)
    # read settings
    options.osm_fn = configget(config, 'input_data', 'osm_file', None)
    if options.osm_fn is None:
        raise ValueError('OSM file name not found in ini file, check [input_data] -> osm_file')
    options.layer_index = configget(config, 'input_data', 'layer_index', 1, 'int')
    options.layer_type = configget(config, 'input_data', 'layer_type', 'LineString', 'str')
    options.xmin = configget(config, 'input_data', 'xmin', None, 'float')
    options.xmax = configget(config, 'input_data', 'xmax', None, 'float')
    options.ymin = configget(config, 'input_data', 'ymin', None, 'float')
    options.ymax = configget(config, 'input_data', 'ymax', None, 'float')

    if 'bounds' in config:
        options.bounds = options_add_filter(config, 'bounds')
    else:
        options.bounds = None

    if options.check == 'crossings':
        options.filter_highway = options_add_filter(config, 'filter_highway')
        options.filter_bridge = options_add_filter(config, 'filter_bridge')
        options.filter_tunnel = options_add_filter(config, 'filter_tunnel')


    if options.check == 'connectivity':
        options.filter = options_add_filter(config, 'filter')
        options.connectivity = {}
        options.key_types = {}
        options.key_ranges = {}
        options.connectivity['idx'] = configget(config, 'connectivity_options', 'selected_id', 'list')
        options.connectivity['tolerance'] = configget(config, 'connectivity_options', 'tolerance', '', 'float')
        options.json_types = {}
        options.key_ranges = {}
        for key in config['key_types']:
            options.key_types[key] = eval(configget(config, 'key_types', key, '', 'str'))
            options.json_types[key] = configget(config, 'key_types', key, '', 'str')

    if options.check == 'data_model':
        options.filter = options_add_filter(config, 'filter')
        options.key_types = {}
        options.json_types = {}
        options.key_ranges = {}
        for key in config['key_types']:
            options.key_types[key] = eval(configget(config, 'key_types', key, '', 'str'))
            options.json_types[key] = configget(config, 'key_types', key, '', 'str')


        # now parse the allowed values, check if these need to be converted to a certain data type
        for key in config['key_ranges']:
            # check datatype
            if key in options.key_types:
                dtype_str = options.key_types[key].__name__
            else:
                # assume datatype can be string
                dtype_str = 'str'


            options.key_ranges[key] = configget_list(config, 'key_ranges', key, dtype=dtype_str)
            if (dtype_str == 'float') & (len(options.key_ranges[key]) != 2):
                logger.error('key "{:s}" of type "{:s}" should have 2 range values in key_ranges section (min and max)'.format(key, dtype_str))
                sys.exit(1)
    # make some more option entries based on path and model name
    options.gis_path = os.path.join(options.dest_path, 'gis_files')
    options.report_path = os.path.join(options.dest_path, 'report_files')
    options.report_xlsx = os.path.join(options.report_path, '{:s}_report.xlsx'.format(options.prefix))
    options.report_json = os.path.join(options.gis_path, '{:s}_geo.json'.format(options.prefix))
    return options

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
        elif dtype == 'list':
            return [int(str_part) for str_part in str.split(',')]
        else:
            return [str_part for str_part in str]
    else:
        return []

def options_add_filter(config, section):
    filter = {}
    filter['key'] = configget(config, section, 'key', '', 'str')
    filter['value'] = configget_list(config, section, 'value', dtype='str')
    if 'layer_index' in config[section]:
        filter['layer_index'] = configget(config, 'bounds', 'layer_index', None, 'int')
    return filter

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

def classify(value, classes, cmap, extend=None):
    """
    Return a color tuple (R, G, B, trans) for the chosen value
    according to a list of classes
    Inputs:
        value       -   numeric value
        classes     -   list with classes
        cmap        -   colormap object (e.g. cm.jet)
        extend      -   either 'min', 'max' or 'both'. Indicates whether the
                        list of classes is extended on left or right side
                        if values smaller/larger than the most extreme values
                        in the list of classes are also feasible
    """
    # first estimate a number between 0 and one
    idx = 0
    if np.logical_or(extend == 'min', extend == 'max'):
        nrClasses = len(classes)
    elif extend == 'both':
        nrClasses = len(classes) + 1
    else:
        nrClasses = len(classes) - 1
    # define the color locations in cmap per class
    lookup = np.linspace(0, 1, nrClasses)

    if np.logical_or(extend == 'min', extend == 'both'):
        idx_start = 0
    else:
        idx_start = 1
    if np.logical_or(extend == 'max', extend == 'both'):
        idx_end   = len(classes)
    else:
        idx_end   = len(classes)-1


    for n, Class in enumerate(classes[idx_start:idx_end]):
        if value > Class:
            idx += 1
    return cmap(lookup[idx])

def classify_legend(cax, classes, class_names, cmap, class_title):
    allFaceColors = []
    p = []
    classLabels = []

    for n, Class in enumerate(classes):
        classLabels.append('{:d}'.format(Class))
        classColor = classify(Class, classes, cmap, extend='both')
        allFaceColors.append(classColor)
        ClassPatch = patches.Rectangle((0,0), 1, 1, fc=classColor, ec='#999999')
        p.append(ClassPatch)

    leg = cax.legend(p, class_names, ncol=1, bbox_to_anchor=None, handlelength=.7, prop=None, title=class_title) # ,columnspacing=.75,handletextpad=.25, ,
    leg.draw_frame(False)
    plt.setp(leg.get_title(),fontsize='small')
    return cax

def plot_lines_gpd(fn, key, vmin=0., vmax=4., cmap=cm.jet, classes=range(4),
                   class_names=['correct', 'invalid value', 'invalid data type', 'missing values'],
                   class_title='validation'):
    gpd_obj = gpd.read_file(fn)
    # plt.style.use('classic')
    fig, ax = plt.subplots(subplot_kw=dict(aspect='equal'))
    fig.subplots_adjust(right=0.8)
    plt.grid()
    gpd_obj.plot(ax=ax, column=key, cmap=cmap, linewidth=2., vmin=vmin, vmax=vmax)
    cax = fig.add_axes([0.82, 0.3, 0.15, 0.5])
    cax.axis('off')
    cax = classify_legend(cax, classes, class_names, cmap, class_title)
    return fig, ax

def plot_leaflet_lines(fn, keys, linewidth=4., name='', popup=False):
    import folium
    import geopandas as gpd
    import branca.colormap as cm
    from folium.plugins import MarkerCluster
    
    def new_feature_group(gpd_obj, key, colormap, linewidth=4, name=''):
        feature_group = folium.FeatureGroup(name=name)
        gpd_obj['style'] = [
            {'color': colormap(value), 'weight': linewidth} for value in gpd_obj[key]
            ]
        folium.GeoJson(
            gpd_obj,
            name='',
            ).add_to(feature_group)
        return feature_group

    gpd_obj = gpd.read_file(fn)
    step = cm.StepColormap(['green', 'yellow', 'orange', 'red'],
                           vmin=-0.5, vmax=3.5, index=[-0.5, 0.5, 1.5, 2.5, 3.5],
                           caption='step')
    ## Added second color map for "yes / no flags (e.g. connected yes or no)
    step_ = cm.StepColormap(['red', 'blue'],
                           vmin=-0.5, vmax=1.5, index=[-0.5, 0.5, 1.5],
                           caption='step')
   
    m = folium.Map(max_zoom=20, control_scale=True)
    # m = folium.Map(min_lat=min_lat, min_lon=min_lon, max_lat=max_lat, max_lon=max_lon)
    m.fit_bounds([[-6.807052, 39.2226719], [-6.7851343, 39.2397977]])
#    # make a black style column
#    gpd_obj['style'] = [
#        {'color': 'black', 'weight': linewidth+2} for geom in gpd_obj.geometry
#    ]
#    folium.GeoJson(
#        gpd_obj,
#        name=name
#        ).add_to(m)
    for key in keys:
#        if not 'connected' in key:
#            new_feature_group(gpd_obj, key + '_flag', step, linewidth=linewidth, name=key).add_to(m)
#        else:
        new_feature_group(gpd_obj, key, step_, linewidth=linewidth, name=key).add_to(m)

    step.caption = '0: Correct 1: Value outside range 2: Incorrect data type 3: no value'
    m.add_child(step)
    if popup:
        popups, locations = [], []
        for idx, row in gpd_obj.iterrows():
            locations.append([row.geometry.centroid.y, row.geometry.centroid.x])
            osmid    = row['osm_id']
            width    = row['width']
            depth    = row['depth']
            diameter = row['diameter']
            covered  = row['covered']
            iframe = IFrame(table(osmid, width, depth, diameter, covered), width=200, height=250)
            popups.append(iframe)
        
        t = folium.FeatureGroup(name='Popup')
        t.add_child(MarkerCluster(locations=locations, popups=popups))
        m.add_child(t)

    add = '/MapServer/tile/{z}/{y}/{x}'
    ESRI = dict(World_Imagery='http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                World_Topo_Map='http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                MapBox='http://a.tiles.mapbox.com/v4/openstreetmap.map-inh7ifmo/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoib3BlbnN0cmVldG1hcCIsImEiOiJncjlmd0t3In0.DmZsIeOW-3x-C5eX-wAqTw')
    
    for tile_name, tile_url in ESRI.items():
        folium.WmsTileLayer(url=tile_url, name=tile_name, format="image/png", overlay=False).add_to(m)
    
    folium.TileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png',
            max_zoom=20, attr = """OSM Black&White""", name="OSM (black & white)"
            ).add_to(m)
    
    folium.TileLayer('http://b.tiles.mapbox.com/v3/worldbank-education.pebkgmlc/{z}/{x}/{y}.png',
            max_zoom =25,attr = """Drone data""", name="Drone data"
            ).add_to(m)
        
    folium.LayerControl().add_to(m) #Add layer control to toggle on/off

    # step.tick_labels(['a', 'b', 'c', 'd', ''])
    return m

def create_bounds(options, logger=logging):
    # find the geographical boundaries
    logger.info('Filtering bounds from {:s}'.format(options.osm_fn))
    bound_features = filter_features(options.osm_fn,
                                     key=options.bounds['key'],
                                     value=options.bounds['value'],
                                     layer_index=options.bounds['layer_index'],
                                     wgs2utm=False,
                                     logger=logger,
                                     )
    if len(bound_features) > 1:
        logger.warning('More than one feature found, preparing a list of results per feature...')
    elif len(bound_features) == 0:
        logger.error('No bounding features found with key {:s} and value {:s}'.format(options.bounds['key']))
        sys.exit(1)
    else:
        # filter the all_features to only provide within-bounds
        logger.info('Found a unique bounding area with key {:s} and value {:s}'.format(options.bounds['key'],
                                                                             str(options.bounds['value'])))
    bbox = {}
    for val in options.bounds['value']:
        bb = shapely.geometry.MultiPolygon([bound_feature['geometry']
                                            for bound_feature in bound_features
                                            if bound_feature['properties'][options.bounds['key']] == val])
        bbox[val] = bb
    # bbox = [bound_feature['geometry'] for bound_feature in bound_features]
    if len(bbox) == 0:
        bbox = {} # [None]
    return bbox

def get_osm_data(options, logger=logging):
    # prepare domain
    domain = shapely.geometry.Polygon([(options.xmin, options.ymax),
                                       (options.xmin, options.ymin),
                                       (options.xmax, options.ymin),
                                       (options.xmax, options.ymax)])
    bbox_latlon = domain.bounds
    logger.info('Downloading OSM data to {:s}'.format(options.osm_fn))
    if os.path.isfile(options.osm_fn):
        logger.warning(
            'File {:s} already exists, assuming download of OSM data is not necessary...'.format(options.osm_fn))
    else:
        download_overpass('{:s}.tmp'.format(options.osm_fn), bbox_latlon,
                          url_template='http://www.overpass-api.de/api/xapi_meta?*[bbox={xmin},{ymin},{xmax},{ymax}]')
        os.rename('{:s}.tmp'.format(options.osm_fn),
                  options.osm_fn)
    return None

def get_data_model_check(options, bbox, global_props={}, logger=logging):
    logger.info('Filtering features from {:s}'.format(options.osm_fn))
    logger.info('Using key: {:s} and value: {:s}'.format(options.filter['key'], str(options.filter['value'])))
    all_features = filter_features(options.osm_fn,
                                   key=options.filter['key'],
                                   value=options.filter['value'],
                                   layer_index=options.layer_index,
                                   wgs2utm=False,
                                   logger=logger,
                                   bbox=bbox,
                                   )
    logger.info('{:d} features found'.format(len(all_features)))

    # prepare schema
    schema = {
              'geometry': options.layer_type,
              'properties': options.json_types
    }
    logger.info('Checking data model')
    feats_checked = check_data_model(all_features,
                                     check_keys=options.key_types,
                                     check_ranges=options.key_ranges,
                                     schema=schema,
                                     keep_original=True,
                                     global_props=global_props,
                                     logger=logger,
                                     )

    return feats_checked

def get_crossings_check(options, bbox, props={}, logger=logging):
    logger.info('Checking crossings of waterways and highways')
    # make a list of results per filtered bbox
    highways = filter_features(options.osm_fn,
                               key=options.filter_highway['key'],
                               value=options.filter_highway['value'],
                               layer_index=1,
                               wgs2utm=False,
                               logger=logger,
                               bbox=bbox,
                               )
    waterways = filter_features(options.osm_fn,
                                key=options.filter['key'],
                                value=options.filter['value'],  # these should be the waterways
                                layer_index=1,
                                wgs2utm=False,
                                logger=logger,
                                bbox=bbox,
                                )
    crossings = check_crossings(highways,
                                waterways,
                                options.filter_bridge['key'],
                                options.filter_bridge['value'],
                                options.filter_tunnel['key'],
                                options.filter_tunnel['value'],
                                props=props,
                                logger=logger,
                                )
    return highways, waterways, crossings

def main():
    options, logger, ch = create_options()
    ## OSM DOWNLOAD
    if options.osm_download:
        get_osm_data(options, logger=logger)
    # filter geographical bounds (if provided)
    if options.bounds:
        bbox = create_bounds(options, logger=logger)
    else:
        bbox = {'full_area': None}
    # checking data model
    if options.check == 'data_model':
        schema = {
                  'geometry': options.layer_type,
                  'properties': options.json_types
        }
        feats_checked = []
        validation_report = {}
        for bb in bbox:
            if bbox[bb] is None:
                bound_filter_key = 'name_bound'
                bound_filter_name = 'full_area'
            else:
                bound_filter_key = options.bounds['key'] + '_bound'
                bound_filter_name = bb
            validation_report[bound_filter_name] = {}
            logger.info('Checking data model for {:s}'.format(bound_filter_name))
            _feats_checked = get_data_model_check(options, bbox[bb], global_props={bound_filter_key: bound_filter_name}, logger=logger)
            feats_checked += _feats_checked
            logger.info('Preparing data model validation report')
            for key in schema['properties']:
                key_flag = key + '_flag'
                flag = [feat['properties'][key_flag] for feat in _feats_checked]
                validation_report[bound_filter_name][key] = [flag.count(0),
                                                             flag.count(1),
                                                             flag.count(2),
                                                             flag.count(3),
                                                             ]
        # logger.info('Filtering features from {:s}'.format(options.osm_fn))
        # logger.info('Using key: {:s} and value: {:s}'.format(options.filter['key'], str(options.filter['value'])))
        # all_features = filter_features(options.osm_fn,
        #                                key=options.filter['key'],
        #                                value=options.filter['value'],
        #                                layer_index=options.layer_index,
        #                                wgs2utm=False,
        #                                logger=logger,
        #                                bbox=bbox,
        #                                )
        # logger.info('{:d} features found'.format(len(all_features)))
        #
        # # prepare schema
        # logger.info('Checking data model')
        # feats_checked = check_data_model(all_features,
        #                                  check_keys=options.key_types,
        #                                  check_ranges=options.key_ranges,
        #                                  schema=schema,
        #                                  keep_original=True,
        #                                  logger=logger,
        #                                  )

        prop_with_flags = {}
        for key in options.json_types:
            prop_with_flags[key] = options.json_types[key]
            prop_with_flags[key + '_flag'] = 'int'
            # add bounding box naming
            prop_with_flags[bound_filter_key] = 'str'

        # write data to GeoJSON file for further GIS-use.
        logger.info('Writing filtered and checked data to GeoJSON in {:s}'.format(options.report_json))
        
        schema_flag = {
                      'geometry': options.layer_type,
                      'properties': prop_with_flags,
                      }
        write_layer(options.report_json,
                    None,
                    feats_checked,
                    format='GeoJSON',
                    write_mode='w',
                    crs=fiona.crs.from_epsg(4326),
                    schema=schema_flag,
                    logger=logger,
                    )
        # write reports to excel
        logger.info('Writing report to {:s}'.format(options.report_xlsx))
        writer = pd.ExcelWriter(options.report_xlsx)
        for bound_name in validation_report:
            df = pd.DataFrame(validation_report[bound_name])
            df.index = ['correct', 'invalid value', 'invalid data type', 'missing value']
            df.index.name = 'validation'
            df.to_excel(writer, bound_name)
        writer.save()
        # Make pieplot for quick summary of validation rules
        fig, axes = plt.subplots(figsize=(16,8),nrows=2, ncols=3)
        for ax, col in zip(axes.flat, df.columns[1:]):
            artists = ax.pie(df[col], autopct='%1.0f%%', pctdistance=1.1, labeldistance=1.2)
            ax.set(ylabel='', title=col, aspect='equal')

        fig.legend(artists[0], df.index, loc='upper center', bbox_to_anchor=(0.4, 0.05),
              fancybox=True, shadow=True, ncol=4)

        plt.savefig((options.report_xlsx).replace('xlsx','png'), dpi=150, bbox_inches='tight')

    if options.check =='connectivity':
        schema = {
                  'geometry': options.layer_type,
                  'properties': options.json_types
                  }
#        if options.check =='data_model':
#            feats = feats_checked         
        feats = filter_features(options.osm_fn,
                               key=options.filter['key'],
                               value=options.filter['value'],
                               layer_index=options.layer_index,
                               wgs2utm=False,
                               logger=logger,
                               bbox=None,
                               )
        ## ADD connectivity flag to the model
        logger.info('Checking connectivity of the network')
        schema = {
                  'geometry': options.layer_type,
                  'properties': options.json_types
        }
  
        feats_checked = check_data_model(feats,
                                 check_keys=options.key_types,
                                 check_ranges=options.key_ranges,
                                 schema=schema,
                                 keep_original=True,
                                 logger=logger,
                                 )
        prop_with_flags = {}
        for key in options.json_types:
            prop_with_flags[key] = options.json_types[key]
            prop_with_flags[key + '_flag'] = 'int'
        schema = {
              'geometry': options.layer_type,
              'properties': prop_with_flags,
              }
        
        feats_connected = check_connectivity(feats_checked, 
                                 osm_ids = options.connectivity['idx'], 
                                 tolerance = float(options.connectivity['tolerance']), 
                                 check_keys=options.json_types,
                                 schema=schema)
        
        logger.info('Writing filtered and checked data to GeoJSON in {:s}'.format(options.report_json))
        
        props_schema = schema['properties']
        
        props_schema['connected'] = 'int'
        props_schema['endpoints'] = 'int'

        schema = {
              'geometry': options.layer_type,
              'properties': props_schema,
        }
        
        write_layer(options.report_json,
                    None,
                    feats_connected,
                    format='GeoJSON',
                    write_mode='w',
                    crs=fiona.crs.from_epsg(4326),
                    schema=schema,
                    logger=logger,
                    )

    if options.check == 'crossings':
        validation_report = {}

        highways = []
        waterways = []
        crossings = []
        for bb in bbox:

            _highways, _waterways, _crossings = get_crossings_check(options, bbox[bb], props={options.bounds['key']: bb}, logger=logger)
            highways += _highways
            waterways += _waterways
            crossings += _crossings
            flag = [feat['properties']['flag'] for feat in _crossings]  # list all the flag values and write to df
            type = [feat['properties']['structure'] for feat in _crossings]  # list all the flag values and write to df
            validation_report[bb] = [flag.count(0),
                                     flag.count(1),
                                     type.count(options.filter_bridge['value']),
                                     type.count(options.filter_tunnel['value'])]

        df = pd.DataFrame(validation_report)
        df.index = ['correct', 'no crossing info', 'number of bridges counted', 'number of tunnels counted']
        df.index.name = 'validation'
        logger.info('Writing report to {:s}'.format(options.report_xlsx))
        df.to_excel(options.report_xlsx)

        write_layer(options.report_json,
                    None,
                    crossings,
                    format='GeoJSON',
                    write_mode='w',
                    crs=fiona.crs.from_epsg(4326),
                    schema=None,
                    logger=logger,
                    )

    if options.plot_validation:
#        if options.check == 'connectivity':
#            schema = {
#                  'geometry': options.layer_type,
#                  'properties': options.json_types
#                  }
#            schema['properties']['connected'] = 'int'
            logger.info('Preparing Leaflet visual')
            # parse a leaflet HTML
            html_name = os.path.join(options.report_path, '{:s}.html'.format(options.prefix))
            m = plot_leaflet_lines(options.report_json, schema['properties'], name=options.prefix, popup=options.popup)
            
            logger.info('Writing Leaflet to {:s}'.format(html_name))
            m.save(html_name)
#        else:
#            schema = {
#                  'geometry': options.layer_type,
#                  'properties': options.json_types
#                  }
#            logger.info('Preparing Leaflet visual')
#            # parse a leaflet HTML
#            html_name = os.path.join(options.report_path, '{:s}.html'.format(options.prefix))
#            m = plot_leaflet_lines(options.report_json, schema['properties'], name=options.prefix, popup=options.popup)
#            
#            logger.info('Writing Leaflet to {:s}'.format(html_name))
#            m.save(html_name)
    
    logger, ch = closeLogger(logger, ch)
    del logger, ch
#    sys.exit(0)

if __name__ == "__main__":
    main()

