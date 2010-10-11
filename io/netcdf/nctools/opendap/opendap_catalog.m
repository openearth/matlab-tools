function varargout = opendap_catalog(varargin)
%OPENDAP_CATALOG   get urls of all datasets in an OPeNDAP catalog.xml url
%
%   nc_file_list = opendap_catalog(url)
%
% loads the urls of all datsets (netCDF files) that reside 
% under the OPeNDAP catalog.xml located at the specified url,
% as well as all catalogs that it links to.
%
% When url does not start with 'http', the url is assumed
% to be a local directory, and all netCDF files (*.nc) 
% in the directory tree below it are returned.
% Any trailing /catalog.html is replaced with /catalog.xml.
%
%   nc_file_list = opendap_catalog(url,<keyword,value>)
%
% The following important <keyword,value> pairs are implemented.
% You can list all keyword by calling OPT = filelist = opendap_catalog().
%
%  * maxlevel : specify how deep to crawl linked catalogs 
%               (default 1 for speed, set to Inf for all levels)
%               Does not work when url is on a local file system:
%               for maxlevel=1 one folder is crawled, for maxlevel > 1 the entire tree is crawled.
%  * leveltype: specify how levels are defined: 
%               'tree' when new level  = extra '/' in catalog url  (local catalog is not a new level)
%               'link' when new level  = linked (local catalog is a new level)
%  * debug    : display debug info (default 0)
%  * external : whether to include links to external catalogs (default 0)
%  * log      : log progress, 0 = quiet, 1 = command line, nr>1 = fid passed to fprintf (default 0)
%  * ...
%
% Tested succesfully with maxlevel=Inf for:
%
% * THREDDS: http://opendap.deltares.nl/thredds/catalog/opendap/catalog.xml
% * HYRAX:   http://opendap.deltares.nl/opendap/catalog.xml (need to specify toplevel url)
%
% * THREDDS: http://coast-enviro.er.usgs.gov/thredds/catalog.xml (externals do not work yet)
%
% * HYRAX:   http://data.nodc.noaa.gov/opendap/catalog.xml (with maxlevel=4, some forbidden catalogs are handled with try, catch)
% * local directory
%
% Example:
%
%    files = opendap_catalog('http://opendap.deltares.nl/thredds/catalog/opendap/knmi/NOAA/mom/1990_mom/5/catalog.xml')
%    nc_dump(files{1})
%   
%See web:  http://www.unidata.ucar.edu/Projects/THREDDS/tech/catalog/v1.0.2/Primer.html
%See also: OPENDAP_CATALOG_DATASET, XML_READ, XMLREAD, FINDALLFILES, SNCTOOLS

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
% $Keywords: $

%% keywords

   OPT.url                   = 'http://opendap.deltares.nl/thredds/catalog/opendap/catalog.xml';
   OPT.serviceType           = 'OPENDAP'; % only load this service type
   OPT.serviceBase           = [];
   OPT.serviceName           = [];
   OPT.level                 = 1;  % level of current catalog
   OPT.maxlevel              = 1;  % how deep to load local/remote catalogs, default fast, not deep
   OPT.external              = 0;  % load external (remote) catalogs
   OPT.serviceName_inherited = '';
   OPT.leveltype             = 'tree'; %'tree' 'or 'link': defines when a catalog is considered one level deeper
   OPT.serviceBaseURL        = '';
   OPT.toplevel              = ''; % to solve end catalogs in HYRAX
   OPT.debug                 = 0;  % writes levels to OPT.log
   OPT.log                   = 0;  % log progress, 0 = quiet, 1 = command line, nr>1 = fid passed to fprintf (default 0)
   OPT.ignoreCatalogNc       = 1;  % filters a file named catalog.nc from the files, if found 
   OPT.onlyCatalogNc         = 0;  % filter only files named catalog.nc
   
   if nargin==0
      varargout = {OPT};
      return
   end

   nextarg = 1;
   if nargin == 1
      if ~isstruct(varargin{1})
      OPT.url = varargin{1};
      nextarg = 2;
      end
   elseif nargin > 1
      if ( odd(nargin) & ~isstruct(varargin{2})) | ...
         (~odd(nargin) &  isstruct(varargin{2}));
         OPT.url = varargin{1};
         nextarg = 2;
     end
   end

   OPT = setproperty(OPT,varargin{nextarg:end});
   
