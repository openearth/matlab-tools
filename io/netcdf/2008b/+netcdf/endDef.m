function endDef(ncid,varargin)
%netcdf.endDef End netCDF file define mode.
%   netcdf.endDef(ncid) Takes a netCDF file identified by ncid out of
%   define mode.
%
%   netcdf.endDef(ncid,h_minfree,v_align,v_minfree,r_align) is the same
%   as netcdf.endDef, but with the addition of four performance tuning
%   parameters.  
%
%   One reason for using the performance parameters is to reserve
%   extra space in the netCDF file header using the h_minfree parameter.  
%   For example,
%
%       ncid = netcdf.endDef(ncid,20000,4,0,4);
%
%   reserves 20000 bytes in the header, which may be used later when 
%   adding attributes.  This can be extremely efficient when working 
%   with very large files.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_enddef" and "nc__enddef" functions 
%   in the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$


switch nargin
case 1
    netcdflib('endDef', ncid);            
case 5
    netcdflib('pEndDef', ncid, varargin{:});            
otherwise
    error ( 'MATLAB:netcdf:endDef:wrongNumberOfInputArguments', ...
            'There must be either one or five input arguments supplied to netcdf.endDef.' );
end

