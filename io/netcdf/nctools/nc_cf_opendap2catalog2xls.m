function nc_cf_opendap2catalog2xls(xlsname,ATT,varargin)
%NC_CF_OPENDAP2CATALOG2XLS save harvested THREDDS catalog to catalog.xls
%
% NC_CF_OPENDAP2CATALOG2XLS(xlsname,ATT,<keyword,value>)
%
% where ATT = NC_CF_OPENDAP2CATALOG()
%
%See also: nc_cf_opendap2catalog, nc_cf_opendap2catalog2nc, nc_cf_opendap2catalog2kml

OPT.datatype = '';
OPT.debug    = 0;
OPT = setproperty(OPT,varargin);

      if OPT.debug
      structfun(@(x) x{1},ATT,'UniformOutput',0)	
      end
      n = length(ATT.geospatialCoverage_northsouth);
      
      if strcmpi(OPT.datatype,'timeseries')
      D.platform_id                   = ATT.platform_id;            
      D.platform_name                 = ATT.platform_name;          
      D.number_of_observations        = cell2mat(ATT.number_of_observations);
      end

      D.timecoverage_start     = char(cellfun(@(x) x(1,:),ATT.timeCoverage,'UniformOutput',0));
      D.timecoverage_end       = char(cellfun(@(x) x(2,:),ATT.timeCoverage,'UniformOutput',0));

      D.longitude_start        = cellfun(@(x) x(1),ATT.geospatialCoverage_eastwest);
      D.longitude_end          = cellfun(@(x) x(2),ATT.geospatialCoverage_eastwest);
      D.latitude_start         = cellfun(@(x) x(1),ATT.geospatialCoverage_northsouth);
      D.latitude_end           = cellfun(@(x) x(2),ATT.geospatialCoverage_northsouth);

      D.urlPath                = ATT.urlPath;        
      D.standard_names         = ATT.standard_names;        
      D.long_names             = ATT.long_names;        

      D.altitude_start         = cellfun(@(x) x(1),ATT.geospatialCoverage_updown);
      D.altitude_end           = cellfun(@(x) x(2),ATT.geospatialCoverage_updown);
      
      xlsname = fullfile(xlsname);
      if exist(xlsname)
         delete(xlsname);
      end
 
      struct2xls(xlsname,D,'header','catalog.nc was created offline by $HeadURL$ from the associatec catalog.xml. Catalog.xls is a test development, please do not rely on it. Please join www.OpenEarth.eu and request a password to change $HeadURL$ until it harvests all meta-data you need.');