%% remote vs. local url

if ~strcmpi(OPT.url(1:4),'http') && ~strcmpi(OPT.url(end-10:end),'catalog.xml')

   if OPT.maxlevel > 1
      fprintf(2,'opendap_catalog: maxlevel ignored because request concerns local file system.\n')
   end
   
   [nc_file_list,nc_folder_list] = findAllFiles(OPT.url,'pattern_incl','*.nc','recursive',OPT.maxlevel>1);
   
   % make sure thwere is a file separator at the end of the url field 
   if strcmp(filesep,OPT.url(end))
        %do nothing
   else
       OPT.url(end+1) = filesep;
   end
   % make sure we always return the full path
   if OPT.maxlevel<2
      nc_file_list   = path2os(cellstr(addrowcol(char(nc_file_list),0,-1,fliplr([OPT.url,filesep])))); % left-padd path
      nc_folder_list = OPT.url;
   end

else

   %% replace html into xml or warn

   if      strcmpi(OPT.url(end-4:end),'.html')
        OPT.url = [OPT.url(1:end-5)   '.xml'];
   elseif ~strcmpi(OPT.url(end-3:end),'.xml')
      fprintf(2,'warning: opendap_catalog: url does not have extension ".xml" or ".html"')
   end
      
   %% pre-allocate

   nc_file_list     = {}; % we cannot pre-allocate as some datasets may be a container with lots of nc_file_lists inside it
   nc_folder_list   = {}; % we cannot pre-allocate as some datasets may be a container with lots of nc_file_lists inside it

   %% check

   if OPT.level > OPT.maxlevel
      dprintf(OPT.log,['Skipped>maxlevel ',num2str(OPT.level,'%0.2d'),' catalog: ',OPT.url,'\n'])
   else
      dprintf(OPT.log,['Processing level ',num2str(OPT.level,'%0.2d'),' catalog: ',OPT.url,'\n'])

   %% load xml
   
      pref.KeepNS = 0; % hyrax has thredds namespace, while thredds has not
   
   try
      
      D   = xml_read(OPT.url,pref);
      
      if OPT.debug
         dprintf(OPT.log,'opendap_catalog: xml.\n')
         dprintf(OPT.log,['fieldnames: ',str2line(fieldnames(D),'s',','),'\n'])
        %dprintf(OPT.log,D.ATTRIBUTE,'\n')
      end
   
   %% check
   
      if isfield(D.ATTRIBUTE,'xmlns') % thredds_COLON_xmlns
      if ~strcmpi(D.ATTRIBUTE.xmlns,'http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0')
         error('requested url is not in correct name space.')
      end
      end
   
   %% DATASET and CATALOGREF
      nc_file_list   = opendap_catalog_dataset(D,OPT)
      nc_folder_list = []; % TO DO

   catch
      dprintf(OPT.log,['Skipped erronous ',                         '   catalog: ',OPT.url,'\n'])
   end

   end % OPT.level    
   
end

%% filter catalog nc

    if OPT.ignoreCatalogNc
        isCatalogNc = false(length(nc_file_list),1);
        for ii = 1:length(nc_file_list)
            isCatalogNc(ii) = strcmpi(nc_file_list{ii}(end-9:end),'catalog.nc');
        end
        nc_file_list(isCatalogNc) = [];
    end
    
%% filter catalog nc

    if OPT.onlyCatalogNc
        isCatalogNc = false(length(nc_file_list),1);
        for ii = 1:length(nc_file_list)
            isCatalogNc(ii) = strcmpi(nc_file_list{ii}(end-9:end),'catalog.nc');
        end
        nc_file_list(~isCatalogNc) = [];
    end
    
%% output

   if nargout==1
   varargout = {nc_file_list};
   else
   varargout = {nc_file_list,nc_folder_list};
   end
  
   %% EOF