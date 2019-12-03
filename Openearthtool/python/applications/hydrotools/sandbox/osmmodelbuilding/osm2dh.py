"""
filter and pipeline functions to convert OSM data to D-Flow FM data

"""

# import general libraries
import os
from collections import Counter
import logging
import shapely
import numpy as np
import copy
import shapely.wkt
from shapely.geometry import (Point, LineString, Polygon,
                              MultiLineString, MultiPoint, MultiPolygon, GeometryCollection)
import fiona
from fiona import crs
from urllib2 import urlopen
import ogr
import gdal
import rtree
#import local libraries
import utm_conversion as utm
from DFlowFM_tools import Channel, Culvert, Obs, create_feature, read_layer, create_gate, multi2single_geoms
import shapely_tools as st


def download_overpass(fn,
                      bbox,
                      url_template='http://overpass.osm.rambler.ru/cgi/xapi_meta?*[bbox={xmin},{ymin},{xmax},{ymax}]'):
    xmin, ymin, xmax, ymax = bbox
    url = url_template.format(xmin=xmin,
                              ymin=ymin,
                              xmax=xmax,
                              ymax=ymax
                              )
    response = urlopen(url)
    with open(fn, 'w') as f:
        f.write(response.read())
    return


def generate_obs(obs_fn, obs_xyz):
    points = read_layer(obs_fn)
    obs = [Obs(o['geometry'], str(o['properties']['id']), o['properties']['name'])
           for o in points]
    return obs


def osm2channel(fn, check_fields, dtm_fn,
                values, depths, widths, min_width, proftypes,
                ids_bnd, types_bnd, files_bnd, # default properties
                layer_index=1,  # input layer
                bbox=None, bbox_buffer=10, key='waterway', max_snap_dist=1, logger=logging):  # properties
    """function to create channel objects from osm objects, read from a geo database (e.g. SQLITE)
    first all waterways are read from the OSM database, clipped to the bbox + buffer & snapped together,
    then the default properties are set and channel objects are created """
    # TODO: extend description
    # create dictionaries for default values
    dproftypes = {k: v for (k, v) in zip(values, proftypes)}
    ddepths = {k: v for (k, v) in zip(values, depths)}
    dwidths = {k: v for (k, v) in zip(values, widths)}
    # filter features from OSM -> no 'rest' category
    filtered = filter_features(fn, bbox=bbox, key=key, value=values,
                                   layer_index=layer_index, logger=logger)
    all_features = check_data_model(filtered, check_keys=check_fields, keep_original=False, logger=logging)
    geoms = [feat['geometry'] for feat in all_features]
    logger.info('{:d} lines filtered'.format(len(geoms)))

    # clip lines within bbox
    if bbox is not None:
        geoms, index = st.clip_lines_with_polygon(geoms, bbox.buffer(bbox_buffer), return_index=True)
        logger.info('line clipping done. {:d} lines'.format(len(geoms)))
    else:
        index = range(len(geoms))

    # snap lines and find indices of edited geometries
    geoms, idx_snap = st.snap_lines(geoms, max_dist=max_snap_dist, return_index=True)
    idx_snap = [index[i] for i in idx_snap]  # translate to original index
    logger.info('snapping done. {:d} edits'.format(len(idx_snap)))

    # split lines at intersection
    geoms, index0 = st.split_lines(geoms, tolerance=1e-3, return_index=True)
    index = [index[i] for i in index0]  # translate to original index
    # get original indices of all lines edited in split_lines function
    idx_split = [idx for idx, count in Counter(index).most_common(len(geoms)) if count > 1]
    logger.info('splitting done. {:d} edits'.format(len(idx_split)))

    # make dictionary with counter for edited lines
    idx_edit = np.unique(np.array(idx_split + idx_snap))
    id_count = {idx: 0 for idx in idx_edit}
    # set default values and create channel objects
    channel_objects = []
    bnd_objects = []
    for i, ift in enumerate(index):
        osm_id = all_features[ift]['properties']['osm_id']
        if not isinstance(geoms[i], LineString):
            logger.error('bad geom type for feature with osm id: {}'.format(osm_id))
            continue
        ft = copy.deepcopy(all_features[ift])
        ft['geometry'] = geoms[i]
        ft['properties']['ids'] = "{}{}".format(osm_id, ft['properties'].get("geom_postfix", ""))
        ft['properties']['ids_org'] = osm_id  # keep original osm_id

        # if geom is edited, make unique id
        edited = ift in idx_edit
        if edited:
            id_count[ift] += 1  # start at 1
            ft['properties']['ids'] = "{}_{:03d}".format(ft['properties']['ids'], id_count[ift])
            logger.info('geometry of feature with osm id: {} has been successfully changed'.format(osm_id))
        ft['properties']['geom_edit'] = int(edited)  # int(1) for geometry edits
        ft['properties']['profnr'] = i + 1

        # set default values
        attr_edit = 0
        ft['properties']['proftype'] = dproftypes.get(ft['properties'][key])
        if not('depth' in ft['properties']):
            ft['properties']['depth'] = ddepths.get(ft['properties'][key])
            attr_edit = 1
        elif ft['properties']['depth'] in [None, '']:
            ft['properties']['depth'] = ddepths.get(ft['properties'][key])
            attr_edit = 1

        if not('width' in ft['properties']):
            ft['properties']['width'] = dwidths.get(ft['properties'][key])
            attr_edit = max(1, attr_edit)
        elif ft['properties']['width'] in [None, '']:
            ft['properties']['width'] = dwidths.get(ft['properties'][key])
            attr_edit = max(1, attr_edit)
        elif ft['properties']['width'] < min_width:
            ft['properties']['width'] = min_width
            attr_edit = max(1, attr_edit)
        ft['properties']['attr_edit'] = int(attr_edit)  # int(1) for property edits

        # parse osm features and append to list
        o = Channel(geom=ft['geometry'], dtm_fn=dtm_fn, **ft['properties'])
        channel_objects.append(o)

        # parse/create boundary condition if osm_id mentioned in ini file
        if (bbox is not None) and (ft['properties']['osm_id'] in ids_bnd):
            idx = ids_bnd.index(osm_id)
            # create boundary condition
            logger.info('channel {}: checking its location and preparing boundary condition object...'.format(ft['properties']['ids']))
            bnds = o.create_boundary_condition(bnd_type=types_bnd[idx], bnd_fn=files_bnd[idx], bbox=bbox, org_ids=osm_id)
            for bnd in bnds:  # can be multiple, always list
                bnd_objects.append(bnd)
    logger.info('Creating Channel objects done')

    return channel_objects, bnd_objects

