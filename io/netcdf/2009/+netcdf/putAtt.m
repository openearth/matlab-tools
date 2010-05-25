function putAtt(ncid,varid,attname,attvalue)
%netcdf.putAtt Write netCDF attribute.
%   netcdf.putAtt(ncid,varid,attrname,attrvalue) writes an attribute
%   to a netCDF variable specified by varid.  In order to specify a 
%   global attribute, use netcdf.getConstant('GLOBAL') for the varid.  
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_put_att" family of functions in 
%   the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstant.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

% Determine the xtype (datatype) and attribute data parameters.
% Get the datatype from the class of data.
switch ( class(attvalue) )
  case 'double' 
    xtype = netcdf.getConstant('double');
  case 'single' 
    xtype = netcdf.getConstant('float');
  case 'int32' 
    xtype = netcdf.getConstant('int');
  case 'int16' 
    xtype = netcdf.getConstant('short');
  case { 'int8', 'uint8' }
    xtype = netcdf.getConstant('byte');
  case 'char' 
    xtype = netcdf.getConstant('char');
  otherwise 
    error('MATLAB:netcdf:putAtt:invalidDatatype', ... 
          'The datatype %s is not allowed with %s.', ... 
          class(attvalue), mfilename );
end



% Determine the correct function string.
switch ( class(attvalue) ) 
  case 'double' 
    funstr = 'putAttDouble'; 
  case 'single'
    funstr = 'putAttFloat'; 
  case 'int32' 
    funstr = 'putAttInt'; 
  case 'int16' 
    funstr = 'putAttShort'; 
  case 'int8' 
    funstr = 'putAttSchar'; 
  case 'uint8' 
    funstr = 'putAttUchar'; 
  case 'char' 
    funstr = 'putAttText'; 
  otherwise 
    error('MATLAB:netcdf:putAtt:badDatatype', ... 
          'The datatype %s is not allowed with %s.', ...
          class(attvalue), mfilename ); 
end



% Invoke the correct netCDF library routine.
if ischar(attvalue)
    netcdflib('putAttText',ncid,varid,attname,attvalue);
else
    netcdflib(funstr,ncid,varid,attname,xtype,attvalue);
end


