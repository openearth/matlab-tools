from common import *

road_network_input_file = 'Inputs/All_json.geojson'
hazard_map_input_file = 'Inputs/susceptibility_map.tif'
damage_category = ''
road_network = read_file_as_gdf(road_network_input_file)
road_network = get_gdf_geometry(road_network)
road_network = multilinestring_list_to_multilinestring(road_network)
hazard_map = read_raster_file(hazard_map_input_file)
profile = get_dataset_profile(hazard_map)

polygon_list = extract_polygon_by_mask(hazard_map, road_network)
length_list = calc_length_in_cell_list(polygon_list, road_network)
rasterized = rasterize(hazard_map, polygon_list, length_list)
exposure_map = open_physical_file(rasterized,'Output/exposure_map.tif', profile)

hazard_map.close()