def osm2culvert(fn, check_fields, dtm_fn,
                depth, width, min_length,
                id_blocked, block_factor,
                # default properties
                key='tunnel', value='culvert',  # osm key value pair
                bbox=None, bbox_buffer=0, layer_index=1,
                logger=logging):

    # filter features from OSM
    filtered = filter_features(fn, bbox=bbox, key=key, value=value,
                                   layer_index=layer_index, logger=logger)
    all_features = check_data_model(filtered, check_keys=check_fields,
                                    keep_original=False, logger=logging)
    # clip lines within bbox
    if bbox is not None:
        geoms = [feat['geometry'] for feat in all_features]
        geoms, index_clip = st.clip_lines_with_polygon(geoms, bbox.buffer(bbox_buffer), return_index=True)
        logger.info('line clipping done. {:d} lines'.format(len(geoms)))
    else:
        index_clip = range(len(all_features))

    culvert_objects, gate_objects = [], []
    for i, ift in enumerate(index_clip):
        if not isinstance(geoms[i], LineString):
            logger.error('bad geom type for feature with osm id: {}'.format(all_features[ift]['properties']['osm_id']))
            continue
        # check for the length of the feature, if smaller than threshold, skip for now
        if geoms[i].length < min_length:
            logger.warning('skipping culvert of length {:.2f}, smaller than {:.2f} m'.format(geoms[i].length, min_length))
            continue
        # TODO: replace for line extending when smaller than threshold
        ft = copy.deepcopy(all_features[ift])
        osm_id = ft['properties']['osm_id']
        ft['geometry'] = geoms[i]
        ft['properties']['ids'] = "{}{}".format(osm_id, ft['properties'].get("geom_postfix", ""))
        ft['properties']['ids_org'] = osm_id  # keep original osm_id

        # check if feature is blocked
        if not('blocked' in ft['properties']):
            if osm_id in id_blocked:
                idx = id_blocked.index(osm_id)
                ft['properties']['blocked'] = (block_factor[idx] > 0)
            else:
                ft['properties']['blocked'] = False
        else:
            ft['properties']['blocked'] = True

        # set geometry edit status
        ft['properties']['geom_edit'] = int(0)  # int(1) if edited
        ft['properties']['length'] = geoms[i].length
        # set default values
        attr_edit = 0
        if not('depth' in ft['properties']):
            ft['properties']['depth'] = depth
            attr_edit = 1
        elif ft['properties']['depth'] in [None, '']:
            ft['properties']['depth'] = depth
            attr_edit = 1

        if not('width' in ft['properties']):
            ft['properties']['width'] = width
            attr_edit = max(1, attr_edit)
        elif ft['properties']['width'] in [None, '']:
            ft['properties']['width'] = width
            attr_edit = 1

        ft['properties']['attr_edit'] = int(attr_edit)  # int(1) for property edits

        # parse osm features and append to list
        # TODO: add try, except
        o = Culvert(dtm_fn=dtm_fn, geom=ft['geometry'], **ft['properties'])
        culvert_objects.append(o)

        # only if blocked: create gate(=dam) object
        if ft['properties']['blocked']:
            logger.info('culvert {} is blocked, preparing gate object...'.format(ft['properties']['ids']))
            gate_objects.append(o.create_gate(dtm_fn=dtm_fn))

    msg = 'Creating Culvert {:d} objects done; {:d} (partly) blocked'
    logger.info(msg.format(len(culvert_objects), len(gate_objects)))

    return culvert_objects, gate_objects


