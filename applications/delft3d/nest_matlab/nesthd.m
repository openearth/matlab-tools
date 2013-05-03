function nesthd(varargin)
% NESTHD  nesting of curvi-linear hydrodynamic models (Delft3D-Flow & Rijkswaterstaat SIMONA(WAQUA/TRIWAQ)
%
% nesthd() launches GUI
% nesthd(keyword) runs in batch mode
%
% Help is available as Windows help file: NestHD.chm
%
% Unlike the Delft3D fortran nesth programs, nest_matlab has
% support for Neumann boundaries, Riemann boundaries, and
% tangential velocity components (parallel to open boundary), 
%
%See also: delft3d

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 www.Deltares.nl
%       Theo van der Kaaij
%
%       theo.vanderkaaij@deltares.nl
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
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% set additional paths
%  is already taken care of by oetsettings: then setproperty is on path (most important OET function)

if ~isdeployed & any(which('setproperty'))
   addpath(genpath('..\..\..\..\matlab'));
   addpath(genpath('nest_ui'));
   addpath(genpath('nesthd1'));
   addpath(genpath('nesthd2'));
   addpath(genpath('general'));
   addpath(genpath('reawri'));
end

%% Check if nesthd_path is set

if isempty (getenv('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Initialize

handles  = [];

%% run

if ~isempty(varargin)

    % Batch

    [handles] = nesthd_ini_ui(handles);
    [handles] = nesthd_read_ini(handles,varargin{1});
    nesthd_run_now(handles);
else

    % Stand alone
    nesthd_nest_ui;
end
