from decimal import Decimal

import geopandas
import shapely
from rasterio import mask, features, warp
from rasterio.io import MemoryFile
from shapely import ops, wkt
import rasterio
import numpy as np

def read_file_as_gdf(input_file):
    gdf = geopandas.read_file(input_file)
    return gdf

def check_divisibility(dividend, divisor):
    """Checks if the dividend is a multiple of the divisor and outputs a
    boolean value

    Keyword arguments:
    dividend -- the number which is divided
    divisor -- the number which divides
    """
    dividend = Decimal(str(dividend))
    divisor = Decimal(str(divisor))
    remainder = dividend % divisor

    if remainder == Decimal('0'):
        return True
    else:
        return False


def multilinestring_list_to_multilinestring(multilinestring_list):
    """Converts a list of multilinestring objects into a multiline string with
    many linestring objects.

    Keyword arguments:
    multilinestring_list -- list of multilinestring objects. Each
    multilinestring contains only 1 linestring
    """
    linestring_list = []
    for multilinestring in multilinestring_list:
        for linestring in multilinestring:
            linestring_list.append(linestring)
    out_multilinestring = shapely.geometry.MultiLineString(linestring_list)
    return out_multilinestring


def line_merge(multi_line_string):
    """Returns a LineString or MultiLineString representing the merger of all
    contiguous elements of lines.

    Keyword arguments:
    multi_line_string -- list of multilinestring objects. Each
    """
    single_line_string = shapely.ops.linemerge(multi_line_string)  # merged
    return single_line_string


def cut(line, distance):
    # Cuts a line in two at a distance from its starting point
    if distance <= 0.0 or distance >= line.length:
        return [shapely.geometry.LineString(line)]
    coords = list(line.coords)
    for i, p in enumerate(coords):
        pd = line.project(shapely.geometry.Point(p))
        if pd == distance:
            return [
                shapely.geometry.LineString(coords[:i+1]),
                shapely.geometry.LineString(coords[i:])]
        if pd > distance:
            cp = line.interpolate(distance)
            return [
                shapely.geometry.LineString(coords[:i] + [(cp.x, cp.y)]),
                shapely.geometry.LineString([(cp.x, cp.y)] + coords[i:])]


def number_of_segments(linestring, split_length):
    # returns the number of segments which will result from chopping up a
    # linestring with split_length
    divisible = check_divisibility(linestring.length, split_length)
    if divisible:
        n = int(linestring.length/split_length)
    else:
        n = int(linestring.length/split_length)+1
    return n


def split_linestring(linestring, split_length):
    # cuts a linestring in length/split_length number of segments
    n_segments = number_of_segments(linestring, split_length)
    if n_segments != 1:
        result_list = [None]*n_segments
        current_right_linestring = linestring

        for i in range(0, n_segments-1):
            r = cut(current_right_linestring, split_length)
            current_left_linestring = r[0]
            current_right_linestring = r[1]
            result_list[i] = current_left_linestring
            result_list[i+1] = current_right_linestring
    else:
        result_list = [linestring]

    return result_list


def buffer_linestring(linestring, buffer_length):
    # buffers 1 linestring object with flat end caps
    return linestring.buffer(buffer_length, cap_style=2)


def buffer_linestring_list(linestring_list, buffer_length):
    polygon_list = []
    for linestring in linestring_list:
        current_polygon = buffer_linestring(linestring, buffer_length)
        polygon_list.append(current_polygon)
    return polygon_list


def get_gdf_geometry(in_gdf):
    return in_gdf.geometry.tolist()


def set_gdf_geometry(in_gdf, geometry_list):
    in_gdf.geometry = geometry_list
    return in_gdf


def create_blank_gdf():
    return geopandas.GeoDataFrame()


def split_linestring_list(in_linestring_list, split_length):
    out_linestring_list = []
    for linestring in in_linestring_list:
        linestring_segments = split_linestring(linestring, split_length)
        for linestring_segment in linestring_segments:
            out_linestring_list.append(linestring_segment)
    return out_linestring_list


def extract_by_mask(raster_dataset, geometry, all_touched=False):
    # outputs a numpy masked array with values within polygon geometry
    geometry = [shapely.geometry.mapping(geometry)]
    m = mask.mask(dataset=raster_dataset, shapes=geometry, filled=False, all_touched=all_touched)
    return m[0]


def compute_statistic(masked_array, statistic):
    # statistic can be one of mean, max and min
    method = getattr(masked_array, statistic)
    return float(method())


def compute_statistic_list(geometry_list, raster_dataset, statistic):
    stat_list = []
    for geometry in geometry_list:
        masked_array = extract_by_mask(raster_dataset, geometry)[0]
        current_stat = compute_statistic(masked_array, statistic)
        stat_list.append(current_stat)
    return stat_list

