import pcraster as pcr
import os
import numpy as np
import shutil
import sys
import glob
try:
    from osgeo import ogr
except ImportError:
    import ogr
try:
    from osgeo import gdal
    from osgeo.gdalconst import *
except ImportError:
    import gdal
    from gdalconst import *
    
import hydrotopo
from collections import Counter
    
import osr 
argv = None

# usage definition
def Usage():
    print('')             
    print('Usage: CreateWaterdistricts.py [--help] [-t_srs EPSG_projection] [-order river_order] [-B basin_name]')
    print('[-RIV rivers_shape_in] [-LDD ldd_map_in] [-WS watershed_shape_in]')
    print('')   
    
def LongUsage():
    Usage()
    print('-B(required):        Basin name used in output files')
    print('-t_srs(optional):    EPSG code of UTM projection to calculate area (only if source is in latlon)')
    print('-order(optional):    Integer value of river order used to generate ldd_rivers.map (default = 3)')   
    print('-RIV(optional):      File containing rivers (default is reach.shp)')
    print('-LDD(optional):      PCRaster map with local drainage direction (default is wflow_ldd.map)')
    print('-WS(optional):       File containing watershed used to "clump" areas not covered in LDD')
    print('-debug(optional):    if set true no all generated files will be preserved')

# merge shape-filese definition   
def MergeShapes(shapesin, Layer):
    for SHP in shapesin:
        if os.path.exists(SHP):
            ATT = os.path.splitext(os.path.basename(SHP))[0]
            DATA = ogr.Open(SHP)
            LYR = DATA.GetLayerByName(ATT)
            LYR.ResetReading()
            for idx, i in enumerate(range(LYR.GetFeatureCount())):
                oldfeature = LYR.GetFeature(i)
                geometry = oldfeature.geometry()
                feature = ogr.Feature(Layer.GetLayerDefn())
                feature.SetGeometry(geometry)
                feature.SetField("ID",oldfeature.GetFieldAsString(0))
                Layer.CreateFeature(feature)
            DATA.Destroy()

# defaults
debug = False
basin = None
DAS_SHP = None
tsrs = None
DAS_ID = None
order = 3
ldd = 'wflow_ldd.map'
CONN_SHP = "connections.shp"
OBJ_SHP = "objects.shp"
REACH_SHP = "reach.shp"
SELEC_SHP = "RIV_SELECTION.shp"
LOCA_SHP = ['sbk_boundary_terminal_n.shp']
CONPNT_SHP = ['sbk_sbk-3b-node_runoffriver_n.shp','sbk_sbk-3b-node_weir_n.shp','sbk_sbk-3b-node_reservoir_n.shp','sbk_sbk-3b-node_confluence_n.shp']
ssrs= "EPSG:4326"
CATCH_ATT = "DAS"

# deleting oldies
if os.path.isdir("TEMP/"):
    shutil.rmtree("TEMP/")
os.makedirs("TEMP/")

# Parse command line arguments.   
argv = list(sys.argv)
#argv = ['-t_srs', 'EPSG:32750','-b','SADDANG','-order','2','-ldd','wflow_ldd.map','-debug','-wsid','NAMA_DAS','-ws','das_saddang_mergeHydroSHED.shp']
if argv is None:
    Usage()
    sys.exit(1)

if len(argv) > 1:
    if argv[1] == '--help':
        LongUsage()
        sys.exit(1)

i = 0
while i < len(argv):
    arg = argv[i]
    if arg == '-b':
        i = i + 1
        basin = str(argv[i])
        print "basin name: " + basin
    elif arg == '-order':
        i = i + 1
        order = int(argv[i])
        print "min strahler order: " + str(order)
    elif arg == '-ws':
        i = i + 1
        DAS_SHP = str(argv[i])
        print "catchment shape: " + DAS_SHP
    elif arg == '-wsid':
        i = i + 1
        DAS_ID = str(argv[i])
        print "catchment attribute: " + DAS_ID
    elif arg == '-debug':
        debug = True 
        print "debug is true"
    elif arg == '-riv':
        i = i + 1
        REACH_SHP = str(argv[i])  
        print "river shape: " + REACH_SHP
    elif arg == '-t_srs':
        i = i + 1
        tsrs = str(argv[i])  
        print "using EPSG for area-computation: " + tsrs
    elif arg == '-ldd':
        i = i + 1
        ldd = str(argv[i])
        print "ldd-file: " + ldd
    elif arg[len(arg)-3:len(arg)] == '.py':
        print ''
    else:
        print 'this is the last argument: ' + str(arg)
        Usage()
        sys.exit(1)

    i = i + 1

