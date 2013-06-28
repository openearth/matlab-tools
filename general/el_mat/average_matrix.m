function reducedData = average_matrix(data,factor)
%average_matrix  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also

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
% Created: 28 Jun 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

siz = size(data);
assert(isequal(size(siz),size(factor)))

sizReducedData = siz./factor;
assert(all(sizReducedData == round(sizReducedData)))

reducedData = nan(sizReducedData);

for ii = 1:numel(reducedData);
    [n{1:numel(siz)}] = ind2sub(sizReducedData,ii);
    indices = cellfun(@(n,fact) (n-1)*fact + 1 : n*fact,n,num2cell(factor),'UniformOutput',false);
    
    selection = data(indices{:});
    notNan = ~isnan(selection);
    if any(notNan(:))
        reducedData(ii) = sum(selection(notNan)) / sum(notNan(:));
    else
        reducedData(ii) = nan;
    end
end