def explode_linestring(linestring):
    out_list = []
    for i in range(len(linestring.coords)-1):
        x1 = linestring.coords[i][0]
        y1 = linestring.coords[i][1]
        x2 = linestring.coords[i+1][0]
        y2 = linestring.coords[i+1][1]
        new_linestring = shapely.geometry.LineString([(x1, y1), (x2, y2)])
        out_list.append(new_linestring)
    return out_list

def explode_linestring_list(linestring_list):
    out_list = []
    for linestring in linestring_list:
        exploded_sublist = explode_linestring(linestring)
        for item in exploded_sublist:
            out_list.append(item)

    return out_list


def polygonize_raster(dataset):

    # Read the dataset's valid data mask as a ndarray. Dataset is a rasterio read object open for reading
    mask = dataset.dataset_mask()

    array = dataset.read(1)
    generator = rasterio.features.shapes(source=array, mask=mask, transform=dataset.transform)
    # Extract feature shapes and values from the array
    geom_list = []
    for geom, value in generator:
        # Print GeoJSON shapes to stdout
        geom = shapely.geometry.shape(geom)
        geom_list.append(geom)

    return geom_list

def extract_polygon_by_mask(template_dataset, linestring):
    profile = template_dataset.profile
    extracted = extract_by_mask(template_dataset, linestring, all_touched=True)
    extracted_uniqified = uniqify_masked_array(extracted)
    extracted_filled = fill_masked_array(extracted_uniqified)
    heterogeneous_dataset = open_memory_file(extracted_filled[0], profile=profile)
    polygon_list = polygonize_raster(heterogeneous_dataset)
    heterogeneous_dataset.close()
    return polygon_list
def open_memory_file(data, west_bound=0, north_bound=2, cellsize=0.5, nodata=-9999, driver='AAIGrid', profile=None):
    memfile = MemoryFile()
    if profile==None:
        #data is a numpy array
        dtype = data.dtype
        shape = data.shape
        transform = rasterio.transform.from_origin(west_bound, north_bound, cellsize, cellsize)
        dataset = memfile.open(driver=driver, width= shape[1], height = shape[0], transform=transform, count=1, dtype=dtype, nodata=nodata)
    else:
        dataset = memfile.open(**profile)

    dataset.write(data,1)
    dataset.close()
    dataset = rasterio.open(dataset.name)
    return dataset

def get_raster_cell_size(dataset):
    transform = dataset.transform
    pixel_size_X = transform[0]
    pixel_size_Y = -transform[4]
    return pixel_size_X

def calc_length_in_cell(polygon_geom, linestring_geom):
    length = linestring_geom.intersection(polygon_geom).length
    return length
def calc_length_in_cell_list(polygon_geom_list, multilinestring):
    #loops through all polygon geometries, calculates cell length inside and returns list with all lengths
    lengths = []
    for i,polygon_geom in enumerate(polygon_geom_list):
        lengths.append(calc_length_in_cell(polygon_geom, multilinestring))
    return lengths

def open_raster_file(filename,data, profile):
    dataset = rasterio.open(filename, 'w', **profile)
    dataset.write(data,1)
    dataset.close()
    dataset = rasterio.open(dataset.name)
    return dataset
def read_raster_file(filename):
    dataset = rasterio.open(filename)
    return dataset
def fill_masked_array(masked_array):
    #dataset must have write permissions
    filled_array = masked_array.filled()
    return filled_array

def get_dataset_profile(dataset):
    profile = dataset.profile
    return profile

def open_physical_file(data, filename, profile):
    dataset = rasterio.open(filename, 'w', **profile)
    dataset.write(data,1)
    dataset.close()
    dataset = rasterio.open(dataset.name)
    return dataset
def uniqify(in_array):
    #warning: array is mutable and gets modified outside this scope
    out_array = np.arange(in_array.size).reshape(in_array.shape)
    return out_array.astype(np.float32)

def uniqify_masked_array(masked_array):

    data = np.ma.getdata(masked_array)
    mask = np.ma.getmask(masked_array)
    fill_value = masked_array.fill_value
    uniqified_data = uniqify(data)
    new_mask = np.ma.masked_array(uniqified_data, mask)
    np.ma.set_fill_value(new_mask, fill_value)
    return new_mask


def rasterize(template_dataset, polygon_list, length_list):
    content = template_dataset.read(1)
    transform = template_dataset.transform

    geometry_value_pairs = []

    for i, item in enumerate(length_list):
        geom = polygon_list[i]
        value = length_list[i]
        geometry_value_pairs.append((geom, value))

    rasterized = rasterio.features.rasterize(geometry_value_pairs, out_shape=content.shape, transform=transform,
                                             fill=template_dataset.nodata)

    return rasterized

#def split_by_attribute(in_gdf, attribute_name):

gdf = create_blank_gdf()