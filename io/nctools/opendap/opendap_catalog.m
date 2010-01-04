function varargout = opendap_catalog(varargin)
%OPENDAP_CATALOG   get urls of all datasets in an OPeNDAP catalog.xml url
%
%   urlPath = opendap_catalog(url)
%
% loads the urls of all datsets that reside in under the OPeNDAP catalog.xml 
% located at url and all catalogs it links to. 
%
%   urlPath = opendap_catalog(url,<keyword,value>)
%
% The following important <keyword,value> pairs are implemented
% You can list all keyword by calling OPT = filelist = opendap_catalog().
%
%  * maxlevel : specify how deep to crawl linked catalogs (default 2, not too slow, set to Inf for all levels)
%  * debug    : display debug info
%  * external : whether to include links to external catalogs (default 0)
%  * log      : log progress, 0 = quiet, 1 = command line, nr is fid passed to fprintf (default 0)
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
%   
%See web:  http://www.unidata.ucar.edu/Projects/THREDDS/tech/catalog/v1.0.2/Primer.html
%See also: OPENDAP_CATALOG_DATASET, XML_READ, XMLREAD

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
   OPT.maxlevel              = 2;  %  how deep to load local/remote catalogs, default fast, not deep
   OPT.external              = 0;  % load external (remote) catalogs
   OPT.serviceName_inherited = '';
   OPT.leveltype             = 'link'; %'tree' 'or 'link': defines when a catalog is considered one level deeper
   OPT.debug                 = 0;  % writes levels to screen
   OPT.serviceBaseURL        = '';
   OPT.toplevel              = ''; % to solve end catalogs in HYRAX
   OPT.log                   = 1;  % log progress, 0 = quiet, 1 = command line, nr is fid passed to fprintf (default 0)

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

   OPT = setProperty(OPT,varargin{nextarg:end});
   
%% pre-allocate

   urlPath     = {}; % we cannot pre-allocate as some datasets may be a container with lots of urlPaths inside it

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
         dprintf(OPT.log,D,'\n')
         dprintf(OPT.log,D.ATTRIBUTE,'\n')
      end
   
   %% check
   
      if isfield(D.ATTRIBUTE,'xmlns') % thredds_COLON_xmlns
      if ~strcmpi(D.ATTRIBUTE.xmlns,'http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0')
         error('requested url is not in correct name space.')
      end
      end
   
   %% DATASET and CATALOGREF
      
      urlPath = opendap_catalog_dataset(D,OPT);

   catch
      dprintf(OPT.log,['Skipped erronous ',                         '   catalog: ',OPT.url,'\n'])
   end

   end % OPT.level    
   
   varargout = {urlPath};
  
   %% EOF