from subprocess import call
import pcraster as pcr
import os
import numpy as np
import glob
import shutil
import wflow_lib as tr
import ConfigParser
import gc
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

   
def OpenConf(fn):
    config = ConfigParser.SafeConfigParser()
    config.optionxform = str

    if os.path.exists(fn):
        config.read(fn)
    else:
        print "Cannot open config file: " + fn
        sys.exit(1)
        
    return config

def configget(config,section,var,default):
    """
    gets parameter from config file and returns a default value
    if the parameter is not found
    """
    try:
        ret = config.get(section,var)
    except:
        print "returning default (" + default + ") for " + section + ":" + var
        ret = default
        
    return ret

Driver = ogr.GetDriverByName("ESRI Shapefile")
    
inifile = 'wflow_prepare.ini'
config=OpenConf(inifile)


# create workdir and resultdir
workdir = configget(config,"directories","workdir","work")
resultdir = configget(config,"directories","resultdir","staticmaps")
workdir = workdir + "/"
resultdir = resultdir + "/"

if os.path.isdir(workdir):
    shutil.rmtree(workdir)
os.makedirs(workdir)

if not os.path.isdir(resultdir):
    os.makedirs(resultdir)
    
# Read files
dem_in = configget(config,"files","demin","dem.tif")
rivshp = configget(config,"files","riverin","river.shp")
catchshp = configget(config,"files","catchmentin","catchment.shp")
landuse = configget(config,"files","landusein","empty")
soiltype = configget(config,"files","soiltypein","empty")

# Read parameters
burn_outlets = int(configget(config,"parameters","burn_outlets",10000))
burn_rivers = int(configget(config,"parameters","burn_rivers",200))
burn_connections = int(configget(config,"parameters","burn_connections",100))
burn_gauges = int(configget(config,"parameters","burn_gauges",100))
minorder = int(configget(config,"parameters","riverorder_min",3))

# Read transformations
t_srs = configget(config,"transformations","EPSG_target",None)

# Create mask
masklayer = configget(config,"mask","masklayer","catchment.shp")

# Output maps
catchment_map = configget(config,"staticmaps", "catchment", "wflow_catchment.map")
dem_map = configget(config,"staticmaps", "dem","wflow_dem.map")
demmax_map = configget(config,"staticmaps", "demmax","wflow_demmax.map")
demmin_map = configget(config,"staticmaps", "demmin","wflow_demmin.map")
gauges_map = configget(config,"staticmaps", "gauges","wflow_gauges.map")
landuse_map = configget(config,"staticmaps", "landuse","wflow_landuse.map")
ldd_map = configget(config,"staticmaps", "ldd","wflow_ldd.map")
river_map = configget(config,"staticmaps", "river","wflow_river.map")
outlet_map = configget(config,"staticmaps", "outlet", "wflow_outlet.map")
riverlength_fact_map = configget(config,"staticmaps", "riverlength_fact","wflow_riverlength_fact.map")
soil_map = configget(config,"staticmaps", "soil","wflow_soil.map")
streamorder_map = configget(config,"staticmaps", "streamorder","wflow_streamorder.map")
subcatch_map = configget(config,"staticmaps", "subcatch","wflow_subcatch.map")

maskext = os.path.splitext(os.path.basename(masklayer))[1]
if maskext == ".shp":
    maskdata = ogr.Open(masklayer)
    maskattr = os.path.splitext(os.path.basename(masklayer))[0]
    masklyr = maskdata.GetLayerByName(maskattr)
    shp_extent = list(masklyr.GetExtent())
    ds = gdal.Open(dem_in,GA_ReadOnly)
    cellsize = float(configget(config,"mask","cellsize",ds.RasterXSize))
    extent = [shp_extent[0],shp_extent[2],shp_extent[1],shp_extent[3]]
    extent_mask= list(hydrotopo.round_extent(extent, float(cellsize)))
    ds = None
elif maskext == ".tif" or maskext == ".map":
    ds = gdal.Open(masklayer,GA_ReadOnly)
    proj = ds.GetGeoTransform()
    cellsize = proj[1]
    extent_mask = [proj[0],proj[3]-ds.RasterYSize*cellsize,proj[0]+ds.RasterXSize*cellsize,proj[3]]
    ds = None

ds = gdal.Open(dem_in,GA_ReadOnly)
band = ds.GetRasterBand(1)
nodata = band.GetNoDataValue()
cellsize_in = ds.GetGeoTransform()[1]
upscalefactor = int(cellsize/cellsize_in)
ds = None
    
xmin, ymin, xmax, ymax = map(str, extent_mask)

