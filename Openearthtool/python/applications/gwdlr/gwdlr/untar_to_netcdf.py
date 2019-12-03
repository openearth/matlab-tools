# -*- coding: utf-8 -*-
"""
Created on Fri Aug 15 13:18:10 2014

@author: winsemi
"""
import tarfile
import read_gwdlr_raw
import shutil
import os
import numpy as np
import pdb
import netCDF4 as nc

def recursive_glob(rootdir='.', suffix=''):
    """
    Prepares a list of files in location rootdir, with a suffix
    input:
        rootdir:    string, path-name
        suffix:     suffix of required files
    output:
        fileList:   list-strings, file paths and names
    """

    fileList = [os.path.join(rootdir, filename)
            for rootdir, dirnames, filenames in os.walk(rootdir)
            for filename in filenames if filename.endswith(suffix)]
    fileList.sort()
    return fileList

def prepare_nc(trgFile, x, y, metadata, var_name, units, standard_name, datatype='f4', chunksizes=(6000, 6000)):
    print('Setting up {:s}').format(trgFile)
    nc_trg = nc.Dataset(trgFile, 'w')
    print('Setting up dimensions and attributes')
    nc_trg.createDimension('lat', len(y))
    nc_trg.createDimension('lon', len(x))
    y_var = nc_trg.createVariable('lat','f4',('lat',))
    y_var.standard_name = 'latitude'
    y_var.long_name = 'latitude'
    y_var.units = 'degrees_north'
    x_var = nc_trg.createVariable('lon','f4',('lon',))
    x_var.standard_name = 'longitude'
    x_var.long_name = 'longitude'
    x_var.units = 'degrees_east'
    y_var[:] = y
    x_var[:] = x
    projection= nc_trg.createVariable('projection','c')
    projection.long_name = 'wgs84'
    projection.EPSG_code = 'EPSG:4326'
    projection.proj4_params = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
    projection.grid_mapping_name = 'latitude_longitude'

    # now add all attributes from user-defined metadata
    for attr in metadata:
        nc_trg.setncattr(attr, metadata[attr])
    # add a variable
    new_var = nc_trg.createVariable(var_name, datatype, ('lat', 'lon', ), zlib=True, chunksizes=chunksizes, fill_value=-9999)
    new_var.units = units
    new_var.standard_name = standard_name
    nc_trg.sync()
    nc_trg.close()

def untar_to_netcdf(folder, filename, tempdir):
    filelist = recursive_glob(folder, filename)
    #for targz in filelist:
        #f = tarfile.open(targz)
        #f.extractall(tempdir)
        # now make a list of all extracted files and treat these!
        #unzipped_list = recursive_glob(tempdir, '.bin')
        #f.close()
        
        #shutil.rmtree(tempdir)
        #os,makedirs(tempdir)
        
        
    return filelist
    
folder = r'd:\data\GlobalWidthDatabase\SHEDS'
filename = 'flwdir.tar.gz'
tempdir = r'd:\data\GlobalWidthDatabase\temp'
datatype = '<i1'

metadata = {}
metadata['title'] = 'Global river width database'
metadata['source'] = 'SRTM 4.1, SRTM permanent water bodies database'
metadata['history'] = 'converted from original files obtained from Yamazaki'
metadata['contact'] = 'hessel.winsemius@deltares.nl, gennaddi.donchyts@deltares.nl, wiebe.deboer@deltares.nl'
metadata['references'] = 'Yamazaki, D., O’Loughlin, F., Trigg, ' + \
    'M. A., Miller, Z. F., Pavelsky, T. M. and Bates, P. D.: Development ' + \
    'of the Global Width Database for Large Rivers, Water Resour. Res., ' + \
    'doi:10.1002/2013WR014664, 2014.'
metadata['institution'] = 'Deltares'
metadata['disclaimer'] = 'The quality and availability of these data can in no ' + \
    'way be guaranteed by Deltares and any of its associate parties'
metadata['license'] = 'Creative Commons 3.0'
metadata['conventions'] = 'CF-1.7'


lly = -90
llx = -180
urx = 180
ury = 90
nrcols = 432000
nrrows = 216000

# prepare axes
xaxis = np.linspace(llx+1./2400, urx-1./2400, nrcols)
yaxis = np.linspace(lly+1./2400, ury-1./2400, nrrows)
src_missval = -9
trgFile = 'flwdir.nc'

# if existing, remove the temp dir completely
try:
    print('Cleaning up {:s}...').format(tempdir)
    shutil.rmtree(tempdir)
except:
    print('{:s} not existing...').format(tempdir)
    
# now (re) make the tempdir
print('Preparing {:s}...').format(tempdir)
os.makedirs(tempdir)


# prepare netcdf file and reopen it for appending
prepare_nc(trgFile, xaxis, yaxis, metadata, 'flwdir', 'dir', 'flow_directions', datatype='i2', chunksizes=(1000, 1000))
#
nc_trg = nc.Dataset(trgFile, 'a')

# re-open the variable for writing
var_trg = nc_trg.variables['flwdir']

filelist = recursive_glob(folder, filename)
for targz in filelist:
    print('Untarring {:s}').format(targz)
    f = tarfile.open(targz)
    f.extractall(tempdir)
    f.close()
    # now make a list of all extracted files and treat these!
    unzipped_list = recursive_glob(tempdir, '.bin')
    for unzipped_file in unzipped_list:
        llx, lly, x, y, data = read_gwdlr_raw.read_raw_yama(unzipped_file, 1, datatype, 6000, 6000)
        # replace missings by -9999
        print('Writing {:s} to netCDF file...').format(unzipped_file)
        data[data==src_missval] = -9999
        idx_xmin = (np.abs(xaxis - x[0])).argmin()
        idx_xmax = (np.abs(xaxis - x[-1])).argmin()
        idx_ymin = (np.abs(yaxis - y[0])).argmin()
        idx_ymax = (np.abs(yaxis - y[-1])).argmin()
        var_trg[idx_ymin:idx_ymax+1, idx_xmin:idx_xmax+1] = data
        
    # after all files are treated, delete them and continue with the next gz file.    
    print('Cleaning up {:s}...').format(tempdir)
    shutil.rmtree(tempdir)
    os.makedirs(tempdir)
nc_trg.sync()
nc_trg.close()
