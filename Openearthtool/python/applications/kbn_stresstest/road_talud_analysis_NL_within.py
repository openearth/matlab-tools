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
write_shp=True

# Iterate
sf = shapefile.Reader(shape_blad)
fields = sf.fields[1:] 
field_names = [field[0] for field in fields] 
ri = 0 
rn = len(sf.shapeRecords())

# Add attributes
if write_postgis:
	try:
		engine.execute('ALTER TABLE {} ADD roadMinH numeric'.format(roads_table))
		engine.execute('ALTER TABLE {} ADD roadHeight numeric'.format(roads_table))
		engine.execute('ALTER TABLE {} ADD percTalud numeric'.format(roads_table))
		engine.execute('ALTER TABLE {} ADD taludHigh numeric'.format(roads_table))
		engine.execute('ALTER TABLE {} ADD taludLow numeric'.format(roads_table))
	except:
		pass # columns exist

for r in sf.shapeRecords():

	# Get Blad index and bbox
	x0, y0, x1, y1 = r.shape.bbox
	atr = dict(zip(field_names, r.record))
	bladnr = atr['bladnr']
	ri+=1
	print('[{i}/{n}] BLAD = {b}, BBOX = {bb}'.format(i=ri, n=rn, b=bladnr, bb=[x0, x1, y0, y1]))	

	# Source data
	ahnRast = os.path.join(elev_data_dir, 'r{}.tif'.format(bladnr))
	taludRast = os.path.join(talud_data_dir, 'r{}_talud.tif'.format(bladnr))
	roadsRast = os.path.join(talud_data_dir, 'i{}_roads.tif'.format(bladnr))

	# Select filter interesting areas [blad numbers with data]
	if not os.path.exists(ahnRast) or not os.path.exists(taludRast) or not os.path.exists(roadsRast):
		continue
	
	# Get Roads for the blad box, a buffer around them for every stukje
	sqlStr = 'select {id}, ST_AsText(ST_Buffer({geomfield}, {roadbuf1}, \'endcap=flat join=round\')), ST_AsText(ST_Buffer({geomfield}, {roadbuf2}, \'endcap=flat join=round\')) from {t} where ST_Contains(ST_MakeEnvelope({xmin}, {ymin}, {xmax}, {ymax}, 28992), {t}.{geomfield})'.format(
		t=roads_table, xmin=x0, ymin=y0, xmax=x1, ymax=y1, roadbuf1=roads_buffer_asfalt, roadbuf2=roads_buffer_surroundings, geomfield=roads_table_geomfield, id=roads_table_idfield)    
	res = engine.execute(sqlStr)

	# Assign right projection
	srs = osr.SpatialReference()
	srs.ImportFromEPSG(28992)
	shpdriver = ogr.GetDriverByName('Esri Shapefile')

	# Prepare output shapefile [skip if processed]
	shpFilePath = os.path.join(results_dir, '{}.shp'.format(bladnr))
	if os.path.exists(shpFilePath):
		print ('Skipping {}'.format(bladnr))
		continue
	
	# Shapefile definition
	ds = shpdriver.CreateDataSource(shpFilePath)
	layer = ds.CreateLayer('', srs, ogr.wkbPolygon)
	layer.CreateField(ogr.FieldDefn(roads_table_idfield, ogr.OFTReal))	
	layer.CreateField(ogr.FieldDefn('roadMinH', ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn('roadHeight', ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn('percTalud', ogr.OFTReal))	
	layer.CreateField(ogr.FieldDefn('taludHigh', ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn('taludLow', ogr.OFTReal))
	defn = layer.GetLayerDefn()

	# For every piece of road
	i = 0
	for stukje in res:

		# Make a feature
		idval = float(stukje[0])
		feat = ogr.Feature(defn)
		feat.SetField(roads_table_idfield, idval)		
		featBuf = ogr.Feature(defn)
		featBuf.SetField(roads_table_idfield, idval)

		# Make a geometry [roads and buffer]
		geom = ogr.CreateGeometryFromWkt(stukje[1])		
		feat.SetGeometry(geom)
		geomBuf = ogr.CreateGeometryFromWkt(stukje[2])	
		featBuf.SetGeometry(geomBuf)	

		# Prepare temporary shapefile [roads]		
		dsTmp = shpdriver.CreateDataSource(tmpFeaturePath)
		layerTmp = dsTmp.CreateLayer('', srs, ogr.wkbPolygon)		
		layerTmp.CreateFeature(feat)
		dsTmp = None
		
		# Prepare temporary shapefile [roads-buffer]		
		dsTmpBuf = shpdriver.CreateDataSource(tmpFeaturePathBuff)
		layerTmpBuf = dsTmpBuf.CreateLayer('', srs, ogr.wkbPolygon)		
		layerTmpBuf.CreateFeature(featBuf)
		dsTmpBuf = None

		# Cut by feature [get road pixels height]
		arr = rasterizeGeom(ahnRast, tmpRast, tmpFeaturePath)
		
		# Get minimum [5% percentile] and mean of road height
		roadMinH = np.nanpercentile(arr, 5)
		roadHeight = np.nanmean(arr)
		if np.isnan(roadHeight): continue # skip irrelevant piece
		if write_shp:
			feat.SetField('roadHeight', float(roadHeight))
			feat.SetField('roadMinH', float(roadMinH))		
		
		# Cut by buffer [get nearby taluds and nearby elevation]
		arrTaludBuff = rasterizeGeom(taludRast, tmpRastBuf, tmpFeaturePathBuff)
		taludInd = np.where(arrTaludBuff > 1) # danger classes = 2,3
		totalInd = np.where(arrTaludBuff >= 1) # all data pixels		
		arrTaludAhn = rasterizeGeom(ahnRast, tmpRastBuf, tmpFeaturePathBuff)
		if len(totalInd[0]) == 0: continue # skip empty pieces

		# If more than 50% pixels are talud
		percTalud = 100.0 * float(len(taludInd[0])) / float(len(totalInd[0]))
		feat.SetField('percTalud', float(percTalud))		
		if len(taludInd[0]):
			try:
				taludHigh = float(np.max(arrTaludAhn[taludInd])) - roadHeight
				taludLow = float(np.min(arrTaludAhn[taludInd])) - roadHeight			
				if write_shp:	
					feat.SetField('taludHigh', taludHigh) 
					feat.SetField('taludLow', taludLow)
			except:
				taludHigh = np.nan
				taludLow = np.nan				
		else:
			taludHigh = np.nan
			taludLow = np.nan
		
		# Add feature to output
		if write_shp:
			layer.CreateFeature(feat)

		# Update db table
		if write_postgis:
			if np.isnan(taludHigh):	taludHigh = 'NULL'
			if np.isnan(taludLow):	taludLow = 'NULL'			
			sqlStr = 'update {t} set {c1} = {v1}, {c2} = {v2}, {c3} = {v3}, {c4} = {v4}, {c5} = {v5} where {idfield} = {idval}'.format(
				t=roads_table, idfield=roads_table_idfield, idval=idval, c1='roadHeight', v1=roadHeight, 
				c2='taludHigh', v2=taludHigh, c3='taludLow', v3=taludLow, c4='percTalud', v4=percTalud,
				c5='roadMinH', v5=roadMinH)    
			engine.execute(sqlStr)

		# Feature
		i += 1
	# Blad
	ri += 1

	print ('{} features added'.format(i))