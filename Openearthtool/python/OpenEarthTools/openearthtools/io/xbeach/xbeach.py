## python file to read XBeach output and write to netcdf file

# $Id: xbeach.py 12827 2016-07-29 14:49:32Z janjaapmeijer.x $
# $Date: 2016-07-29 07:49:32 -0700 (Fri, 29 Jul 2016) $
# $Author: janjaapmeijer.x $
# $Revision: 12827 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/xbeach/xbeach.py $
# $Keywords: $

import array,os,numpy,sys
# from pupynere import netcdf_file as nc
from scipy.io.netcdf import netcdf_file as nc
import numpy as np
import datetime
from optparse import OptionParser

# constants
fmt = '%Y-%m-%d %H:%M:%S'
class Params(dict):
    """Read and write XBeach params.txt files."""
    @staticmethod
    def fromfile(filename='params.txt'):
        """read the params/txt file"""
        with open(filename,'U') as f:
            key = None
            values = Params()
            for line in f:
                if line.strip().startswith('#') or line.strip().startswith('-') or line.strip().endswith(':') or not line.strip():
                    continue
                else:
                    if '=' in line:
                        key, value = map(str.strip, line.split('='))
                        values[key] = tonumber(value)
                    else:
                        if key is None:
                            raise ValueError("invalid line:\n" + line)
                        # We have some array type of value
                        values[key[1:]] = values.get(key[1:], []) + [line.strip()]
        return values

    def tofile(self, filename="params.txt"):
        phys_process = ['swave', 'nonh', 'single_dir', 'sedtrans', 'morphology', 'avalanching']
        grid_params = ['xori', 'yori', 'alfa', 'nx', 'ny', 'posdwn', 'depfile', 'vardx', 'xfile', 'yfile',
                       'thetamin', 'thetamax', 'thetanaut', 'dtheta_s', 'dtheta']
        model_time = ['tstop']
        wave_bc = ['instat', 'bcfile', 'snells']
        tide_bc = ['tideloc', 'zs0file', 'front', 'back']
        flow_params = ['bedfriction']
        morph_params = ['morfac', 'morstart']
        output_vars = ['tintg', 'tintm', 'outputformat']

        with open(filename, 'w') as f:
            f.writelines('### XBeach parameter settings input file\n')
            f.writelines('### Created on: ' + datetime.datetime.now().strftime(fmt) + '\n')

            f.writelines('\n### Physical processes\n')
            for key, value in self.items():
                if key in phys_process:
                        f.writelines('%-15s= %s' % (key, value) + '\n')

            f.writelines('\n### Grid parameters\n')
            for key, value in self.items():
                if key in grid_params:
                        f.writelines('%-15s= %s' % (key, value) + '\n')

            f.writelines('\n### Model time parameters\n')
            for key, value in self.items():
                if key in model_time:
                        f.writelines('%-15s= %s' % (key, value) + '\n')

            f.writelines('\n### Wave boundary condition parameters\n')
            for key, value in self.items():
                if key in wave_bc:
                        f.writelines('%-15s= %s' % (key, value) + '\n')

            f.writelines('\n### Tide boundary condition\n')
            for key, value in self.items():
                if key in tide_bc:
                        f.writelines('%-15s= %s' % (key, value) + '\n')

            f.writelines('\n### Flow parameters\n')
            for key, value in self.items():
                if key in flow_params:
                        f.writelines('%-15s= %s' % (key, value) + '\n')

            f.writelines('\n### Morphology parameters\n')
            for key, value in self.items():
                if key in morph_params:
                        f.writelines('%-15s= %s' % (key, value) + '\n')

            f.writelines('\n### Output variables\n')
            for key, value in self.items():
                if key in output_vars:
                    f.writelines('%-15s= %s' % (key, value) + '\n')

            for key, value in self.items():
                if key == 'nglobalvar':
                    f.writelines("\n%s = %s" % (key, value) + '\n')
                    for val in self['globalvar']:
                        f.writelines(val + '\n')
                elif key == 'nmeanvar':
                    f.writelines("%s = %s" % (key, value) + '\n')
                    for val in self['meanvar']:
                        f.writelines(val + '\n')


                # elif key in grid_params:
                #     for line in open(filename):
                #         match = re.match(r'###\s+Grid\s+Parameters.*$', line)
                #         print(match)
                #         if match:
                #             with open(filename, 'a') as f:
                #                 f.writelines("%s=%s" % (key, value) + '\n')
                #                 f.close()
                #


            # for line in open(filename):
            #     print(line)
            #     print(match)
            #     match = heading.match(line)
            #     if match: # found ID, print with comma
            #         f.write(match.group(1) + ",")
            #         continue
            #     match = pat_name.match(line)
            #     if match: # found name, print and end line
            #         f.write(match.group(1) + "\n")
            #
            #


                
            
        
