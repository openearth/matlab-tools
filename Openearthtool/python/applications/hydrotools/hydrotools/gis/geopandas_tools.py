# -*- coding: utf-8 -*-
"""
library with functions to edit and perform spatial analysis on vector data.
build around shapely and fiona libraries

Created on 2016-July-16
@author: Dirk Eilander (dirk.eilander@deltares.nl)

$Id: geopandas_tools.py 207 2016-08-04 04:15:21Z eilan_dk $
$Date: 2016-08-04 11:15:21 +0700 (Thu, 04 Aug 2016) $
$Author: eilan_dk $
$Revision: 207 $
$HeadURL: https://repos.deltares.nl/repos/peat/trunk/lidar-waterlevel/geopandas_tools.py $
$Keywords: $

"""

import geopandas as gpd
import shapely_tools as st
import geojson
import json
from fiona import collection
from shapely.geometry import shape


# I/O
def read_file(fn, bbox=None):
    """
    reads to shapely geometries to geopandas geodataframe and remove rows with possible missing geometries
    """
    with collection(fn, "r") as c:
        geometry = []
        attributes = []
        crs = c.crs['init']
        c = c.items(bbox=bbox)
        for ft in c:
            if ft[1]['geometry'] is not None:
                geometry.append(shape(ft[1]['geometry']))
                attributes.append(ft[1]['properties'])
    return gpd.geodataframe.GeoDataFrame(geometry=geometry, data=attributes, crs=crs)


def to_geojson(fn, gdf, attr_names=None, epsg='32748'):
    """writes a list of features to a geojson as a featurecollection"""

    # slim attribute table
    if attr_names is not None:
        gdf = gpd.geodataframe.GeoDataFrame(data=gdf[attr_names], geometry=gdf.geometry)

    # first to json format, than to geojson
    js = json.loads(gdf.to_json())
    # epsg = gdf.crs.values()[0].split(':')[-1]
    crs = geojson.crs.Named(properties={"name": "urn:ogc:def:crs:EPSG::{}".format(epsg)})
    fcol = geojson.FeatureCollection(js['features'], crs=crs)

    # write file
    with open(fn, 'w') as f:
        geojson.dump(fcol, f)


# add property methods
def add_length_attribute(gdf, length_name='length'):
    """add length value to property table"""
    gdf[length_name] = gdf.geometry.length
    return gdf


def add_index_attribute(gdf, index_name='ID'):
    """add length value to property table"""
    gdf[index_name] = gdf.index
    return gdf


def attributes_sjoin(gdf_in, gdf_sample, idmapping, function='within'):
    """set property values based on values of geospatially related features

    :param ft_list:         feature list to be updated
    :param ft_list_sample:  feature list property values from
    :param idmapping:       dictionary with idmapping between ft_lis and ft_list_sample
    :param function:        sting with name of shapely binary predicates to define spatial relation,
                            options are: 'within', 'contains', 'crosses', 'disjoint', 'equals', 'intersects', 'touches'
                            see: http://toblerity.org/shapely/manual.html#binary-predicates
    :return:                updated feature list
    """
    gdf_out = gdf_in.copy()
    index = st.index_spatial_join(gdf_in.geometry.tolist(), gdf_sample.geometry.tolist(), function=function)

    for name in idmapping:
        gdf_out[name] = return_attribute_with_index_geometry(gdf_sample, index, idmapping[name])

    return gdf_out


# simplify, reduce and merge  geometries methods
def simplify(gdf, tolerance, preserve_topology=True):
    gdf_out = gdf.copy()
    gdf_out[gdf.geometry.name] = gdf.geometry.simplify(tolerance=tolerance, preserve_topology=preserve_topology)
    return gdf_out


def linemerge(gdf):
    geometry, index = st.linemerge(gdf.geometry.tolist(), return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, [geom for geom in geometry])


def extend_lines_min_length(gdf, min_length=99, tolerance=1e-7, simplify_tolerance=None):
    gdf_out = gdf.copy()
    gdf_out[gdf.geometry.name] = st.extend_lines_min_length(gdf.geometry.tolist(), min_length=min_length,
                                                            tolerance=tolerance)
    if simplify_tolerance is not None:
        gdf_out[gdf.geometry.name] = gdf_out.geometry.simplify(simplify_tolerance)
    return gdf_out


def polygon_union(gdf):
    geometry, index = st.polygon_union(gdf.geometry.tolist(), return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, [geom for geom in geometry])


