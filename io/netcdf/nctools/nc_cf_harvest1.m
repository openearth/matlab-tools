function varargout = nc_cf_harvest1(varargin)
%NC_cf_HARVEST1  extract CF + THREDDS meta-data from 1 netCDF/OPeNDAP url
%
%  struct = nc_cf_harvest1(ncfile)
%
% harvests (extracts) <a href="http://cf-pcmdi.llnl.gov/">CF meta-data</a> + <a href="http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/index.html">THREDDS catalog</a>
% meta-data from one ncfile (netCDF file/OPeNDAP url)
% into a multi-layered struct.
%
% Use NC_CF_HARVEST to harvest a list of ncfiles (netCDF file/OPeNDAP url).
%
%See also: NC_INFO, nc_dump, NC_ACTUAL_RANGE, NC_CF_HARVEST, OPENDAP_CATALOG

   OPT.disp           = ''; %'multiWaitbar';
   OPT.separator      = ';'; % for long names
   OPT.datatype       = 'timeSeries'; % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
   OPT.catalog_entry  = {'title',...
                         'institution',...
                         'source',...
                         'history',...
                         'references',...
                         'email',...
                         'comment',...
                         'version',...
                         'Conventions',...
                         'terms_for_use',...
                         'disclaimer'};
                         
%% Instances initialize (to be able to return for introspection)
%  global and timeseries catalog_entries added later, after setproperty.

   ATT = nc_cf_harvest1_init(OPT);

%% File

   if isempty(varargin{1})
      varargout = {ATT};
      return
   elseif isstruct(varargin{1})
      fileinfo = varargin{1};
      ncfile   = fileinfo.Filename;
   elseif ~isstruct(varargin{1})
      ncfile   = varargin{1};
      fileinfo = nc_info(ncfile);
   end
   
   OPT = setproperty(OPT,{varargin{2:end}});                      

   ATT = nc_cf_harvest1_init(OPT);
   
%% get relevant global attributes
%  using above read fileinfo
    
   for iatt  = 1:length(OPT.catalog_entry)
     catalog_entry = OPT.catalog_entry{iatt};
     fldname = mkvar(catalog_entry);
       for iglob = 1:length(fileinfo.Attribute)
        if strcmpi(catalog_entry,fileinfo.Attribute(iglob).Name)
           ATT.(fldname) = fileinfo.Attribute(iglob).Value;
        end
     end
   end
   
