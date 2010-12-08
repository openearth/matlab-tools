function varargout = xb_directional_wavegrid(xb,varargin)
%UNTITLED  Generates wave directional grid for wave action balance.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Jaap van Thiel de Vries
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 08 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% 

% xb = xb_generate_waves
% xb = xb_set(xb,'dir',[231],'s',[10]);

OPT = struct( ...
            'varthr', 0.05, ...
            'nbins', 7 ...
            );

OPT = setproperty(OPT, varargin{:});

% find mean wave direction, minimum wave direction and maximum wave
% direction in wave bc time series
phi0t = xb_get(xb,'dir');
phi0 = mean(phi0t);
theta_min = phi0;
theta_max = phi0;

% use max s to setup wavedir grid
st = xb_get(xb,'s');

% make directional distribution as proposed by Longuet_Higgins et al.
% (1963)
figure(1);
for i = 1:length(st)
    m = 2*st(i);
    phi = phi0t(i)-90:1:phi0t(i)+90;
    p = cosd((phi-phi0t(i))/2).^m;

    % find range over which directional distribution is larger than OPT.varthr
    indmin = min(find(p>=max(OPT.varthr)));
    indmax = max(find(p>=max(OPT.varthr)));
    
    theta_min = min(theta_min,phi(indmin));
    theta_max = max(theta_max,phi(indmax));
    
    sig(i) = sqrt(2/(st+1))/2/pi*360
     
    plot(phi,p,'b'); hold on;
    plot(phi(indmin),p(indmin),'r*');
    plot(phi(indmax),p(indmax),'r*');
    
end
% combine range p> OPT.varthr and directional range from wave bc time series
dthetasum = theta_max-theta_min;

% set dtheta, thetamin and thetamax and round off at 5 degrees
dtheta = ceil(0.5*dthetasum/(0.5*OPT.nbins)/5)*5;
theta_min = phi0-dtheta*0.5*OPT.nbins;
theta_max = phi0+dtheta*0.5*OPT.nbins;

%directional spreading as defined by Kuik et al, 1988


% choose bin width based on directional spreading
thetagr = [theta_min:dtheta:theta_max];
dtheta

plot(thetagr,zeros(1,length(thetagr)),'g-s'); grid on;


%


