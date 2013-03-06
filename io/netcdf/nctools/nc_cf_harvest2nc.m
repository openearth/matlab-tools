function nc_cf_opendap2catalog2nc(ncname,ATT,varargin)
%NC_CF_OPENDAP2CATALOG2NC <{[deprecated]}>
%
% deprecated: use nc_cf_harvest2nc
%
%See also: NC_CF_HARVEST, nc_cf_harvest2xml, nc_cf_harvest2xls,
%          thredds_dump, thredds_info

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

OPT.debug       = 0;

OPT = setproperty(OPT,varargin);

      if OPT.debug
      structfun(@(x) x{1},ATT,'UniformOutput',0)	
      end
      n = length(ATT.geospatialCoverage_northsouth_start);

      if isfield(ATT,'platform_id')
      D.platform_id                   = ATT.platform_id;   
      end

      if isfield(ATT,'platform_name')
      D.platform_name                 = ATT.platform_name;
      end

      if isfield(ATT,'number_of_observations')
      D.number_of_observations        = ATT.number_of_observations;
      end

      D.datenum_start                 = ATT.timeCoverage_start;
      D.datenum_end                   = ATT.timeCoverage_end;
      D.timeCoverage_start            = datestr(ATT.timeCoverage_start,'yyyy-mm-ddTHH:MM:SS');
      D.timeCoverage_end              = datestr(ATT.timeCoverage_end  ,'yyyy-mm-ddTHH:MM:SS');

      D.urlPath                       = ATT.urlPath;
      D.variable_name                 = ATT.variable_name     ;%     char(cellfun(@(x) str2line(x,'s',' ')  ,ATT.variable_name,'UniformOutput',false));
      D.standard_name                 = ATT.standard_name     ;%     char(cellfun(@(x) str2line(x,'s',' ')  ,ATT.standard_name,'UniformOutput',false));
      D.units                         = ATT.units             ;%     char(cellfun(@(x) str2line(x,'s',' ')  ,ATT.units        ,'UniformOutput',false));
      D.long_name                     = ATT.long_name         ;%char(cellfun(@(x) addrowcol(str2line(x,'s','" "'),0,[-1 1],'"'),ATT.long_name    ,'UniformOutput',false));
      
      ind = find(cellfun(@(x) isempty(x),ATT.projectionEPSGcode));
      for i=ind
      ATT.projectionEPSGcode{i}=nan;
      end
      D.projectionEPSGcode            =         cell2mat(ATT.projectionEPSGcode           )';    

      D.geospatialCoverage_northsouth = [ATT.geospatialCoverage_northsouth_start;ATT.geospatialCoverage_northsouth_end];
      D.geospatialCoverage_eastwest   = [ATT.geospatialCoverage_eastwest_start  ;ATT.geospatialCoverage_eastwest_end  ];
      D.projectionCoverage_x          = [ATT.geospatialCoverage_x_start     ;ATT.geospatialCoverage_x_end     ];
      D.projectionCoverage_y          = [ATT.geospatialCoverage_y_start     ;ATT.geospatialCoverage_y_end     ];
      D.geospatialCoverage_updown     = [ATT.geospatialCoverage_updown_start;ATT.geospatialCoverage_updown_end];
      
                D.title =         ATT.title;
          D.institution =   ATT.institution;
               D.source =        ATT.source;
              D.history =       ATT.history;
           D.references =    ATT.references;
                D.email =         ATT.email;
              D.comment =       ATT.comment;
              D.version =       ATT.version;
          D.Conventions =   ATT.Conventions;
        D.terms_for_use = ATT.terms_for_use;
           D.disclaimer =    ATT.disclaimer;
      
      struct2nc(ncname,D);

      nc_attput(ncname,nc_global,'comment','catalog.nc was created offline by $HeadURL$ from the associatec catalog.xml. Catalog.nc is a test development, please do not rely on it. Please join www.OpenEarth.eu and request a password to change $HeadURL$ until it harvests all meta-data you need.');
