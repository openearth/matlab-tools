function varstruct = nccreateVarstruct(varargin)
%NCCREATEVARSTRUCT  Subsidiary of nccreateSchema
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nccreateVarstruct(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nccreateVarstruct
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
% Created: 30 Mar 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
varstruct.Name         = '';
varstruct.Dimensions   = {};        % list of dimension names
varstruct.Size         = [];        % This is determined from Dimensions
varstruct.Datatype     = 'double';  % choose from: char double float int8 int16 int32 int64 uint8 uint16 uint32 uint64 
varstruct.Attributes   = {};        % Name value pairs
varstruct.ChunkSize    = [];        % leave empty to let netcdf library decide 
varstruct.DeflateLevel = [];        % set to value 1-9 to enable deflation
varstruct.Shuffle      = false;     % leave at false
varstruct.scale_factor = [];        % scale value (handy for storing integers)
varstruct.add_offset   = [];        % offset value, applied after scaling

% first run without FillValue field and don't allow classchange
varstruct = setproperty(varstruct,varargin,'onExtraField','silentIgnore','onClassChange','error');

% allow classchange only for FillValue field, as the class depends on the
% datatype' if left at auto, the default fill value will be used
varstruct.FillValue    = 'auto';
varstruct = setproperty(varstruct,varargin,'onClassChange','ignore');

% set files in same order matlab uses (only cosmetic)
varstruct = orderfields(varstruct,[1:6 11 7:10]);