# functions
def listdat(path):
    """find all .dat-files in directory"""
    import glob
    return glob.glob(os.path.join(path,'*.dat'))

def listfiles(path):
    import glob
    return glob.glob(os.path.join(path,'*.*'))

def copyfiles(src_path, dest_path):
    import shutil
    for filename in listfiles(src_path):
        shutil.copy(filename, dest_path)

def readdims(fullfile, verbose=True):
    """read dimensions from dims.dat"""

    if verbose:
        print('reading file: ' + fullfile)

    fileobj = open(fullfile, mode='rb')
    
    binvalues = array.array('d')
    binvalues.read(fileobj, 1 * 14)
    dims = numpy.array(binvalues, dtype=int);
    
    nt,nx,ny = tuple(1 + dims[0:3])
    
    fileobj.close()
    
    return nt,nx,ny

def readxy(fullfile, nx, ny, verbose=True):
    """read x and y from xy.dat"""
    
    if verbose:
        print('reading file: ' + fullfile)

    fileobj = open(fullfile, mode='rb')
    
    binvalues = array.array('d')
    binvalues.read(fileobj, nx * ny * 2)
    
    fileobj.close()
    
    xy = numpy.array(binvalues)
    
    x = numpy.reshape(xy[0:nx*ny], (ny, nx)).T
    y = numpy.reshape(xy[-nx*ny:], (ny, nx)).T
    
    return x,y

def readdata(fullfile, nx, nt, verbose=True):
    """read <variable> from <variable>.dat"""
    
    if verbose:
        print('reading file: ' + fullfile)
        
    fileobj = open(fullfile, mode='rb')
    
    binvalues = array.array('d')
    binvalues.read(fileobj, nx * nt)
    
    fileobj.close()
    
    data = numpy.array(binvalues)

    data = numpy.reshape(data, (nt, nx))
    
    return data

def tonumber(text):
    """cast a text to a number"""
    try:
        return int(text)
    except ValueError as e:
        pass
    try:
        return float(text)
    except ValueError as e:
        pass
    return text

def readbathy(filename='bed.dep'):
    """read the bathymetry file"""
    bathy = np.loadtxt(filename)
    return bathy

def writenc(ncfile, XB, nt, nx, ny, verbose=True):
    """write variable to netcdf file"""
    
    if verbose:
        print('writing file "' + ncfile + '"')
    # open file
    f = nc(ncfile, 'w')
    # global attributes
    f.title = 'XBeach calculation result'
    f.source = os.path.join(datadir, '*.dat')
    f.history = 'created on: ' + datetime.datetime.now().strftime(fmt)
    # dimensions
    f.createDimension('time', nt)
    f.createDimension('cross_shore', nx)
    f.createDimension('alongshore', ny)
    
    for variable in XB:
        if variable in ('x', 'y'):
            dims = ('cross_shore', 'alongshore')
        else:
            dims = ('time', 'cross_shore')
        tmp = f.createVariable(variable, 'f', dims)
        tmp[:] = XB[variable]
    
    # close file
    f.close()

if __name__ == '__main__':
    if not os.path.basename(sys.argv[0]) == 'spyder.pyw':
        # if not running in spyder
        parser = OptionParser()
        parser.add_option("-d", "--directory", dest="datadir", default='.', help="read .dat-files from <directory>*.dat")
        parser.add_option("-f", "--file", dest="filename", default='result.nc', help="write data to netcdf file FILENAME (extension='.nc')")
        parser.add_option("-q", "--quiet", action="store_false", dest="verbose", default=True, help="don't print status messages")
        (options, args) = parser.parse_args()
        
        datadir = os.path.abspath(options.datadir)
        verbose = options.verbose
        ncpath,ncfile = os.path.split(options.filename)
        if ncpath == '':
            ncpath = datadir
    else:
        datadir = os.path.abspath('.')
        ncpath = datadir
        ncfile = 'result.nc'
        verbose = True
    ncfname,ncext = os.path.splitext(ncfile)
    
    if not ncext.lower() == '.nc':
        ncfile = os.path.join(ncfname, '.nc')

    var = dict(listdat(datadir))
    if var.keys() == []:
        print('No .dat-files found in "' + datadir + '"')
    else:
        XB = dict()
        nt,nx,ny = readdims(var['dims'], verbose=verbose)
        XB['x'],XB['y'] = readxy(var['xy'], nx, ny, verbose=verbose)
        for variable in var:
            if not variable in ('dims', 'xy'):
                XB[variable] = readdata(var[variable], nx, nt, verbose=verbose)
        writenc(os.path.join(ncpath, ncfile), XB, nt, nx, ny, verbose=verbose)
