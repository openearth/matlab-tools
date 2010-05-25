function names = getConstantNames()
%netcdf.getConstantNames Return list of constants known to netCDF library.
%   names = netcdf.getConstantNames() returns a list of names of netCDF 
%   library constants, definitions, and enumerations.  When these 
%   strings are supplied as actual parameters to the netCDF package 
%   functions, they will automatically be converted to the appropriate 
%   numeric value.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.create, netcdf.defVar, netcdf.open, 
%   netcdf.setDefaultFormat, netcdf.setFill.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

names = netcdflib('getConstantNames');
names = sort(names);

