function ATT = nc_cf_opendap2catalog(varargin)
%NC_CF_OPENDAP2CATALOG   creates catalog of CF compliant netCDF files on one OPeNDAP server (BETA)
%
%   ATT = nc_cf_opendap2catalog(<baseurl>,<keyword,value>)
%
% For <keyword,value> pairs see:
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
%              'standard_names'
%              'timecoverage_start'
%              'timecoverage_end'
%              'datenum_start'
%              'datenum_end'
%              'timecoverage_duration'
%              'geospatialCoverage_northsouth'
%              'geospatialCoverage_eastwest'
%              'dataTypes'
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
%See also: STRUCT2NC, NC2STRUCT

% TO DO: standard_name_vocabulary

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
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
   OPT.save           = 1; % save catalog in directory
   OPT.recursive      = 0;
   OPT.processfiles   = 401:600;
   OPT.catalog_dir    = 'd:\checkouts\';
   OPT.catalog_name   = 'catalog_waterbase_401_600'; % exclude from indexing

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
    'timecoverage_start',...
    'timecoverage_end',...
    'datenum_start',...
    'datenum_end',...
    'geospatialCoverage_northsouth',...
    'geospatialCoverage_eastwest'};
   %'dataTypes'};

   OPT.atttype = ...
  [ 0   % 'title',...
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
    0   % 'timecoverage_start',...
    0   % 'timecoverage_end',...
    1   % 'datenum_start',...
    1   % 'datenum_end',...
    1   % 'geospatialCoverage_northsouth',...
    1 ];% 'geospatialCoverage_eastwest',...
   %0 ];% 'dataTypes'};

%% File keywords

% if nargin==0
%     varargout = {OPT};
%     return
% end

   varargout = {OPT}; 
   nextarg = 1;
   if odd(nargin)
       OPT.base = varargin{1};
       nextarg  = 2;
   end
   
   OPT = setproperty(OPT,varargin{nextarg:end});

%% File loop to get meta-data from subdirectories (recursively)

%% File inquiry

   if isempty(OPT.files)
       OPT.files = opendap_catalog(OPT.base);
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

%% File loop to get meta-data

   entry = 0;
   
   for ifile=OPT.processfiles%1:length(OPT.files)
       OPT.filename = OPT.files{ifile};
       
       entry = entry + 1;
       
       disp(['  Processing ',num2str(entry,'%0.4d'),'/',num2str(length(OPT.files),'%0.4d'),': ',filename(OPT.filename)]);
       
    %% Get global attributes (PRE-ALLOCATE)
       
       ATT.geospatialCoverage_northsouth(entry,1:2) = nan;
       ATT.geospatialCoverage_eastwest  (entry,1:2) = nan;
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
       
       urlPath = OPT.filename;
       ATT.urlPath(entry,1:length(urlPath)) = urlPath;
       
    %% get all standard_names (and prevent doubles)
    %  get actual_range attribute instead if present for lat, lon, time
       
       fileinfo       = nc_info(OPT.filename);
       standard_names = [];
       
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
                       latitude  = nc_varget(OPT.filename, fileinfo.Dataset(idat).Name);
                       ATT.geospatialCoverage_northsouth(entry,1) = min(ATT.geospatialCoverage_northsouth(entry,1),min(latitude(:)));
                       ATT.geospatialCoverage_northsouth(entry,2) = max(ATT.geospatialCoverage_northsouth(entry,2),max(latitude(:)));
                   end
                   
                   if strcmpi(Value,'longitude')
                       longitude = nc_varget(OPT.filename, fileinfo.Dataset(idat).Name);
                       ATT.geospatialCoverage_eastwest(entry,1)   = min(ATT.geospatialCoverage_eastwest  (entry,1),min(longitude(:)));
                       ATT.geospatialCoverage_eastwest(entry,2)   = max(ATT.geospatialCoverage_eastwest  (entry,2),max(longitude(:)));
                   end
                   
                   % get temporal
                   if strcmpi(Value,'time')
                       time      = nc_cf_time(OPT.filename, fileinfo.Dataset(idat).Name);
                       ATT.datenum_start(entry)   = min(ATT.datenum_start(entry),min(time(:)));
                       ATT.datenum_end  (entry)   = max(ATT.datenum_end  (entry),max(time(:)));
                   end
               end % standard_names
           end % iatt
       end % idat
       
       if isempty(standard_names)
           standard_names = ' ';
       end
       
       ATT.standard_names(entry,1:length(standard_names)) = standard_names;
       
    %% get latitude (actual_range or min() max() full array)
       
       [names,indices] = nc_varfind(fileinfo,'attributename', 'standard_name', 'attributevalue', 'latitude');
       names = cellstr(names);
       
       % cycle all latitudes
       
       for idat=indices
           latitude = [];
           % cycle all attributes
           natt = length(fileinfo.Dataset(idat).Attribute);
           for iatt=1:natt
               Name  = fileinfo.Dataset(idat).Attribute(iatt).Name;
               %% get standard_names only ...
               if strcmpi(Name,'actual_range')
                   latitude = fileinfo.Dataset(idat).Attribute(iatt).Value;
               end % actual_range
           end % iatt
           
           if isempty(latitude)
              latitude  = nc_varget(OPT.filename, fileinfo.Dataset(idat).Name);
           end
           
           ATT.geospatialCoverage_northsouth(entry,1) = min(ATT.geospatialCoverage_northsouth(entry,1),min(latitude(:)));
           ATT.geospatialCoverage_northsouth(entry,2) = max(ATT.geospatialCoverage_northsouth(entry,2),max(latitude(:)));
       end % idat
       
    %% get longitude (actual_range or min() max() full array)
       
       [names,indices] = nc_varfind(fileinfo,'attributename', 'standard_name', 'attributevalue', 'longitude' );
       names = cellstr(names);
       
       % cycle all longitudes
       
       for idat=indices
           longitude = [];
           % cycle all attributes
           natt = length(fileinfo.Dataset(idat).Attribute);
           for iatt=1:natt
               Name  = fileinfo.Dataset(idat).Attribute(iatt).Name;
               %% get standard_names only ...
               if strcmpi(Name,'actual_range')
                   longitude = fileinfo.Dataset(idat).Attribute(iatt).Value;
               end % actual_range
           end % iatt
           
           if isempty(longitude)
               longitude  = nc_varget(OPT.filename, fileinfo.Dataset(idat).Name);
           end
           
           ATT.geospatialCoverage_eastwest(entry,1) = min(ATT.geospatialCoverage_eastwest(entry,1),min(longitude(:)));
           ATT.geospatialCoverage_eastwest(entry,2) = max(ATT.geospatialCoverage_eastwest(entry,2),max(longitude(:)));
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
           ATT.(fldname) = strtrim(ATT.(fldname))
           if isempty(ATT.(fldname))
               ATT.(fldname) = repmat(' ',[entry 1]);
           end
       end
   end

%% store database (mat file, netCDF file, xls file, ..... and perhaps some day as xml file)

   if OPT.save
       struct2nc (fullfile(OPT.catalog_dir, OPT.catalog_name),ATT)
       %     struct2nc ([OPT.base,filesep,OPT.directory,filesep,OPT.catalog_name,'.nc' ],ATT);
       %     save      ([OPT.base,filesep,OPT.directory,filesep,OPT.catalog_name,'.mat'],'-struct','ATT');
   end

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
