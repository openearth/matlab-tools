#!/usr/bin/env python
import polygonrasterizer as pr
import numpy as np
import math
import pprint as pp

def test_polygons(tgt):
    '''
       Produces a test raster with some rasterized polygon shapes in it.
       tgt - target array
  
    '''

    polygons = []
    polygons.append(
        ([150832.750000, 150832.750000, 150794.312500, 150793.062500],
         [418243.500000, 418285.031250, 418284.437500, 418244.125000]))

    polygons.append(
        ([150832.750000, 150833.984375, 150712.468750, 150714.328125],
         [418323.500000, 418443.781250, 418443.156250, 418324.093750]))

    polygons.append(
        ([148032.859375, 147994.406250, 147952.875000],
         [418404.781250, 418443.218750, 418366.343750]))

    polygons.append(
        ([148034.093750, 147951.640625, 148035.953125],
         [418363.843750, 418363.218750, 418404.781250]))

    polygons.append(
        ([147994.406250, 148036.578125, 148032.234375],
         [418444.437500, 418443.843750, 418404.781250]))


    polygons.append(
        ([148251.765625, 149189.203125, 150796.250000, 149708.156250, 148246.187500, 148078.781250],
         [419212.062500, 418084.906250, 419223.218750, 420333.656250, 420099.281250, 419652.906250]))

    polygons.append(
        ([139100.578125, 138230.093750, 138297.062500, 139167.546875],
         [423598.093750, 423547.875000, 422560.187500, 422610.437500]))

    polygons.append(
        ([140104.984375, 140456.531250, 141008.953125],
         [422643.906250, 423464.187500, 422526.718750]))




    bbox = [129873.4, 416764.7, 152193.4, 426204.7]
    dx = 100
    dy = 100
    tgt[2,3] = 3.14
    
    ncols = math.ceil((bbox[2] - bbox[0])/dx)
    nrows = math.ceil((bbox[3] - bbox[1])/dy)

    xc = 0.5*dx + np.linspace(bbox[0], bbox[2], ncols, endpoint=False)
    yc = 0.5*dy + np.linspace(bbox[1], bbox[3], nrows, endpoint=False)
    
    print('Bounding box: ', bbox)
    print('nrows = ', nrows, ', ncols = ', ncols)
    print(xc)
    #    >>> y = np.linspace(0, 1, ny)
    #xv, yv = np.meshgrid(xc, yc)
    #    # bounding box for polygon
    tgt = np.zeros((nrows, ncols))
    #pr.fill_poly_with_pixels(xc, yc, np.array([140000, 145000, 145000]), np.array([420000, 420000, 423000]), tgt, 3.14)
    #pr.fill_poly_with_pixels(xc, yc, np.array([135000, 144000, 144000, 135000]), np.array([421000, 421000, 424000, 424000]), tgt, 1.23)
    for tpl in polygons:
        pr.fill_poly_with_pixels(xc, yc, np.array(tpl[0]), np.array(tpl[1]), tgt, 1.23)

    print('rasterized: ')
    #pp.pprint(tgt, width=1300, compact=False)
    print(np.array2string(tgt, threshold=np.inf, max_line_width=np.inf, separator=','))



################################################################
def main():
   usage = "usage: "+sys.executable+" %prog --[no]overwrite"
   parser = OptionParser(usage)

   # define options
   parser.add_option("--overwrite", dest="overwrite", action="store_true", default=True, help="Regenerate complete model and overwrite any existing files.")
   parser.add_option("--nooverwrite", dest="overwrite", action="store_false", help="Keep any existing previously generated files.")

   (opts, args) = parser.parse_args()

   generate_model(opts, args)

if __name__ == "__main__":
    #main()
    pxvals = np.zeros((13,7))
    test_polygons(pxvals)
    #print('pxvals.shape = ', pxvals.shape)
    #print(pxvals)
    #print('hoi')