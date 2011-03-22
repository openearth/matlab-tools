function varargout = nc_cf_opendap2catalog(varargin)
%NC_CF_OPENDAP2CATALOG   creates catalog of CF compliant netCDF files on one OPeNDAP server (BETA)
%
%   ATT = nc_cf_opendap2catalog(<baseurl>,<keyword,value>)
%
% Extracts meta-data from all netCDF files in baseurl, which can either be an
% opendap catalog or a local directory. Set 'maxlevel' to harvest deeper.
% When you query a local directory, and you want the catalog to work on a server,
% use keyword 'urlPathFcn' to replace the local root with the opendap root, e.g.:
%
% 'urlPathFcn'= @(s) strrep(s,OPT.root_nc,['http://opendap.deltares.nl/thredds/dodsC/opendap/',OPT.path]))
%
% For other <keyword,value> pairs see:
%
%    OPT = nc_cf_opendap2catalog()
%
% Extracts  (i) netCDF CF meta-data keywords
%               'title'
%               'institution'
%               'source'
%               'history'
%               'references'
%               'email'
%               'comment'
%               'version'
%               'Conventions'
%               'CF:featureType'
%               'terms_for_use'
%               'disclaimer'
%
%          (ii) THREDDS meta-data keywords
%               'urlPath'
%               'standard_names'      % white space separated
%               'long_names'          % OPT.separator=';' space separated as they may contain spaces
%               'timecoverage_start'
%               'timecoverage_end'
%               'datenum_start'
%               'datenum_end'
%               'timecoverage_duration'
%               'geospatialCoverage_northsouth'
%               'geospatialCoverage_eastwest'
%               'projectionCoverage_x'
%               'projectionCoverage_y'
%               'projectionEPSGcode' % from x,y
% 
%          (iii) Specified 1D variables 
%                For grids, it is advised to only use the 1D dimension variables x, y,and time
%
% from all specified netCDF files and stores them into a
% struct for storage in netCDF file or mat file.
%
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#geospatialCoverageType
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#timeCoverageType
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#dataType
% (http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html)
%
% A catalog can be used as follows:
%
%   catalog = nc2struct('catalog.nc')
%   Element = structfun(@(x) (x(1)),catalog,'UniformOutput',0)
%
% For the stationtimeseries extra information is loaded.
%
%See also: STRUCT2NC, NC2STRUCT, opendap_catalog, snctools, nc_cf_opendap2catalog_loop

% TO DO: standard_name_vocabulary

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% which directories to scan

OPT.base           = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/catalog.xml'; % base url where to inquire, NB: needs to end with catalog.xml
OPT.files          = [];
OPT.directory      = '.'; % relative path that ends up in catalog
OPT.mask           = '*.nc';
OPT.pause          = 0;
OPT.test           = 0;
OPT.urlPathFcn     = @(s)(s); % function to run on urlPath, as e.g. strrep
OPT.save           = 0; % save catalog in directory
OPT.catalog_dir    = [];
OPT.catalog_name   = 'catalog.nc'; % exclude from indexing
OPT.xls_name       = 'catalog.xls'; % exclude from indexing
OPT.maxlevel       = 1;
OPT.separator      = ';'; % for long names
OPT.datatype       = 'stationtimeseries'; % CF data types (grid, stationtimeseries upcoming CF standard https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions)
OPT.debug          = 0;
OPT.disp           = 'multiWaitbar';

if nargin==0
   varargout = {OPT};
   return
end

%% List of variables to include
OPT.varname        = {}; % could be {'x','y','time'}

%% what information (global attributes) to extract

   OPT.catalog_entry = ...
    {'title',...
    'institution',...
    'source',...
    'history',...
    'references',... % 5
    'email',...
    'comment',...
    'version',...
    'Conventions',...
    'CF:featureType',... % 10
    'terms_for_use',...
    'disclaimer',...
    'urlPath',... %
    'standard_names',...
    'long_names',... % 15
    'timecoverage_start',...
    'timecoverage_end',...
    'datenum_start',...
    'datenum_end',...
    'geospatialCoverage_northsouth',... % 20
    'geospatialCoverage_eastwest',...
    'projectionCoverage_x',...
    'projectionCoverage_y',...
    'projectionEPSGcode'};

   if strcmpi(OPT.datatype,'stationtimeseries')
      OPT.catalog_entry{end+1} = 'station_id'            ; % 25
      OPT.catalog_entry{end+1} = 'station_name'          ;
      OPT.catalog_entry{end+1} = 'number_of_observations';
   end

