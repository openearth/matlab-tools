function [a, b, r2, r, k2] = xb_linreg(x, y)
%XB_LINREG  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_linreg(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_linreg
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 13 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% linear regression

% Number of known points
n = length(x);

% Initialization
j = 0; k = 0; l = 0; m = 0; r2 = 0;

% Accumulate intermediate sums
j = sum(x);
k = sum(y);
l = sum(x.^2);
m = sum(y.^2);
r2 = sum(x.*y);

% Compute curve coefficients
b = (n*r2 - k*j)/(n*l - j^2);
a = (k - b*j)/n;

% Compute regression analysis
j = b*(r2 - j*k/n);
m = m - k^2/n;
k = m - j;

% Coefficient of determination
r2 = j/m;

% Coefficient of correlation
r = sqrt(r2);

% Std. error of estimate
k2 = sqrt(k/(n-2));