def osm2blocked_bridge(fn, check_fields, dtm_fn,
                       id_blocked, block_factor,
                       # default properties
                       key='bridge', values='',  # osm key value pair
                       bbox=None, layer_index=1,
                       logger=logging, **kwargs):
    """"""
    # filter features from OSM
    filtered = filter_features(fn, bbox=bbox, key=key, value=values,
                                   layer_index=layer_index, logger=logger)
    all_features = check_data_model(filtered, check_keys=check_fields,
                                    keep_original=False, logger=logging)

    logger.info("{:d} bridge objects found".format(len(all_features)))

    objects = []
    for i, ft in enumerate(all_features):
        osm_id = ft['properties']['osm_id']
        # check if feature is blocked
        if osm_id in id_blocked:
            idx = id_blocked.index(osm_id)
            ft['properties']['blocked'] = (block_factor[idx] > 0)
            ft['properties']['ids'] = "{}{}".format(osm_id, ft['properties'].get("geom_postfix", ""))
            ft['properties']['ids_org'] = osm_id  # keep original osm_id

            logger.info('bridge {} is blocked, preparing gate object...'.format(ft['properties']['ids']))
            o = create_gate(geom=ft['geometry'], dtm_fn=dtm_fn, type_name='blocked_bridge', **ft['properties'])
            objects.append(o)
    logger.info("{:d} bridge objects (partly) blocked".format(len(objects)))

    return objects

