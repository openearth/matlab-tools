function [pass info] = xb_checkBoundaryDepth(Hm0,Tp,h)
%XB_CHECKBOUNDARYDEPTH  Checks if model has sufficient depth for waves
%
%   This function checks whether the XBeach model has sufficient water
%   depth on the offshore boundary for the imposed wave conditions. The 
%   function checks the depth against the wave period (ratio of cg/c) and 
%   the water depth against the wave height (ratio H/h). 
%   The function returns a pass (logical) and info structure with the values
%   of cg/c and H/h and their individual pass values.
%
%   Syntax:
%   [pass info] = xb_checkBoundaryDepth(Hm0,Tp,h)
%
%   Input:
%   Hm0  =  Maximum spectral or significant wave height (m)
%   Tp   =  Maximum peak period (s)
%   h    =  (Minimum) water depth at the offshore model boundary (m)
%
%   Output:
%   pass =  Logical value if there is sufficient water depth (true) or 
%           insufficient water depth (false)
%   info =  Structure containing the pass value for the wave period
%           (npass), the value of cg/c (n), the pass value for the wave
%           height (gammapass) and the value of H/h (gamma)
%
%   Example
%   [pass info] = xb_checkBoundaryDepth(4,9,11.3)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall
%
%       robert.mccall@deltares.nl	
%
%       Rotterdamseweg 185
%       Delft
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% Set criteria
nmax = 0.85;
gammamax = 0.5;

% Initial values
pass = false;
info = struct(...
    'npass',false,...
    'n',NaN,...
    'gammapass','false',...
    'gamma',NaN);

%%
% Check cg/c ratio
L1=9.81*Tp^2/2/pi;
L2=0;
er=1;
while er>0.01
    L2=9.81*Tp^2/2/pi*tanh(2*pi*h/L1);
    er=abs(L2-L1);
    L1=L2;
end
k=2*pi/L1;
info.n=0.5+k*h/sinh(2*k*h);
info.npass=info.n<nmax;
%% test for H/h

info.gamma = Hm0/h;
info.gammapass = info.gamma<gammamax;

%% pass test
pass = info.npass && info.gammapass;
