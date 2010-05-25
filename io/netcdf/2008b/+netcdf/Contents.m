%NETCDF Summary of MATLAB NETCDF capabilities.
%   MATLAB provides low-level access to netCDF files via direct access to 
%   more than 30 functions in the netCDF library.  To use these MATLAB 
%   functions, you must be familiar with the netCDF C interface.  The 
%   "NetCDF C Interface Guide" for version 3.6.2 may be consulted at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%
%   In most cases, the syntax of the MATLAB function is similar to the 
%   syntax of the netCDF library function.  The functions are implemented 
%   as a package called "netcdf".  To use these functions, one needs to 
%   prefix the function name with package name "netcdf", i.e. 
%
%      ncid = netcdf.open ( ncfile, mode );
%
%   The following table lists all the netCDF library functions supported by 
%   the netCDF package.
%
%      abort            - Revert recent netCDF file definitions.
%      close            - Close netCDF file.
%      create           - Create new netCDF file.
%      endDef           - End netCDF file define mode.
%      inq              - Return information about netCDF file.
%      inqLibVers       - Return netCDF library version information.
%      open             - Open netCDF file.
%      reDef            - Set netCDF file into define mode.
%      setDefaultFormat - Change default netCDF file format.
%      setFill          - Set netCDF fill mode.
%      sync             - Synchronize netCDF dataset to disk.  
%      
%      defDim           - Create netCDF dimension.
%      inqDim           - Return netCDF dimension name and length.
%      inqDimID         - Return dimension ID.
%      renameDim        - Change name of netCDF dimension.
%      
%      defVar           - Create netCDF variable.
%      getVar           - Return data from netCDF variable.
%      inqVar           - Return information about variable.
%      inqVarID         - Return ID associated with variable name.
%      putVar           - Write data to netCDF variable.
%      renameVar        - Change name of netCDF variable.
%      
%      copyAtt          - Copy attribute to new location.
%      delAtt           - Delete netCDF attribute.
%      getAtt           - Return netCDF attribute.
%      inqAtt           - Return information about netCDF attribute.
%      inqAttID         - Return ID of netCDF attribute.
%      inqAttName       - Return name of netCDF attribute.
%      putAtt           - Write netCDF attribute.
%      renameAtt        - Change name of attribute.
%
% 
%   The following functions have no equivalents in the netCDF library.
%
%      getConstantNames - Return list of constants known to netCDF library.
%      getConstant      - Return numeric value of named constant
% 
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
 
%   Copyright 2008 The MathWorks, Inc.
%   $Revision$ $Date$