%% Cycle datasets
%  get all standard_name (and prevent doubles)
%  get actual_range attribute instead if present for lat, lon, time

   idat = 1;

   if isurl(ncfile);
      ATT.urlPath = ncfile;
   else
      ATT.urlPath = filenameext(ncfile);
   end
   
   ndat = length(fileinfo.Dataset);
   for idat=1:ndat
   
      if strcmpi(OPT.disp,'multiWaitbar')
      multiWaitbar([mfilename,'1'],idat/ndat,'label','Cycling datasets ...')
      end
   
      % cycle all attributes
      natt = length(fileinfo.Dataset(idat).Attribute);
      for iatt=1:natt
      
          if strcmpi(OPT.disp,'multiWaitbar')
          multiWaitbar([mfilename,'2'],iatt/natt,'label','Cycling attributes ...')
          end
      
          Name  = fileinfo.Dataset(idat).Attribute(iatt).Name;
          
          % get standard_name only ...
          if strcmpi(Name,'standard_name')
      
              standard_name_Value = fileinfo.Dataset(idat).Attribute(iatt).Value;
              
           % get standard names ... once
           
              if ~any(strfind(ATT.standard_name,standard_name_Value))  % remove redudant standard_name (can occur with statistics)
                  ATT.standard_name = [ATT.standard_name standard_name_Value ' '];  % needs to be char
              end
              
           % get spatial extent
           
              if strcmpi(standard_name_Value,'latitude')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'degrees_north');
                  latitude  = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.northsouth.start = min(ATT.geospatialCoverage.northsouth.start,latitude(1));
                  ATT.geospatialCoverage.northsouth.end   = max(ATT.geospatialCoverage.northsouth.end  ,latitude(2));
              end
              
              if strcmpi(standard_name_Value,'longitude')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'degrees_north');
                  longitude = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.eastwest.start  = min(ATT.geospatialCoverage.eastwest.start,longitude(1));
                  ATT.geospatialCoverage.eastwest.end    = max(ATT.geospatialCoverage.eastwest.end  ,longitude(2));
              end
              
              if strcmpi(standard_name_Value,'altitude') % | strcmpi(standard_name_Value,'height_above_*')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'m');
                  z         = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.updown.start    = min(ATT.geospatialCoverage.updown.start,z(1));
                  ATT.geospatialCoverage.updown.end      = max(ATT.geospatialCoverage.updown.end  ,z(2));
              end
              
              if strcmpi(standard_name_Value,'projection_x_coordinate')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'m');
                  x         = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.x.start = min(ATT.geospatialCoverage.x.start,min(x(1)));
                  ATT.geospatialCoverage.x.end   = max(ATT.geospatialCoverage.x.end  ,max(x(2)));
                  
                  if nc_isatt(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping')
                      grid_mappings = strtokens2cell(nc_attget(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping'));
                      for ii=1:length(grid_mappings)
                      if nc_isvar(ncfile,grid_mappings{ii})
                          ATT.projectionEPSGcode = unique([ATT.projectionEPSGcode double(nc_varget(ncfile,grid_mappings{ii},0,1))]);
                      end
                      end
                  else
                      fprintf(2,'%s\n',['projection_x_coordinate without grid_mapping attribute found: ',ncfile])
                  end
              end
              
              if strcmpi(standard_name_Value,'projection_y_coordinate')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'m');
                  y         = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.y.start = min(ATT.geospatialCoverage.y.start,min(y(1)));
                  ATT.geospatialCoverage.y.end   = max(ATT.geospatialCoverage.y.end  ,max(y(2)));
                  
                  if nc_isatt(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping')
                      grid_mappings = strtokens2cell(nc_attget(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping'));
                      for ii=1:length(grid_mappings)
                      if nc_isvar(ncfile,grid_mappings{ii})
                          projectionEPSGcode = unique([ATT.projectionEPSGcode double(nc_varget(ncfile,grid_mappings{ii},0,1))]);
                      end
                      end
                      
                      if ~all(sort(projectionEPSGcode)==sort(ATT.projectionEPSGcode))
                      error('projectionEPSGcode x and y different')
                      end
                  else
                      fprintf(2,'%s\n',['projection_y_coordinate without grid_mapping attribute found: ',ncfile])
                  end
              end
              
           % get temporal extent
           
              if strcmpi(standard_name_Value,'time')
                  time      = nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  timeunits = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  time      = udunits2datenum(time,timeunits);
                  ATT.timeCoverage.start   = min(ATT.timeCoverage.start,time(1));
                  ATT.timeCoverage.end     = max(ATT.timeCoverage.end  ,time(2));
      
                  if strcmpi(OPT.datatype,'timeseries')
                     ATT.number_of_observations = fileinfo.Dataset(idat).Size;
                  end
      
              end
      
           % get timeseries specifics
           
              if strcmpi(OPT.datatype,'timeSeries')
              
                  if strcmpi(standard_name_Value,'platform_id') | ... % CF-1.6
                     strcmpi(standard_name_Value,'station_id')      % < CF-1.6
                      ATT.platform_id  = nc_varget(ncfile, fileinfo.Dataset(idat).Name);
                      if isnumeric(ATT.platform_id)
                      ATT.platform_id = num2str(ATT.platform_id);
                      end
                      ATT.platform_id = ATT.platform_id(:)';
                  end
           
                  if strcmpi(standard_name_Value,'platform_name') | ... % CF-1.6
                     strcmpi(standard_name_Value,'station_name')      % < CF-1.6
                      ATT.platform_name = nc_varget(ncfile, fileinfo.Dataset(idat).Name);
                      ATT.platform_name = ATT.platform_name(:)';
                  end
           
              end
      
          end % loop standard_name
          
          %% get long_name only ...
          
          if strcmpi(Name,'long_name')
              
              long_name_Value = fileinfo.Dataset(idat).Attribute(iatt).Value;
              
              % ... once
              if ~any(strfind(ATT.long_name,[' ',long_name_Value]))   % remove redudant long_name (can occur with statistics)
                 ATT.long_name = [ATT.long_name long_name_Value OPT.separator];  % needs to be char, ; separatred
              end
      
          end % loop long_name
          
      end % iatt
   end % idat

%% Instances initialize

   ATT.geospatialCoverage.northsouth = geospatialCoverage_complete(ATT.geospatialCoverage.northsouth);
   ATT.geospatialCoverage.eastwest   = geospatialCoverage_complete(ATT.geospatialCoverage.eastwest  );
   ATT.geospatialCoverage.updown     = geospatialCoverage_complete(ATT.geospatialCoverage.updown    );
   ATT.timeCoverage                  =       timeCoverage_complete(ATT.timeCoverage                 );
   ATT.geospatialCoverage.x          = geospatialCoverage_complete(ATT.geospatialCoverage.x         );
   ATT.geospatialCoverage.y          = geospatialCoverage_complete(ATT.geospatialCoverage.y         );

varargout = {ATT};

function geospatialCoverage = geospatialCoverage_initialize()

   geospatialCoverage.start          = nan; % TDS required
   geospatialCoverage.size           = nan; % TDS required
   geospatialCoverage.resolution     = nan; % TDS optional
   geospatialCoverage.end            = nan; % TDS extra

function geospatialCoverage = geospatialCoverage_complete(geospatialCoverage)

   geospatialCoverage.size = geospatialCoverage.end - geospatialCoverage.start;

function timeCoverage = timeCoverage_initialize()

   timeCoverage.start                = nan;
   timeCoverage.duration             = nan;
   timeCoverage.resolution           = nan;
   timeCoverage.end                  = nan;

function timeCoverage = timeCoverage_complete(timeCoverage)

   if isnan(timeCoverage.start)
   timeCoverage.start    = timeCoverage.end   - timeCoverage.duration;
   end
   
   if isnan(timeCoverage.duration)
   timeCoverage.duration = timeCoverage.end   - timeCoverage.start;
   end
   
   if isnan(timeCoverage.end)
   timeCoverage.end      = timeCoverage.start + timeCoverage.duration;
   end

function ATT = nc_cf_harvest1_init(OPT)

   ATT.urlPath       = '';

   ATT.geospatialCoverage.northsouth = geospatialCoverage_initialize();
   ATT.geospatialCoverage.eastwest   = geospatialCoverage_initialize();
   ATT.geospatialCoverage.updown     = geospatialCoverage_initialize();
   ATT.timeCoverage                  = timeCoverage_initialize();
   ATT.geospatialCoverage.x          = geospatialCoverage_initialize();
   ATT.geospatialCoverage.y          = geospatialCoverage_initialize();
   ATT.projectionEPSGcode            = []; % NB does not allow use of cell2mat later on
   
%   http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   
%   
%   ATT.variables.name          = '';
%   ATT.variables.standard_name = '';
%   ATT.variables.units         = '';
%   ATT.variables.long_name     = '';

   ATT.standard_name = '';
   ATT.long_name     = '';
   
   if strcmpi(OPT.datatype,'timeseries')
      OPT.catalog_entry{end+1} = 'platform_id'            ;
      OPT.catalog_entry{end+1} = 'platform_name'          ;
      OPT.catalog_entry{end+1} = 'number_of_observations';
   end

   for iatt  = 1:length(OPT.catalog_entry)
     catalog_entry = OPT.catalog_entry{iatt};
     fldname = mkvar(catalog_entry);
     ATT.(fldname) = '';
   end   