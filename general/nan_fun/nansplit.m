function varargout = nansplit(varargin)
%NANSPLIT  Split vectors with nan's to a cell array of nan-less parts
%
%   If more iputs are given they are split at the nan's of the first input
%
%   Syntax:
%   varargout = nansplit(varargin)
%
%   Input: For <keyword,value> pairs call nansplit() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nansplit
%
%   See also: nanjoin

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       TDA
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 05 Jun 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% input check
assert(isfloat(varargin{1}),'First input must be a vector of singles or doubles')
assert(isvector(varargin{1}),'First input must be a vector')
if iscolumn(varargin{1})
    for n=2:nargin
        assert(isequal(size(varargin{n},1),length(varargin{1})),'Inputs must equal size')
    end
else
    for n=2:nargin
        assert(isequal(size(varargin{n},2),length(varargin{1})),'Inputs must equal size')
    end
end

%% identify nan parts
nans = isnan(varargin{1});
cnt  = cumsum(ones(size(varargin{1})));

ii = find(~nans,1,'first');
n = 0;
jj = 0;
i_start = [];
i_end   = [];
while ~isempty(ii)
    jj = find(nans & (cnt>ii),1,'first')-1;
    if isempty(jj)
        jj = cnt(end);
    end
    n = n+1;
    i_start(n) = ii;
    i_end(n)   = jj;
    ii = find(~nans & (cnt>jj+1),1,'first');
end

%% assign output
varargout{1} = arrayfun(@(ii,jj) varargin{1}(ii:jj),i_start,i_end,'UniformOutput',false);
if iscolumn(varargin{1})
    for n = nargin:-1:2
        varargout{n} = arrayfun(@(ii,jj) varargin{n}(  ii:jj,:,:,:,:,:,:),i_start,i_end,'UniformOutput',false);
    end
else
    for n = nargin:-1:2
        varargout{n} = arrayfun(@(ii,jj) varargin{n}(:,ii:jj,:,:,:,:,:,:),i_start,i_end,'UniformOutput',false);
    end
end