def one_linestring_per_intersection(gdf):
    geometry, index = st.one_linestring_per_intersection(gdf.geometry.tolist(), return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


# snapping methods
def snap_endings(gdf, max_dist):
    gdf_out = gdf.copy()
    gdf_out[gdf.geometry.name] = st.snap_endings(gdf.geometry.tolist(), max_dist=max_dist)
    return gdf_out


def snap_lines(gdf, max_dist):
    geometry, index = st.snap_lines(gdf.geometry.tolist(), max_dist=max_dist, return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


def snap_points2geometries(gdf, geometries, max_dist):
    geometry, index = st.snap_points2geometries(gdf.geometry.tolist(), geometries, max_dist=max_dist, return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


# clipping / split methods
def clip_lines_with_polygon(gdf, polygon, tolerance=1e-8, within=True):
    geometry, index = st.clip_lines_with_polygon(gdf.geometry.tolist(), polygon,
                                                 tolerance=tolerance, within=within, return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


def offset_and_clip(gdf, offset_dist=30, buffer_dist=29.9, side='both', join_style=2):
    """offset lines, but clip where these lines are within buffer distance of other lines"""
    # calc buffer around lines
    gdf = gdf.copy()
    lines = gdf.geometry.tolist()
    cbuffer = st.polygon_union([c.buffer(buffer_dist, join_style=join_style) for c in lines])

    if side == 'both':
        sides = ['left', 'right']
    else:
        sides = [side]

    gdf_out = []
    for s in sides:
        # offset canal lines
        gdf['geometry'] = [c.parallel_offset(offset_dist, s, join_style=join_style) for c in lines]
        #clip lines outside canal buffer
        gdf_out.append(clip_lines_with_polygon(gdf, cbuffer, within=False))

    if side == 'both':
        return gdf_out[0], gdf_out[1]
    else:
        return gdf_out[0]


def split_lines_point(gdf, point, tolerance=1e-8):
    geometry, index = st.split_lines_point(gdf.geometry.tolist(), point=point, tolerance=tolerance, return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


def split_lines_points(gdf, point_list, tolerance=1e-8):
    geometry, index = st.split_lines_points(gdf.geometry.tolist(), point_list=point_list,
                                            tolerance=tolerance, return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


def split_lines_angle(gdf, split_angle=90):
    geometry, index = st.split_lines_angle(gdf.geometry.tolist(), split_angle=split_angle, return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


def explode_lines(gdf, length, min_length, equal_length=False, remove_too_small=False, simplify_tolerance=None):
    geometry, index = st.explode_lines(gdf.geometry.tolist(), length=length, min_length=min_length,
                                       equal_length=equal_length, remove_too_small=remove_too_small, return_index=True)
    gdf_out = reconstruct_gdf_with_index_geometry(gdf, index, geometry)
    if simplify_tolerance is not None:
        gdf_out[gdf.geometry.name] = gdf_out.geometry.simplify(simplify_tolerance)
    return gdf_out




def explode_polygons(gdf):
    geometry, index = st.explode_polygons(gdf.geometry.tolist(), return_index=True)
    return reconstruct_gdf_with_index_geometry(gdf, index, geometry)


def add_nodes(gdf, point_list, tolerance=1e-8):
    gdf_out = gdf.copy()
    gdf_out[gdf.geometry.name] = st.add_nodes(gdf.geometry.tolist(), point_list=point_list, tolerance=tolerance)
    return gdf_out


# create a grid shapefile
def create_rect_grid(bound_coords, cell_sizes=[1.0,1.0], overlaps=[0,0], int_vector=None):
    """
    Creates a grid geopandas dataframe which can be exported to shape  / geojson.

    Input:
    - list of bounding coordinates (lon_start, lon_end, lat_start, lat_end)
    - list of cell sizes (dx, dy, in degrees)
    - list of overlap size (dx_overlap, dy_overlap)
    - list of shapely objects on which the grid is filtered based on spatial intersection (optional)

    Output:
    - rectangular grid (geopandas)
    """
    # get bounding coordinates:
    lon_start  = bound_coords[0]
    lon_end    = bound_coords[1]
    lat_start  = bound_coords[2]
    lat_end    = bound_coords[3]

    # get cell sizes and overlap
    dx         = cell_sizes[0]
    dy         = cell_sizes[1]
    dx_overlap = overlaps[0]
    dy_overlap = overlaps[1]

    # create list of rectangular polygons
    geoms = []
    props = []
    i = 0
    lon        = lon_start + dx/2.
    while lon < lon_end:
        x1   = lon - dx/2. - dx_overlap
        x2   = lon + dx/2. + dx_overlap
        lon += dx
        lat  = lat_start + dy/2.
        while lat < lat_end:
            y1   = lat - dy/2. - dy_overlap
            y2   = lat + dy/2. + dy_overlap
            lat += dy
            poly = Polygon([(x1, y1), (x1, y2), (x2, y2), (x2, y1)])


            # write feature
            if int_vector is not None:
                for vector in int_vector:
                    if poly.intersects(vector):
                        i += 1
                        dictarr.append(ft)
                        geoms.append(poly)
                        props.append({'id': i})
                        break
            else:
                i += 1
                geoms.append(poly)
                props.append({'id': i})

    return GeoDataFrame(geometry=geoms, data=props)

# utils
def reconstruct_gdf_with_index_geometry(gdf, index, geometry):
    attr_names = [c for c in gdf.columns if c != gdf.geometry.name]
    # attributes = [{c: gdf[c].iloc[ind] for c in attr_names} if not type(ind) == list  # integer index 1:1 relations
    #               else {c: gdf[c].iloc[ind].values.tolist() for c in attr_names} if len(ind) > 1  # list index 1:n rel.
    #               else {c: gdf[c].iloc[ind[0]] for c in attr_names}  # list index 1:1 relation
    #               for ind in index]
    attributes = return_attributes_with_index_geometry(gdf, index, attr_names)
    if not type(geometry) is list:
        geometry = [geometry]
    return gpd.geodataframe.GeoDataFrame(geometry=geometry, data=attributes, crs=gdf.crs)


def return_attributes_with_index_geometry(gdf, index, attr_names):
    return [{c: gdf[c].iloc[ind] for c in attr_names} if not type(ind) == list  # integer index 1:1 relations
            else {c: gdf[c].iloc[ind].values.tolist() for c in attr_names} if len(ind) > 1  # 1:n relations
            else {c: "" for c in attr_names} if len(ind) == 0
            else {c: gdf[c].iloc[ind[0]] for c in attr_names}  # list index 1:1 relation
            for ind in index]


def return_attribute_with_index_geometry(gdf, index, attr_name):
    return [gdf[attr_name].iloc[ind] if not type(ind) == list  # integer index 1:1 relations
            else gdf[attr_name].iloc[ind].values.tolist() if len(ind) > 1  # 1:n relations
            else "" if len(ind) == 0
            else gdf[attr_name].iloc[ind[0]]  # list index 1:1 relation
            for ind in index]
