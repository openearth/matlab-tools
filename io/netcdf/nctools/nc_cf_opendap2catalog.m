function varargout = nc_cf_opendap2catalog(varargin)
%NC_CF_OPENDAP2CATALOG   harvester for netCDF-CF in THREDDS OPeNDAP catalogues: returns meta-data
%
% NB We are preparing to replace nc_cf_opendap2catalog with nc_harvest.
%
%   ATT = nc_cf_opendap2catalog(<baseurl>,<keyword,value>)
%   ATT = nc_cf_opendap2catalog(<files>  ,<keyword,value>)
%
% Extracts meta-data from all netCDF files in <baseurl>, which can 
% be either an OPeNDAP catalog or a local directory. It is a harvester 
% on top of the crawler OPENDAP_CATALOG. Each node is harvested with 
% nc_cf_file2catalog. The full catalog is written to file nc2struct:
%
%  +-----------------------------------+
%  |Harvest loop:                      |
%  |nc_cf_opendap2catalog (NC_HARVEST) |
%  |   +-------------------------------+
%  |   |crawler:                       |
%  |   |OPENDAP_CATALOG                |
%  |   +-------------------------------+
%  |   |for each dataset node:         |
%  |   |   +---------------------------+
%  |   |   |harvester:                 |
%  |   |   |NC_HARVEST1                |
%  |.. +---+---------------------------+
%  |   :Store meta-data in cache:      |
%  |   :NC_CF_OPENDAP2CATALOG2nc       |
%  |   :+---STRUCT2NC                  |
%  |   :NC_CF_OPENDAP2CATALOG2xls      |
%  |   :+---STRUCT2XLS                 |
%  +---+-------------------------------+
%
% Set 'maxlevel' to crawl deeper (default 1). When you query a local directory, 
% and you want the resulting catalog.nc to work on a server, use keyword
% 'urlPathFcn' 
% to  replace the local root with the opendap root, e.g.:
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
%               'timeCoverage'
%               'datenum'
%               'geospatialCoverage_northsouth'
%               'geospatialCoverage_eastwest'
%               'geospatialCoverage_updown'
%               'projectionCoverage_x'
%               'projectionCoverage_y'
%               'projectionEPSGcode' % from x,y
% 
%          (iii) Specified 1D variables 
%                For orthogonal grids, it is advised to only use the 1D dimension variables x, y, and time
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
% For the CF timeseries some extra information is loaded.
%
%SEE ALSO: NC_HARVEST1,NC_HARVEST, NC_INFO, NC_ACTUAL_RANGE, 
%          STRUCT2NC, NC2STRUCT, OPENDAP_CATALOG, SNCTOOLS
%          NC_CF_OPENDAP2CATALOG2NC, NC_CF_OPENDAP2CATALOG2XLS, NC_CF_OPENDAP2CATALOG2KML

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

OPT                = opendap_catalog();
OPT.base           = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/catalog.xml'; % base url where to inquire, NB: needs to end with catalog.xml
OPT.files          = [];
OPT.directory      = '.'; % relative path that ends up in catalog
OPT.mask           = '*.nc';
OPT.pause          = 0;
OPT.test           = 0;
OPT.urlPathFcn     = @(s)(s); % function to run on urlPath, as e.g. strrep
OPT.save           = 0; % save catalog in directory
OPT.catalog_dir    = [];
OPT.catalog_name   = 'catalog'; % exclude from indexing
OPT.separator      = ';'; % for long names
OPT.datatype       = 'timeseries'; % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
OPT.disp           = 'multiWaitbar';
OPT.datestr        = 'yyyy-mm-ddTHH:MM:SS'; % default for high-freq timeseries

if nargin==0
   varargout = {OPT};
   return
end

%% List of variables to include
OPT.varname        = {}; % could be {'x','y','time'}

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
      if length(OPT.base)>7 &&  ~strcmpi(OPT.base(1:7),'http://')
         OPT.catalog_dir = OPT.base;
      end
   end

%% initialize waitbar

    if strcmpi(OPT.disp,'multiWaitbar')
    multiWaitbar(mfilename,0,'label','Generating catalog.nc','color',[0.3 0.6 0.3])
    end
    
