function varargout = open(filename, mode, chunksize)
%netcdf.open Open netCDF file.
%   ncid = netcdf.open(filename, mode) opens a existing netCDF file and 
%   returns a netCDF ID in ncid.  
%
%   The type of access is described by the mode parameter,  which can be 
%   'WRITE' for read-write access, 'SHARE' for synchronous file 
%   updates, or 'NOWRITE' for read-only access.  The mode may also be 
%   a numeric value that can be retrieved via netcdf.getConstant.  The 
%   mode may also be a bitwise-or of numeric mode values.
%
%   [chosen_chunksize, ncid] = netcdf.open(filename, mode, chunksize) 
%   is similar to the above, but makes use of an additional 
%   performance tuning parameter, chunksize, which can affect I/O
%   performance.  The actual value chosen by the netCDF library may
%   not correspond to the input value.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_open" and "nc__open" functions in 
%   the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstant.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

if ischar(mode)
    mode = netcdf.getConstant(mode);
end

% Get the full path name.
fid = fopen(filename,'r');
if fid == -1
    error('MATLAB:netcdf:open:noSuchFile', ...
          'The specified file does not exist.');
end
filename = fopen(fid);
fclose(fid);


varargout = cell(1,nargout);
switch nargin
	case 2
	    [varargout{:}] = netcdflib ( 'open', filename, mode );
	case 3
	    [varargout{:}] = netcdflib ( 'pOpen', filename, mode, chunksize );
	otherwise
	    error ( 'MATLAB:netcdf:open:wrongNumberOfInputArguments', ...
	            'There must be either two or three input arguments supplied to netcdf.open.' );
end