# Check for common errors
if basin is None or ldd is None:
    print('please check correct usage!')
    print('')
    Usage()
    sys.exit(1)

if not DAS_SHP is None:
    if not os.path.exists(DAS_SHP):
        print('cannot find watershed shapefile: ' +  DAS_SHP + ' !')
        print('')
        Usage()
        sys.exit(1)
if not os.path.exists(ldd):
    print('cannot find watershed ldd!')
    print('')
    Usage()
    sys.exit(1)
if not os.path.exists(REACH_SHP):
    print('cannot find river shapefile: ' +  REACH_SHP + ' !')
    print('')
    Usage()
    sys.exit(1)

# create reference to new shape-files
WADI_SHP = "11_WATERDISTRICT_" + basin + ".shp"
OUTL_SHP = "12_WD_OUTFLOW_" + basin + ".shp"
MAINRIV_SHP = "10_MAIN_RIVER_" + basin + ".shp"

Driver = ogr.GetDriverByName("ESRI Shapefile")

# create the spatial reference, WGS84
srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)

# check if new shape-files allready exist and delete
def DeleteShapes(shapes):
    for shape in shapes:
        if os.path.exists(shape):
            Driver.DeleteDataSource(shape)
itemlist = [WADI_SHP,CONN_SHP,SELEC_SHP,OBJ_SHP,OUTL_SHP,MAINRIV_SHP]
DeleteShapes(itemlist)

 
# create emtpy river selection file  
SELEC_out = Driver.CreateDataSource(SELEC_SHP)
SELEC_ATT = os.path.splitext(os.path.basename(SELEC_SHP))[0]
SELEC_LYR  = SELEC_out.CreateLayer(SELEC_ATT, srs, geom_type=ogr.wkbLineString)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
SELEC_LYR.CreateField(fieldDef)

# create main river file
MAINRIV_out = Driver.CreateDataSource(MAINRIV_SHP)
MAINRIV_ATT = os.path.splitext(os.path.basename(MAINRIV_SHP))[0]
MAINRIV_LYR  = MAINRIV_out.CreateLayer(MAINRIV_ATT, srs, geom_type=ogr.wkbLineString)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
MAINRIV_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("WD_INCL", ogr.OFTString)
fieldDef.SetWidth(12)
MAINRIV_LYR.CreateField(fieldDef)

# create emtpy object nodes shape-file
OBJ_out = Driver.CreateDataSource(OBJ_SHP)
OBJ_ATT = os.path.splitext(os.path.basename(OBJ_SHP))[0]
OBJ_LYR  = OBJ_out.CreateLayer(OBJ_ATT, srs, geom_type=ogr.wkbPoint)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
OBJ_LYR.CreateField(fieldDef)

# create emtpy connection nodes shape-file
CONN_out = Driver.CreateDataSource(CONN_SHP)
CONN_ATT = os.path.splitext(os.path.basename(CONN_SHP))[0]
CONN_LYR  = CONN_out.CreateLayer(CONN_ATT, srs, geom_type=ogr.wkbPoint)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
CONN_LYR.CreateField(fieldDef)

# create empty water district shape-file  
WADI_out = Driver.CreateDataSource(WADI_SHP)
WADI_ATT = os.path.splitext(os.path.basename(WADI_SHP))[0] 
WADI_LYR  = WADI_out.CreateLayer(WADI_ATT, srs, geom_type=ogr.wkbMultiPolygon)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
WADI_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("AREA_M2", ogr.OFTReal)
fieldDef.SetWidth(20)
fieldDef.SetPrecision(0)
WADI_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("HYDRO", ogr.OFTString)
fieldDef.SetWidth(12)
WADI_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn(CATCH_ATT, ogr.OFTString)
fieldDef.SetWidth(50)
WADI_LYR.CreateField(fieldDef)

attlist = ['DMURB14','DMURB35','PDAMCAP14','PDAMCAP35','DMRUR14','DMRUR35']
for attribute in attlist:
    fieldDef = ogr.FieldDefn(attribute, ogr.OFTReal)
    fieldDef.SetWidth(20)
    fieldDef.SetPrecision(3)
    WADI_LYR.CreateField(fieldDef)
