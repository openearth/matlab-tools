import os, sys
import shapefile
from sqlalchemy import create_engine
from osgeo import ogr, osr, gdal
from rasterutils import *
from rasterstats import zonal_stats

# Input
results_dir = r"/mnt/d/RoadsNL/results"
shape_blad = r"/mnt/d/RoadsNL/shapes/blad_index.shp"
elev_data_dir = r"/mnt/d/RoadsNL/geotiff_buffered"
talud_data_dir = r"/mnt/d/RoadsNL/taluds"
tmp_data_dir = r"/mnt/d/RoadsNL/tmpdir"

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
pg = 'host={h} dbname={d} user={u} password={p}'.format(h=h, u=u, d=d, p=p)
write_postgis=True
write_shp=True

# Iterate
sf = shapefile.Reader(shape_blad)
fields = sf.fields[1:] 
field_names = [field[0] for field in fields] 
ri = 0 
rn = len(sf.shapeRecords())

for r in sf.shapeRecords():

	# Get Blad index and bbox
	x0, y0, x1, y1 = r.shape.bbox
	atr = dict(zip(field_names, r.record))
	bladnr = atr['bladnr']
	ri+=1
	print('[{i}/{n}] BLAD = {b}, BBOX = {bb}'.format(i=ri, n=rn, b=bladnr, bb=[x0, x1, y0, y1]))	

	# Source data
	ahnRast = os.path.join(elev_data_dir, 'r{}.tif'.format(bladnr))
	taludRast = os.path.join(talud_data_dir, 'i{}_talud.tif'.format(bladnr))
	roadsRast = os.path.join(talud_data_dir, 'i{}_roads.tif'.format(bladnr))

	# Select filter interesting areas [blad numbers with data]
	if not os.path.exists(ahnRast):			
		continue
	
	# Get Roads for the blad box, a buffer around them for every stukje
	sqlStr = 'select {id}, ST_Buffer({geomfield}, {roadbuf1}, \'endcap=flat join=round\') as line from {t} where ST_Contains(ST_MakeEnvelope({xmin}, {ymin}, {xmax}, {ymax}, 28992), {t}.{geomfield})'.format(
		t=roads_table, xmin=x0, ymin=y0, xmax=x1, ymax=y1, roadbuf1=roads_buffer_asfalt, roadbuf2=roads_buffer_surroundings, geomfield=roads_table_geomfield, id=roads_table_idfield)    

	# Prepare output shapefile [skip if processed]
	shpFilePath = os.path.join(results_dir, '{}.shp'.format(bladnr))
	if not os.path.exists(shpFilePath):				
		# Export to SHP
		cmd = '''ogr2ogr -f "ESRI Shapefile" {shp} PG:"{p}" -sql "{s}"'''.format(s=sqlStr, p=pg, shp=shpFilePath)
		os.system(cmd)
		
		# Get stats 	
		try:	
			geojson_stats = zonal_stats(shpFilePath, ahnRast, stats="percentile_5 mean", geojson_out=True)
			for s in geojson_stats:
				idval = s['properties'][roads_table_idfield]
				roadMinH = s['properties']['percentile_5']
				roadHeight = s['properties']['mean']
				if roadHeight and roadMinH:
					sqlStr = 'update {t} set {c1} = {v1}, {c2} = {v2} where {idfield} = {idval}'.format(t=roads_table, idfield=roads_table_idfield, idval=idval, c1='roadHeight', v1=roadHeight, c2='roadMinH', v2=roadMinH)    
					engine.execute(sqlStr)	
		except:
			os.remove(shpFilePath)
	

	# Blad
	ri += 1

## Those segments that are between blads need a different treatment
## NULL features are uncalculated because they are not fully within a blad box

## IMPORTANT: THIS SCRIPT COMPLETES THE JOB DONE PREVIOUSLY BY road_talud_analysis_NL_within.py
sqlStr = 'select {i}, ST_AsText(ST_Buffer({g}, {roadbuf1}, \'endcap=flat join=round\')), ST_AsText(ST_Buffer({g}, {roadbuf2}, \'endcap=flat join=round\')) from {t} where roadMinH is NULL'.format(
	t=roads_table, g=roads_table_geomfield, i=roads_table_idfield, roadbuf1=roads_buffer_asfalt, roadbuf2=roads_buffer_surroundings)
res = engine.execute(sqlStr)

for r in res:
	# Shapefile generation temporary
	id_stukje = r[0]
	geom_stukje = r[1]
	geom_stukje_buf = r[2]
	print('Processing intersect road section {}'.format(id_stukje))
	
	# Select blads
	sqlStr = 'select ahn.unit from {t} w, ahn_units ahn where w.{i} = {id} AND ST_Intersects(w.{g}, ahn.{g})'.format(
		t=roads_table, g=roads_table_geomfield, i=roads_table_idfield, id=id_stukje)
	res2 = engine.execute(sqlStr)

	# For every blad [we average around the affected blads]
	roadHeight = 0.0
	roadMinH = 0.0
	blads = 0.0
	for bladnr in res2:
		# Calculate statistics
		ahnRast = os.path.join(elev_data_dir, 'r{}.tif'.format(bladnr[0]))
		
		# Get stats 	
		geojson_stats = zonal_stats(geom_stukje, ahnRast, stats="percentile_5 mean", geojson_out=True)		
		for s in geojson_stats:			
			roadM = s['properties']['percentile_5']
			roadH = s['properties']['mean']

			# Accumulate [if data is available]
			if roadM and roadH:
				roadHeight += roadH
				roadMinH += roadM
				blads+=1.0
	
	# Totals
	if roadHeight and roadMinH:
		print 'Updating {}'.format(id_stukje)
		sqlStr = 'update {t} set {c1} = {v1}, {c2} = {v2} where {idfield} = {idval}'.format(t=roads_table, idfield=roads_table_idfield, idval=id_stukje, c1='roadHeight', v1=roadHeight/blads, c2='roadMinH', v2=roadMinH/blads)    
		engine.execute(sqlStr)