def filter_features(fn, layer_index=1, bbox=None, key='waterway', value='',
                    split_multigeoms=True, flatten=True, wgs2utm=True, logger=logging):
    """
    Filters out objects from a geo database (E.g. SQLite or OSM file) and a specified layer using key value pairs
    The values are checked for their datatype using "check_fields". If a different datatype is found than requested,
    this key/value pair is not parsed to the list of features
    Inputs:
        fn: filename of geo database or file (string)
        layer_index=1: integer, defining the layer in geo database to be used (=1 typically is line layer in OSM SQLite)
        bbox=None: shapely Polygon object indicating the domain, if supplied, any feature outside will be removed
        key: string, attribute used for filtering objects
        value: string or list with strings, value of attribute, used for filtering objects. if empty string all objects
            with key are passed
        split_multigeoms: Multi geometries are splitted into single geometries, the id is edited with _xxx
        logger=logging: handle to logging object far passing messages
    """
    def _check_osm(fn):
        """
        check if the file is an openstreetmap file or not
        Args:
            fn: gdal vector file name

        Returns: True/False

        """
        a = gdal.OpenEx(fn)
        drv = a.GetDriver().LongName
        a = None
        return drv.__contains__('OpenStreetMap')

    def _check_filter(feat, key, value):
        """
        Checks if feature has a key value pair according to filter
        Returns: True or False
        """
        if key in feat.keys():
            f = feat.GetField(key)
        else:
            return False
        # filter on key/values

        if isinstance(value, str):
            # if value is empty strings, pass all objects of key (unless f return nothing)
            if value == '':
                if f in ['', None, '-1']:
                    return False  # next feat
            # only matching key-value pairs
            else:
                if f != value:
                    return False
        # check against multiple values
        elif isinstance(value, list):
            if f not in value:
                return False
        return True

    def _props2dict(feat):
        """
        Translates all properties of a OGR feature to a JSON dictionary structure
        """
        properties = {}
        for i in range(feat.GetFieldCount()):
            fieldDef = feat.GetFieldDefnRef(i)
            fieldName = fieldDef.GetName()
            v = feat.GetField(fieldName)
            properties[fieldName] = v
        return properties
    if not(isinstance(bbox, list)):
        bbox = [bbox]
    assert os.path.isfile(fn), "Input file 'fn' {:s} does not exists".format(fn)
    assert isinstance(key, str), "Input variable 'key' should be of type string"
    assert isinstance(value, (str, list)), "Input variable 'value' should be of type string or list{string}"
    if isinstance(value, list):
        assert all(isinstance(n, str) for n in value), "Input variable 'value' should be of type string or list{string}"
    # check if dataset is of OpenStreetMap format
    osm_driver = _check_osm(fn)
    # read data
    if osm_driver:
        src_ds = gdal.OpenEx(fn, open_options=['CONFIG_FILE=osmconf_osm2dh.ini'])
    else:
        # assume the file can be read by any other driver
        src_ds = gdal.OpenEx(fn)
    src_lyr = src_ds.GetLayerByIndex(layer_index)
    all_features = [[]]*len(bbox)
    # features = []  # output is list of features
    for n, feat in enumerate(src_lyr):
        geom = shapely.wkt.loads(feat.GetGeometryRef().ExportToWkt())
        if wgs2utm:
            geom = toUTM(geom)
        # check if feature is completely outside domain (if so, discard)
        if bbox[0] is not None:
            geom_disjoint = [bb.disjoint(geom) for bb in bbox if bb is not None]
            if all(geom_disjoint):
                continue
        else:
            geom_disjoint = [False]*len(bbox)
        # check if feature obeys to key/value filter. If not continue to next feature
        if not(_check_filter(feat, key, value)):
            continue
        # copy properties to JSON dictionary structure
        properties = _props2dict(feat)
        # read geometry
        try:
            ft = create_feature(geom, missing_value=None, **properties)
        except Exception as e:
            logger.warning('Error({0}), skipping geometry.'.format(e))
            continue
        
        if split_multigeoms:
            # geoms splitted and added "geom_postfix" property
            append = [features.append(ft) for disjoint, features in zip(geom_disjoint, all_features) if not(disjoint) for ft in multi2single_geoms(ft)]
            # [features.append(ft) for ft in multi2single_geoms(ft)]
        else:
            # features.append(ft)
            append = [features.append(ft) for disjoint, features in zip(geom_disjoint, all_features) if not(disjoint)]
    src_ds = None
    # if len(all_features) == 1:
    #     return all_features[0]
    # else:
    if flatten:
        return [y for x in all_features for y in x]
    else:
        return all_features

