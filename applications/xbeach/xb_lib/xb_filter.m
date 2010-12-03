function matches = xb_filter(vars, filters)
%XB_FILTER  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_filter(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_filter
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 03 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% check input

if ~iscell(vars); vars = {vars}; end;
if ~iscell(filters); filters = {filters}; end;

%% search matches

matches = false(size(vars));

for i = 1:length(filters)
    if filters{i}(1) == '/'
        % regexp filter
        f = regexp(filters{i}, '^/(.*?)/{0,1}$', 'tokens'); f = f{1};
        matches(~cellfun('isempty', regexpi(vars, f, 'start'))) = true;
    elseif ismember('*', filters{i})
        % dos filter
        f = ['^' strrep(filters{i}, '*', '.*') '$'];
        matches(~cellfun('isempty', regexpi(vars, f, 'start'))) = true;
    else
        % exact match
        matches(strcmpi(filters{i}, vars)) = true;
    end
end