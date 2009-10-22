%NC_CF_CATALOG_TEST   test script for 
%
%See also: NC_CF_DIRECTORY2CATALOG, NC_CF2CATALOG

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% get catalog

   OPT.baseurl = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/';
   
   C           = nc2struct([OPT.baseurl,'catalog.nc'])
   
%% query call

   index       = (C.datenum_start                    < datenum(1850,1,1)   & ...
                  C.datenum_end                      > datenum(2000,1,1)   & ...
                  C.geospatialCoverage_northsouth(1) >  50 & ...
                  C.geospatialCoverage_northsouth(2) <  57 & ...
                  C.geospatialCoverage_eastwest  (1) >   3 & ...
                  C.geospatialCoverage_eastwest  (2) <  10);
                  
   index = find(index);

%% query overview

   for ii=1:length(index)
   
   disp([C.timecoverage_start{index(ii)},'   ',...
           C.timecoverage_end{index(ii)},'   ',...
                    C.urlPath{index(ii)}]);
   
   end
   
%% use query

   [D,M]=nc_cf_stationTimeSeries([OPT.baseurl,filename(char(C.urlPath(index(1),:))),'.nc']);