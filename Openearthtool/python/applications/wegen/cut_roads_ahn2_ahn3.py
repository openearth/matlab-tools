import os
import psycopg2
import subprocess
import shapely.wkt
from utils_wcs import *

## SAVE geom
def save_geom_shp(ogrid, output_file):
    sqlStr = 'SELECT ogc_fid, wkb_geometry from allroads where ogc_fid = {}'.format(ogrid)
    cmd = """pgsql2shp -f \"{}\" -h localhost -u postgres -P postgres roadsnl \"{}\" 2> nul""".format(output_file, sqlStr)
    subprocess.call(cmd)

## CUT TIFF function
def cut_by_geojson(input_file, output_file, geojson_file, srs='+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs 2'):
    cmd = """gdalwarp -q --config GDAL_CACHEMAX 2048 -dstnodata -3.40282e+38 -s_srs \"{}\" -of GTiff -crop_to_cutline -overwrite -cutline \"{}\" \"{}\" \"{}\"""".format(srs, geojson_file, input_file, output_file)
    subprocess.call(cmd)

## Tiff differences
def tiffDiff(t1, t2, outfname):
    cmd = """python \"{}\" --calc="A-B" --outfile=\"{}\" -A \"{}\" -B \"{}\"""".format("D:\Anaconda2\Scripts\gdal_calc.py", outfname, t1, t2)
    subprocess.call(cmd)

## Compare tiffss
def compareTiffs(t1,t2, outfname):
    ds1 = gdal.Open(t1)
    arr1 = np.array(ds1.GetRasterBand(1).ReadAsArray())
    ds2 = gdal.Open(t2)
    arr2 = np.array(ds2.GetRasterBand(1).ReadAsArray())
    diff = arr1-arr2
    # Write diff
    [cols, rows] = diff.shape
    driver = gdal.GetDriverByName("GTiff")
    outdata = driver.Create(outfname, rows, cols, 1, gdal.GDT_CFloat32)
    outdata.SetGeoTransform(ds1.GetGeoTransform())
    outdata.SetProjection(ds1.GetProjection())
    outdata.GetRasterBand(1).SetNoDataValue(0.0)  # Transparent differences
    outdata.GetRasterBand(1).WriteArray(diff)
    outdata.FlushCache()

# Typical sql query
def perform_sql(sql, conn_string):
    conn = psycopg2.connect(conn_string)
    cur = conn.cursor()
    try:
        cur.execute(sql)
        conn.commit()
        return True
    except Exception, e:
        print(e.message.__str__())
        if e.message.__str__().index('already exists') > 0:
            return True
        else:
            return False
    finally:
        cur.close()
        conn.close()

# Get a nice unique name
def nice(ch):
    res = ''
    if isinstance(ch,list):
        for c in ch:
            res = res + (c+'_')
    else:
        res = ch
    return str(res).replace('None','').replace('[','').replace(']','')

# Get Raster transect intersect [default 5m]
def getDatafromWCS(wcsparams, rbbox, outtif, crs=28992, all_box=False):
    linestr = 'LINESTRING ({} {}, {} {})'.format(rbbox[0],rbbox[1],rbbox[2],rbbox[3])
    l = LS(linestr, crs, wcsparams[0], wcsparams[1], outtif)
    l.line()
    l.intersect(all_box=all_box)

# Store difference in the db
def storeDiffDB(diftif, iden, gjson):
    # Basic statistics of tiff
    ds = gdal.Open(diftif)
    arr = np.array(ds.GetRasterBand(1).ReadAsArray())
    arr[arr > 1000] = np.nan # delete nonsense values
    max = round(np.nanmax(arr), 3)
    min = round(np.nanmin(arr),3)
    mean = round(np.nanmean(arr),3)
    if np.isnan(max):   max = -99999
    if np.isnan(min):   min = -99999
    if np.isnan(mean):  mean = -99999
    sqlStr = """
    INSERT INTO results(iden, mean, min, max, wkb_geometry)
    VALUES ({},{},{},{}, ST_GeomFromText('{}',28992))""".format(iden, mean, min, max, gjson)
    return sqlStr

