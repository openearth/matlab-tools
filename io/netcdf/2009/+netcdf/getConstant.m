function param = getConstant(param_name)
%netcdf.getConstant Return numeric value of named constant.
%   val = netcdf.getConstant(param_name) returns the numeric value 
%   corresponding to the name of a constant defined by the netCDF
%   library.  For example, netcdf.getConstant('noclobber') will return 
%   the numeric value corresponding to the netCDF constant NC_NOCLOBBER.
%
%   The value for param_name can be either upper case or lower case, and
%   does not need to include the leading three characters 'NC_'.
%
%   The list of all names can be retrieved with netcdf.getConstantNames
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstantNames
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

param = netcdflib('parameter', param_name);            
