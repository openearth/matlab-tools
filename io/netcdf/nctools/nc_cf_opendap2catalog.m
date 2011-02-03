function ATT = nc_cf_opendap2catalog(varargin)
%NC_CF_OPENDAP2CATALOG   creates catalog of CF compliant netCDF files on one OPeNDAP server (BETA)
%
%   ATT = nc_cf_opendap2catalog(<baseurl>,<keyword,value>)
%
% Extracts meta-data from all netCDF files in baseurl, which can either be an
% opendap catalog or a local directory. When you query a local directory,
% and you want the catalog to work on a server, use keyword 'urlPathFcn'
% to replace the local root with the opendap root, e.g.:
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
%              'urlPath'
%              'standard_names'      % white space separated
%              'long_names'          % OPT.separator=';' space separated as they may contain spaces
%              'timecoverage_start'
%              'timecoverage_end'
%              'datenum_start'
%              'datenum_end'
%              'timecoverage_duration'
%              'geospatialCoverage_northsouth'
%              'geospatialCoverage_eastwest'
%              'projectionCoverage_x'
%              'projectionCoverage_y'
%              'projectionEPSGcode' % from x,y
%              'dataTypes'
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

%% netCDF JAVA issues

% OPT.USE_JAVA = getpref ('SNCTOOLS', 'USE_JAVA');
% setpref                ('SNCTOOLS', 'USE_JAVA', 0)
%

%% which directories to scan

OPT.base           = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/catalog.xml'; % base url where to inquire, NB: needs to end with catalog.xml
OPT.files          = [];
OPT.directory      = '.'; % relative path that ends up in catalog
OPT.char_length    = 256; % pre-allocate for speed-up in addition to length(OPT.directory)
OPT.mask           = '*.nc';
OPT.pause          = 0;
OPT.test           = 0;
OPT.urlPathFcn     = @(s)(s); % function to run on urlPath, as e.g. strrep
OPT.save           = 0; % save catalog in directory
OPT.recursive      = 0;
OPT.catalog_dir    = [];
OPT.catalog_name   = 'catalog.nc'; % exclude from indexing
OPT.maxlevel       = 1;
OPT.separator      = ';'; % for long names

%% List of variables to include
OPT.varname        = {}; % could be {'x','y','time'}

%% what information (global attributes) to extract

OPT.attname = ...
    {'title',...
    'institution',...
    'source',...
    'history',...
    'references',...
    'email',...
    'comment',...
    'version',...
    'Conventions',...
    'CF:featureType',...
    'terms_for_use',...
    'disclaimer',...
    'urlPath',... %
    'standard_names',...
    'long_names',...
    'timecoverage_start',...
    'timecoverage_end',...
    'datenum_start',...
    'datenum_end',...
    'geospatialCoverage_northsouth',...
    'geospatialCoverage_eastwest',...
    'projectionCoverage_x',...
    'projectionCoverage_y',...
    'projectionEPSGcode'};

%% atttype: 0=char, 1= numeric

OPT.atttype = [...
    0   % 'title',...
    0   % 'institution',...
    0   % 'source',...
    0   % 'history',...
    0   % 'references',...
    0   % 'email',...
    0   % 'comment',...
    0   % 'version',...
    0   % 'Conventions',...
    0   % 'CF:featureType',...
    0   % 'terms_for_use',...
    0   % 'disclaimer',...
    0   % 'urlPath',...
    0   % 'standard_names',...
    0   % 'long_names',...
    0   % 'timecoverage_start',...
    0   % 'timecoverage_end',...
    1   % 'datenum_start',...
    1   % 'datenum_end',...
    1   % 'geospatialCoverage_northsouth',...
    1   % 'geospatialCoverage_eastwest',...
    1   % 'projectionCoverage_x',...
    1   % 'projectionCoverage_y',...
    1 ];% 'projectionEPSGcode'


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

    multiWaitbar('nc_cf_opendap2catalog',0,'label','Generating catalog.nc','color',[0.2 0.5 0.2])
    
%% File loop to get meta-data from subdirectories (recursively)
    
   if OPT.recursive
   end
    
%% File inquiry

    if isempty(OPT.files)
        OPT.files = opendap_catalog(OPT.base,'maxlevel',OPT.maxlevel,'ignoreCatalogNc',1);
    end

%% pre-allocate catalog (Note: expanding char array lead to 0 as fillvalues)

for ifld=1:length(OPT.attname)
    
    fldname = mkvar(OPT.attname{ifld});
    
    if OPT.atttype(ifld)==1
        ATT.(fldname) = nan(        length(OPT.files),1);
    else
        ATT.(fldname) = repmat(' ',[length(OPT.files),length(OPT.files) + OPT.char_length]);
    end
    