# Round a bounding box [5m]
def round_bbox(bbox):
    b0 = int(round(bbox[0]) - 5)
    b1 = int(round(bbox[1]) - 5)
    b2 = int(round(bbox[2]) + 5)
    b3 = int(round(bbox[3]) + 5)
    return (b0,b1,b2,b3)

# Delete file if exists
def delete_if_exists(f):
    if os.path.exists(f):
        os.remove(f)

# Cleanup shapefile
def cleanup_shapefile(b):
    for ext in ['.shp','.prj','.dbf','.shx','.cpg']:
        delete_if_exists(b.replace('.shp',ext))

## MAIN
def main():
    # Define our connection string
    conn_string = "host='localhost' dbname='roadsnl' user='postgres' password='postgres'"
    conn = psycopg2.connect(conn_string)
    cursor = conn.cursor()
    print "INFO: Connected to database!\n"

    # Query database
    #cursor.execute("select awegnummer, ewegnummer, nwegnummer, ogc_fid, ST_Astext(ST_Envelope(ST_Buffer(wkb_geometry, 20))) as bbox, ST_Asgeojson(wkb_geometry) as json from allroads where awegnummer @> ARRAY['A12']::varchar[]")
    cursor.execute("select awegnummer, ewegnummer, nwegnummer, ogc_fid, ST_Astext(ST_Envelope(ST_Buffer(wkb_geometry, 20))) as bbox, ST_Astext(wkb_geometry) as txt from allroads where awegnummer @> ARRAY['A12']::varchar[]")
    print "INFO: Loading records ..."

    # WCS to cut
    input_wcs = {
        'ahn2': ['https://geodata.nationaalgeoregister.nl/ahn2/wcs?', 'ahn2:ahn2_5m', '1.1.1'],
        'ahn3': ['https://geodata.nationaalgeoregister.nl/ahn3/wcs?', 'ahn3:ahn3_5m_dtm', '1.1.1']
    }

    # Output directory
    #outdir = r'N:\Projects\11202000\11202179\B. Measurements and calculations\elevationdata_v2_JS'
    outdir = './elevationdata_V2'

    # Loop over shapes
    i=0
    records = cursor.fetchall()
    N=len(records)

    for r in records:
        (a, e, n, iden, wktbbox, geom) = r

        # Bbox to float
        bbox = shapely.wkt.loads(wktbbox)
        bbox = round_bbox(bbox.bounds)

        # Build unique name
        name = nice(a) + nice(e) + nice(n) + nice(iden)
        print '{} - Cutting {} of {} ...'.format(name, i, N)

        # Save area shp
        shpfile = os.path.join(outdir, name + '.shp')
        if not (os.path.exists(shpfile)):
            save_geom_shp(iden, shpfile)

        res = []
        for key, wcsparams in input_wcs.iteritems():
            # Cut/WCS
            otiff = os.path.join(outdir, '{}_{}.tif'.format(name, key))
            otiff_clip = otiff.replace('.tif', '_clipped.tif')
            res.append(otiff_clip)
            if not(os.path.exists(otiff)):
                getDatafromWCS(wcsparams, bbox, otiff)
            # Clip by shape
            if not (os.path.exists(otiff_clip)):
                cut_by_geojson(otiff, otiff_clip, shpfile)
            # Cleanup
            delete_if_exists(otiff)
        i+=1

        # Difference
        diftif = res[0].replace('ahn3_clipped.tif', '_diff.tif')
        tiffDiff(res[0], res[1], diftif)

        # Store diff in db
        sqlstr=storeDiffDB(diftif, iden, geom)
        perform_sql(sqlstr, conn_string)

        # Cleanup
        cleanup_shapefile(os.path.abspath(shpfile))


if __name__ == "__main__":
    main()
