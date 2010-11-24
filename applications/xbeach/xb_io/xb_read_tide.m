function xbSettings = xb_read_tide(filename, varargin)
%XB_READ_TIDE  Reads tide definition file for XBeach input
%
%   Reads a tide definition file containing a nx3 matrix of which the first
%   column is the time definition and the second and third column the water
%   level definition at respectively the seaward and landward boundary of
%   the model.
%
%   Syntax:
%   xbSettings  = xb_read_tide(filename)
%
%   Input:
%   filename    = filename of tide definition file
%   varargin    = none
%
%   Output:
%   xbSettings  = structure array with fields 'name' and 'value' containing
%                 all settings of the params.txt file
%
%   Example
%   xbSettings  = xb_read_tide(filename)
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% read file

xbSettings = xb_empty();
xbSettings = xb_set(xbSettings, 'time', [], 'tide', []);

if exist(filename, 'file')
    try
        A = load(filename);
        xbSettings = xb_set(xbSettings, 'time', {A(:,1) 's'});
        xbSettings = xb_set(xbSettings, 'tide', {A(:,2:end) 'm'});
    catch
        error(['Tide definition file incorrectly formatted [' filename ']']);
    end
end

% set meta data
xbSettings = xb_meta(xbSettings, mfilename, 'tide', filename);
