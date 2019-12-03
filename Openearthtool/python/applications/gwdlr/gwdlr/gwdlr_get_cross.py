
# coding: utf-8

## Convert Yamazaki 0.025 degree width data to shapefile lines

# In this notebook, we convert the Yamazaki database (gridded) to a shapefile, which can be used in hydraulic models. We will establish a line shapefile consisting of segments. Segments are opened at the outlet, and closed at the first split between 2 (or more) upstream segments. This will be branched until the most upstream cell is found.
# 
# Then we will add the average width, slope to the lines.
# 
# In a separate ipynb, the point shapefile with widths will be prepared.
# 

# In[40]:

from gdal_readmap import gdal_readmap
from osgeo import gdal, ogr
import pdb
import numpy as np
import os

def cut_area(src_arrays, centre, window):
    """
    Function returns a limited array from src array along with the idx axes for y and x coordinates
    src_arrays: list of arrays from which to cut    
    centre: (y, x) coordinate of centre point
    window: size of window to use around the centre point
    
    """
    xmin = np.maximum(centre[1] - window, 0)
    xmax = np.minimum(centre[1] + window + 1, src_arrays[0].shape[1])
    ymin = np.maximum(centre[0] - window, 0)
    ymax = np.minimum(centre[0] + window + 1, src_arrays[0].shape[0])
    
    # now cut the array
    trg_arrays = []
    for src_array in src_arrays:
        trg_arrays.append(src_array[ymin:ymax, xmin:xmax])
    x_idx_cut = range(xmin, xmax)
    y_idx_cut = range(ymin, ymax)
    return trg_arrays, x_idx_cut, y_idx_cut
    
def distance_on_unit_sphere(lat1, long1, lat2, long2, radius=6371000):
    # Convert latitude and longitude to 
    # spherical coordinates in radians.
    degrees_to_radians = np.pi/180.0
        
    # phi = 90 - latitude
    phi1 = (90.0 - lat1)*degrees_to_radians
    phi2 = (90.0 - lat2)*degrees_to_radians
        
    # theta = longitude
    theta1 = long1*degrees_to_radians
    theta2 = long2*degrees_to_radians
        
    # Compute spherical distance from spherical coordinates.
        
    # For two locations in spherical coordinates 
    # (1, theta, phi) and (1, theta, phi)
    # cosine( arc length ) = 
    #    sin phi sin phi' cos(theta-theta') + cos phi cos phi'
    # distance = rho * arc length
    
    cos = (np.sin(phi1)*np.sin(phi2)*np.cos(theta1 - theta2) + 
           np.cos(phi1)*np.cos(phi2))
    arc = np.arccos( cos )

    # Remember to multiply arc by the radius of the earth 
    # in your favorite set of units to get length.
    return arc * radius   


    
def find_upstream(nextx, nexty, x, y, x_idx, y_idx):
    # look for upstream cells
    (nextx_cut, nexty_cut), x_idx_cut, y_idx_cut = cut_area([nextx, nexty], (y_idx, x_idx), 20)
    y_up_idx_cut, x_up_idx_cut = np.where(np.logical_and(nextx_cut==x, nexty_cut==y))
    #pdb.set_trace()
    y_up_idx = np.atleast_1d(np.array(y_idx_cut)[y_up_idx_cut])
    x_up_idx = np.atleast_1d(np.array(x_idx_cut)[x_up_idx_cut])
    #pdb.set_trace()
    # save old sink cell
    up_sinkcell = [(m, n) for m, n in zip(x_up_idx, y_up_idx)]
    return up_sinkcell

def find_upstream_all(nextx, nexty, x, y):
    # look for upstream cells
    y_up_idx, x_up_idx = np.where(np.logical_and(nextx==x, nexty==y))
    # save old sink cell
    up_sinkcell = [(m, n) for m, n in zip(x_up_idx, y_up_idx)]
    return up_sinkcell

def add_profile(layer_point, lon_point, lat_point, riv_width, riv_depth):
    point_latlon = ogr.Geometry(type=ogr.wkbPoint)
    point_latlon.SetPoint(0, np.float64(lon_point), np.float64(lat_point))
    feature_point_latlon = ogr.Feature(layer_point.GetLayerDefn())
    feature_point_latlon.SetGeometryDirectly(point_latlon)
    # write the attributes to the current feature
    #pdb.set_trace()
    feature_point_latlon.SetField('WIDTH', np.float64(riv_width))
    feature_point_latlon.SetField('DEPTH', np.float64(riv_depth))
    layer_point.CreateFeature(feature_point_latlon)
    return layer_point

