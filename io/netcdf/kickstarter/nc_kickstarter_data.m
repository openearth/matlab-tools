function m = nc_kickstarter_data(host, template, vars)
%NC_KICKSTARTER_DATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_kickstarter_data(varargin)
%
%   Input: For <keyword,value> pairs call nc_kickstarter_data() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_kickstarter_data
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% user input

url = fullfile(host,'json','templates',[template '?category=dim']);
data = urlread(url);
m1 = json.load(data);
[m1.value] = deal(nan);

dims = struct();

for i = 1:length(m1)
    dims.(m1(i).key) = input(sprintf('Provide data for dimension "%s": ',m1(i).key));
    m1(i).value = num2str(length(dims.(m1(i).key)));
end

for i = 1:length(vars)
    vars{i} = input(sprintf('Provide data for variable "%s": ',vars{i}));
end

%% compute bounds

url = fullfile(host,'json','templates',[template '?category=dat']);
data = urlread(url);
m2 = json.load(data);
[m2.value] = deal(nan);

for i = 1:length(m2)
    switch m2(i).key
        case 'x_valid_min'
            if isfield(dims,'x')
                m2(i).value = min(dims.x);
            end
        case 'x_valid_max'
            if isfield(dims,'x')
                m2(i).value = max(dims.x);
            end
        case 'y_valid_min'
            if isfield(dims,'y')
                m2(i).value = min(dims.y);
            end
        case 'y_valid_max'
            if isfield(dims,'y')
                m2(i).value = max(dims.y);
            end
        case 'lat_valid_min'
        case 'lat_valid_max'
        case 'lon_valid_min'
        case 'lon_valid_max'
        case 'time_min'
        case 'time_max'
        case 'time_resolution'
        case 'lat_min'
        case 'lat_max'
        case 'lat_resolution'
        case 'lon_max'
        case 'lon_min'
        case 'lon_resolution'
    end
    if isnan(m2(i).value)
        m2(i).value = m2(i).default;
    end
    if ~ischar(m2(i).value)
        m2(i).value = num2str(m2(i).value);
    end
end

%% output

m = [m1 m2];