function data = xb_read_bcffile(filename, varargin)
%XB_READ_BCFFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_read_bcffile(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_read_bcffile
%
%   See also 

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
% Created: 02 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

[fdir fname] = fileparts(filename);

% determine dimensions
dims = xb_read_dims(fdir);

switch upper(fname(1))
    case 'E'
        fdims = [dims.globaly dims.wave_angle];
    case 'Q'
        fdims = [dims.globaly 3];
end

% determine time dimension based on filesize
info = dir(filename);
nt = info.bytes/8/prod(fdims);

% read file
fid = fopen(filename, 'r');

data = nan([fdims nt]);

for i = 1:nt
    idx = [num2cell(repmat(':',1,length(fdims))) {i}];
    data(idx{:}) = fread(fid, fdims, 'double');
end

fclose(fid);