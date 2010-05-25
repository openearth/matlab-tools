function putVar(ncid,varid,varargin)
%netcdf.putVar Write data to netCDF variable.
%   netcdf.putVar(ncid,varid,data) writes data to an entire netCDF
%   variable.  The variable is identified by varid and the netCDF file 
%   is identified by ncid.
%
%   netcdf.putVar(ncid,varid,start,data) writes a single data value into 
%   the variable at the specified index. 
%
%   netcdf.putVar(ncid,varid,start,count,data) writes an array section 
%   of values into the netCDF variable.  The array section is specified 
%   by the start and count vectors, which give the starting index and 
%   count of values along each dimension of the specified variable.
%
%   netcdf.putVar(ncid,varid,start,count,stride,data) uses a sampling 
%   interval given by the stride argument.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_put_var" family of functions in 
%   the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

% Which family of functions?
switch nargin
  case 3
    funcstr = 'putVar';
  case 4
    funcstr = 'putVar1';
  case 5
    funcstr = 'putVara';
  case 6
    funcstr = 'putVars';
	otherwise
	    error ( 'MATLAB:netcdf:putVar:wrongNumberOfInputArguments', ...
	            'There must be between two and six input arguments supplied to netcdf.putVar.' );
end


    


% Finalize the function string from the appropriate datatype.
switch ( class(varargin{end}) ) 
  case 'double' 
    funcstr = [funcstr 'Double']; 
  case 'single'
    funcstr = [funcstr 'Float']; 
  case 'int32' 
    funcstr = [funcstr 'Int']; 
  case 'int16' 
    funcstr = [funcstr 'Short']; 
  case 'int8' 
    funcstr = [funcstr 'Schar']; 
  case 'uint8' 
    funcstr = [funcstr 'Uchar']; 
  case 'char' 
    funcstr = [funcstr 'Text']; 
  otherwise 
    error('MATLAB:netcdf:putVar:badDatatype', ... 
          'The datatype %s is not allowed with %s.', ...
          class(varargin{end}), mfilename ); 
end



% Invoke the correct netCDF library routine.
netcdflib(funcstr,ncid,varid,varargin{:});


