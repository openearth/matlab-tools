gdal_translate -of GTiff null.map 12_WD_OUTFLOW_SUMBAWA.tif
gdal_rasterize -a ID -l 12_WD_OUTFLOW_SUMBAWA 12_WD_OUTFLOW_SUMBAWA.shp 12_WD_OUTFLOW_SUMBAWA.tif
gdal_translate -of PCRaster -ot Float32 12_WD_OUTFLOW_SUMBAWA.tif temp.map
pcrcalc wflow_gauges.map=ordinal(temp.map)

del temp.map


pause