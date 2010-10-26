function [b ndx pos] = nanunique(a, varargin)
%NANUNIQUE  Set unique, considering all nan-values as equal.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nanunique(varargin)
%
%   Input:
%   a         = array to be made unique
%   varargin  = optional flag1 and flag2 as used in unique
%
%   Output:
%   b   = unique values of a, sorted
%   ndx =
%   pos =
%
%   Example
%   nanunique
%
%   See also unique

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
% Created: 26 Oct 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% derive the maximum finite value in a
maxval = max(a(isfinite(a(:))));
if isempty(maxval)
    maxval = 0;
end
% create dummy-value for NaN which is larger than the maximum value
nandummyval = maxval + 1;
% replace all NaN-values with the dummy-value
a(isnan(a)) = nandummyval;
% run the unique function
[b ndx pos] = unique(a, varargin{:});
% replace the dummy-value by NaN
b(b == nandummyval) = NaN;