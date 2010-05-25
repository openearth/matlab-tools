function attrvalue = getAtt(ncid,varid,attname,output_datatype)
%netcdf.getAtt Return netCDF attribute.
%   attrvalue = netcdf.getAtt(ncid,varid,attname) reads an attribute
%   value.  The class of attrvalue will match that of the internal
%   attribute datatype.  For example, if the attribute has netCDF 
%   datatype NC_INT, then the class of the output data will be int32.
%   If an attribute has netCDF datatype NC_BYTE, it will result in an
%   int8 value.
%
%   This function can be further modified by using a datatype string as 
%   the final input argument.  This has the effect of specifying the 
%   output datatype as long as the netCDF library allows the conversion.
%
%   The list of allowable datatype strings consists of 'double', 
%   'single', 'int32', 'int16', 'int8', and 'uint8'.
%   
%   To read in an attribute value as double precision, use 
%
%     data=netcdf.getAtt(ncid,varid,attname,'double');
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_get_att" family of functions in 
%   the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstant.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

switch ( nargin )
  case 3
    % Use the internal datatype to determine the output class. 
    xtype = netcdflib('inqAtt',ncid,varid,attname);
    switch ( xtype )
      case 6
        funcstr = 'getAttDouble';
      case 5
        funcstr = 'getAttFloat';
      case 4
        funcstr = 'getAttInt';
      case 3
        funcstr = 'getAttShort';
      case 2
        funcstr = 'getAttText';
      case 1
        funcstr = 'getAttSchar';
      otherwise
        error('MATLAB:netcdf:getAtt:unhandledAttributeDatatype', ...
              'Attribute datatype %d is not recognized.', xtype );
    end
    
  case 4
    % In this case we determine the funcstr from the specified class.
    switch ( output_datatype )
      case { 'double' }
        funcstr = 'getAttDouble';
      case { 'float', 'single' }
        funcstr = 'getAttFloat';
      case { 'int', 'int32' }
        funcstr = 'getAttInt';
      case { 'short', 'int16' }
        funcstr = 'getAttShort';
      case { 'short', 'int16' }
        funcstr = 'getAttShort';
      case { 'schar', 'int8' }
        funcstr = 'getAttSchar';
      case { 'uchar', 'uint8' }
        funcstr = 'getAttUchar';
      case { 'char', 'text' }
        funcstr = 'getAttText';
      otherwise
        error('MATLAB:netcdf:getAtt:unhandledAttributeClassSpecification', ...
              'The specified output attribute class ''%s'' is not recognized.', ...
              output_datatype );
    end

	otherwise 
		error ( 'MATLAB:netcdf:getAtt:wrongNumberOfInputArguments', ...  
			'There must be either two or four input arguments supplied to netcdf.getAtt' );

end
        
        
attrvalue = netcdflib(funcstr, ncid, varid, attname);            