%% File inquiry

    if isempty(OPT.files)
        OPT.url = OPT.base;
        
        keyvals = reshape([fieldnames(OPT)'; ...
	                      struct2cell(OPT)'], 1, ...
                  2*length(fieldnames(OPT)));
        
        OPT.files = opendap_catalog(OPT.base,keyvals{:},'onExtraField','silentIgnore');
    end

%  %% pre-allocate catalog (Note: expanding char array leads to 0 as fillvalues)
%  
%     for ifld=1:length(OPT.catalog_entry)
%      
%        fldname = mkvar(OPT.catalog_entry{ifld});
%        ATT.(fldname) = cell(length(OPT.files),1);
%      
%     end

% pre allocate

   for ivar = 1:length(OPT.varname)
      VAR.(OPT.varname{ivar}) = cell(length(OPT.files),1);
   end

%% File loop to get meta-data

   entry = 0;
   n     = length(OPT.files);

%% Get global attributes (PRE-ALLOCATE)
    
for entry=1:length(OPT.files)

   OPT.filename = OPT.files{entry};
   if strcmpi(OPT.disp,'multiWaitbar')
      multiWaitbar(mfilename,entry/length(OPT.files),'label',['Adding ',filename(OPT.filename) ' to catalog'])
   end
   
   urlPath            = OPT.urlPathFcn(OPT.filename);
   ATT.urlPath{entry} = urlPath;
   
   ATT1 = nc_harvest1(OPT.filename);
   
   ATT.projectionEPSGcode{entry}            =  ATT1.projectionEPSGcode;
   ATT.geospatialCoverage_northsouth{entry} = [ATT1.geospatialCoverage.northsouth.start ATT1.geospatialCoverage.northsouth.end];
   ATT.geospatialCoverage_eastwest{entry}   = [ATT1.geospatialCoverage.eastwest.start   ATT1.geospatialCoverage.eastwest.end  ];
   ATT.geospatialCoverage_updown{entry}     = [ATT1.geospatialCoverage.updown.start     ATT1.geospatialCoverage.updown.end    ];
   ATT.projectionCoverage_x{entry}          = [ATT1.geospatialCoverage.x.start          ATT1.geospatialCoverage.x.end         ];
   ATT.projectionCoverage_y{entry}          = [ATT1.geospatialCoverage.y.start          ATT1.geospatialCoverage.y.end         ];
   ATT.datenum{entry}                       = [ATT1.timeCoverage.start                  ATT1.timeCoverage.end                 ];

   ATT.standard_names{entry}                =  ATT1.standard_name;
   ATT.long_names    {entry}                =  ATT1.long_name;
   
   if strcmpi(OPT.datatype,'timeSeries')
   ATT.platform_id{entry}             = ATT1.platform_id;            
   ATT.platform_name{entry}           = ATT1.platform_name;          
   ATT.number_of_observations{entry}  = ATT1.number_of_observations;
   end
    
%% include variables

   for ivar = 1:length(OPT.varname)
       if nc_isvar(OPT.filename, OPT.varname{ivar})
       VAR.(OPT.varname{ivar}){entry} = nc_varget(OPT.filename, OPT.varname{ivar});
       end
   end
    
%% pause

   if OPT.pause
       pausedisp
   end
   
 %catch
 %    disp(['skipped erronous datasest: ',OPT.filename])
 %end
    
end % entry

ATT.timeCoverage  = cellfun(@(x) datestrnan(x),ATT.datenum, 'UniformOutput', false); 

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
   
      nc_cf_opendap2catalog2nc (fullfile(OPT.catalog_dir, [OPT.catalog_name,'.nc' ]),ATT,'datatype',OPT.datatype);
      nc_cf_opendap2catalog2xls(fullfile(OPT.catalog_dir, [OPT.catalog_name,'.xls']),ATT,'datatype',OPT.datatype);

   elseif nargout==0
       
       warning('output neither stored with ''save'' keyword, nor returned as argument: saved as ATT.mat.')
       
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
