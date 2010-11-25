function xbSettings = xb_read_bathy(varargin)
%XB_READ_BATHY  Read xbeach bathymetry files
%
%   Routine to read xbeach bathymetry files.
%
%   Syntax:
%   xbSettings = xb_read_bathy(xfile, yfile, depfile, nefile)
%
%   Input:
%   varargin    = xfile:    file name of x-coordinates file (cross-shore)
%                 yfile:    file name of y-coordinates file (alongshore)
%                 depfile:  file name of bathymetry file
%                 ne_layer: file name of non erodible layer file
%
%   Output:
%   xbSettings  = XBeach structure array
%
%   Example
%   xbSettings = xb_read_bathy('xfile', xfile, 'yfile', yfile)
%
%   See also xb_write_bathy, xb_read_input

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
    'xfile', '', ...
    'yfile', '', ...
    'depfile', '', ...
    'ne_layer', '' ...
);

OPT = setproperty(OPT, varargin{:});

%% create xbeach struct

xbSettings = xb_empty();

files = {};

if exist(OPT.xfile, 'file')
    % read file with x-coordinates (cross-shore)
    xbSettings = xb_set(xbSettings, 'xfile', load(OPT.xfile));
    files = [files {OPT.xfile}];
end

if exist(OPT.yfile, 'file')
    % read file with y-coordinates (alongshore)
    xbSettings = xb_set(xbSettings, 'yfile', load(OPT.yfile));
    files = [files {OPT.yfile}];
end

if exist(OPT.depfile, 'file')
    % read bathymetry file
    xbSettings = xb_set(xbSettings, 'depfile', load(OPT.depfile));
    files = [files {OPT.depfile}];
end

if exist(OPT.ne_layer, 'file')
    % read non-erodible layer file
    xbSettings = xb_set(xbSettings, 'ne_layer', load(OPT.ne_layer));
    files = [files {OPT.ne_layer}];
end

% set meta data
xbSettings = xb_meta(xbSettings, mfilename, 'bathymetry', files);