from pyproj import Proj, transform
import numpy as np
import bisect


def getLocations(locations):
    lat = np.arange(-100, 100.25, 0.25)
    lon = np.arange(-190, 190, 0.25)

#    lon_viewer, lat_viewer = locations['x'], locations['y']
    x_coor = locations['x']
    y_coor = locations['y']
    P3857 = Proj(init='epsg:3857') # Mercator OSM projectie
    P4326 = Proj(init='epsg:4326') # latlon

    lon_viewer, lat_viewer= transform(P3857, P4326, x_coor, y_coor) # from latlon to Mercator OSM projection
    lon_i = bisect.bisect(lon, lon_viewer)
    lat_i = bisect.bisect(lat, lat_viewer)

    m = 5
    grid_lat, grid_lon = np.meshgrid(lat[lat_i-m:lat_i+m], lon[lon_i-m:lon_i+m])
    distance = np.sqrt((grid_lat - lat_viewer)**2 + (grid_lon - lon_viewer)**2)
    grid_lat = grid_lat.ravel()
    grid_lon = grid_lon.ravel()
    distance = distance.ravel()
    id_sorted = np.argsort(distance)

    grid_lon[(grid_lon>-190) & (grid_lon<0)] += 360
    grid_lat[grid_lat > 90] = 90 - (grid_lat[grid_lat > 90] - 90)
    grid_lat[grid_lat < -90] = - 90 - (grid_lat[grid_lat < -90] + 90)

    return grid_lat[id_sorted], grid_lon[id_sorted]