def segment_to_vertex(layer_line, layer_point, max_prof_distance, x_cell_nr,
                      y_cell_nr, nextx, nexty, uparea, rivwth,
                      dem, lon, lat, sinkcell, up_sinkcell, id, depth,
                      min_upstream, min_width, total_const, QdivUp=7.e-8):
    """
    Function searches from a sink cell and maps the upstream points flowing towards the sink cell
    until it finds a split to more than one stream. When it does, it will write the found cells to a 
    shape vertex and start mapping the more upstream vertices.
    Input:
        layer_line: shape line layer
        x_cell_nr: count of x axis
        y_cell_nr: count of y axis
        nextx: map (numpy array 2D) with nextx values
        nexty: map (numpy array 2D) with nexty values
        uparea: map (numpy array 2D) with upstream area values
        rivwth: map (numpy array 2D) with river width values
        lon: map (numpy array 2D) with longitude coordinates of outflow point within cell
        lat: map (numpy array 2D) with latitude coordinates of outflow point within cell
        sinkcell: cell from which upstream cells are sought (x, y)
        up_sinkcell: list of tuples with upstream cells, always starting with one upstream cell (x, y)
        id: name of current vertex
        depth: depth of function call
        min_upstream: minimum upstream area to consider a cell! (e.g. 2500 km --> 2500e6.)
    """
        # we are going to add a geomorphological relationship to estimate the bank full depth from Hey and Thorne (1986)
        # Full reference:
        # Hey, R. D., and C. R. Thorne (1986), Stable channels with mobile gravel 
        #     beds, J. Hydraul. Eng., 112(8), 671–689    
        #
        # rule used in this paper is from Neal et al. (2012).
        #
        #        c
        # d = -------- w**(f/b) = r*w**p
        #     a**(f/b)
        # 
        # where d is bank full depth, w is width and all others are coefficients from Hey et al.
        
    r = 0.12
    p = 0.78
    
    # Create a new line geometry for river segment, until more than one upstream cell is found
    depth += 1
    # start with a dummy elevation of non-existing upstream cell
    
    print('Function depth: {:d}').format(depth)
    print('Writing line element "{:d}"').format(id)
    line = ogr.Geometry(type=ogr.wkbLineString)
    x_idx = sinkcell[0]
    y_idx = sinkcell[1]

    # add points sequentially to line segment
    line.AddPoint(np.float64(lon[y_idx, x_idx]), np.float64(lat[y_idx, x_idx]))  # x, y
    riv_width =  rivwth[y_idx, x_idx]
    
    elevation = dem[y_idx, x_idx]
    lon_point = lon[y_idx, x_idx]
    lat_point = lat[y_idx, x_idx]
    #layer_point = add_profile(layer_point, lon_point, lat_point, riv_width)

    # save the values
    riv_width_old = riv_width
    elevation_old = elevation
    lon_old = lon_point
    lat_old = lat_point
    
    cell_amount = 0.
    riv_width_total = 0.
    profile_distance = 0.
    while len(up_sinkcell) == 1:
        x_idx = up_sinkcell[0][0]
        y_idx = up_sinkcell[0][1]
        riv_width = rivwth[y_idx, x_idx]
        
        elevation = dem[y_idx, x_idx]
        width_av = np.mean((riv_width, riv_width_old))
        lon_point = lon[y_idx, x_idx]
        lat_point = lat[y_idx, x_idx]
        distance = distance_on_unit_sphere(lat_point, lon_point, lat_old, lon_old)
        slope = np.maximum((elevation - elevation_old)/distance, 0.001)
        upstream = uparea[y_idx, x_idx]
        
        if riv_width < min_width:
            # width is too small to be reliable or even unknown (value = 0)
            # use geomorphological law to estimate the width from downstream point
            Q0375 = (QdivUp * upstream)**0.375
            riv_width = total_const*slope**(-.1875)*Q0375
        else:
            # compute Q**0.375 if needed for next segment
            QdivUp = ((width_av/(total_const*slope**(-0.1875)))**(1./0.375))/upstream
        # compute bank full depth using Hey et al. (1986)
        riv_depth = r*riv_width**p
        # TO-DO compute river width by inversing manning using the Q of Beck et al. (2013)
        
        riv_width_total += riv_width    
        cell_amount += 1
        profile_distance += 1  # add one profile distance to total
        if profile_distance >= max_prof_distance:
            layer_point = add_profile(layer_point, lon_point, lat_point, riv_width, riv_depth)
            profile_distance = 0.
        line.AddPoint(np.float64(lon[y_idx, x_idx]), np.float64(lat[y_idx, x_idx]))  # x, y
        # save old sink cell
        sinkcell = up_sinkcell[0]
        # look for upstream cells
        up_sinkcell_total = find_upstream(nextx, nexty, x_cell_nr[x_idx], y_cell_nr[y_idx], x_idx, y_idx)
        up_sinkcell = []
        for up_sinkcell_point in up_sinkcell_total:
