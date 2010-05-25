function varargout = create(filename, mode, varargin)
%netcdf.create Create new netCDF file.
%   ncid = netcdf.create(filename, mode) creates a new netCDF file 
%   according to the file creation mode.  The return value is a file
%   ID.  
%   
%   The type of access is described by the mode parameter, which could
%   be 'noclobber' to protect existing files, 'share' for synchronous 
%   file updates, or '64bit_offset' to allow the creation of files which
%   are larger than two gigabytes.  The mode may also be a numeric value 
%   that can be retrieved via netcdf.getConstant, or even be a 
%   bitwise-or of numeric mode values.  
%
%   [chunksize_out, ncid]=netcdf.create(filename,mode,initsz,chunksize) 
%   creates a new netCDF file with additional performance tuning 
%   parameters.  initsz sets the initial size of the file.  
%   chunksize can affect I/O performance.  The actual value chosen by 
%   the netCDF library may not correspond to the input value.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_create" and "nc__create" functions 
%   in the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstant.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

if ~(ischar(mode) || isnumeric(mode))
    error ( 'MATLAB:netcdf:badModeDatatype', ...
            'The mode must either be char or numeric.' );
end

% Make the mode numeric.
if ischar(mode)
    mode = netcdf.getConstant(mode);
end



varargout = cell(1,nargout);
switch nargin
case 2
    ncid = netcdflib('create', filename, mode);            
    varargout{1} = ncid;
case 4
    [czout,ncid] = netcdflib('pCreate', filename, mode, varargin{:}); 
    varargout{1} = czout;
    varargout{2} = ncid;
otherwise
    error ( 'MATLAB:netcdf:create:wrongNumberOfInputArguments', ...
            'There must be either two or four input arguments supplied to netcdf.create.' );
end




