import os
import shapefile
from sqlalchemy import create_engine
from osgeo import ogr, osr, gdal
from rasterutils import *

# Input
results_dir = r"/mnt/c/Users/sala/OneDrive - Stichting Deltares/Documents/Ri2DE/TALUDS/results"
shape_blad = r"/mnt/c/Users/sala/OneDrive - Stichting Deltares/Documents/Ri2DE/TALUDS/shapes/blad_index.shp"
raster_data_dir = r"/mnt/c/Users/sala/OneDrive - Stichting Deltares/Documents/Ri2DE/TALUDS/geotiff_buffered"
tmp_data_dir = r"/mnt/c/Users/sala/OneDrive - Stichting Deltares/Documents/Ri2DE/TALUDS/tmpdir"
tmpFeaturePath = os.path.join(tmp_data_dir, 'tmp_road.shp')
tmpFeaturePathBuff = os.path.join(tmp_data_dir, 'tmp_buffer.shp')
tmpRast = os.path.join(tmp_data_dir, 'tmp.tif')
tmpRastBuf = os.path.join(tmp_data_dir, 'tmp_buffer.tif')

# DB connections / roads
h='al-pg010.xtr.deltares.nl'
u='admin'
p='&Ez3)r5{Gc'
d='hobbelkaart'
roads_table='nisv_verharding'
pp=5432
engine = create_engine('postgresql+psycopg2://'+u+':'+p+'@'+h+':'+str(pp)+'/'+d, strategy='threadlocal')

# Iterate
sf = shapefile.Reader(shape_blad)
fields = sf.fields[1:] 
field_names = [field[0] for field in fields] 
ri = 0 
for r in sf.shapeRecords():

	# Get Blad index and bbox
	x0, y0, x1, y1 = r.shape.bbox
	atr = dict(zip(field_names, r.record))
	bladnr = atr['bladnr']
	
	# Select filter interesting areas
	if not bladnr in selected_blads:
		continue

	# Source data
	ahnRast = os.path.join(raster_data_dir, 'i{}.tif'.format(bladnr))
	taludRast = os.path.join(raster_data_dir, 'i{}_talud.tif'.format(bladnr))
	roadsRast = os.path.join(raster_data_dir, 'i{}_roads.tif'.format(bladnr))
	slopeRast = os.path.join(raster_data_dir, 'i{}_slope.tif'.format(bladnr))
	print('BLAD = {b}, BBOX = {bb}'.format(b=bladnr, bb=[x0, x1, y0, y1]))

	# Get Roads for the blad box, a buffer around them for every stukje
	sqlStr = 'select objectid, ST_AsText(wkb_geometry), ST_AsText(ST_Buffer(wkb_geometry, {roadbuf}, \'endcap=flat join=round\')) from {t} where ST_Contains(ST_MakeEnvelope({xmin}, {ymin}, {xmax}, {ymax}, 28992), {t}.wkb_geometry)'.format(
		t=roads_table, xmin=x0, ymin=y0, xmax=x1, ymax=y1, roadbuf=20)    
	res = engine.execute(sqlStr)

	# Assign right projection
	srs = osr.SpatialReference()
	srs.ImportFromEPSG(28992)

	# Prepare output shapefile
	shpdriver = ogr.GetDriverByName('Esri Shapefile')
	ds = shpdriver.CreateDataSource(os.path.join(results_dir, '{}.shp'.format(bladnr)))
	layer = ds.CreateLayer('', srs, ogr.wkbPolygon)

	# Add attributes
	layer.CreateField(ogr.FieldDefn('objectId', ogr.OFTInteger))	
	layer.CreateField(ogr.FieldDefn('roadHeight', ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn('percTalud', ogr.OFTReal))	
	layer.CreateField(ogr.FieldDefn('taludHigh', ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn('taludLow', ogr.OFTReal))
	defn = layer.GetLayerDefn()

	# For every piece of road
	i = 0
	for stukje in res:

		# Make a feature
		feat = ogr.Feature(defn)
		feat.SetField('objectId', stukje[0])		
		featBuf = ogr.Feature(defn)
		featBuf.SetField('objectId', stukje[0])

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
		if arr.size == 0: continue
		roadH = np.nanmean(arr)
		feat.SetField('roadHeight', float(roadH))
		
		# Cut by buffer [get nearby taluds and nearby elevation]
		arrTaludBuff = rasterizeGeom(taludRast, tmpRastBuf, tmpFeaturePathBuff)
		if arrTaludBuff.size == 0: continue
		taludInd = np.where(arrTaludBuff > 1) # danger classes = 2,3
		totalInd = np.where(arrTaludBuff >= 1) # all data pixels		
		arrTaludAhn = rasterizeGeom(ahnRast, tmpRastBuf, tmpFeaturePathBuff)
		if arrTaludAhn.size == 0: continue
		
		# If more than 50% pixels are talud
		perc_talud = 100.0 * float(len(taludInd[0])) / float(len(totalInd[0]))
		feat.SetField('percTalud', float(perc_talud))		
		if len(taludInd[0]):			
			feat.SetField('taludHigh', float(np.max(arrTaludAhn[taludInd])) - roadH) 
			feat.SetField('taludLow', float(np.min(arrTaludAhn[taludInd])) - roadH)
		
		# Add feature to output
		layer.CreateFeature(feat)

		# Feature
		i += 1
	# Blad
	ri += 1

	print ('{} features added'.format(i))