function w = getFallVelocity(D50, a, b, c)
%GETFALLVELOCITY  routine to compute fall velocity of sediment in water
%
%   This routine returns the fall velocity of sediment with grain size D50
%   in water
%
%   Syntax:
%   w = getFallVelocity(D50, a, b, c)
%
%   Input:
%   D50 = Grain size D50 [m]
%   a   = coefficient in fall velocity formulation
%   b   = coefficient in fall velocity formulation
%   c   = coefficient in fall velocity formulation
%
%   Output:
%   w   = fall velocity [m/s]
%
%   Example
%   getFallVelocity
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 20 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%% check input / set defaults
getdefaults('D50', 225e-6, 1);

if nargin <= 1
    % use default values for the Dutch situation
    [a b c] = deal(.476, 2.18, 3.226);
end    

%% fall velocity formulation
w = 1. / (10.^(a * (log10(D50)).^2 + b * log10(D50) + c));
