function xb = xb_read_tide(filename, varargin)
%XB_READ_TIDE  Reads tide definition file for XBeach input
%
%   Reads a tide definition file containing a nx3 matrix of which the first
%   column is the time definition and the second and third column the water
%   level definition at respectively the seaward and landward boundary of
%   the model.
%
%   Syntax:
%   xb  = xb_read_tide(filename)
%
%   Input:
%   filename    = filename of tide definition file
%   varargin    = none
%
%   Output:
%   xb          = XBeach structure array
%
%   Example
%   xb  = xb_read_tide(filename)
%
%   See also xb_read_params, xb_write_tide

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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_read_tide.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_io/xb_read_tide.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% read file

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']'])
end

xb = xs_empty();
xb = xs_set(xb, 'time', [], 'tide', []);

try
    A = load(filename);
    xb = xs_set(xb, '-units', 'time', {A(:,1) 's'}, 'tide', {A(:,2:end) 'm'});
catch
    error(['Tide definition file incorrectly formatted [' filename ']']);
end

% set meta data
xb = xs_meta(xb, mfilename, 'tide', filename);
