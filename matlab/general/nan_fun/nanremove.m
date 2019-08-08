function varargout = nanremove(varargin)
%NANREMOVE  Remove NaNs out of one or more vectors.
%
%   This function removes elements out of all vectors in any of them occurs
%   a NaN at that particular position.
%
%   Syntax:
%   varargout = nanremove(varargin)
%
%   Input:
%   varargin  = one or more vectors
%
%   Output:
%   varargout =
%
%   Example
%   nanremove
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 20 May 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if ~all(cellfun(@isvector, varargin))
    error('All input arguments must be vectors')
end

sizes = cell2mat(cellfun(@size, varargin, 'UniformOutput', false)');
if ~isequal(mean(sizes), sizes(1,:))
    error('All input arguments must have the same size')
end

% pre-allocate logical variable indicating where to remove elements
removeid = false(size(varargin{1}));

for iarg = 1:nargin
    removeid(isnan(varargin{iarg})) = true;
end

varargout = varargin;

for iarg = 1:nargin
    varargout{iarg}(removeid) = [];
end