#            if np.logical_and(uparea[up_sinkcell_point[1], up_sinkcell_point[0]] > min_upstream,
#                              rivwth[up_sinkcell_point[1], up_sinkcell_point[0]] > min_width):
            if uparea[up_sinkcell_point[1], up_sinkcell_point[0]] > min_upstream:
                up_sinkcell.append(up_sinkcell_point)
    # Add line as a new feature to the shapefiles
    feature = ogr.Feature(feature_def=layer_line.GetLayerDefn())
    feature.SetGeometryDirectly(line)
    feature.SetField('RIVER_ID', int(id))
    feature.SetField('WIDTH', riv_width_total/cell_amount)
    feature.SetField('WTH_PLOT', np.maximum(np.minimum(riv_width_total/(cell_amount*1000), 10.), 0.1))
    id += 1
    # TO-DO: also add average width, depth here
    layer_line.CreateFeature(feature)
    # Cleanup
    feature.Destroy()
    # now loop over the new set of upstream cells if they are larger than 1, if smaller, return
    if len(up_sinkcell) > 1:
        up_sinkcell_new = up_sinkcell
        sinkcell_new = sinkcell
#        while n < len(up_sinkcell_new):
#            up_sink_new = up_sinkcell_new[n]
        for n, up_sink_new in enumerate(up_sinkcell_new):
#            if id==13:
#                pdb.set_trace()
            layer_line, id, depth = segment_to_vertex(layer_line, layer_point,
                                                      max_prof_distance, x_cell_nr,
                                                      y_cell_nr, nextx, nexty,
                                                      uparea, rivwth, dem, lon, lat,
                                                      sinkcell_new,
                                                      [up_sink_new], id, depth,
                                                      min_upstream, min_width,
                                                      total_const, QdivUp=QdivUp)
            n += 1
    #else:
    # no upstream cells found, so return!
    print('Function depth: {:d}').format(depth)
    depth -= 1
    return layer_line, id, depth


SHP_FILENAME = 'glob_rivwdt_line_10km.shp'
SHP_POINT_FILENAME = 'glob_rivwdth_point_10km.shp'
min_catch = 1e11  # minimum upstream area of river should be 100,000 km2 for starters
min_upstream = 10000e6  # minimum upstream area to take a pixel into account
min_width = 200
max_prof_distance = 5
src_folder = r'd:\data\GlobalWidthDatabase\data'
nextx_file = os.path.join(src_folder, 'next_x.tif')
nexty_file = os.path.join(src_folder, 'next_y.tif')
rivwth_file = os.path.join(src_folder, 'rivwth.tif')
uparea_file = os.path.join(src_folder, 'uparea.tif')
lat_file = os.path.join(src_folder, 'lat.tif')
lon_file = os.path.join(src_folder, 'lon.tif')
dem_file = os.path.join(src_folder, 'dem_globe.tif')

alpha = 50
alpha_const = (alpha*(alpha+2)**(2./3))**0.375
n = 0.04  # s m^(-1./3)
n_const = n**0.375

total_const = n_const*alpha_const

# now the geomorphological law is:
# W = total_const * slope**(-0.1875)*Q**0.375
# So Q**0.375 = W/(total_const*slope**(-0.1875))


# make index arrray for search
idx_vector_x = np.arange(0, 14400)
idy_array_y = np.arange(0, 6000)

# read all the tiffs in memory
template = 'Reading {:s}'
print(template).format(nextx_file)
x, y, nextx, fill_value = gdal_readmap(nextx_file, 'GTiff')
print(template).format(nexty_file)
x, y, nexty, fill_value = gdal_readmap(nexty_file, 'GTiff')
print(template).format(rivwth_file)
x, y, rivwth, fill_value = gdal_readmap(rivwth_file, 'GTiff')
print(template).format(uparea_file)
x, y, uparea, fill_value = gdal_readmap(uparea_file, 'GTiff')
print(template).format(lat_file)
x, y, lat, fill_value = gdal_readmap(lat_file, 'GTiff')
print(template).format(lon_file)
x, y, lon, fill_value = gdal_readmap(lon_file, 'GTiff')
print(template).format(dem_file)
x, y, dem, fill_value = gdal_readmap(dem_file, 'GTiff')

