function OpenDAPlinks = getOpenDAPlinks(varargin)
%GETOPENDAPLINKS  Routine gets available links from OpenDAP server given an OpenDAP url
%
%   Routine gets available links from OpenDAP server given an OpenDAP url.
%   This routine is intended to be a general engine that can be used at
%   e.g. the institute level, the data sets level and the data set level.
%   From the input url the available data sets including their appropriate
%   urls may be derived.
%
%
%   Syntax:
%       OpenDAPlinks = getOpenDAPlinks(varargin)
%
%   Input:
%       For the following keywords, values are accepted (values indicated are the current default settings):
%           'url', 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/catalog.xml' % default is OpenDAP test server url
%
%   Output:
%       OpenDAPlinks = cell array with links found at the level indicated by the url
%
%   Example
%       url = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/catalog.xml';
%       OpenDAPlinks = getOpenDAPlinks('url', url)
%
%   See also getOpenDAPinfo

warning('getOpenDAPlinks is deprecated, use opendap_catalog instead')

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

% Created: 26 Apr 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: getOpenDAPlinks.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/io/opendap/getOpenDAPlinks.m $
% $Keywords: $

%%
OPT = struct(...
    'url', 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/catalog.xml', ... % default is OpenDAP test server url
    'pattern', ' xlink:title="' ... % default is pattern at levels below the actual data files (e.g. institute level)
    );

OPT = setproperty(OPT, varargin{:});

%% get OpenDAP links
try
    txt = urlread(OPT.url);
catch
    xx=0
end
pattern = OPT.pattern;
locs = strfind(txt, pattern);
if ~isempty(locs)
    for i = 1: length(locs)
        [OpenDAPlinks{i,1}] = strtok(txt(locs(i)+length(pattern):end), '"');
    end
else
    OpenDAPlinks = [];
end