def check_data_model(feats, check_keys={}, check_ranges={}, schema=None,
                     keep_original=False, flag_suffix='_flag', logger=logging):
    """
    checks all features in list "feats" for compliancy with a data model

    Args:
        feats: list of JSON-type features (with 'geometry' and 'properties')
        check_keys={}: dictionary of keys with datatypes
        check_ranges={}: dictionary of keys with values
        schema=None: fiona schema that should be followed. If None, then schema is copied from features and all keys are copied
        keep_original=False: if set to True, the values (read as string) will be converted to their mandated key type
        flag_suffix='_flag': suffix to use for keys showing the flag value
        logger=logging: reference to logger object for messaging

    Returns:
        feats_checked: list of JSON-type features with 'properties' containing the flag values after data model checking
    """

    def _value_in_range(value, range_list):
        if isinstance(value, float):
            # check if value is in between first and second validation nr (when type is float)
            return _check_range(value, range_list)
        else:
            return ((value in range_list) or (len(range_list) == 0))

    def _check_range(value, range_list):
        """
        Check if a value lies within a predefined range
        if the range does not consist of 2 numbers, a None is returned
        Inputs:
            value: float or integer to check if it lies within range
            range_list: list of 2 numbers used to check valid range. These do not have to be in ascending order
        """

        if len(range_list) != 2:
            return None

        if np.min(range_list) <= value <= np.max(range_list):
            return True
        return False

    def _flag_data_model(check_keys, check_ranges, key, v):
        """
        Checks if value in a given key is according to a given data model,
        consisting of a mandated data type and allowed values
        :param check_keys: dictionary, with key names and mandated data type
        :param check_ranges: dictionary with key names and mandated data values
        :param key: key to check with data model (if it exists in the data model, then check!)
        :param v: value of key to check with data model
        :return:
            v_checked: checked value (left empty if checks are not successful
            flag: flag value with check, can be:
                (None) key is not required in data model
                (0) value is valid
                (1) there is a value of correct type but not within range of valid values
                (2) there is a value but in wrong data type (e.g. string instead of float)
                (3) there is no value (i.e. v is None or empty string)
        """
        if not (key in check_keys) and not (key in check_ranges):
            # nothing to be checked, so return with a flag=None
            return v, None

        if (key in check_keys) and (v is not None):
            # field value should have a mandated data type, check validity
            ftype = check_keys[key]
            v_checked = check_Ftype(ftype, v)
            if v_checked:  # if not an empty string or None is returned
                flag = 0  # there is data, we assume in the right data model if any
                if key in check_ranges:
                    # check if v_checked is in range
                    if not _value_in_range(v_checked, check_ranges[key]):
                        flag = 1
            else:
                v_checked = ''
                if v:
                    flag = 2  # there is data, but wrong data type
                else:
                    flag = 3  # there is no data (v = '')

        else:
            # only flags 0, 1 and 3 are possible
            # field value should only follow a valid value range
            flag = 0  # first assume value is within range, then check and update
            if isinstance(v, str):
                v_checked = v.lower()
            else:
                v_checked = v
            if key in check_ranges:
                # check if v_checked is in range
                if not _value_in_range(v_checked, check_ranges[key]):
                    flag = 1
            if v_checked is None:  # v should be checked, but is None, and
                flag = 3
        return v_checked, flag

    feats_checked = []

    for feat in feats:
        if schema is not None:
            props_schema = schema['properties']
        else:
            props_schema = {}
            for key in feat['properties']:
                props_schema[key] = type(feat['properties'][key]).__name__

    # set field values based on field in scheme
        props = {}
        for key in props_schema:
            try:
                v = feat['properties'][key]
            except:
                v = None
                pass
            key_flag = key + flag_suffix
            v_check, v_flag = _flag_data_model(check_keys, check_ranges, key, v)
            props[key] = v
            if v_flag is not None:
                # key is within data model (else, don't use key)
                if not(keep_original):
                    props[key] = v_check
                props[key_flag] = v_flag
        # make a new features
        feat_checked = create_feature(feat['geometry'], missing_value=None, **props)
        feats_checked.append(feat_checked)
    return feats_checked