end

% pre allocate
for ivar = 1:length(OPT.varname)
    VAR.(OPT.varname{ivar}) = cell(length(OPT.files),1);
end


%% File loop to get meta-data

entry = 0;

for ifile=1:length(OPT.files)
    
    OPT.filename = OPT.files{ifile};
    multiWaitbar('nc_cf_opendap2catalog',entry/length(OPT.files),'label',...
        ['Adding ',filename(OPT.filename) ' to catalog'])
    entry = entry + 1;

%% Get global attributes (PRE-ALLOCATE)
    
    ATT.projectionEPSGcode           (entry)     = nan;
    ATT.geospatialCoverage_northsouth(entry,1:2) = nan;
    ATT.geospatialCoverage_eastwest  (entry,1:2) = nan;
    ATT.projectionCoverage_x         (entry,1:2) = nan;
    ATT.projectionCoverage_y         (entry,1:2) = nan;
    ATT.timecoverage_start           (entry,:)   = ' ';
    ATT.timecoverage_end             (entry,:)   = ' ';
    ATT.datenum_start                (entry)     = nan;
    ATT.datenum_end                  (entry)     = nan;
    
%% get relevant attributes
    
    for iatt = 1:length(OPT.attname)
        attname = OPT.attname{iatt};
        fldname = mkvar(attname);
        try
            att = nc_attget(OPT.filename, nc_global, attname);
            if isnumeric(ATT.(fldname))
                ATT.(fldname)(entry)               = att;
            else
                ATT.(fldname)(entry,1:length(att)) = att;
            end
        catch
            if isnumeric(ATT.(fldname))
                ATT.(fldname)(entry)               = nan;
            else
                ATT.(fldname)(entry,:)             = ' ';
            end
        end
    end

    urlPath = OPT.urlPathFcn(OPT.filename);
    ATT.urlPath(entry,1:length(urlPath)) = urlPath;
    
%% get all standard_names (and prevent doubles)
    %  get actual_range attribute instead if present for lat, lon, time

    fileinfo       = nc_info(OPT.filename);
    standard_names = [];
    long_names     = [];
    
    % cycle all datasets
    
    ndat = length(fileinfo.Dataset);
    for idat=1:ndat
        % cycle all attributes
        natt = length(fileinfo.Dataset(idat).Attribute);
        for iatt=1:natt
            Name  = fileinfo.Dataset(idat).Attribute(iatt).Name;
            % get standard_names only ...
            if strcmpi(Name,'standard_name')
                Value = fileinfo.Dataset(idat).Attribute(iatt).Value;
                
                % ... once
                if ~any(strfind(standard_names,[' ',Value]))  % remove redudant standard_names (can occur with statistics)
                    standard_names = [standard_names ' ' Value];  % needs to be char
                end
                
                % get spatial
                if strcmpi(Value,'latitude')
                    latitude  = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
                    ATT.geospatialCoverage_northsouth(entry,1) = min(ATT.geospatialCoverage_northsouth(entry,1),latitude(1));
                    ATT.geospatialCoverage_northsouth(entry,2) = max(ATT.geospatialCoverage_northsouth(entry,2),latitude(2));
                end
                
                if strcmpi(Value,'longitude')
                    longitude = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
                    ATT.geospatialCoverage_eastwest(entry,1)   = min(ATT.geospatialCoverage_eastwest  (entry,1),longitude(1));
                    ATT.geospatialCoverage_eastwest(entry,2)   = max(ATT.geospatialCoverage_eastwest  (entry,2),longitude(2));
                end
                
                % get temporal
                if strcmpi(Value,'time')
                    time      = nc_cf_time(OPT.filename, fileinfo.Dataset(idat).Name);
                    ATT.datenum_start(entry)   = min(ATT.datenum_start(entry),min(time(:)));
                    ATT.datenum_end  (entry)   = max(ATT.datenum_end  (entry),max(time(:)));
                end
            end % standard_names
            
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

            end % long_names
            
            
        end % iatt
    end % idat
    
    if isempty(standard_names)
        standard_names = ' ';
    end
    if isempty(long_names)
        long_names = ' ';
    end
    
    ATT.standard_names(entry,1:length(standard_names)) = standard_names;
    ATT.long_names    (entry,1:length(long_names))     = long_names;
    
%% get latitude actual_range
    
    [names,indices] = nc_varfind(fileinfo,'attributename', 'standard_name', 'attributevalue', 'latitude');
    names = cellstr(names);
    
    % cycle all latitudes
    
    for idat=indices

        latitude  = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
        
        ATT.geospatialCoverage_northsouth(entry,1) = min(ATT.geospatialCoverage_northsouth(entry,1),latitude(1));
        ATT.geospatialCoverage_northsouth(entry,2) = max(ATT.geospatialCoverage_northsouth(entry,2),latitude(2));
        
    end % idat
    
