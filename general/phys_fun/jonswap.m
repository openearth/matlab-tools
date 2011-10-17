function y = jonswap(x, gam)
%JONSWAP  Create unscaled JONSWAP spectrum
%
%   Create unscaled JONSWAP spectrum.
%
%   Syntax:
%   y = jonswap(x, gam)
%
%   Input:
%   x         = nondimensional frequency, divided by the peak frequency
%   gam       = peak enhancement factor, optional parameter (default: 3.3)
%   y         = nondimensional relative spectral density, equal to one at
%               the peak
%
%   Output:
%   y         = unscaled energy density
%
%   Example
%   y = jonswap(x);
%   y = jonswap(x, 1.0);
%
%   See also disper

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 17 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

if nargin < 2
    gam = 3.3;
end

%% create spectrum

xa          = abs(x);
zxa         = find(xa == 0);

if ~isempty(zxa)
  xa(zxa)   = eps * ones(size(xa(zxa)));
end;

sigma       = (xa < 1) * 0.07 + (xa >= 1) * 0.09;
fac1        = xa .^ (-5);
fac2        = exp (-1.25*(xa.^(-4)));
fac3        = (gam .* ones(size(xa))) .^ (exp (-((xa-1).^2) ./ (2*sigma.^2)));

y = fac1 .* fac2 .* fac3;

y = y / max(y);
