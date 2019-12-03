
from osgeo import ogr
import pdb
import numpy as np
import os

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


#if __name__ == '__main__':

SHP_POINT_FILENAME = r'd:\projects\1208848-Curacao\DFLOWFM\drainage_1d\curacao_point.shp'
prof_file = 'curacao_profdef.txt'
sample_file = 'curacao_1d_depth.xyz'
loc_file = 'curacao_profloc.xyz'
field_depth = 'DEPTH'
field_width = 'WIDTH'
decimals = 1  # amount of decimals rounding of profile data

driver = ogr.GetDriverByName('ESRI Shapefile')

ds_point = driver.Open(SHP_POINT_FILENAME, 0) # 0 means read-only. 1 means writeable.    
layer_point = ds_point.GetLayer()
all_widths = []

fid_profloc = open(loc_file, 'w')
fid_profdef = open(prof_file, 'w')
fid_sample = open(sample_file, 'w')

template_profdef = str('PROFNR={:d}     TYPE={:d}             WIDTH={:f}\n')
template_profloc = str('{:f} {:f} {:d}\n')
template_sample = str('{:f} {:f} {:f}\n')
for n, feat in enumerate(layer_point):
    width = np.round(feat.GetField(field_width), decimals=decimals)
    depth = np.round(feat.GetField(field_depth), decimals=decimals)
    centr = feat.GetGeometryRef().Centroid()
    print('Writing feature {:d} width={:f}, depth={:f} to file').format(n, width, depth)
    x, y, z = centr.GetPoint()
    # find profile in all_widths
    idx = np.where(np.array(all_widths)==width)[0]
    if len(idx)==1:
        prof_nr = idx[0] + 1
    else:
        all_widths.append(width)
        prof_nr = len(all_widths)
        print('New profile found, nr: {:d}').format(prof_nr)
        # write new profile to profdef file
        fid_profdef.write(template_profdef.format(prof_nr, 2, width))
    # now write to files
    fid_profloc.write(template_profloc.format(x, y, prof_nr))
    fid_sample.write(template_sample.format(x, y, depth))
        
    # write to a file
fid_profdef.close()
fid_profloc.close()
fid_sample.close()
ds_point.Destroy()
#width_ID = ogr.FieldDefn()
#width_ID.SetName('WIDTH')
#width_ID.SetType(ogr.OFTReal)
#width_ID.SetWidth(10)
#width_ID.SetPrecision(3)
#layer_point.CreateField(width_ID)
    