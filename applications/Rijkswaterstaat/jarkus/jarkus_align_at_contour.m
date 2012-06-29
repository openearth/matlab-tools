function [xshift1 xshift2 xcr1 xcr2] = jarkus_align_at_contour(x1, z1, x2, z2, varargin)
%JARKUS_ALIGN_AT_CONTOUR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_align_at_contour(varargin)
%
%   Input:
%   varargin  = propertyname-propertyvalue pairs
%     'contour' : z-value to align at (default = 0)
%     'index'   : indication of either 'first', 'last', or n-th crossing
%                   (default = 1)
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_align_at_contour
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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
% Created: 05 Aug 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'contour', 0,...
    'index', 1);

OPT = setproperty(OPT, varargin{:});

%%
xc1 = x1([1 end]);
zc1 = repmat(OPT.contour, size(xc1));
xcr1 = findCrossings(x1, z1, xc1, zc1);
if isempty(xcr1)
    xcr1 = NaN;
elseif isnumeric(OPT.index)
    xcr1 = xcr1(OPT.index);
elseif strcmp(OPT.index, 'first')
    xcr1 = xcr1(1);
elseif strcmp(OPT.index, 'last')
    xcr1 = xc1(end);
end

xc2 = x2([1 end]);
zc2 = repmat(OPT.contour, size(xc2));
xcr2 = findCrossings(x2, z2, xc2, zc2);
if isempty(xcr2)
    xcr2 = NaN;
elseif isnumeric(OPT.index)
    xcr2 = xcr2(OPT.index);
elseif strcmp(OPT.index, 'first')
    xcr2 = xcr2(1);
elseif strcmp(OPT.index, 'last')
    xcr2 = xc2(end);
end

%%
xshift1 = xcr2 - xcr1;
xshift2 = xcr1 - xcr2;