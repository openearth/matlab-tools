function figHandle = xb_visualize_modelsetup(varargin)
%XB_VISUALIZE_MODELSETUP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_visualize_modelsetup(varargin)
%
%   Input: For <keyword,value> pairs call xb_visualize_modelsetup() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_visualize_modelsetup
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 04 Mar 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: xb_visualize_modelsetup.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_visualise/xb_visualize_modelsetup.m $
% $Keywords: $

%%
OPT = struct( ...
    'figureHandle', [], ...
    'xbeachStructure', [], ...
    'path', pwd, ...
    'showShadowZone', true ...
);

OPT = setproperty(OPT, varargin);

%% Read model input into XBeach structure if necessary

if isempty(OPT.xbeachStructure)
    xs = xb_read_input(OPT.path);
elseif isa(OPT.xbeachStructure,'struct')
    xs = OPT.xbeachStructure;
else
    error('Specified XBeach structure is not a structure!');
end

%% Get relevant variables from input structure

alfa        = xs_get(xs, 'alfa');
xori        = xs_get(xs, 'xori');
yori        = xs_get(xs, 'yori');
thetanaut   = xs_get(xs, 'thetanaut');
if thetanaut
    thetamin    = xs_get(xs, 'thetamin');
    thetamax    = xs_get(xs, 'thetamax');
    dtheta      = xs_get(xs, 'dtheta');
else
    thetamin    = 90 - xs_get(xs, 'thetamin');
    thetamax    = 90 - xs_get(xs, 'thetamax');    
    dtheta      = xs_get(xs, 'dtheta');
end

xfile       = xs_get(xs, 'xfile');
yfile       = xs_get(xs, 'yfile');
zfile       = xs_get(xs, 'depfile');
xgrid       = xfile.data.value;
ygrid       = yfile.data.value;
zgrid       = zfile.data.value;

bcfile      = xs_get(xs, 'bcfile');
if xs_check(bcfile)
    if strcmp(xs_get(bcfile, 'type'), 'unknown')
        wave_angles = xs_get(xs, 'dir0');
        if isempty(wave_angles)
            wave_angles = xs_get(bcfile, 'mainang');
        end
    elseif strcmp(xs_get(bcfile, 'type'), 'jonswap')
        wave_angles = xs_get(bcfile, 'mainang');
    elseif strcmp(xs_get(bcfile, 'type'), 'jonswap_mtx')
        wave_angles = xs_get(bcfile, 'dir');
    end
else
	wave_angles = xs_get(xs, 'dir0');
end

%% Rotate grid if necessary (alfa, xori or yori ~= 0)

if (~isempty(alfa) && abs(alfa) > 0) || ...
   (~isempty(xori) && abs(xori) > 0) || ...
   (~isempty(yori) && abs(yori) > 0)
    [xw, yw] = xb_grid_xb2world(xgrid, ygrid, xori, yori, alfa);
else 
    [xw, yw] = deal(xgrid, ygrid);
end

%% Plot bathymetry, thetagrid & wave directions

if ~isempty(OPT.figureHandle)
    figHandle = OPT.figureHandle;
    figure(figHandle)
    %maximize(figHandle)
elseif isempty(OPT.figureHandle)
    figHandle = figure;
    %maximize(figHandle)
end
ax1 = subplot(1,4,[1 2 3]);
if ~isvector(zgrid)
    p1 = pcolor(ax1,xw,yw,zgrid);
else
    p1 = plot(ax1,xw,yw);
end
colormap gray;
shading flat;
axis equal;

% add shadow zone
if OPT.showShadowZone
    for i = 1:length(wave_angles)
        for j = [1 size(yw,1)]
            xw_start  = xw(j,1);
            xw_end    = xw(j,end);
            yw_start  = yw(j,1);
            yw_end    = yw(j,1) + diff(xw(1,[1 end])) / tand(wave_angles(i));

            p2 = patch([xw_start xw_end xw_end],[yw_start yw_start yw_end],'w','FaceAlpha',3/length(wave_angles),'EdgeColor','none'); % don't know why the 3 should be there...
        end
    end
else
    p2 = [];
end

% visualize origin and offshore boundary
line1 = line(xw([1 end],1),yw([1 end],1));
set(line1,'color','r','linewidth',3);
hold on
p3 = scatter(xw(1,1),yw(1,1),75,'go','filled');
hold off
title('Bathymetric grid')
legend([p1 line1 p3 p2],'location','NorthEast','Bed level','Offshore boundary','Origin','Shadow zone');
colorbar;

% reset axis limits
xlim(minmax(xw(:)'));
ylim(minmax(yw(:)'));

% plot thetamin & thetamax
ax2 = subplot(1,4,4);
line2 = line([0 sind(thetamin)],[0 cosd(thetamin)]);
line3 = line([0 sind(thetamax)],[0 cosd(thetamax)]);
set(line2,'color','b','linewidth',1.5);
set(line3,'color','r','linewidth',1.5);

legend('location','NorthWest','Thetamin','Thetamax')

% add arrow pointing North
arrow([0.8 1],[0.8 1.5],'Length',35,'TipAngle',4,'BaseAngle',30);
text(0.85,1.3,'N');
axis equal;
axis([-1 1 -1 1.5]);
hold on

% add wave angles
for i = 1:length(wave_angles)
    xw_start  = sind(wave_angles(i));
    xw_end    = sind(wave_angles(i))*0.2;
    yw_start  = cosd(wave_angles(i));
    yw_end    = cosd(wave_angles(i))*0.2;
    
    arrow([xw_start yw_start],[xw_end yw_end],'Length',10,'TipAngle',10,'BaseAngle',50);
end

% add theta bins
ntheta = round(thetamax-thetamin)/dtheta;

if abs(ntheta) > 1
    if ntheta > 0
        thetas = (1:(ntheta-1))*dtheta + thetamin;
    else
        thetas = (-1:-1:(ntheta+1))*dtheta + thetamin;
    end
    line4 = line([zeros(1,length(thetas)); sind(thetas)],[zeros(1,length(thetas)); cosd(thetas)]);
    set(line4,'color','g');
end

axis off
title(['Directional wave grid (thetanaut = ' num2str(thetanaut) ')'])