%% File keywords

   if nargin==0;varargout = {OPT};OPT;return;end
   
   varargout = {OPT};
   nextarg = 1;
   if odd(nargin)
       if ischar(varargin{1})
           OPT.base = varargin{1};
           nextarg  = 2;
       end
   end
   
   OPT = setproperty(OPT,varargin{nextarg:end});
   
   if isempty(OPT.catalog_dir)
      if ~strcmpi(OPT.base(1:7),'http://')
         OPT.catalog_dir = OPT.base;
      end
   end

%% initialize waitbar

    if strcmpi(OPT.disp,'multiWaitbar')
    multiWaitbar(mfilename,0,'label','Generating catalog.nc','color',[0.3 0.6 0.3])
    end
    
%% File inquiry

    if isempty(OPT.files)
        OPT.files = opendap_catalog(OPT.base,'maxlevel',OPT.maxlevel,'ignoreCatalogNc',1);
    end

%% pre-allocate catalog (Note: expanding char array lead to 0 as fillvalues)

   for ifld=1:length(OPT.catalog_entry)
    
      fldname = mkvar(OPT.catalog_entry{ifld});
      ATT.(fldname) = cell(length(OPT.files),1);
    
   end

% pre allocate

   for ivar = 1:length(OPT.varname)
      VAR.(OPT.varname{ivar}) = cell(length(OPT.files),1);
   end

%% File loop to get meta-data

   entry = 0;
   n     = length(OPT.files);

%% Get global attributes (PRE-ALLOCATE)
    
    [ATT.projectionEPSGcode{:}]            = deal(nan);
    [ATT.geospatialCoverage_northsouth{:}] = deal([nan nan]);
    [ATT.geospatialCoverage_eastwest{:}]   = deal([nan nan]);
    [ATT.projectionCoverage_x{:}]          = deal([nan nan]);
    [ATT.projectionCoverage_y{:}]          = deal([nan nan]);
    [ATT.timecoverage_start{:}]            = deal(' ');
    [ATT.timecoverage_end{:}]              = deal(' ');
    [ATT.datenum_start{:}]                 = deal(nan);
    [ATT.datenum_end{:}]                   = deal(nan);

    if strcmpi(OPT.datatype,'stationtimeseries')
    [ATT.station_id{:}]                    = deal(' ');
    [ATT.station_name{:}]                  = deal(' ');
    [ATT.number_of_observations{:}]        = deal(nan);
    end

for entry=1:length(OPT.files)

   OPT.filename = OPT.files{entry};
   if strcmpi(OPT.disp,'multiWaitbar')
   multiWaitbar(mfilename,entry/length(OPT.files),'label',['Adding ',filename(OPT.filename) ' to catalog'])
   end
   
   fileinfo       = nc_info(OPT.filename);

%% get relevant global attributes
%  using above read fileinfo
    
   for iatt  = 1:length(OPT.catalog_entry)
     catalog_entry = OPT.catalog_entry{iatt};
     fldname = mkvar(catalog_entry);
       for iglob = 1:length(fileinfo.Attribute)
        if strcmpi(catalog_entry,fileinfo.Attribute(iglob).Name)
           ATT.(fldname){entry} = fileinfo.Attribute(iglob).Value;
        end
     end
   end

   urlPath = OPT.urlPathFcn(OPT.filename);
   ATT.urlPath{entry} = urlPath;
    
