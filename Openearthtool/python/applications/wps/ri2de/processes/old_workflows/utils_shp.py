from osgeo import ogr
from osgeo import gdal
import os
from shutil import copyfile

def createBuffer(inputFile, outputBuffer, bufferDist):
    print inputFile
    inputds = ogr.Open(inputFile)
    inputlyr = inputds.GetLayer()

    shpdriver = ogr.GetDriverByName('ESRI Shapefile')
    if os.path.exists(outputBuffer):
        shpdriver.DeleteDataSource(outputBuffer)
    outputBufferds = shpdriver.CreateDataSource(outputBuffer)
    bufferlyr = outputBufferds.CreateLayer(outputBuffer, geom_type=ogr.wkbPolygon)
    featureDefn = bufferlyr.GetLayerDefn()

    for feature in inputlyr:
        ingeom = feature.GetGeometryRef()
        geomBuffer = ingeom.Buffer(bufferDist)

        outFeature = ogr.Feature(featureDefn)
        outFeature.SetGeometry(geomBuffer)
        bufferlyr.CreateFeature(outFeature)
        
def creategrid(fileIn, fileOut,cellsize):
    
    NoData_value = -9999
    xres = cellsize
    yres = cellsize
    
    # Open Shapefile
    source = ogr.Open(fileIn)
    source_layer = source.GetLayer()
    xmin, xmax, ymin, ymax = source_layer.GetExtent()
    xmin = int(xmin)
    xmax = int(xmax)
    ymin = int(ymin)
    ymax = int(ymax)
    xdim = int((xmax - xmin) / xres)
    ydim = int((ymax - ymin) / yres)
    xmax = xmin+(xdim*xres)
    ymax = ymin+(ydim*yres)
    
    # Create Target - TIFF
    raster = gdal.GetDriverByName('GTiff').Create(fileOut, xdim, ydim, 1, gdal.GDT_Byte)
    raster.SetGeoTransform((xmin, xres, 0, ymax, 0, -yres))
    band = raster.GetRasterBand(1)
    band.SetNoDataValue(NoData_value)
    
    # Rasterize
    gdal.RasterizeLayer(raster, [1], source_layer,burn_values=[1])
    return fileOut

def createmask(fileIn, fileOut, targetfile):
    copyfile(targetfile, fileOut)      
    os.system('gdal_rasterize -burn 1 -l ' + fileIn[0:-4] + ' ' + fileIn + ' ' + fileOut)

def createClipedShapefile(filter_area,inShapefile,outShapefile):
    
    os.system('ogr2ogr -spat ' + str(filter_area[0]) + ' ' + str(filter_area[1]) + ' ' + str(filter_area[2]) + ' ' + str(filter_area[3]) + ' -clipsrc spat_extent ' + outShapefile + ' ' + inShapefile)
    
def createFilteredShapefile(filter_value,filter_area,inShapefile,outShapefile):

#    filter_value = ['trunk', 'primary']
#    inShapefile  = "roads.shp"
#    outShapefile = "roads_filter.shp"
#    filter_area = (1892743.319, 4632654.133, 1947567.929, 4673772.591)
 
    # Get the input Layer
    inDriver = ogr.GetDriverByName("ESRI Shapefile")
    inDataSource = inDriver.Open(inShapefile, 0)
    inLayer = inDataSource.GetLayer()
    
    #Filter layer
    inLayer.SetAttributeFilter("fclass IN {}".format(tuple(filter_value)))
    
    # Create the output LayerS
    outDriver = ogr.GetDriverByName("ESRI Shapefile")

    # Remove output shapefile if it already exists
    if os.path.exists(outShapefile):
        outDriver.DeleteDataSource(outShapefile)

    # Create the output shapefile
    outDataSource = outDriver.CreateDataSource(outShapefile)
    out_lyr_name = os.path.splitext(os.path.split( outShapefile )[1] )[0]
    outLayer = outDataSource.CreateLayer(out_lyr_name, geom_type=ogr.wkbLineString )

    # Add input Layer Fields to the output Layer if it is the one we want
    inLayerDefn = inLayer.GetLayerDefn()
    for i in range(0, inLayerDefn.GetFieldCount()):
        fieldDefn = inLayerDefn.GetFieldDefn(i)
        outLayer.CreateField(fieldDefn)

    # Get the output Layer's Feature Definition
    outLayerDefn = outLayer.GetLayerDefn()

    # Add features to the ouput Layer
    for inFeature in inLayer:
        # Create output Feature
        outFeature = ogr.Feature(outLayerDefn)

        # Add field values from input Layer
        for i in range(0, outLayerDefn.GetFieldCount()):
            fieldDefn = outLayerDefn.GetFieldDefn(i)
            outFeature.SetField(outLayerDefn.GetFieldDefn(i).GetNameRef(),
                inFeature.GetField(i))

        # Set geometry as centroid
        geom = inFeature.GetGeometryRef()
        outFeature.SetGeometry(geom.Clone())
        # Add new feature to output Layer
        outLayer.CreateFeature(outFeature)
        outFeature = None

    # Save and close DataSources
    inDataSource = None
    outDataSource = None