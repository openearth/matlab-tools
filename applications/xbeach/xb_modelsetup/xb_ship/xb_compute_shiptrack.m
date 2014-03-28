function [xb_st] = xb_compute_shiptrack(iship,varargin)
% XB_COMPUTE_SHIPTRACK  Computes XBeach ship track (t,x,y) based on ship-xyfile.
%
%   Computes ship track (t,x,y) based on ship-xyfile for simulation of
%   ship-induced waves in XBeach. Output (t,x,y) should be saved in an
%   ascii-file and specified in the XB ship file (keyword: shiptrack)
%
%   Syntax:
%   [t,x,y] = xb_compute_shiptrack('ship_xyfile','track.txt,'dt',10,'v',[.1
%   8 8],'tv',[0 180 600],'tstop',600)
%
%   Input:
%   varargin  =     ship_xyfile:    ship-x,y file (ascii) with x,y points of entire ship
%                                   track
%                   dt:             timestep in ship track t,x,y-file
%                   v:              velocity in time (block mode)
%                   tv:             time points corresponding with velocity
%                                   specified
%                   tstop:          simulation stop time
%                   plot:           make a plot of ship track (1) or not
%                                   (0, default)
%   Output:
%                   t : time vector [s]
%                   x : x(s) ship location
%                   y : y(s) ship location
%
%   Example:
%   [t,x,y] = xb_compute_shiptrack('ship_xyfile','track.txt,'dt',10,'v',[.1
%   8 8],'tv',[0 180 600],'tstop',600)
%   out = [t,x,y];
%   save ship_track.txt out -ascii
%
%   Based on initial code by Dano Roelvink (UNESCO-IHE / Deltares)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       rooijen
%
%       arnold.vanrooijen@deltares.nl
%
%       Rotterdamseweg 185, Delft, The Netherlands
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
% Created: 18 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
OPT.trackxyt      = sprintf('track%03d.txt', iship); % Ship track filename (t,x,y,z)
OPT.dt            = 10;                              % Timestep [s]
OPT.v             = [.1 8 8];    % Speed [m/s]
OPT.tv            = [0 180 600]; % time points for speed [s]
OPT.z             = [0 0 0];     % height of ship for flying in
OPT.tstop         = 600;         % Simulation stop time [s]
OPT.plot          = 0;
OPT.trackxy       = '';% Ship track filenames (x,y)
OPT = setproperty(OPT,varargin{:});

%% Load ship track file
try
    xy = load(OPT.trackxy);
catch
    xy = landboundary('read',OPT.trackxy);
end

%% Compute track
t = [0:OPT.dt:OPT.tstop];
v = interp1(OPT.tv,OPT.v,t);
s = zeros(size(t));
z = interp1(OPT.tv,OPT.z,t);

% Compute distance travelled
for i = 2:length(t);
    s(i) = s(i-1)+v(i-1)*OPT.dt;
end

% Compute x,y-locations
xtr = xy(:,1);
ytr = xy(:,2);
str = zeros(size(xtr));
for i = 2:length(xtr);
    str(i) = str(i-1)+sqrt((xtr(i)-xtr(i-1))^2+(ytr(i)-ytr(i-1))^2);
end
s = s(s<=max(str));
x = interp1(str,xtr,s);
y = interp1(str,ytr,s);

if OPT.plot
    figure()
    plot(x,y,'k-o');hold on
    for i = 1:round(60/OPT.dt):length(t)
        text(x(i)+50,y(i),[num2str(t(i)) ' s']);
    end
    axis equal;xlabel('X');ylabel('Y');
    title('Ship track');
end
tstop = t(length(s));
out = [t(1:length(s));x;y;z(1:length(s))]';
% out(end+1
% save([OPT.runDir OPT.ship_xytfile],'out','-ascii')

% Save data in xbeach structure
xb_st = xs_empty;
xb_st = xs_meta(xb_st, mfilename, 'ship', sprintf('track%03d.txt', iship));

% check if txy or txyz
if size(out,2) == 3
    xb_st = xs_set(xb_st, 'time', [], 'x', [], 'y', []);
    xb_st = xs_set(xb_st, '-units', 'time', {out(:,1) 's'}, 'x', {out(:,2) 'm'}, 'y', {out(:,3) 'm'});
elseif size(out,2) == 4
    xb_st = xs_set(xb_st, 'time', [], 'x', [], 'y', [], 'z', []);
    xb_st = xs_set(xb_st, '-units', 'time', {out(:,1) 's'}, 'x', {out(:,2) 'm'}, 'y', {out(:,3) 'm'}, 'z', {out(:,4) 'm'});
else
    error(['Error Reading Ship Track File [' filename ']'])
end