def check_connectivity(feats, osm_ids=[], tolerance=0.0001, check_keys={}, check_ranges={}, logger=logging,schema=None):
    """
    checks the connectivity of all features in list "feats". Connected features are given the same connected_id, based on the 
    initialy selected feature.

    Args:
        feats: list of JSON-type features (with 'geometry' and 'properties')
        select_id={}: id of the selected elemenet for which the connected network will be checked. Is set in ini-file
        tolerance=: tolerance where within elements are assumend to be connected. Is set in ini-file
        check_keys={}: dictionary of keys with datatypes
        logger=logging: reference to logger object for messaging

    Returns:
        feats: list of JSON-type features with 'properties' containing the connected flag (id)
    """
    feats_     = copy.copy(feats) 
    
    ## Build a spatial index to make all faster
    tree_idx   = rtree.index.Index()
    lines_bbox = [l['geometry'].buffer(tolerance).bounds for l in feats_]
    
    for i, bbox in enumerate(lines_bbox):
        tree_idx.insert(i, bbox)
    
    ## Create two new properties, needed to check connectivity. Initial value == 0
    for i, feat in enumerate(feats_):
        feat['properties']['connected'] = 0
        feat['properties']['endpoints'] = 0
    
    ## Make a list of the selected elements, for which we need to check the connectivity
    select_ids = [idx for idx in np.arange(0,len(feats_)) if feats_[idx]['properties']['osm_id'] in osm_ids]            
    
    ## Now start the actual check, looping over the selected elements
    for select_id in select_ids:
        ## First set the properties of the selected elements
        feats_[int(select_id)]['properties']['connected'] = feats_[select_id]['properties']['osm_id']
        feats_[int(select_id)]['properties']['endpoints'] = 2
        to_check = 1
        endpoints_list = [select_id]
        while to_check > 0:
            for endpoint_id in endpoints_list:
                ## Find all elements for which the boudning box connects to the selected element to narrow the number of elements
                ## to loop over.
                hits = list(tree_idx.intersection(lines_bbox[int(endpoint_id)], objects=False))
                for i in hits:
                    ## Ugly solution to solve the issue
                    if feats_[i]['properties']['endpoints'] > 0:      
                        feats_[i]['properties']['endpoints'] = feats_[i]['properties']['endpoints'] - 1
                        
                    ## Check if element is not itself, to overcome the issue of endless loop.                   
                    if feats_[i]['properties']['connected'] != feats_[select_id]['properties']['osm_id']: 
                        ## Now check is elements are disjoint. If disjoint, continue to the next step.
                        if feats_[i]['geometry'].disjoint(feats_[int(endpoint_id)]['geometry'].buffer(tolerance)):
                            continue
                        else:
                            ## If elements are not disjoint, change the properties and add element to the "connected" list.
                            #print "%s CONNECTED" %(feats_[i]['properties']['osm_id'])
                            feats_[i]['properties']['endpoints'] = 15
                            feats_[i]['properties']['connected'] = feats_[select_id]['properties']['osm_id']
                    
            endpoints_list = [j for j, feat in enumerate(feats_) if feat['properties']['endpoints'] > 0]
            to_check = len(endpoints_list)

    return feats_

def check_crossings(feats_1, feats_2, key_bridge, value_bridge, key_tunnel, value_tunnel, props={}, logger=logging):
    """
    locates crossings of all features in list "feats_1" with features in list "feats_2". Result: list of pairs of
    objects from feats_1 and feats_2
    For each crossing, establishes if a data model entry is available to understand the crossing behaviour
    Uses functionality from check_data_model

    initialy selected feature.

    Args:
        feats: list of JSON-type features (with 'geometry' and 'properties')
        select_id={}: id of the selected elemenet for which the connected network will be checked. Is set in ini-file
        tolerance=: tolerance where within elements are assumend to be connected. Is set in ini-file
        check_keys={}: dictionary of keys with datatypes
        logger=logging: reference to logger object for messaging

    Returns:
        feats: list of JSON-type features with 'properties' containing the connected flag (id)
    """
    def _pair_crossings(feats_1, feats_2, buffer=0.0001):
        """
        Determines where features of one set cross with another, using spatial indexing
        """
        crossings = []
        all_feats = feats_1 + feats_2
        end_idx_1 = len(feats_1)  # last index of first feature set
        # make a list of bounding boxes so that we can perform spatial indexing
        lines_bbox = [f['geometry'].buffer(buffer).bounds for f in all_feats]
        tree_idx = rtree.index.Index()
        for i, bbox in enumerate(lines_bbox):
            tree_idx.insert(i, bbox)
        # now go over each feature from feats_1 and check which features of feats_2 it intersects using spatial indexing
        for idx_1 in range(end_idx_1):
            feat_1 = all_feats[idx_1]
            hits = np.array(list(tree_idx.intersection(lines_bbox[idx_1])))
            hits_feats_2 = hits[hits >= end_idx_1]
            for idx_2 in hits_feats_2:
                intersections = [(feat_1, feat_2) for feat_2 in list(np.array(all_feats)[hits_feats_2]) if feat_2['geometry'].intersects(feat_1['geometry'])]
            crossings += intersections
        return crossings

    def _check_dict(props, key, value):
        """
        Checks if feature has a key value pair according to filter
        Returns: True or False
        """
        if key in props.keys():
            f = props[key]
        else:
            return False
        # filter on key/values

        if isinstance(value, str):
            # if value is empty strings, pass all objects of key (unless f return nothing)
            if value == '':
                if f in ['', None, '-1']:
                    return False  # next feat
            # only matching key-value pairs
            else:
                if f != value:
                    return False
        # check against multiple values
        elif isinstance(value, list):
            if f not in value:
                return False
        return True

    def _flag_crossing(pass_1, pass_2, struct_1='bridge', struct_2='tunnel'):
        if pass_1 & pass_2:
            struct = '{:s} and {:s}'.format(struct_1, struct_2)
            flag = 0
        elif pass_1:
            struct = struct_1
            flag = 0
        elif pass_2:
            struct = struct_2
            flag = 0
        else:
            struct = ''
            flag = 1
        return struct, flag

    def _crossings_collection(crossings, key_1, key_2, values_1, values_2, name_1='highway', name_2='waterway', props={}):
        collection = []
        for c in crossings:
            ps = c[0]['geometry'].intersection(c[1]['geometry'])
            if isinstance(ps, shapely.geometry.LineString):
                ps = shapely.geometry.MultiPoint(zip(*ps.xy))
            elif isinstance(ps, shapely.geometry.Point):
                ps = [ps]
            # get all properties together
            props_1 = c[0]['properties']
            props_2 = c[1]['properties']
            pass_2 = _check_dict(props_2, key_2, values_2)
            pass_1 = _check_dict(props_1, key_1, values_1)
            struct, flag = _flag_crossing(pass_1, pass_2)

            props_cross = {'osm_id_{:s}'.format(name_1) : props_1['osm_id'],
                           'osm_id_{:s}'.format(name_2) : props_2['osm_id'],
                           'flag' : flag,
                           'structure' : struct,
                          }
            for prop in props:
                props_cross[prop] = props[prop]
            for n, p in enumerate(ps):
                collection.append(create_feature(p, **props_cross))
        return collection

    crossings = _pair_crossings(feats_1, feats_2)
    return _crossings_collection(crossings, key_bridge, key_tunnel, value_bridge, value_tunnel, props=props)



