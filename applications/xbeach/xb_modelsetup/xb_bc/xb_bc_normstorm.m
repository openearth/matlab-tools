function [h Hs Tp] = xb_bc_normstorm(varargin)
%XB_BC_NORMSTORM  Returns normative storm conditions for the Dutch coast (WL|Delft Hydraulics, 2007, project H4357, product 3)
%
%   Returns normative storm conditions for the Dutch coast (WL|Delft
%   Hydraulics, 2007, project H4357, product 3)
%
%   Syntax:
%   [h Hs Tp] = xb_bc_normstorm(varargin)
%
%   Input:
%   varargin  = freq:   Normative frequency of occurrence
%               loc:    Location along Dutch coast
%
%   Output:
%   h         = Normative surge level above MSL
%   Hs        = Normative wave height
%   Tp        = Normative wave period
%
%   Example
%   [h Hs Tp] = xb_bc_normstorm()
%
%   See also xb_bc_stormsurge

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
% Created: 24 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% read options

OPT = struct( ...
    'freq', 1e-4, ...
    'loc', 0 ...
);

OPT = setproperty(OPT, varargin{:});

%% maximum surge level

%       omega   rho     alpha   sigma

A1 = [  1.95    7.237   0.57    0.0158      % Hoek van Holland
        1.85    5.341   0.63    0.0358      % IJmuiden
        1.60    3.254   1.60    0.9001      % Den Helder
        2.25    0.500   1.86    1.0995      % Eierland
        1.85    5.781   1.27    0.5350  ];  % Borkum

Fe = OPT.freq'*ones(size(A1,1),1);

h = A1(:,4).*((A1(:,1)./A1(:,4)).^A1(:,3)-log(Fe./A1(:,2))).^(1./A1(:,3));

if any(h < A1(:,1))
    warning('Maximum surge level is outside validity range of probabilitic formulation');
end

%% maximum wave height

%       a       b       c       d   e

A2 = [  4.35    0.6     0.008   7   4.67
        5.88    0.6     0.0254  7   2.77
        9.43    0.6     0.68    7   1.26
        12.19   0.6     1.23    7   1.14
        10.13   0.6     0.57    7   1.58    ];
    
Hs = A2(:,1)+A2(:,2).*h-A2(:,3).*max(0, A2(:,4)-h).^A2(:,5);

%% maximum wave period

%       alpha   beta

A3 = [  3.86    1.09            % Hoek van Holland
        4.67    1.12    ];      % Den Helder
    
Tp = A3(:,1)+A3(:,2).*Hs([1 3]);
