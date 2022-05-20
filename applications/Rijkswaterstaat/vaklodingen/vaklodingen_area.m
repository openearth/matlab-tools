function [area range] = vaklodingen_area(url, varargin)
%VAKLODINGEN_AREA  Determines extent of Vaklodingen maps
%
%   Determines extent of Vaklodingen maps based on netCDF source.
%
%   Syntax:
%   [area range] = vaklodingen_area(url, varargin)
%
%   Input:
%   url       = url of datasource
%   varargin  = none
%
%   Output:
%   area      = area definition (as x, y, w, h)
%   range     = range definitiona (as x1, x2, y1, y2)
%
%   Example
%   area = vaklodingen_area(url)
%
%   See also vaklodingen_url

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 07 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% get range of vaklodingen id

if ~isempty(url)
    info = nc_info(url);

    fields = {'x' 'y'};
    range = zeros(length(fields),2);
    for i = 1:length(fields)
        idx1 = strcmpi({info.Dataset.Name}, fields{i});
        idx2 = strcmpi({info.Dataset(idx1).Attribute.Name}, 'actual_range');
        range(i,:) = str2double(regexp(info.Dataset(idx1).Attribute(idx2).Value, '\s+', 'split'));
    end
    
    area = [range(1,1) range(2,1) diff(range(1,:)) diff(range(2,:))];
end