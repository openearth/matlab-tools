function data = getVar(ncid,varid,varargin)
%netcdf.getVar Return data from netCDF variable. 
%   data = netcdf.getVar(ncid,varid) reads an entire variable.  The 
%   class of the output data will match that of the netCDF variable.
%
%   data = netcdf.getVar(ncid,varid,start) reads a single value starting
%   at the specified index.
%
%   data = netcdf.getVar(ncid,varid,start,count) reads a contiguous
%   section of a variable.
%
%   data = netcdf.getVar(ncid,varid,start,count,stride) reads a strided
%   section of a variable.
% 
%   This function can be further modified by using a datatype string as 
%   the final input argument.  This has the effect of specifying the 
%   output datatype as long as the netCDF library allows the conversion.
%
%   The list of allowable datatype strings consists of 'double', 
%   'single', 'int32', 'int16', 'int8', and 'uint8'.
%   
%   To read in an entire integer variable as double precision, use 
%
%     data=netcdf.getVar(ncid,varid,'double');
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_get_var" family of functions in 
%   the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

error ( nargchk(2,6,nargin,'struct') );

% How many index arguments do we have?  This tells us whether we
% are retrieving an entire variable, just a single value, a contiguous 
% subset, or a strided subset.
if (nargin > 2) && ischar(varargin{end})
    num_index_args = nargin - 2 - 1;
else
    num_index_args = nargin - 2;
end
    
% Figure out whether we are retrieving an entire variable, just a single
% value, a contiguous subset, or a strided subset.
switch ( num_index_args ) 
  case 0
    funcstr = 'getVar';  % retrieve the entire variable
  case 1
    funcstr = 'getVar1'; % retrieve just one element
  case 2
    funcstr = 'getVara'; % retrieve a contiguous subset
  case 3
    funcstr = 'getVars'; % retrieve a strided subset.
end


if (nargin > 2) && ischar(varargin{end})
    % An output datatype was specified.  Determine which funcstr
    % we need to use, and then don't forget to remove the output
    % datatype from the list of inputs.
    switch ( varargin{end} )
      case 'double'
        funcstr = [funcstr 'Double'];
      case { 'float', 'single' }
        funcstr = [funcstr 'Float'];
      case { 'int', 'int32' }
        funcstr = [funcstr 'Int'];
      case { 'short', 'int16' }
        funcstr = [funcstr 'Short'];
      case { 'schar', 'int8' }
        funcstr = [funcstr 'Schar'];
      case { 'uchar', 'uint8' }
        funcstr = [funcstr 'Uchar'];
      case { 'text', 'char' }
        funcstr = [funcstr 'Text'];
      otherwise
        error('MATLAB:netcdf:getVar:badDatatypeSpecification', ...
              '%s is not allowed as an output netCDF datatype.', ...
              varargin{end} );
    end
    
    data = netcdflib(funcstr,ncid,varid,varargin{1:end-1});            
    
else
    % The last argument is not character, meaning we keep the 
    % native datatype.
    [varname,xtype] = netcdf.inqVar(ncid,varid);
    switch(xtype)
      case 6 % NC_DOUBLE
        funcstr = [funcstr 'Double'];
      case 5 % NC_FLOAT
        funcstr = [funcstr 'Float'];
      case 4 % NC_INT
        funcstr = [funcstr 'Int'];
      case 3 % NC_SHORT
        funcstr = [funcstr 'Short'];
      case 2 % NC_CHAR
        funcstr = [funcstr 'Text'];
      case 1 
        % NC_BYTE.  This is an unusual case.  The netCDF datatype
        % is ambiguous here as to whether it is uint8 or int8.  
        % We will assume int8.
        funcstr = [funcstr 'Schar'];
      otherwise
        error('MATLAB:netcdf:getVar:unrecognizedDatatype', ...
              '%d is not a recognized netCDF datatype.', xtype );
    end
    
    data = netcdflib(funcstr,ncid,varid,varargin{:});            

end

    