%% get all standard_names (and prevent doubles)
%  get actual_range attribute instead if present for lat, lon, time

   standard_names = [];
   long_names     = [];
   
   % cycle all datasets
   
   ndat = length(fileinfo.Dataset);
   for idat=1:ndat
       if strcmpi(OPT.disp,'multiWaitbar')
       multiWaitbar('nc_cf_opendap2catalog_2',idat/ndat,'label','Cycling datasets ...')
       end

       % cycle all attributes
       natt = length(fileinfo.Dataset(idat).Attribute);
       for iatt=1:natt
           if strcmpi(OPT.disp,'multiWaitbar')
           multiWaitbar('nc_cf_opendap2catalog_3',iatt/natt,'label','Cycling attributes ...')
           end

           Name  = fileinfo.Dataset(idat).Attribute(iatt).Name;
           % get standard_names only ...
           if strcmpi(Name,'standard_name')

               Value = fileinfo.Dataset(idat).Attribute(iatt).Value;
               
            % get standard names ... once
            
               if ~any(strfind(standard_names,[' ',Value]))  % remove redudant standard_names (can occur with statistics)
                   standard_names = [standard_names ' ' Value];  % needs to be char
               end
               
            % get spatial extent
            
               if strcmpi(Value,'latitude')
                   latitude  = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
                   ATT.geospatialCoverage_northsouth{entry}(1) = min(ATT.geospatialCoverage_northsouth{entry}(1),latitude(1));
                   ATT.geospatialCoverage_northsouth{entry}(2) = max(ATT.geospatialCoverage_northsouth{entry}(2),latitude(2));
               end
               
               if strcmpi(Value,'longitude')
                   longitude = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
                   ATT.geospatialCoverage_eastwest{entry}(1)   = min(ATT.geospatialCoverage_eastwest{entry}(1),longitude(1));
                   ATT.geospatialCoverage_eastwest{entry}(2)   = max(ATT.geospatialCoverage_eastwest{entry}(2),longitude(2));
               end
               
               if strcmpi(Value,'projection_x_coordinate')
                   x = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
                   ATT.projectionCoverage_x{entry}(1) = min(ATT.projectionCoverage_x{entry}(1),min(x(1)));
                   ATT.projectionCoverage_x{entry}(2) = max(ATT.projectionCoverage_x{entry}(2),max(x(2)));
                   if nc_isatt(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping')
                       grid_mapping = nc_attget(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping'); % TO DO: get from fileinfo
                       if nc_isvar(OPT.filename,grid_mapping)
                           ATT.projectionEPSGcode{entry} = double(nc_varget(OPT.filename,grid_mapping)); % pre allocated nan and int do not work with cell2mat
                       end
                   end
               end
               
               if strcmpi(Value,'projection_y_coordinate')
                   y = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
                   ATT.projectionCoverage_y{entry}(1) = min(ATT.projectionCoverage_y{entry}(1),min(y(1)));
                   ATT.projectionCoverage_y{entry}(2) = max(ATT.projectionCoverage_y{entry}(2),max(y(2)));
                   if nc_isatt(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping')
                       grid_mapping = nc_attget(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping'); % TO DO: get from fileinfo
                       if nc_isvar(OPT.filename,grid_mapping)
                           if ~ (ATT.projectionEPSGcode{entry} == double(nc_varget(OPT.filename,grid_mapping)))
                               error('x and y have different epsg code')
                           end
                       end
                   end
               end
               
            % get temporal extent
            
               if strcmpi(Value,'time')
                   time      = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
                   timeunits = nc_attget      (OPT.filename, fileinfo.Dataset(idat).Name,'units'); % TO DO: get from fileinfo
                   time      = udunits2datenum(time,timeunits);
                   ATT.datenum_start{entry}   = min(ATT.datenum_start{entry},time(1));
                   ATT.datenum_end  {entry}   = max(ATT.datenum_end  {entry},time(2));

                  if strcmpi(OPT.datatype,'stationtimeseries')
                     ATT.number_of_observations{entry} = fileinfo.Dataset(idat).Size;
                  end

               end

            % get stationtimeseries specifics
            
               if strcmpi(OPT.datatype,'stationtimeseries')
            
                 if strcmpi(Value,'station_id')
                   ATT.station_id{entry}  = nc_varget(OPT.filename, fileinfo.Dataset(idat).Name);
                 end
            
                 if strcmpi(Value,'station_name')
                   ATT.station_name{entry} = nc_varget(OPT.filename, fileinfo.Dataset(idat).Name);
                 end
            
               end

           end % loop standard_names
           
           %% get long_names only ...
           
           if strcmpi(Name,'long_name')
               
               Value = fileinfo.Dataset(idat).Attribute(iatt).Value;
               
               % ... once
               if ~any(strfind(long_names,[' ',Value]))   % remove redudant long_names (can occur with statistics)
                 if isempty(long_names)
                   long_names = Value;
                 else
                   long_names = [long_names OPT.separator Value];  % needs to be char, ; separatred
                 end
               end

           end % loop long_names
           
       end % iatt
   end % idat
   
   if isempty(standard_names)
       standard_names = ' ';
   end
   if isempty(long_names)
       long_names = ' ';
   end
   
   ATT.standard_names{entry} = standard_names;
   ATT.long_names    {entry}     = long_names;
    
%% include variables

   for ivar = 1:length(OPT.varname)
       VAR.(OPT.varname{ivar}){entry} = nc_varget(OPT.filename, OPT.varname{ivar});
   end
    
%% pause

   if OPT.pause
       pausedisp
   end
    
end % entry

%% remove amount to much pre-allocated in catalog dimension and make numeric or char matrix

   for ifld=1:length(OPT.catalog_entry)
       fldname = mkvar(OPT.catalog_entry{ifld});
       try
       ATT.(fldname) = cell2mat({ATT.(fldname){1:entry}}');
       catch
          try
             ATT.(fldname) = char({ATT.(fldname){1:entry}});
          catch
             ATT.(fldname) =     ({ATT.(fldname){1:entry}});
          end
       end
   end
   
   ATT.timecoverage_start   = datestr(ATT.datenum_start,'yyyy-mm-ddTHH:MM:SS');
   ATT.timecoverage_end     = datestr(ATT.datenum_end  ,'yyyy-mm-ddTHH:MM:SS');

%% merge VAR structure in the ATT structure

   for ivar = 1:length(OPT.varname)
       maxelements = 0;
       for entry=1:length(OPT.files)
           maxelements = max(maxelements,numel(VAR.(OPT.varname{ivar}){entry}));
       end
       ATT.(OPT.varname{ivar}) = nan(length(OPT.files),maxelements);
       for entry=1:length(OPT.files)
           data = VAR.(OPT.varname{ivar}){entry}(:);
           ATT.(OPT.varname{ivar})(entry,1:length(data)) = data;
       end
   end

%% store database (mat file, netCDF file, xls file, ..... and perhaps some day as xml file)

   if OPT.save

      struct2nc(fullfile(OPT.catalog_dir, OPT.catalog_name),ATT);
      nc_attput(fullfile(OPT.catalog_dir, OPT.catalog_name),nc_global,'comment','catalog.nc was created offline by $HeadURL$ from the associatec catalog.xml. Catalog.nc is a test development, please do not rely on it. Please join www.OpenEarth.eu and request a password to change $HeadURL$ until it harvests all meta-data you need.');
       
      %for ifld=1:length(OPT.xls_entry)
      %   fldname = mkvar(OPT.xls_entry{ifld});
      %   XLS.(fldname) = ATT.(fldname);
      %end

      if strcmpi(OPT.datatype,'stationtimeseries')
      XLS.station_id             = ATT.station_id;            
      XLS.station_name           = ATT.station_name;          
      XLS.number_of_observations = ATT.number_of_observations';
      end
      XLS.timecoverage_start     = ATT.timecoverage_start;
      XLS.timecoverage_end       = ATT.timecoverage_end;
      XLS.longitude_start        = ATT.geospatialCoverage_eastwest(:,1)';
      XLS.longitude_end          = ATT.geospatialCoverage_eastwest(:,2)';
      XLS.latitude_start         = ATT.geospatialCoverage_northsouth(:,1)';
      XLS.latitude_end           = ATT.geospatialCoverage_northsouth(:,2)';
      XLS.urlPath                = ATT.urlPath;        
      XLS.title                  = ATT.title;        
      XLS.standard_names         = ATT.standard_names;        
      XLS.long_names             = ATT.long_names;        
      
      xlsname = fullfile(OPT.catalog_dir, OPT.xls_name);
      if exist(xlsname)
         delete(xlsname);
      end
      struct2xls(xlsname,XLS);

   end

   if strcmpi(OPT.disp,'multiWaitbar')
   multiWaitbar(mfilename,1,'label','Generating catalog.nc')
   end

% load database as check

   if OPT.debug
      DEBUG = nc2struct (fullfile(OPT.catalog_dir, OPT.catalog_name)); % WRONG, because nc chars in nc are wrong.
      var2evalstr(DEBUG)
   end
   
% output

   varargout = {ATT};

%% EOF
