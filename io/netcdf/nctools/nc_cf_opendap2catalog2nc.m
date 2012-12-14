function nc_cf_opendap2catalog2nc(ncname,ATT,varargin)
%NC_CF_OPENDAP2CATALOG2NC save harvested THREDDS catalog to catalog.nc
%
% NC_CF_OPENDAP2CATALOG2NC(ncname,ATT,<keyword,value>)
%
% where ATT = NC_CF_OPENDAP2CATALOG()
%
%See also: nc_cf_opendap2catalog, nc_cf_opendap2catalog2xls, nc_cf_opendap2catalog2kml

OPT.datatype = '';
OPT.debug    = 0;
OPT = setproperty(OPT,varargin);

      if OPT.debug
      structfun(@(x) x{1},ATT,'UniformOutput',0)	
      end
      n = length(ATT.geospatialCoverage_northsouth);

      D.urlPath                       = ATT.urlPath        ;
      D.standard_names                = ATT.standard_names ;
      D.long_names                    = ATT.long_names     ;

      D.timeCoverage_start            = char(cellfun(@(x) x(1,:),ATT.timeCoverage,'UniformOutput',0));
      D.timeCoverage_end              = char(cellfun(@(x) x(2,:),ATT.timeCoverage,'UniformOutput',0));
      D.datenum_start                 =      cellfun(@(x) x(1)  ,ATT.datenum)'; 
      D.datenum_end                   =      cellfun(@(x) x(2)  ,ATT.datenum)';

      D.geospatialCoverage_northsouth = reshape(cell2mat(ATT.geospatialCoverage_northsouth),[2 n])';
      D.geospatialCoverage_eastwest   = reshape(cell2mat(ATT.geospatialCoverage_eastwest  ),[2 n])';

      D.projectionCoverage_x          = reshape(cell2mat(ATT.projectionCoverage_x         ),[2 n])';
      D.projectionCoverage_y          = reshape(cell2mat(ATT.projectionCoverage_y         ),[2 n])';
      D.geospatialCoverage_updown     = reshape(cell2mat(ATT.geospatialCoverage_updown    ),[2 n])';
      
      ind = find(cellfun(@(x) isempty(x),ATT.projectionEPSGcode));
      for i=ind
      ATT.projectionEPSGcode{i}=nan;
      end
      D.projectionEPSGcode            =         cell2mat(ATT.projectionEPSGcode           )';    

      if strcmpi(OPT.datatype,'timeSeries')
      D.platform_id                   = ATT.platform_id;            
      D.platform_name                 = ATT.platform_name;          
      D.number_of_observations        = cell2mat(ATT.number_of_observations);
      end
      
      struct2nc(ncname,D);

      nc_attput(ncname,nc_global,'comment','catalog.nc was created offline by $HeadURL$ from the associatec catalog.xml. Catalog.nc is a test development, please do not rely on it. Please join www.OpenEarth.eu and request a password to change $HeadURL$ until it harvests all meta-data you need.');
