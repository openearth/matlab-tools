function delete2(D)
%DELETE2  Deletes all files and folders in a structure returned by dir2
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = delete2(varargin)
%
%   Input:
%   D = struct returned by dir2 function
%
%   Output:
%   varargout =
%
%   Example
%   delete2
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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
% Created: 26 Apr 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% code
if ~isequal(fieldnames(D),{ 'name'
        'date'
        'bytes'
        'isdir'
        'datenum'
        'pathname'})
    error('input must be a struct returned by dir2')
end

dirs  = find( [D.isdir]);
files = find(~[D.isdir]);
for ii = files
    delete([D(ii).pathname D(ii).name]);
end

[~,order] = sort(cellfun(@length,{D(dirs).pathname}),'descend');
dirs      = dirs(order);

for ii = dirs
    rmdir([D(ii).pathname D(ii).name]);
end

