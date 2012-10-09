function vardata = ncread_strict_dimension_order(ncFile, varName, dimNames, varargin)
%UNTITLED  As ncread, except that you can specify the dimension order of the output
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: 
%   dimNames  = cell array with the names of the dimensions
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also: ncread   

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
% Created: 09 Oct 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
assert(iscellstr(dimNames),'dimNames must be a cell string')

info = ncinfo(ncFile, varName);
assert(numel(dimNames) == numel(info.Dimensions),'Wrong number of dimensions')

[in_a,order] = ismember({info.Dimensions.Name},dimNames);
assert(all(in_a),'Wrong dimension names, should be these');

% are all
if issorted(order)
    vardata = ncread(ncFile, varName, varargin{:});
else
    % Permute start, count, stride
    varargin = cellfun(@(arg) arg(order),varargin,'UniformOutput',false);
    
    % read data and permute outcome
    vardata = permute(ncread(ncFile, varName, varargin{:}),order);
end


