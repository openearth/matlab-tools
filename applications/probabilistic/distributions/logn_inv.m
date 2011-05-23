function X = logn_inv(P, mu, sigma)
%LOGN_INV  inverse of the lognormal cumulative distribution function (cdf)
%
%   This function returns the inverse cdf of the lognormal distribution,
%   evaluated at the values in P.
%
%   Syntax:
%   X = logn_inv(P, mu, sigma)
%
%   Input:
%   X     = variable values
%
%   Output:
%   P     = cdf
%   mu    = mean value
%   sigma = standard deviation
%
%   Example
%   logn_inv
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% Created: 25 May 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% Return NaN for out of range parameters or probabilities.
sigma(sigma <= 0) = NaN;
P(P < 0 | 1 < P) = NaN;

logx0 = -sqrt(2).*erfcinv(2*P);
X = exp(sigma.*logx0 + mu);