%% get longitude actual_range
    
    [names,indices] = nc_varfind(fileinfo,'attributename', 'standard_name', 'attributevalue', 'longitude' );
    names = cellstr(names);
    
    % cycle all longitudes
    
    for idat=indices

        longitude = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
        
        ATT.geospatialCoverage_eastwest(entry,1) = min(ATT.geospatialCoverage_eastwest(entry,1),longitude(1));
        ATT.geospatialCoverage_eastwest(entry,2) = max(ATT.geospatialCoverage_eastwest(entry,2),longitude(2));
        
    end % idat
    
%% get x actual_range and epsg
    
    [names,indices] = nc_varfind(fileinfo,'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate');
    names = cellstr(names);
    
    % cycle all x's
    
    for idat=indices

        x = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
        
        ATT.projectionCoverage_x(entry,1) = min(ATT.projectionCoverage_x(entry,1),min(x(1)));
        ATT.projectionCoverage_x(entry,2) = max(ATT.projectionCoverage_x(entry,2),max(x(2)));
        
        if nc_isatt(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping')
           grid_mapping = nc_attget(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping');
           if nc_isvar(OPT.filename,grid_mapping)
             ATT.projectionEPSGcode(entry) = nc_varget(OPT.filename,grid_mapping);
           end
        end
        
    end % idat
    
%% include variables   
    for ivar = 1:length(OPT.varname)
        VAR.(OPT.varname{ivar}){entry} = nc_varget(OPT.filename, OPT.varname{ivar});
    end
%% get y actual_range and epsg
    
    [names,indices] = nc_varfind(fileinfo,'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate');
    names = cellstr(names);
    
    % cycle all y's
    
    for idat=indices

        y  = nc_actual_range(OPT.filename, fileinfo.Dataset(idat).Name);
        
        ATT.projectionCoverage_y(entry,1) = min(ATT.projectionCoverage_y(entry,1),min(y(1)));
        ATT.projectionCoverage_y(entry,2) = max(ATT.projectionCoverage_y(entry,2),max(y(2)));
        
        if nc_isatt(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping')
           grid_mapping = nc_attget(OPT.filename, fileinfo.Dataset(idat).Name,'grid_mapping');
           if nc_isvar(OPT.filename,grid_mapping)
             ATT.projectionEPSGcode(entry) = nc_varget(OPT.filename,grid_mapping);
           end
           
           %EPSGcodeStr = regexp(nc_attget(OPT.filename,'crs','spatial_ref'),'PROJECTION.*EPSG","(\d*)','tokens');
           %ATT.projectionEPSGcode(entry) = str2double(EPSGcodeStr{:}{:});
           
        end

    end % idat
    if OPT.pause
        pausedisp
    end
    
end % ifile

%% remove amount to much pre-allocated in catalog dimension

for ifld=1:length(OPT.attname)
    fldname = mkvar(OPT.attname{ifld});
    ATT.(fldname) = ATT.(fldname)(1:entry,:);
end

ATT.timecoverage_start   = datestr(ATT.datenum_start,'yyyy-mm-ddTHH:MM:SS');
ATT.timecoverage_end     = datestr(ATT.datenum_end  ,'yyyy-mm-ddTHH:MM:SS');

%% remove amount to much pre-allocated in char dimension

for ifld=1:length(OPT.attname)
    fldname = mkvar(OPT.attname{ifld});
    if ischar(ATT.(fldname))
        ATT.(fldname) = strtrim(ATT.(fldname));
        if isempty(ATT.(fldname))
            ATT.(fldname) = repmat(' ',[entry 1]);
        end
    end
end

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
    struct2nc (fullfile(OPT.catalog_dir, OPT.catalog_name),ATT)
    %     struct2nc ([OPT.base,filesep,OPT.directory,filesep,OPT.catalog_name,'.nc' ],ATT);
    %     save      ([OPT.base,filesep,OPT.directory,filesep,OPT.catalog_name,'.mat'],'-struct','ATT');
end

multiWaitbar('nc_cf_opendap2catalog',1,'label','Generating catalog.nc')

% load database as check

% if OPT.test
%     ATT1 = nc2struct ([          'catalog.nc' ]); % WRONG, because nc chars in nc are wrong.
%     ATT2 = load      ([          'catalog.mat']);
% end
%
% %% Java issue
%
% setpref ('SNCTOOLS', 'USE_JAVA', OPT.USE_JAVA)
%
% varargout = {ATT};
%
% %% EOF
