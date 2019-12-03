
# coding: utf-8

# In[1]:

import os
import numpy as np
import shapely
import fiona
import shutil
from shapely.geometry import LineString, MultiLineString
# import local libraries
import osm2dh
import shapely_tools as st
import DFlowFM_tools as df
from DFlowFM_tools import BoundaryCondition, Channel


# [GENERAL]
# Model name
name = "SanJuan"
# path to save file
osm_fn = r"d:\temp\SanJuan\OSM\SanJuan_bbox.db"
# path to read bbox
fn_bbox = r"d:\temp\SanJuan\bbox_utm19N.geosjon"  # should be in UTM!
# output path to save model files to
path_out = r"d:\temp\SanJuan\DFM_data"
# dtm
dtm_fn = r"d:\temp\SanJuan\DTM\dem_smoothed_wRoads001m_UTM19N.tif"
# output crs based on epsg
crs = fiona.crs.from_epsg(32619)  # osm data is converted shapefiles are not!

# [SINK SOURCES]
# key / value pair to select OSM features
key = 'highway'
values = ''  # an empty string means all the highway features will be selected
# boundary type
bnd_type = "discharge_salinity_temperature_sorsin"
# a polygon with areas for which specific discharge boundaries are set
bnd_areas_fn = r"d:\temp\SanJuan\sinksources_areas.shp"
# mapping from <id> in boundaries shapefile to tim sink source files
bnd_fn_mapping = {1: r"d:\temp\SanJuan\vanDidrik\SourceSink01.tim",
                  2: r"d:\temp\SanJuan\vanDidrik\SourceSink02.tim",
                  3: r"d:\temp\SanJuan\vanDidrik\SourceSink03.tim"}

# [CHANNELS]
channel_fn = r"d:\temp\SanJuan\OSM\channel_expresoRoad_utm19N.shp" # should be in UTM!
depth = 2
width = 1
proftype = 2  # only proftype supported?

# main functions
def sinksatcrossings(osm_fn,
                     bnd_ft, bnd_type, bnd_method=1,
                     key='highway', values='',  # osm key value pair
                     min_spacing=50.,
                     bbox=None, layer_index=1, check_fields={},
                     logger=None, **kwargs):
    """"""
    # filter features from OSM
    all_features = osm2dh.filter_features(osm_fn, check_fields=check_fields, bbox=bbox, key=key, value=values,
                                          layer_index=layer_index, logger=logger)
    nft = len(all_features)
    print("{:d} streets found".format(nft))

    # find intersections
    street_geoms = [feat['geometry'] for feat in all_features]
    int_points = st.intersection_points(street_geoms, min_spacing=min_spacing)
    npnts = len(int_points)
    index = np.arange(npnts)+1

    objects = []
    for i, pnt in zip(index, int_points):
        # check if feature is completely outside domain (if so, discard)
        if bbox is not None:
            outside_bbox = bbox.disjoint(pnt)
            if outside_bbox:
                continue

        # check if in one of the ares define in bnd_ft
        bnd_fn = [ft['properties']['bnd_fn'] for ft in bnd_ft if not ft['geometry'].disjoint(pnt)]
        # if outside all features, continue
        if len(bnd_fn) == 0:
            continue
        else:
            bnd_fn = bnd_fn[0]  # take first if multiple

        # create bnd cond.
        ids = "{:04d}".format(i)  # start counting at 1
        sname = "SourceSink{}".format(ids)
        objects.append(BoundaryCondition(geom=pnt, ids=ids, sname=sname,
                                         bound_type=bnd_type, bound_fn=bnd_fn, bound_method=bnd_method))
    print("{:d} sink sources created".format(len(objects)))

    return objects


def osm2channel(channel_shp, dtm_fn,
                depth, width, proftype=2,
                bnd_fn='', bnd_type='discharge',
                max_snap_dist=5,
                bbox=None, bbox_buffer = 5,
                logger=None, **kwargs):

    geoms = st.read_geometries(channel_shp)
    print("{:d} featured read from {}".format(len(geoms), channel_shp))

    # clip lines within bbox
    if bbox is not None:
        geoms = st.clip_lines_with_polygon(geoms, bbox.buffer(bbox_buffer))

    # snap lines and find indices of edited geometries
    geoms_snapped = st.snap_lines(geoms, max_dist=max_snap_dist)
    # TODO: merging does not work properly!
    geoms_merged = shapely.ops.linemerge(geoms_snapped)
    if isinstance(geoms_merged, LineString):
        geoms_merged = [geoms_merged]
    elif isinstance(geoms_merged, MultiLineString):
        geoms_merged = [g for g in geoms_merged]

    channel_objects, boundary_objects = [], []
    for i, geom in enumerate(geoms_merged):
        # create 1d elements
        ids = "{:04d}".format(i+1)
        o = Channel(geom=geom, ids=ids, dtm_fn=dtm_fn, depth=depth, width=width, proftype=proftype, profnr=i+1)
        channel_objects.append(o)

        # create boundary conditions for line object if it crosses the bbox
        if bbox is not None:
            bnds = o.create_boundary_condition(bnd_type=bnd_type, bnd_fn=bnd_fn, bbox=bbox)
            for bnd in bnds:  # can be multiple, always list
                boundary_objects.append(bnd)

    print("{:d} channels created".format(len(channel_objects)))
    print("{:d} boundary conditions created".format(len(boundary_objects)))

    return channel_objects, boundary_objects


