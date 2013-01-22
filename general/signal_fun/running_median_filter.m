function data = running_median_filter(data,window)
%RUNNING_MEDIAN_FILTER  Fast running median calculation
%
%   More detailed description goes here.
%
%   Syntax:
%   data = running_median_filter(data,window)
%
%   Example
%     % calculate running median over 100k points with a window width of 1k
%     d = 1:1e5;
%     data = randn(size(d))+2*sind(d/15)+sind(d/16)+sind(d/17)+sind(d/18)+sind(d/19);
%     window = uint16(1000);
%     filtered = running_median_filter(data,window);
%     plot(d,data,'.',d,filtered,'r')
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 09 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% code
narginchk(2,2)
assert(~any(isnan(data) | isinf(data)),'NaN''s and Inf''s are not accepted by running_median_filter');
data = running_median_filter(double(data),uint16(window));