attlist = ['ASTIRR14','ASTIRR35']
for attribute in attlist:
    fieldDef = ogr.FieldDefn(attribute, ogr.OFTReal)
    fieldDef.SetWidth(20)
    fieldDef.SetPrecision(0)
    WADI_LYR.CreateField(fieldDef)
attlist = ['ADDURB','ADDRUR','ADDSTIRR']
for attribute in attlist:
    fieldDef = ogr.FieldDefn(attribute, ogr.OFTString)
    fieldDef.SetWidth(50)
    WADI_LYR.CreateField(fieldDef)

# create emtpy connection nodes shape-file
OUTL_out = Driver.CreateDataSource(OUTL_SHP)
OUTL_ATT = os.path.splitext(os.path.basename(OUTL_SHP))[0]
OUTL_LYR  = OUTL_out.CreateLayer(OUTL_ATT, srs, geom_type=ogr.wkbPoint)

fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
OUTL_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("AREA_M2", ogr.OFTReal)
fieldDef.SetWidth(20)
fieldDef.SetPrecision(0)
OUTL_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("XCOORD", ogr.OFTReal)
fieldDef.SetWidth(20)
fieldDef.SetPrecision(5)
OUTL_LYR.CreateField(fieldDef)

fieldDef = ogr.FieldDefn("YCOORD", ogr.OFTReal)
fieldDef.SetWidth(20)
fieldDef.SetPrecision(5)
OUTL_LYR.CreateField(fieldDef)

REACH_DATA = ogr.Open(REACH_SHP)
REACH_LYR = REACH_DATA.GetLayer(0)
spatialRef = REACH_LYR.GetSpatialRef()

# fill selection of rivers shapefile and main-river file
for idx, i in enumerate(range(REACH_LYR.GetFeatureCount())):
    feature = REACH_LYR.GetFeature(i)
    featgeom = feature.geometry()
    feat_out = ogr.Feature(MAINRIV_LYR.GetLayerDefn())
    feat_out.SetGeometry(featgeom)
    feat_out.SetField("ID", feature.GetField("ID        "))
    if feature.GetField("TYPE      ") == 'NotUsed': 
        feat_out.SetField("WD_INCL","NO")
        MAINRIV_LYR.CreateFeature(feat_out)
    else:
        feat_out.SetField("WD_INCL","YES")
        MAINRIV_LYR.CreateFeature(feat_out)
        feat_out = ogr.Feature(SELEC_LYR.GetLayerDefn())
        feat_out.SetGeometry(featgeom)
        feat_out.SetField("ID", feature.GetField("ID        "))
        SELEC_LYR.CreateFeature(feat_out)       

MAINRIV_out.Destroy()
SELEC_out.Destroy()

# Merge shape-files to connections and object layers
MergeShapes(CONPNT_SHP,CONN_LYR)
MergeShapes(LOCA_SHP,OBJ_LYR)

CONN_out.Destroy()
OBJ_out.Destroy()

pcr.setclone(ldd)

# somehow we can only run with these files
os.system("copy bin\out.dbf out.dbf")
os.system("copy bin\out.shx out.shx")
os.system("copy bin\out.shp out.shp")

# set clonemap for pcraster based on LDD
clonemap = pcr.readmap(ldd)
zeromap = pcr.cover(pcr.scalar(clonemap) * 0,0)
nullmap = pcr.ifthen(zeromap > 0, pcr.scalar(1))
pcr.report(pcr.nominal(zeromap), "zero.map")
pcr.report(pcr.nominal(nullmap), "null.map")

# create empty 
os.system("gdal_translate -of GTiff zero.map connections.tif")
os.system("gdal_translate -of GTiff zero.map rivers.tif")
os.system("gdal_translate -of GTiff zero.map WS.tif")
os.system("gdal_translate -of GTiff null.map subcatchment.tif")
os.system("gdal_translate -of GTiff null.map terminals.tif")

## create terminals map
OBJ_ATT = os.path.splitext(os.path.basename(OBJ_SHP))[0]
os.system('gdal_rasterize -burn 1 -l ' + OBJ_ATT + ' ' + OBJ_SHP + ' ' + 'terminals.tif')
os.system("gdal_translate -of PCRaster terminals.tif terminals.map")
terminalsmap = pcr.readmap("terminals.map")

## create connections map
os.system('gdal_rasterize -burn 1 -l ' + CONN_ATT + ' ' + CONN_SHP + ' ' + 'connections.tif')
#os.system("gdal_rasterize -burn 1 -l connections connections.shp conn.tif")
os.system("gdal_translate -of PCRaster connections.tif connections.map")
connectionsmap = pcr.readmap("connections.map")