dem_resample = workdir + "dem_resampled.tif"
if nodata == None:
    call(('gdalwarp', '-overwrite','-te', xmin, ymin, xmax, ymax,'-tr',str(cellsize),str(-cellsize), '-dstnodata', str(-9999),'-r','cubic',dem_in, dem_resample))
else: call(('gdalwarp', '-overwrite','-te', xmin, ymin, xmax, ymax,'-tr',str(cellsize),str(-cellsize), '-srcnodata', str(nodata), '-dstnodata', str(nodata),'-r','cubic',dem_in, dem_resample))

#set PCRaster properties and masks
dem_resample_map = resultdir + dem_map
call(('gdal_translate', '-of', 'PCRaster','-ot','Float32',dem_resample,dem_resample_map))
pcr.setclone(dem_resample_map)
pcr.setglobaloption("lddin")
dem = pcr.readmap(dem_resample_map)
mask = dem * 0
mask = pcr.scalar(pcr.ifthen(mask == 1,pcr.scalar(1)))
zeros = pcr.scalar(pcr.cover(mask,0))
ones = pcr.scalar(pcr.cover(mask,1))
zero_map = workdir + "zero.map"
zero_tif = workdir + "zero.tif"
pcr.report(zeros, zero_map)
call(('gdal_translate','-of','GTiff','-ot','Float32', zero_map,zero_tif))
#
# Strip riverlayer to points
print "split river-layer to nodes"
shapes = hydrotopo.Reach2Nodes(rivshp,t_srs,cellsize/2)
outlets = shapes[1]
connections = shapes[2]
#
# brun rivers, outlets and connections in DEM
print 'burn network objects to DEM'
print ' burn connection points'
outlets_att = os.path.splitext(os.path.basename(outlets))[0]
connections_att = os.path.splitext(os.path.basename(connections))[0]
rivshp_att = os.path.splitext(os.path.basename(rivshp))[0]
dem_resample_att = os.path.splitext(os.path.basename(dem_resample))[0]
connections_tif = workdir + connections_att + ".tif"
rivers_tif = workdir + rivshp_att + ".tif"
outlets_tif = workdir + outlets_att + ".tif"
call(('gdal_translate','-of','GTiff','-ot','Float32',zero_map,connections_tif))
call(('gdal_translate','-of','GTiff','-ot','Float32',zero_map,rivers_tif))
call(('gdal_translate','-of','GTiff','-ot','Float32',zero_map,outlets_tif))
call(('gdal_rasterize','-burn','1','-l',outlets_att,outlets,outlets_tif))
call(('gdal_rasterize','-burn','1','-l',connections_att,connections,connections_tif))

print ' burn river in order'
OrderSHPs = hydrotopo.ReachOrder(rivshp,t_srs,cellsize/4)
hydrotopo.Burn2Tif(OrderSHPs,'order',rivers_tif)

print ' translate tif to map'

# convert tifs
connections_map = workdir + connections_att + ".map"
rivers_map = workdir + rivshp_att + ".map"
outlets_map = workdir + outlets_att + ".map"
call(('gdal_translate','-of','PCRaster','-ot','Float32',connections_tif,connections_map))
call(('gdal_translate','-of','PCRaster','-ot','Float32',rivers_tif,rivers_map))
call(('gdal_translate','-of','PCRaster','-ot','Float32',outlets_tif,outlets_map))

# burn layers in dem
print ' burn layers in DEM'
outletsburn = pcr.scalar(pcr.readmap(outlets_map)) * pcr.scalar(burn_outlets)
connectionsburn = pcr.scalar(pcr.readmap(connections_map))*pcr.scalar(burn_connections)
riverburn = pcr.scalar(pcr.readmap(rivers_map))* pcr.scalar(burn_rivers)
ldddem = pcr.cover(dem, pcr.ifthen(riverburn>0,pcr.scalar(0)))
ldddem = ldddem - outletsburn - connectionsburn - riverburn
pcr.report(ldddem, workdir +"dem_burn.map")
#pcr.report(riverburn, "temp/" + rivshp_att + ".map")
#

# create catchment map
ldd = pcr.ldd(mask)
#
fieldDef = ogr.FieldDefn("ID", ogr.OFTString)
fieldDef.SetWidth(12)
#
TEMP_out = Driver.CreateDataSource(workdir + "temp.shp")
TEMP_LYR  = TEMP_out .CreateLayer("temp", geom_type=ogr.wkbMultiPolygon)
TEMP_LYR.CreateField(fieldDef)
#
DATA = ogr.Open(catchshp)
catchshpattr = os.path.splitext(os.path.basename(catchshp))[0]
LYR = DATA.GetLayerByName(catchshpattr)
#
for i in range(LYR.GetFeatureCount()):
    orgfeature = LYR.GetFeature(i)
    geometry = orgfeature.geometry()
    feature = ogr.Feature(TEMP_LYR.GetLayerDefn())
    feature.SetGeometry(geometry)
    feature.SetField("ID",str(i+1))
    TEMP_LYR.CreateFeature(feature)
