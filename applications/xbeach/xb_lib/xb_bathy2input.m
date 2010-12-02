function xb = xb_bathy2input(xb, varargin)
%XB_BATHY2INPUT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_bathy2input(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_bathy2input
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
% Created: 02 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% convert bathy to input

if ~xb_check(xb); error('Invalid XBeach structure'); end;

[xfile yfile depfile nelayer] = xb_split(xb, 'xfile', 'yfile', 'depfile', 'ne_layer');

xb = xb_empty();

if ~isempty(xfile.data)
    xb = xb_set(xb, 'xfile', xfile);
end

if ~isempty(yfile.data)
    xb = xb_set(xb, 'yfile', yfile);
end

if ~isempty(depfile.data)
    xb = xb_set(xb, 'depfile', depfile);
end

if ~isempty(nelayer.data)
    xb = xb_set(xb, 'ne_layer', nelayer);
end