## create rivers
SELEC_ATT = os.path.splitext(os.path.basename(SELEC_SHP))[0]
os.system('gdal_rasterize -a "ID" -l ' + str(SELEC_ATT) + " " + str(SELEC_SHP) + " " + "rivers.tif")
os.system("gdal_translate -of PCRaster " + "rivers.tif " + "rivers.map")
riversmap = pcr.readmap("rivers.map")
pcr.report(pcr.mapmaximum(pcr.scalar(riversmap)),'result2.map')
riversnp = pcr.pcr2numpy(riversmap, -9999) 
MaxWD = np.amax(np.amax(riversnp,axis=0),axis=0)


#DAS_SHP to background
if not DAS_SHP is None:
    DAS_ATT = os.path.splitext(os.path.basename(DAS_SHP))[0]
    os.system('gdal_rasterize -burn 1 -at -l ' + DAS_ATT + ' ' + DAS_SHP + ' ' + 'WS.tif')
    os.system("gdal_translate -of PCRaster WS.tif WS.map")
    WSmap = pcr.readmap("WS.map")
    WSmap = pcr.ifthen(pcr.scalar(WSmap) == 1, pcr.scalar(1))

# calculate district map
lddmap = pcr.readmap(ldd)
river_order = pcr.ifthen(pcr.streamorder(lddmap) >= pcr.ordinal(order), pcr.streamorder(lddmap))
pcr.report(river_order, "river_order.map")
ldd_riversmap = pcr.ldd(pcr.ifthen(pcr.scalar(river_order) > 0, lddmap))
pcr.report(ldd_riversmap, "ldd_rivers.map")
outletsmap = pcr.downstream(ldd_riversmap,connectionsmap)
outletsmap = pcr.nominal(pcr.scalar(outletsmap) * pcr.scalar(riversmap))
terminalsmap = pcr.nominal(pcr.scalar(terminalsmap) * pcr.scalar(riversmap))
outletsmap = pcr.cover(terminalsmap, outletsmap)
pcr.report(outletsmap,'outlets.map')
districtsmap = pcr.subcatchment(lddmap,outletsmap)
if not DAS_SHP is None:
    hydromap = pcr.ifthenelse(pcr.cover(pcr.cover(pcr.scalar(districtsmap), pcr.scalar(0))) == 0, pcr.scalar(0),pcr.scalar(1)) * pcr.scalar(WSmap)
    pcr.report(pcr.nominal(hydromap),"nohydro.map")
    clumpmap = pcr.clump(pcr.ifthen(pcr.nominal(hydromap) == 0, pcr.nominal(0)))
    nohydrowd = pcr.scalar(clumpmap) + pcr.scalar(MaxWD)
    pcr.report(pcr.nominal(nohydrowd),"districts_nohydro.map")
if not DAS_ID is None:
    # Open Catchment (DAS) shape-file
    DAS_ATT = os.path.splitext(os.path.basename(DAS_SHP))[0]
    DAS_IN = ogr.Open(DAS_SHP)
    DAS_LYR = DAS_IN.GetLayerByName(DAS_ATT)
    DAS_LYR.ResetReading()    
    # create temporary ID catchment-file
    DAS_TEMP = Driver.CreateDataSource("temp\subcatchment_id.shp")
    DAS_TEMP_LYR = DAS_TEMP.CreateLayer('subcatchment_id', geom_type=ogr.wkbPolygon)
    fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
    fieldDef.SetWidth(12)
    DAS_TEMP_LYR.CreateField(fieldDef)
    # write ID catchment file
    das_names = []
    das_ids = []
    for idx, feat in enumerate(DAS_LYR):
        das_names.append("%s" % feat.GetFieldAsString(DAS_ID))
        das_ids.append(idx+1)
        feature = ogr.Feature(DAS_TEMP_LYR.GetLayerDefn())        
        feature.SetGeometry(feat.geometry())
        feature.SetField("ID", str(idx+1))
        DAS_TEMP_LYR.CreateFeature(feature)
    DAS_TEMP.Destroy()
    # link catchment-names to waterdistrict names 
    os.system("gdal_rasterize -at -a ID -l subcatchment_id temp\subcatchment_id.shp subcatchment.tif")
    os.system("gdal_translate -of PCRaster subcatchment.tif subcatchment.map")
    subcatchmentmap = pcr.readmap("subcatchment.map")
    pcr.report(subcatchmentmap,'result1.map')
    alldistrictsmap = pcr.cover(pcr.ifthen(pcr.scalar(districtsmap,)>0,districtsmap),pcr.nominal(nohydrowd))
    pcr.report(alldistrictsmap,'result2.map')
    districtidmap = pcr.areamajority(subcatchmentmap,alldistrictsmap)
    pcr.report(districtidmap,'result3.map')
    alldistrictsnp=pcr.pcr2numpy(alldistrictsmap, -9999)
    districtidnp=pcr.pcr2numpy(districtidmap, -9999)
    MaxWD = np.amax(np.amax(alldistrictsnp,axis=0),axis=0)
    Catchid_list = []
    WDname_list = []
    WDid_list = []
    for WD in range(1,MaxWD+1):
        try:
            CATCH2WD = Counter(districtidnp[alldistrictsnp==WD]).most_common(1)[0][0]
            Catchid_list.append(CATCH2WD)
            WDid_list.append(WD)
            try:
                WDname_list.append(das_names[das_ids.index(int(CATCH2WD))])
            except: WDname_list.append("")
        except: continue
   