def write_layer(db, layer_name, data, write_mode='w', format='ESRI Shapefile', schema=None, crs=crs.from_epsg(4326), logger=logging):
    """
    write fiona gis file

    Args:
        db: filename or database
        layer_name: layer name
        data: list of dictionaries with 'geometry' (containing shapely geom) and 'properties' (containing dictionary of attributes)
        write_mode='w': of type 'a' (append) or 'w' (write)
        format='ESRI Shapefile': fiona/gdal driver to use to write
        schema=None: fiona schema for writing, if none, a schema will be attempted to be generated from the first feature in the list
        crs: fiona.crs object (default epsg:4326)

    Returns:
        Nothing, only a written file

    """
    # Define a polygon feature geometry with one attribute
    # prepare properties
    template = data[0]

    # try remove existing file if exists, otherwise fiona dies without warning when writing
    try:
        if write_mode == 'w':
            if os.path.isfile(db):
                os.unlink(db)
                if db.endswith('.shp'):
                    [os.unlink('{}{}'.format(db[:-3], ext)) for ext in ['cpg', 'dbf', 'prj', 'shx']
                     if os.path.isfile('{}{}'.format(db[:-3], ext))]
    except WindowsError, e:
        logger.error(e)
    if schema is None:
        # try to make a schema based upon the first feature in the list of features (should not contain 'None'!)
        props = {}
        for key in template['properties'].keys():
            if isinstance(template['properties'][key], np.generic):
                prop_type = type(np.asscalar(template['properties'][key])).__name__
            else:
                prop_type = type(template['properties'][key]).__name__

            props[key] = prop_type
        schema = {
                  'geometry': type(template['geometry']).__name__,  # ['type']
                  'properties': props,
                  }
    # Write a new Shapefile
    with fiona.open(db, write_mode, format, schema, layer=layer_name, crs=crs) as c:
        for o in data:
            p = o.copy()
            p['geometry'] = shapely.geometry.mapping(p['geometry'])
            c.write(p)
    logger.info('file successfully written to {}'.format(db))
    return


def generate_mesh(fn, bounds, cell_size, fm_exe='dflowfm.exe', logger=logging):
    nrows = int(round((bounds[2]-bounds[0])/cell_size))
    ncols = int(round((bounds[3]-bounds[1])/cell_size))

    cmd_template_mesh = '{:s} --gridgen:x0={:f}:y0={:f}:dx={:f}:dy={:f}:nrows={:d}:ncols={:d}:spherical=0'.format
    cmd = cmd_template_mesh(fm_exe, bounds[0], bounds[1], cell_size, cell_size, ncols, nrows)
    logger.info('Running "{:s}"'.format(cmd))
    mesh_temp_fn = os.path.join(os.curdir, 'out_net.nc')
    os.system(cmd)
    if os.path.isfile(fn):
        os.unlink(fn)
    os.rename(mesh_temp_fn, fn)
    return

