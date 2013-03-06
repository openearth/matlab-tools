function D = nc_cf_harvest(ncfiles,varargin)
%NC_CF_HARVEST  extract CF + THREDDS meta-data from list of netCDF/OPeNDAP urls
%
%    struct = nc_cf_harvest(ncfiles)
%
% harvests (extracts) <a href="http://cf-pcmdi.llnl.gov/">CF meta-data</a> + <a href="http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/index.html">THREDDS catalog</a>
% meta-data from cell list of ncfiles (netCDF file/OPeNDAP url)
% into an array of multi-layered structs.
%
% nc_cf_harvest can return the harvesting results as
% flat arrays which is memory efficient for a large
% ncfiles list, or as a nested structure, use keyword 'flat'.
%
% Rename url from a lcal rwesource with intended web 
% web location for publication with urlPathFcn.
%
% NC_CF_HARVEST is a simple loop around NC_CF_HARVEST1 
% that extracts only one ncfile (netCDF file/OPeNDAP url).
%
% Use OPENDAP_CATALOG to obtain a list of netCDF 
% files to which you can apply NC_CF_HARVEST or call.
% You can do this before calling to seperate crawling
% and harvesting, or let nc_cf_harvest do the crawling too
% by sypplying a url instead of a list of ncfiles:
%
%  struct = nc_cf_harvest(opendap_url)
%
% You can save the harvesting results to a THREDDS catalog.xml
% a netCDF file or excel file, with with NC_CF_HARVEST2XML,
% NC_CF_HARVEST2NC or NC_CF_HARVEST2XLS. You can also let
% NC_CF_HARVEST do it with struc keyword 'catalog'.
%
%  +--------------------------------------+
%  |for each dataset node:                |
%  |NC_CF_HARVEST                         |
%  |   +----------------------------------+
%  |   |crawler:                          |
%  |   |OPENDAP_CATALOG                   |
%  |   +----------------------------------+
%  |   |for each dataset node:            |
%  |   |                                  |
%  |   |   +------------------------------+
%  |   |   |harvester:                    |
%  |   |   |NC_CF_HARVEST1                |
%  |   +---+------------------------------+
%  |   |Store meta-data in cache:         |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST2xml              |
%  |   |   THREDDS standard xsd           |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST2nc               |
%  |   |    using STRUCT2NC               |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST2xls              |
%  |   |    using STRUCT2XLS              |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST2kml              |
%  |   |    for time series               |
%  +---+----------------------------------+
%
% Example: where crawling, harvesting and caching to xml are separated
%
%  url = 'd:\opendap.deltares.nl\thredds\dodsC\opendap\knmi\etmgeg\'
%  L   = opendap_catalog(url)
%  C   = nc_cf_harvest(L)
%  nc_cf_harvest2xml('etmgeg.xml',C)
%
% Example: everything carried out by NC_CF_HARVEST
%
%  url = 'd:\opendap.deltares.nl\thredds\dodsC\opendap\knmi\etmgeg\'
%  C   = nc_cf_harvest(url,'cataliog.xml','etmgeg.xml')
%
%See also: OPENDAP_CATALOG, NC_CF_HARVEST1, nc_cf_harvest2xml, nc_cf_harvest2nc, nc_cf_harvest2xls
%          thredds_dump, thredds_info,NC_INFO, nc_dump, NC_ACTUAL_RANGE, 
%          ncgentools_generate_catalog
%          python module "openearthtools.io.opendap.dapcrawler"

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011-2013 Deltares for Nationaal Modellen en Data centrum (NMDC),
%                           Building with Nature and internal Eureka competition.
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

   OPT.debug         = Inf; % number of ncfiles to process
   OPT.disp          = ''; %'multiWaitbar';
   OPT.flat          = 1; % flat is multi-layered struct, else struct with vectors
   OPT.urlPathFcn    = @(s)(s); % function to run on urlPath, as e.g. strrep
   OPT.catalog.xml   = '';
   OPT.catalog.xls   = '';
   OPT.catalog.nc    = '';
   OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
   OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
   OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'
   
   OPT = setproperty(OPT,varargin);
   
   if nargin==0
      D = OPT;return
   end
   
   %if any(structfun(@(x) ~isempty(x), OPT.catalog)) & ~(OPT.flat)
   %   warning('exporting catalog is more efficient with flat data storage')
   %end
   
   if ~iscell(ncfiles)
      url     = ncfiles;
      ncfiles = opendap_catalog(url);
   end
   if ~isinf(OPT.debug) || ~isempty(OPT.debug) || ~(OPT.debug==0)
      ncfiles = {ncfiles{1:min(OPT.debug,length(ncfiles))}};
   end
   n       = length(ncfiles);

   if ~(OPT.flat) % best for nested storage formats: xml

      d  = nc_cf_harvest1([],'featuretype',OPT.featuretype);
      D  = repmat(d,[1 n]);
      
   else % best for flat storage formats: netCDF and Excel

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
        D.number_of_observations                  = repmat(nan,[1 n]);
        D.dataSize                                = repmat(nan,[1 n]);
        D.date                                    = repmat(nan,[1 n]);
        
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
        
        D.projectionEPSGcode = cell(1,n);
             D.variable_name = cell(1,n);
             D.standard_name = cell(1,n);
                 D.long_name = cell(1,n);
                     D.units = cell(1,n);
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
        
   end
   
   % initialize harvest waitbar
   if strcmpi(OPT.disp,'multiWaitbar')
   multiWaitbar(mfilename,0,'label','Generating catalog.nc','color',[0.3 0.6 0.3])
   end   

   for i=1:n

      if strcmpi(OPT.disp,'multiWaitbar')
      multiWaitbar([mfilename],i/n,'label',['Harvesting ...',filename(ncfiles{i})]);
      else
      disp([num2str(i) ' ' num2str(n) ' ' ncfiles{i}])
      end

      if ~(OPT.flat)
         D(i) = nc_cf_harvest1(ncfiles{i},'featuretype',OPT.featuretype);
      else % better performance (memory management)
         d    = nc_cf_harvest1(ncfiles{i},'featuretype',OPT.featuretype);

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

        D.number_of_observations                  (i) = d.number_of_observations;
        D.dataSize                                (i) =               d.dataSize;
        D.date                                    (i) =                   d.date;

          D.projectionEPSGcode{i} =     d.projectionEPSGcode;
               D.variable_name{i} =      str2line(d.variable_name,'s',' ');% reverse with strtokens2cell
               D.standard_name{i} =      str2line(d.standard_name,'s',' ');% reverse with strtokens2cell
                       D.units{i} = ['"',str2line(d.units        ,'s','" "'),'"']; % can contain spaces, so embrace with brackets
                   D.long_name{i} = ['"',str2line(d.long_name    ,'s','" "'),'"']; % can contain spaces, so embrace with brackets
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
           D.(OPT.platform_id){i} =      d.(OPT.platform_id);
         D.(OPT.platform_name){i} =    d.(OPT.platform_name);
         
                       D.title{i} =          d.title;
                 D.institution{i} =    d.institution;
                      D.source{i} =         d.source;
                     D.history{i} =        d.history;
                  D.references{i} =     d.references;
                       D.email{i} =          d.email;
                     D.comment{i} =        d.comment;
                     D.version{i} =        d.version;
                 D.Conventions{i} =    d.Conventions;
               D.terms_for_use{i} =  d.terms_for_use;
                  D.disclaimer{i} =     d.disclaimer;
         
      end % flat

   end % i
   
%% Replace local file names with remote OPeNDAP urls (after extracting variables above)

      if ~(OPT.flat)   
         for i=1:n
             D(i).urlPath = OPT.urlPathFcn(D(i).urlPath);
         end
      else
      D.urlPath       = OPT.urlPathFcn(D.urlPath);
      end

%% Export to caches   

   if ~isempty(OPT.catalog.xml)
      nc_cf_harvest2xml(OPT.catalog.xml,D);
   end

   if ~isempty(OPT.catalog.xls)
      nc_cf_harvest2xls(OPT.catalog.xls,D);
   end
   
   if ~isempty(OPT.catalog.nc)
      nc_cf_harvest2nc(OPT.catalog.nc,D);
   end
