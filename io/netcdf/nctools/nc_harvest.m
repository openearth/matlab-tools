function D = nc_harvest(ncfiles,varargin)
%NC_HARVEST  extract CF + THREDDS meta-data from list of netCDF/OPeNDAP urls
%
%  struct = nc_harvest(ncfiles)
%
% harvests (extracts) <a href="http://cf-pcmdi.llnl.gov/">CF meta-data</a> + <a href="http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/index.html">THREDDS catalog</a>
% meta-data from cell list of ncfiles (netCDF file/OPeNDAP url)
% into an array of multi-layered structs.
%
% NC_HARVEST is a simple loop around NC_HARVEST1 
% that extracts only one ncfile (netCDF file/OPeNDAP url).
%
% Use OPENDAP_CATALOG to obtain a list of netCDF 
% files to which you can apply NC_HARVEST or call
%
%  struct = nc_harvest(opendap_url)
%
% Save struct to THREDDS catalog.xml with NC_HARVEST2XML.
%
% NB This function will replace NC_CF_OPENDAP2CATALOG in the near future.
%
%See also: NC_INFO, nc_dump, NC_ACTUAL_RANGE, NC_HARVEST1, OPENDAP_CATALOG, 
%          thredds_dump, thredds_info, nc_harvest2xml

   OPT.disp          = ''; %'multiWaitbar';
   OPT.flat          = 1; % flat is multi-layered struct, else struct with vectors
   OPT.platform_id   = 'platform_id'; % CF-1.6, older: 'station_id'
   OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name'
   
   OPT = setproperty(OPT,varargin);
   
   if ~iscell(ncfiles)
   url     = ncfiles;
   ncfiles = opendap_catalog(url);
   end

   n       = length(ncfiles);

   if ~(OPT.flat)
      d  = nc_harvest1([]);
      D  = repmat(d,[1 n]);
   else

        D.urlPath = ncfiles;

        D.geospatialCoverage_northsouth_start     = repmat(nan,[1 n]);
        D.geospatialCoverage_northsouth_size      = repmat(nan,[1 n]);
        D.geospatialCoverage_northsouth_resolution= repmat(nan,[1 n]);
        D.geospatialCoverage_northsouth_end       = repmat(nan,[1 n]);
        D.geospatialCoverage_eastwest_start       = repmat(nan,[1 n]);
        D.geospatialCoverage_eastwest_size        = repmat(nan,[1 n]);
        D.geospatialCoverage_eastwest_resolution  = repmat(nan,[1 n]);
        D.geospatialCoverage_eastwest_end         = repmat(nan,[1 n]);
        D.geospatialCoverage_updown_start         = repmat(nan,[1 n]);
        D.geospatialCoverage_updown_size          = repmat(nan,[1 n]);
        D.geospatialCoverage_updown_resolution    = repmat(nan,[1 n]);
        D.geospatialCoverage_updown_end           = repmat(nan,[1 n]);
        D.geospatialCoverage_x_start              = repmat(nan,[1 n]);
        D.geospatialCoverage_x_size               = repmat(nan,[1 n]);
        D.geospatialCoverage_x_resolution         = repmat(nan,[1 n]);
        D.geospatialCoverage_x_end                = repmat(nan,[1 n]);
        D.geospatialCoverage_y_start              = repmat(nan,[1 n]);
        D.geospatialCoverage_y_size               = repmat(nan,[1 n]);
        D.geospatialCoverage_y_resolution         = repmat(nan,[1 n]);
        D.geospatialCoverage_y_end                = repmat(nan,[1 n]);

        D.timeCoverage_start                      = repmat(nan,[1 n]);
        D.timeCoverage_duration                   = repmat(nan,[1 n]);
        D.timeCoverage_resolution                 = repmat(nan,[1 n]);
        D.timeCoverage_end                        = repmat(nan,[1 n]);
        
        D.projectionEPSGcode = cell(1,n);
             D.standard_name = cell(1,n);
                 D.long_name = cell(1,n);
                     D.title = cell(1,n);
               D.institution = cell(1,n);
                    D.source = cell(1,n);
                   D.history = cell(1,n);
                D.references = cell(1,n);
                     D.email = cell(1,n);
                   D.comment = cell(1,n);
                   D.version = cell(1,n);
               D.Conventions = cell(1,n);
             D.terms_for_use = cell(1,n);
                D.disclaimer = cell(1,n);
         D.(OPT.platform_id) = cell(1,n);
       D.(OPT.platform_name) = cell(1,n);
    D.number_of_observations = cell(1,n);
        
   end

   for i=1:n

      if strcmpi(OPT.disp,'multiWaitbar')
      multiWaitbar([mfilename,'2'],i/n,'label',['Harvesting ...',filename(ncfiles{i})])
      else
      disp([num2str(i) ' ' num2str(n) ' ' ncfiles{i}])
      end

      if ~(OPT.flat)
         D(i) = nc_harvest1(ncfiles{i});
      else
         d    = nc_harvest1(ncfiles{i});

     % use flat storage for optimal memory management
      
        D.geospatialCoverage_northsouth_start     (i) = d.geospatialCoverage.northsouth.start     ;
        D.geospatialCoverage_northsouth_size      (i) = d.geospatialCoverage.northsouth.size      ;
        D.geospatialCoverage_northsouth_resolution(i) = d.geospatialCoverage.northsouth.resolution;
        D.geospatialCoverage_northsouth_end       (i) = d.geospatialCoverage.northsouth.end       ;
        D.geospatialCoverage_eastwest_start       (i) = d.geospatialCoverage.eastwest.start       ;
        D.geospatialCoverage_eastwest_size        (i) = d.geospatialCoverage.eastwest.size        ;
        D.geospatialCoverage_eastwest_resolution  (i) = d.geospatialCoverage.eastwest.resolution  ;
        D.geospatialCoverage_eastwest_end         (i) = d.geospatialCoverage.eastwest.end         ;
        D.geospatialCoverage_updown_start         (i) = d.geospatialCoverage.updown.start         ;
        D.geospatialCoverage_updown_size          (i) = d.geospatialCoverage.updown.size          ;
        D.geospatialCoverage_updown_resolution    (i) = d.geospatialCoverage.updown.resolution    ;
        D.geospatialCoverage_updown_end           (i) = d.geospatialCoverage.updown.end           ;
        D.geospatialCoverage_x_start              (i) = d.geospatialCoverage.x.start              ;
        D.geospatialCoverage_x_size               (i) = d.geospatialCoverage.x.size               ;
        D.geospatialCoverage_x_resolution         (i) = d.geospatialCoverage.x.resolution         ;
        D.geospatialCoverage_x_end                (i) = d.geospatialCoverage.x.end                ;
        D.geospatialCoverage_y_start              (i) = d.geospatialCoverage.y.start              ;
        D.geospatialCoverage_y_size               (i) = d.geospatialCoverage.y.size               ;
        D.geospatialCoverage_y_resolution         (i) = d.geospatialCoverage.y.resolution         ;
        D.geospatialCoverage_y_end                (i) = d.geospatialCoverage.y.end                ;

        D.timeCoverage_start                      (i) = d.timeCoverage.start     ;
        D.timeCoverage_duration                   (i) = d.timeCoverage.duration  ;
        D.timeCoverage_resolution                 (i) = d.timeCoverage.resolution;
        D.timeCoverage_end                        (i) = d.timeCoverage.end       ;

          D.projectionEPSGcode{i} =     d.projectionEPSGcode;
               D.standard_name{i} =          d.standard_name;
                   D.long_name{i} =              d.long_name;
                       D.title{i} =                  d.title;
                 D.institution{i} =            d.institution;
                      D.source{i} =                 d.source;
                     D.history{i} =                d.history;
                  D.references{i} =             d.references;
                       D.email{i} =                  d.email;
                     D.comment{i} =                d.comment;
                     D.version{i} =                d.version;
                 D.Conventions{i} =            d.Conventions;
               D.terms_for_use{i} =          d.terms_for_use;
                  D.disclaimer{i} =             d.disclaimer;
           D.(OPT.platform_id){i} =            d.(OPT.platform_id);
         D.(OPT.platform_name){i} =          d.(OPT.platform_name);
      D.number_of_observations{i} = d.number_of_observations;

      end

   end
