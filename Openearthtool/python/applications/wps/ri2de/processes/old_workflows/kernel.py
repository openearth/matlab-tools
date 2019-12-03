from common import *
import os
split_length = 2000
buffer_length = 500
stat_type = 'mean'

gdf = geopandas.read_file('Inputs/All_json.geojson') #returns geopandas.GeoDataFrame
raster = rasterio.open('Inputs/susceptibility_map.tif')
gdf_geometry = get_gdf_geometry(gdf) #returns list of multilinestrings
r = explode_gdf_geometry(gdf_geometry) #returns 1 multilinestring object containing all linestrings contained in gdf_geometry
r = line_merge(r) #returns 1 multilinestring object containing less linestrings than previous line
r = split_linestring_list(r,split_length) #returns list of linestring objects (could return multilinestring object?)
p = buffer_linestring_list(r,buffer_length) #returns list of geometry objects

stat_list = compute_statistic_list(p,raster, stat_type)
buffer_layer = create_blank_gdf()
buffer_layer = set_gdf_geometry(buffer_layer, p)
output_layer = create_blank_gdf()
output_layer = set_gdf_geometry(output_layer, r)
output_layer['sus']=stat_list
filename = 'out_file_SplitLength'+str(split_length)+'_BufferLength'+str(buffer_length)+'_StatType'+stat_type+'.geojson'
output_layer.to_file(filename = os.path.join('Output',filename), driver = 'GeoJSON')
buffer_layer.to_file(filename = os.path.join('Intermediate',filename), driver = 'GeoJSON')
print('done')