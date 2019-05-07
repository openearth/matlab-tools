function xb_delft3d_addpath(varargin)
%XB_DELFT3D_ADDPATH  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_delft3d_addpath(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_delft3d_addpath
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 06 Jan 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_delft3d_addpath.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_modelsetup/xb_grid/xb_delft3d/xb_delft3d_addpath.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'd3dpath', 'C:\Delft3D\w32\delft3d_matlab' ...
);

OPT = setproperty(OPT, varargin{:});

%% add path

if exist('wlgrid','file') ~= 2 || exist('wldep','file') ~= 2
    if exist(OPT.d3dpath, 'dir')
        addpath(genpath(OPT.d3dpath));
    else
        error('Cannot add Delft3D path');
    end
end