pcr.report(pcr.ordinal(pcr.ifthen(pcr.scalar(outletsmap) > 0., outletsmap)), "wflow_gauges.map")
pcr.report(pcr.ordinal(districtsmap), "wflow_subcatch.map")
pcr.report(pcr.streamorder(ldd),'wflow_streamorder.map')
OUTL_ATT = os.path.splitext(os.path.basename(OUTL_SHP))[0]
OUTL_TIF = OUTL_ATT + ".tif"
os.system("gdal_translate -of GTiff " + "wflow_gauges.map " + OUTL_TIF)
os.system("gdal_translate -of GTiff " + "wflow_subcatch.map " + "districts.tif")
os.system("gdal_translate -of GTiff " + "districts_nohydro.map " + "districts_nohydro.tif")
os.system("gdal_translate -of AAIGrid -ot Int32 " + "river_order.map " + "river_order.asc")
#
#os.system("ogr2ogr -a_srs EPSG:4326 districts_WGS84.shp")
os.system("gdal_polygonize.bat districts.tif -f 'ESRI_Shapefile' out.shp TEMP/temp0")
os.system('saga_cmd shapes_polygons "Polygon Dissolve" -POLYGONS=TEMP/temp0.shp -DISSOLVED=TEMP/temp.shp -FIELD_1=ID -DISSOLVE=0')
if tsrs == None:
    print "No tsrs specified, assumed source is in UTM"
    os.system("ogr2ogr TEMP/temp_utm.shp TEMP/temp.shp")
else:
    os.system("ogr2ogr -t_srs " + tsrs + " -s_srs " + ssrs + " TEMP/temp_utm.shp TEMP/temp.shp")

if not DAS_SHP is None:
    os.system("gdal_polygonize.bat districts_nohydro.tif -f 'ESRI_Shapefile' out.shp TEMP/demp0")
    os.system('saga_cmd shapes_polygons "Polygon Dissolve" -POLYGONS=TEMP/demp0.shp -DISSOLVED=TEMP/demp.shp -FIELD_1=ID -DISSOLVE=0')
    if tsrs == None:
        print "No tsrs specified, assumed source is in UTM"
        os.system("ogr2ogr TEMP/demp_utm.shp TEMP/demp.shp")
    else:
        os.system("ogr2ogr -t_srs " + tsrs + " -s_srs " + ssrs + " TEMP/demp_utm.shp TEMP/demp.shp") 

#
shapefile_utm = ogr.Open("TEMP/temp_utm.shp")
shapefile = ogr.Open("TEMP/temp.shp")
layer_utm = shapefile_utm.GetLayer(0)
layer = shapefile.GetLayer(0)
spatialRef_utm = layer_utm.GetSpatialRef()
spatialRef = layer.GetSpatialRef()

# Write district layer for part in LDD
WDIDS = []
AREAS = []
DistMax = 0