# Utils
def clean_dir(path):
    if os.path.exists(path):
        shutil.rmtree(path)
    os.mkdir(path)


def rm_file(filename):
    try:
        os.remove(filename)
    except OSError:
        pass

# start of work
if __name__ == "__main__":
    # paths admin
    dfm_path = os.path.join(path_out, "fm_model")
    gis_path = os.path.join(path_out, "gis_model")
    bnd_path = os.path.join(dfm_path, "bnd_files")
    clean_dir(path_out)
    clean_dir(gis_path)
    clean_dir(dfm_path)
    clean_dir(bnd_path)
    # some FM file names
    channel_pli_fn = os.path.join(dfm_path, "{}_channels.pli".format(name))
    channel_lbd_fn = os.path.join(dfm_path, "{}_channels.lbd".format(name))
    channel_dtm_xyz_fn = os.path.join(dfm_path, "{}_channels_dtm.xyz".format(name))
    channel_profdef_txt_fn = os.path.join(dfm_path, "{}_channels_profdef.txt".format(name))
    channel_profloc_xyz_fn = os.path.join(dfm_path, "{}_channels_profloc.xyz".format(name))

    # read bbox
    assert os.path.exists(fn_bbox), "invalid path to bounding box {}".format(fn_bbox)
    domain = df.read_layer(fn_bbox)[0]['geometry']

    # boundary areas polygon and map tim fn to areas
    n_missing_tim_fn = np.sum([os.path.exists(bnd_fn_mapping[id]) == False for id in bnd_fn_mapping])
    assert n_missing_tim_fn == 0, "one or more *.tim files not found, check 'bnd_fn_mapping' setting"
    bnd_ft = df.read_layer(bnd_areas_fn)
    for ft in bnd_ft:
        ft['properties']['bnd_fn'] = bnd_fn_mapping[ft['properties']['id']]

    # SINK SOURCES
    sink_ojbects = sinksatcrossings(osm_fn, bnd_ft, bnd_type, bnd_method=3,
                                    key=key, values=values, bbox=domain, layer_index=1)
    # save FM files
    forcing_file = os.path.join(dfm_path, "{}_forcing.ext".format(name))
    [o.to_dh(forcing_file, bnd_path, append=True) for o in sink_ojbects]
    # save to shapefile
    sink_ojbects_features = [c.feature() for c in sink_ojbects]
    df.write_layer(os.path.join(gis_path, 'sink_sources.shp'), 'sink_sources', sink_ojbects_features, write_mode='w', crs=crs)

    # CHANNEL OBJECTS
    channel_objects, boundary_objects = osm2channel(channel_fn, dtm_fn,
                                                    depth, width, proftype=proftype,
                                                    bbox=domain)
    # save channel locations and write to shapefile
    [o.to_dh(channel_pli_fn, channel_lbd_fn, channel_dtm_xyz_fn, append=True)
     for o in channel_objects]
    channel_features = [c.feature() for c in channel_objects]
    df.write_layer(os.path.join(gis_path, 'channels.shp'), 'channels', channel_features,
                   write_mode='w', crs=crs)
    # save channel profile definitions and write to shapefile
    [o.profile_definition.to_dh(channel_profdef_txt_fn, channel_profloc_xyz_fn, append=True)
     for o in channel_objects]
    profile_features = [c.profile_definition.feature() for c in channel_objects]
    df.write_layer(os.path.join(gis_path, 'profiles.shp'), 'profiles', profile_features,
                   write_mode='w', crs=crs)
    # append boundary conditions dh files and write to shapefile
    if len(boundary_objects) > 0:
        [o.to_dh(forcing_file, bnd_path, append=True) for o in boundary_objects]
        bnd_cnd_features = [c.feature() for c in boundary_objects]
        df.write_layer(os.path.join(gis_path, 'channel_bnds.shp'), 'channel_bnds', bnd_cnd_features,
                           write_mode='w', crs=crs)

