import numpy as np
from osgeo import gdal
from osgeo import osr
import polygonrasterizer as pr
import sys

class tiffwriter (object):
    def __init__(self, tiffname, bbox, res, nband, nptype, epsg, flipped=False):
        self.bbox = bbox
        self.res = res
        xmin, ymin, xmax, ymax = self.bbox
        xres, yres = self.res
        self.nx = int(np.ceil((xmax-xmin) / xres))
        self.ny = int(np.ceil((ymax-ymin) / yres))

        gdaltype = None
        if nptype == np.float64:
            gdaltype = gdal.GDT_Float64                   # todo: add more types 

        self.verbose = True        

        self.flip = flipped         
        if flipped:
            geotransform = (xmin, xres, 0, ymin + self.ny*yres, 0,-yres)    # FIAT required, negative delta Y
        else:
            geotransform = (xmin, xres, 0, ymin, 0, yres)                    # normal
		
        self.dst_ds = gdal.GetDriverByName('GTiff').Create(tiffname, self.nx, self.ny, nband, gdaltype)
        self.dst_ds.SetGeoTransform(geotransform)         # specify coords
        srs = osr.SpatialReference()                      # establish encoding
        srs.ImportFromEPSG(int(epsg))                     # my_epsg was obtained from the projection in Ugrid
        self.dst_ds.SetProjection(srs.ExportToWkt())      # export coords to file

    def from_polygons(self, polygons, my_var, nodata):
        pixels = np.array([[nodata]*self.nx]*self.ny)
        xmin, ymin, xmax, ymax = self.bbox
        xres, yres = self.res
        xg = (np.array(range(self.nx))+0.5) * xres + xmin # pixel x- and y-positions (1d)
        yg = (np.array(range(self.ny))+0.5) * yres + ymin
        npoly = len(polygons)
        for ipoly in range(npoly):                    # set the Pixel Data (interpolation part)
            if self.verbose:
                sys.stderr.write("Writing to TIFF Node : %8.8d, %6.1d%%\r"%(ipoly,round(ipoly*100.0/npoly)))       

            if not(my_var.mask[ipoly]):               # NaNs in the netCDF (masked values in the masked array) should not overwrite the TIFF_NODATA value
                pgon = polygons[ipoly]
                val = my_var.data[ipoly]
                pr.fill_poly_with_pixels(xg, yg, pgon['x'], pgon['y'], pixels, np.float64(val))

            if self.verbose:
                sys.stderr.write("\r")
        return pixels

    def fillband(self, bandnr, pixels, nodata):
        band = self.dst_ds.GetRasterBand(bandnr)
        band.SetNoDataValue(nodata)                       # set the no-data value
        if self.flip:
            band.WriteArray(np.flipud(pixels))            # pixels is the data array
        else:
            band.WriteArray(pixels)                       # pixels is the data array

    def close(self):
        self.dst_ds.FlushCache()                          # write to disk
        self.dst_ds = None


