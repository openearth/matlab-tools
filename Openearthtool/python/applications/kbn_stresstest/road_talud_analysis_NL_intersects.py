import os, sys
import shapefile
from sqlalchemy import create_engine
from osgeo import ogr, osr, gdal
from rasterutils import *

# Input
results_dir = r"/mnt/d/RoadsNL/results"
shape_blad = r"/mnt/d/RoadsNL/shapes/blad_index.shp"
elev_data_dir = r"/mnt/d/RoadsNL/geotiff_buffered"
talud_data_dir = r"/mnt/d/RoadsNL/taluds"
tmp_data_dir = r"/mnt/d/RoadsNL/tmpdir"

# Temp files
tmpFeaturePath = os.path.join(tmp_data_dir, 'tmp_road_{}.shp'.format(sys.argv[1]))
tmpFeaturePathBuff = os.path.join(tmp_data_dir, 'tmp_buffer_{}.shp'.format(sys.argv[1]))
tmpRast = os.path.join(tmp_data_dir, 'tmp_{}.tif'.format(sys.argv[1]))
tmpRastBuf = os.path.join(tmp_data_dir, 'tmp_buffer_{}.tif'.format(sys.argv[1]))

# DB connections / roads
h='al-pg010.xtr.deltares.nl'
u='admin'
p='&Ez3)r5{Gc'
d='hobbelkaart'
roads_table='wegvakken_stresstest2019_split'
roads_table_geomfield='geom'
roads_table_idfield='gid'
roads_buffer_asfalt=1.5
roads_buffer_surroundings=20
pp=5432
engine = create_engine('postgresql+psycopg2://'+u+':'+p+'@'+h+':'+str(pp)+'/'+d, strategy='threadlocal')
write_postgis=True

# Assign right projection
srs = osr.SpatialReference()
srs.ImportFromEPSG(28992)
shpdriver = ogr.GetDriverByName('Esri Shapefile')

## IMPORTANT: THIS SCRIPT COMPLETES THE JOB DONE PREVIOUSLY BY road_talud_analysis_NL_within.py
sqlStr = 'select {i}, ST_AsText(ST_Buffer({g}, {roadbuf1}, \'endcap=flat join=round\')), ST_AsText(ST_Buffer({g}, {roadbuf2}, \'endcap=flat join=round\')) from {t} where roadHeight is NULL'.format(
	t=roads_table, g=roads_table_geomfield, i=roads_table_idfield, roadbuf1=roads_buffer_asfalt, roadbuf2=roads_buffer_surroundings)
res = engine.execute(sqlStr)

# Tmp shapefile
ds = shpdriver.CreateDataSource(tmpShp)
layer = ds.CreateLayer('', srs, ogr.wkbPolygon)
layer.CreateField(ogr.FieldDefn(roads_table_idfield, ogr.OFTReal))	
layer.CreateField(ogr.FieldDefn('roadHeight', ogr.OFTReal))
layer.CreateField(ogr.FieldDefn('percTalud', ogr.OFTReal))	
layer.CreateField(ogr.FieldDefn('taludHigh', ogr.OFTReal))
layer.CreateField(ogr.FieldDefn('taludLow', ogr.OFTReal))
defn = layer.GetLayerDefn()

## NULL features are uncalculated because they are not fully within a blad box
for r in res:
	# Shapefile generation temporary
	id_stukje = r[0]
	geom_stukje = r[1]
	geom_stukje_buf = r[2]
	print('Processing road section {}'.format(id_stukje))
	roadStukjeShp(srs, shpdriver, defn, id_stukje, geom_stukje, geom_stukje_buf, roads_table_idfield, tmpFeaturePath, tmpFeaturePathBuff)
	
	# Select blads
	sqlStr = 'select ahn.unit from {t} w, ahn_units ahn where w.{i} = {id} AND ST_Intersects(w.{g}, ahn.{g})'.format(
		t=roads_table, g=roads_table_geomfield, i=roads_table_idfield, id=id_stukje)
	res2 = engine.execute(sqlStr)
	
	# Every blad [we average around the affected blads]
	roadHeight = 0.0
	percTalud = 0.0
	taludHigh = 0.0
	taludLow = 0.0
	blads = 0.0
	for bladnr in res2:
		# Source data
		ahnRast = os.path.join(raster_data_dir, 'i{}.tif'.format(bladnr[0]))
		taludRast = os.path.join(raster_data_dir, 'r{}_talud.tif'.format(bladnr[0]))
		roadsRast = os.path.join(raster_data_dir, 'i{}_roads.tif'.format(bladnr[0]))
						
		to_delete = ahnRast.replace('_buffered', '')		
		if (os.path.exists(to_delete)):
			print('Deleting {}'.format(to_delete))
			os.unlink(to_delete)
		continue
		# Calculate
		roadH, percT, taludH, taludL = None, None, None, None
		try:
			stukje_magic(tmpFeaturePath, tmpFeaturePathBuff, ahnRast, taludRast, tmpRast, tmpRastBuf)
			print('Road Height = {}, Talud percentage = {}'.format(percT))
		except:
			pass

		# Accumulate [if data is available]
		if roadH and taludHigh and taludLow and percTalud:
			roadHeight += roadH
			percTalud += percT
			taludHigh += taludH
			taludLow += taludL
			blads+=1.0

	# Update db table if data is available
	if write_postgis and blads:
		sqlStr = 'update {t} set {c1} = {v1}, {c2} = {v2}, {c3} = {v3}, {c4} = {v4} where {idfield} = {idval}'.format(
			t=roads_table, idfield=roads_table_idfield, idval=id_stukje, c1='roadHeight', v1=roadHeight/blads, c2='taludHigh', 
			v2=taludHigh/blads, c3='taludLow', v3=taludLow/blads, c4='percTalud', v4=percTalud/blads)    
		print(sqlStr)
		engine.execute(sqlStr)
