function urls = getFixedMapOutlines(type)
%rws_GETFIXEDMAPOUTLINES   Routine to retrieve information from OPeNDAP server
%
%   Syntax:
%   urls = opendap_getFixedMapOutlines(type)
%
%   Input:
%   	datatype = type indicator for fixed map dataset to use ('jarkus', 'vaklodingen')
%
%   Output:
%       urls     = function outputs the urls of all available fixed maps
%
%   Example:
%
% See also: rws_getDataInPolygon, rws_createFixedMapsOnAxes, rws_identifyWhichMapsAreInPolygon, getDataFromNetCDFGrid


% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section 
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

%% get info from OpenDAP (may take a while)
% info = getOpenDAPinfo('url', 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/catalog.xml');
% info = getOpenDAPinfo('url', 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml');

%% extract ncfile names from OPeNDAP info
if strcmp(type,'vaklodingen')
%     ncfiles = info.vaklodingen;
    info = getOpenDAPinfo('url', 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml');
    path =                       'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';
elseif strcmp(type,'jarkus')
%     ncfiles = info.jarkus.temp_grids;
    info = getOpenDAPinfo('url', 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml');
    path =                       'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/';
else
    return
end

%% construct full url for each ncfile
% initialise variable
urls{length(info),1} = '.';

% one by one fill the urls variable
for i = 1:length(info)
    urls{i,1} = [path info{i}];
end
urls = cellfun(@strrep, urls, repmat({'_dot_'} , size(urls)), repmat({'.'}, size(urls)), 'UniformOutput', 0);
urls = cellfun(@strrep, urls, repmat({'/temp_'}, size(urls)), repmat({'/'}, size(urls)), 'UniformOutput', 0);
