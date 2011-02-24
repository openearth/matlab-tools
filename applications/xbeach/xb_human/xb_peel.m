function xb_peel(xb, varargin)
%XB_PEEL  Peels the XBeach structure from the data
%
%   Defines a variable in the Matlab base workspace for each variable in an
%   XBeach structure.
%
%   Syntax:
%   xb_peel(xb, varargin)
%
%   Input:
%   xb        = XBeach structure to peel
%   varargin  = none
%
%   Output:
%   varargout = none
%
%   Example
%   xb_peel(xb)
%
%   See also xb_get, xb_show

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
% Created: 24 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ~xb_check(xb); error('Invalid XBeach structure'); end;

%% peel dimensions, if exists

if xb_exist(xb, 'DIMS')
    dims = xb_get(xb, 'DIMS');
    if xb_check(dims)
        xb_peel(dims);
    end
end

%% decalare variables in base workspace

names = {xb.data.name};
for i = 1:length(names)
    assignin('base', names{i}, xb.data(i).value);
end