def toUTM(shape):
    new_coords = [utm.from_latlon(c[1], c[0])[:2] for c in shape.coords]
    if shape.type == 'LineString':
        return LineString(new_coords)
    elif shape.type == 'Polygon':
        return Polygon(new_coords)
    else:
        raise NotImplementedError('only shapely LineStrings and Polygons have been implemented')

def check_Ftype(ftype, value):
    try:
        v_out = ftype(value)  # parse
        if isinstance(v_out, str):
            v_out = v_out.lower()
    except:
        v_out = None
    return v_out

# ogr input layer to feature table in GDrive
def convert2ft(input_path, output_path, GFT_REFRESH_TOKEN,
               append=False, fix_geometry=False, simplify_geometry=False, start_index=0, layer=0,
               omsconf_ini_fn="osmconf_osm2dh.ini", check_fields=[]):

    field_type_map = {
        int: ogr.OFTInteger,
        float: ogr.OFTReal,
        str: ogr.OFTString
    }

    src_ds = gdal.OpenEx(input_path, open_options=['CONFIG_FILE={}'.format(omsconf_ini_fn)])
    src_lyr = src_ds.GetLayerByIndex(layer)

    # create feature table
    dst_ds = ogr.GetDriverByName('GFT').Open('GFT:refresh=' + GFT_REFRESH_TOKEN, True)

    if append:
        dst_lyr = dst_ds.GetLayerByName(output_path)
    else:
        dst_lyr = dst_ds.CreateLayer(output_path)
        # create fields using OGR
        if len(check_fields) == 0:
            [dst_lyr.CreateField(fd) for fd in src_lyr.schema]
        else:
            for fd in src_lyr.schema:
                if fd.GetName() in check_fields:
                    # check type of this field
                    fd = ogr.FieldDefn(fd.GetName(), field_type_map[check_fields[fd.GetName()]])
                    # create extray "_isempty" field
                    fd_isempty = ogr.FieldDefn(fd.GetName() + '_isempty', ogr.OFTInteger)
                    dst_lyr.CreateField(fd_isempty)
                # create field
                dst_lyr.CreateField(fd)
    index = 0
    batch_size = 250
    index_batch = 0
    for feat in src_lyr:
        if index < start_index:
            index += 1
            continue

        try:
            geom = shapely.wkt.loads(feat.GetGeometryRef().ExportToWkt())
        except Exception as e:
            print('Error({0}), skipping geometry.'.format(e))
            continue

        if fix_geometry and not geom.is_valid:
            geom = geom.buffer(0.0)

        if simplify_geometry:
            geom = geom.simplify(0.004)

        f = ogr.Feature(dst_lyr.GetLayerDefn())

        # set field values
        bad = 0
        for i in range(feat.GetFieldCount()):
            fd = feat.GetFieldDefnRef(i)
            fn = fd.GetName()
            v = feat.GetField(fn)

            # for checked fields only
            if fn in check_fields:
                empty = 0
                if v:
                    try:
                        v1 = check_fields[fn](v)  # parse
                        v = v1
                    except ValueError:
                        bad += 1
                        empty = 1
                    f.SetField(fn, v)
                else:
                    empty = 1
                    # f.SetField(fn, "")
                # set additional "_isempty" field
                f.SetField(fn + "_isempty", empty)
            else:
                if v:
                    f.SetField(fn, v)
                # else:
                #     f.SetField(fn, "")

            # f.SetField(fd.GetName(), feat.GetField(fd.GetName()))

        # set geometry
        f.SetGeometry(ogr.CreateGeometryFromWkt(geom.to_wkt()))

        if index_batch == 0:
            dst_lyr.StartTransaction()

        index_batch = index_batch + 1

        # create feature
        feature = dst_lyr.CreateFeature(f)

        f.Destroy()

        index = index + 1

        if index_batch > batch_size:
            dst_lyr.CommitTransaction()
            print('Inserted {0} features ...'.format(batch_size))

            index_batch = 0

    # src_ds.Destroy()
    src_ds = None
    dst_ds.Destroy()