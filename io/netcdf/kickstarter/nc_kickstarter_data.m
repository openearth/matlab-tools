function [m, dims, vars] = nc_kickstarter_data(host, template, epsg, var)
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
vars = struct();

for i = 1:length(m1)
    q = sprintf('Provide data for dimension "%s": ',m1(i).key);
    dims.(m1(i).key) = evalin('base',input(q,'s'));
    
    q = sprintf('Should dimension "%s" be unlimited in length? [n]: ',m1(i).key);
    if ismember(lower(input(q,'s')),{'y','yes'})
        m1(i).value = 'UNLIMITED';
    else
        m1(i).value = num2str(length(dims.(m1(i).key)));
    end
    
    dims.(m1(i).key) = dims.(m1(i).key)(:); % flatten
end

if isfield(dims,'x') && isfield(dims,'y')
    [X,Y] = meshgrid(dims.x,dims.y);
    [dims.lon, dims.lat]=convertCoordinates(X,Y,'CS1.code',epsg,'CS2.code',4326);
end

for i = 1:length(var)
    key = regexprep(var{i},'\W+','_'); % FIXME
    q = sprintf('Provide data for variable "%s": ',var{i});
    vars.(key) = evalin('base',input(q,'s'));
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
        case {'lat_min' 'lat_valid_min'}
            if isfield(dims,'lat')
                m2(i).value = min(dims.lat(:));
            end
        case {'lat_max' 'lat_valid_max'}
            if isfield(dims,'lat')
                m2(i).value = max(dims.lat(:));
            end
        case {'lon_min' 'lon_valid_min'}
            if isfield(dims,'lon')
                m2(i).value = min(dims.lon(:));
            end
        case {'lon_max' 'lon_valid_max'}
            if isfield(dims,'lon')
                m2(i).value = max(dims.lon(:));
            end
        case 'time_min'
        case 'time_max'
        case 'time_resolution'
        case 'lat_resolution'
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