# prepare the axes that Yamazaki uses to number the cells!
y_cell_nr = np.arange(1, nextx.shape[0]+1)
x_cell_nr = np.arange(1, nextx.shape[1]+1)

# 
all_outlets = find_upstream_all(nextx, nexty, -1, -1)

# reduce outlets to match minimum upstream area
outlets_min_up = []
for outlet in all_outlets:
    if uparea[outlet[1], outlet[0]] >= min_catch:
        outlets_min_up.append(outlet)


## Create new shapefile
#ogr.UseExceptions()
#ds_point = ogr.GetDriverByName('ESRI Shapefile').CreateDataSource('deltas.shp')
#layer_point = ds.CreateLayer("deltas", None, ogr.wkbPoint)
#delta_ID = ogr.FieldDefn()
#delta_ID.SetName('DELTA_ID')
#delta_ID.SetType(ogr.OFTInteger)
#delta_ID.SetWidth(10)
#layer_point.CreateField(delta_ID)

# Create new shapefile
ogr.UseExceptions()
ds_point = ogr.GetDriverByName('ESRI Shapefile').CreateDataSource(SHP_POINT_FILENAME)
layer_point = ds_point.CreateLayer("river_profiles", None, ogr.wkbPoint)
width_ID = ogr.FieldDefn()
width_ID.SetName('WIDTH')
width_ID.SetType(ogr.OFTReal)
width_ID.SetWidth(10)
width_ID.SetPrecision(3)
layer_point.CreateField(width_ID)

depth_ID = ogr.FieldDefn()
depth_ID.SetName('DEPTH')
depth_ID.SetType(ogr.OFTReal)
depth_ID.SetWidth(10)
depth_ID.SetPrecision(3)
layer_point.CreateField(depth_ID)

# Create new shapefile
ogr.UseExceptions()
ds = ogr.GetDriverByName('ESRI Shapefile').CreateDataSource(SHP_FILENAME)
layer_line = ds.CreateLayer("rivers", None, ogr.wkbLineString)
river_ID = ogr.FieldDefn()
river_ID.SetName('RIVER_ID')
river_ID.SetType(ogr.OFTInteger)
river_ID.SetWidth(10)
layer_line.CreateField(river_ID)

segment_width = ogr.FieldDefn()
segment_width.SetName('WIDTH')
segment_width.SetType(ogr.OFTReal)
segment_width.SetWidth(10)
layer_line.CreateField(segment_width)

plot_width = ogr.FieldDefn()
plot_width.SetName('WTH_PLOT')
plot_width.SetType(ogr.OFTReal)
plot_width.SetWidth(10)
layer_line.CreateField(plot_width)
nr = 0
#for outlet in outlets_min_up:
#    if lat[outlet[1], outlet[0]] < 56:
#        # arctic basins not considered here
#        point_latlon = ogr.Geometry(type=ogr.wkbPoint)
#        point_latlon.SetPoint(0, np.float64(lon[outlet[1], outlet[0]]), np.float64(lat[outlet[1], outlet[0]]))
#        feature_point_latlon = ogr.Feature(layer_point.GetLayerDefn())
#        feature_point_latlon.SetGeometryDirectly(point_latlon)
#        # write the attributes to the current feature
#        feature_point_latlon.SetField('DELTA_ID', nr)
#        layer_point.CreateFeature(feature_point_latlon)
#        nr += 1
#ds_point.Destroy()

# initialize river IDs. Start with one!
id = 1
for outlet in outlets_min_up:
    depth = 0
    x_idx = outlet[0]
    y_idx = outlet[1]
    up_sinkcell_total = find_upstream(nextx, nexty, x_cell_nr[x_idx], y_cell_nr[y_idx], x_idx, y_idx)
    up_sinkcell = []
    for up_sinkcell_point in up_sinkcell_total:
        if uparea[up_sinkcell_point[1], up_sinkcell_point[0]] > min_upstream:
            up_sinkcell.append(up_sinkcell_point)
    for up_sink in up_sinkcell:
        layer_line, id, depth = segment_to_vertex(layer_line, layer_point,
                                                  max_prof_distance, x_cell_nr,
                                                  y_cell_nr, nextx, nexty,
                                                  uparea, rivwth, dem, lon, lat,
                                                  outlet, [up_sink], id, depth,
                                                  min_upstream, min_width,
                                                  total_const)
ds.Destroy()
ds_point.Destroy()
#        else:
#    # no upstream cells found, so return!
#    return layer_line, id