for idx, i in enumerate(range(layer_utm.GetFeatureCount())):
    feature_utm = layer_utm.GetFeature(i)
    feature = layer.GetFeature(i)
    if float(feature.GetField("DN")) > 0:
        featgeom_utm = feature_utm.geometry()
        featgeom = feature.geometry()
        Area = featgeom_utm.Area()
        AREAS.append(Area)
        feat_out = ogr.Feature(WADI_LYR.GetLayerDefn())
        feat_out.SetGeometry(featgeom)     
        Dist = feature.GetFieldAsInteger(0)
        WDIDS.append(Dist)
        DistMax = max([Dist,DistMax])
        feat_out.SetField("ID", str(Dist))
        feat_out.SetField("AREA_M2", Area)
        feat_out.SetField("HYDRO", "yes")
        if not DAS_ID is None:
            feat_out.SetField(CATCH_ATT,WDname_list[WDid_list.index(Dist)])
        WADI_LYR.CreateFeature(feat_out)

shapefile_utm.Destroy()
shapefile.Destroy()

# Write district layer for part not in LDD
if not DAS_SHP is None:
    shapefile_utm = ogr.Open("TEMP/demp_utm.shp")
    shapefile = ogr.Open("TEMP/demp.shp")
    layer_utm = shapefile_utm.GetLayer(0)
    layer = shapefile.GetLayer(0)
    spatialRef_utm = layer_utm.GetSpatialRef()
    spatialRef = layer.GetSpatialRef()    

    for idx, i in enumerate(range(layer_utm.GetFeatureCount())):
        feature_utm = layer_utm.GetFeature(i)
        feature = layer.GetFeature(i)
        if float(feature.GetField("DN")) > 0:
            featgeom_utm = feature_utm.geometry()
            featgeom = feature.geometry()
            Area = featgeom_utm.Area()
            feat_out = ogr.Feature(WADI_LYR.GetLayerDefn())
            feat_out.SetGeometry(featgeom)
            Dist = feature.GetFieldAsInteger(0)
            DistMax = max([Dist,DistMax])
            feat_out.SetField("ID", str(Dist))
            feat_out.SetField("AREA_M2", Area)
            feat_out.SetField("HYDRO", "no")
            if not DAS_ID is None:
                feat_out.SetField(CATCH_ATT,WDname_list[WDid_list.index(Dist)])
            WADI_LYR.CreateFeature(feat_out)
    
    shapefile_utm.Destroy()
    shapefile.Destroy()

WADI_out.Destroy()

## create emtpy water district outlets
rasterdriver = gdal.GetDriverByName('GTiff')
OUTL_DS = gdal.Open(OUTL_TIF,GA_ReadOnly)
if OUTL_DS is None:
    print 'Could not open ' + fn
    sys.exit(1)

cols = OUTL_DS.RasterXSize
rows = OUTL_DS.RasterYSize
geotransform = OUTL_DS.GetGeoTransform()
originX = geotransform[0]
originY = geotransform[3]
pixelWidth = geotransform[1]
pixelHeight = geotransform[5]  

band = OUTL_DS.GetRasterBand(1)

for x in range(cols):
    for y in range(rows):
        value = band.ReadAsArray(x, y, 1, 1)
        if value[0][0] > 0: 
            if value[0][0] in WDIDS:
                xCoord = originX + (0.5 + x)*pixelWidth
                yCoord = originY + (y+0.5)*pixelHeight
                Area = AREAS[WDIDS.index(value[0][0])]
                point = ogr.Geometry(ogr.wkbPoint)
                point.AddPoint(xCoord,yCoord)
                feat_out = ogr.Feature(OUTL_LYR.GetLayerDefn())
                feat_out.SetGeometry(point)
                feat_out.SetField("ID", str(value[0][0]))
                feat_out.SetField("AREA_M2", Area)
                feat_out.SetField("XCOORD", xCoord)
                feat_out.SetField("YCOORD", yCoord)
                OUTL_LYR.CreateFeature(feat_out)           

OUTL_out.Destroy()
#OUTL_DS = None

Summary = open("CreateWaterdistricts_summary.txt", "w+")
Summary.write("DistMax: "+ str(DistMax) +"\n")
Summary.close()

if not debug:

    def deletelist(itemlist):
        for item in itemlist:
            os.remove(item)
    
    deletelist(glob.glob(os.getcwd()+'/*.xml'))
    deletelist(glob.glob(os.getcwd()+'/*.asc'))
    deletelist(glob.glob(os.getcwd()+'/*.tif'))
    itemlist = ['connections.map','ldd_rivers.map','null.map','river_order.map','rivers.map','terminals.map','zero.map']
    deletelist(itemlist)


    itemlist = [CONN_SHP,SELEC_SHP,OBJ_SHP]
    DeleteShapes(itemlist)

    if os.path.isdir("TEMP/"):
        shutil.rmtree("TEMP/")
    os.makedirs("TEMP/")
    