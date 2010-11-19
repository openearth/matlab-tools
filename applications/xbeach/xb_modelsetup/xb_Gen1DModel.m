function XB = xb_generate_model_1D(bathy,waves,surge,settings,simdir)
%XB_GENERATE_MODEL_1D  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   XB = xb_generate_model_1D(varargin)
%
%   Input:
%   bathy   = array that contains bed elevations as function of cross-shore position
%   waves   = input array for instat = 41; conatains Hm0 [m], Tp [s], Dir [deg], s [-], gammajsp [-], duration [s], dtbc [s]   
%   surge   = input array of mean water level time [s] wl_offshore [m] wl_bay[m]]
%   settings= xbeach input keywords different than default (see params.f90)
%   simdir  = goal directory for simulation
%
%   Output:
%   
%
%   Example
%   bathy = [0:1:200; 0.1*(0:1:200)-15;]';
%   waves = [[1 2 1]; [5 8 5]; [270 270 270]; [10 10 10]; [1 1 1]; [1000 1000 1000]; [1 1 1];]';
%   surge = [[0 1000 2000 3000]; [0 0 0 0]; [0 0 0 0];]';
%   xb_generate_model_1D(bathy,waves,surge,settings,simdir);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Jaap van Thiel de Vries / Robert McCall
%
%       jaap.vanthiel@deltares.nl
%
%       
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
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% check input arrays



%% create grid 
varargin = {'Tm',min(waves(:,2)),...
            'wl',min(surge(:,2)) ...
            };
        
[xgr ygr zgr] = xb_1D_grid(bathy(:,2), bathy(:,1), varargin);

xb_write_bathy(xgr,ygr,zgr,alfa,xori,yori);

% figure; plot(xgr(2,:),zgr(2,:),'r-o');


%%  

