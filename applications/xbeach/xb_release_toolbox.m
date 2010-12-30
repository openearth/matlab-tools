function varargout = xb_release_toolbox(varargin)
%XB_RELEASE_TOOLBOX  create release of xbeach toolbox
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_release_toolbox(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_release_toolbox
%
%   See also 

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
% Created: 21 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% release

% select xb_* diretories only
fdir = fileparts(which(mfilename));
fdirs = dir(fullfile(fdir, 'xb_*'));
folders = {fdirs.name};
folders = folders([fdirs.isdir]);

% select all files and oetsettings
ffiles = dir(fdir);
files = {ffiles.name};
files = [{'oetsettings'} files{~[ffiles.isdir]}];

% release toolbox
oetrelease(...
    'targetdir'     , fullfile('F:', ['release_' datestr(now, 'ddmmmyyyy')]), ...
    'zipfilename'   , tempname, ...
    'folders'       , folders, ...
    'files'         , files, ...
    'omitdirs'      , {'svn' '_old' '_bak'});