TEMP_out.Destroy()
DATA.Destroy
#
catchments_tif = workdir + "catchments.tif"
catchments_map = workdir + "catchments.map"
call(('gdal_translate','-of','GTiff',zero_map,catchments_tif))
call(('gdal_rasterize','-at','-a','ID','-l',"temp",workdir + 'temp.shp',catchments_tif))
call(('gdal_translate','-of','PCRaster',catchments_tif,catchments_map))
catchments = pcr.readmap(catchments_map)
#
riverunique = pcr.clump(pcr.nominal(pcr.ifthen(riverburn > 0, riverburn)))
rivercatch = pcr.areamajority(pcr.ordinal(catchments),riverunique)
catchments = pcr.cover(pcr.ordinal(pcr.ifthen(catchments > 0, catchments)),pcr.ordinal(rivercatch),pcr.ordinal(0))
rivercatch_map = workdir + "catchments_river.map"
pcr.report(rivercatch,rivercatch_map)
#
TEMP_IN = ogr.Open(workdir + "temp.shp")
LYR = TEMP_IN.GetLayerByName("temp")

print 'calculating ldd'
for i in range(LYR.GetFeatureCount()):
    feature = LYR.GetFeature(i)
    catch = int(feature.GetField("ID"))
    print "calculating ldd for catchment: " + str(i+1) + "/" + str(LYR.GetFeatureCount()) + "...."
    ldddem_select = pcr.scalar(pcr.ifthen(catchments == catch, catchments)) * 0 + 1 * ldddem
    ldd_select=pcr.lddcreate(ldddem_select,float("1E35"),float("1E35"),float("1E35"),float("1E35"))
    ldd=pcr.cover(ldd,ldd_select)   
pcr.report(ldd,resultdir + ldd_map)
streamorder = pcr.ordinal(pcr.streamorder(ldd))
river = pcr.ifthen(streamorder >= pcr.ordinal(minorder),pcr.boolean(1))
mindem = int(np.min(pcr.pcr2numpy(pcr.ordinal(dem),9999999)))
dem = pcr.cover(dem,pcr.scalar(river)*0+mindem)
pcr.report(dem, resultdir+dem_map)
pcr.report(streamorder,resultdir+streamorder_map)
pcr.report(river,resultdir+river_map)
TEMP_IN.Destroy()


#call(('gdal_translate','-of','PCRaster',dem_in,workdir+"dem_in.map"))


#if upscalefactor > 1:
#    gc.collect()
#    print("upscale river length1 (checkerboard map)...")
#    ck = tr.checkerboard(dem_in_map,upscalefactor)
#    tr.report(ck,workdir + "ck.map")
#    tr.report(dem_in_map,workdir + "demck.map")
#    print("upscale river length2...")
#    fact = tr.area_riverlength_factor(ldd, ck,upscalefactor)
#    tr.report(fact,resultdir + "riverlength_fact.map")
#
#    print("Create DEM statistics...")
#    dem_ = tr.areaminimum(dem_in_map,ck)
#    tr.report(dem_,resultdir + "wflow_demmin.map")
#    dem_ = tr.areamaximum(dem_in_map,ck)
#    tr.report(dem_,resultdir + "wflow_demmax.map")

# write demmin demmax
pcr.report(dem, resultdir+demmin_map)
pcr.report(dem, resultdir+demmax_map)

# write riverlength_frac map
pcr.report(pcr.scalar(ones),resultdir+riverlength_fact_map)

# write outlets map
pcr.report(pcr.ifthen(pcr.ordinal(ldd) == 5, pcr.ordinal(1)),resultdir+outlet_map)

# write catchment map
catchment = pcr.ifthen(catchments > 0,pcr.ordinal(1))
pcr.report(catchment,resultdir+catchment_map)

# write soiltype map
if soiltype == "empty":
    pcr.report(pcr.nominal(ones),resultdir+soil_map)

# write landuse map
if landuse == "empty":
    pcr.report(pcr.nominal(ones),resultdir+landuse_map)

#
debug = configget(config,"general", "debug","false")
if debug == "false":
    hydrotopo.DeleteShapes(OrderSHPs)
    hydrotopo.DeleteShapes(shapes)
    hydrotopo.DeleteList(glob.glob(os.getcwd()+'/*.xml'))
#
gridxml = configget(config,"fews", "gridxml",None)
if not gridxml == None:
    hydrotopo.GridDef(dem_resample,gridxml)