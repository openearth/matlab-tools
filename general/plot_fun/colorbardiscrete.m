function [cbd] = colorbardiscrete(colorbartitle,levels,varargin)
%COLORBARDISCRETE(colorbartitle,levels) draws a colorbar with discrete
% colors right of the current axes. The number of colors is the same as the
% number of levels. Useful with contourf. BETA RELEASE
%
%COLORBARDISCRETE(colorbartitle, levels, 'peer',AX) creates
% a discrete colorbar associated with axes AX instead of the current axes.
%
%   Syntax:
%   [cbd] = colorbardiscrete(colorbartitle,levels);
%
%   Input:
%       colorbartitle:    title above the colorbar (string)
%       levels:           levels of discrete colors (vector)
%
%   Optional input:
%       unit:       unit string added to the colorbar labels, e.g. 'm/s'
%       fmt:        format string for labels (see SPRINTF for details)
%       dx:         width of the color patches (default is 0.03)
%       dy:         height of the color patches (default is 0.03)
%       hor:        horizontal colorbar position right of peer axes (default is 0)
%       ver:        horizontal colorbar position right of peer axes (default is 0)
%       fontsize:   label fontsize (default is 7)
%       peer:       axes to with which the colorbar should be associated (default
%                   is the current axes)
%
%   Output:
%   cbd = axes handle to the discrete colorbar
%
%% Example 1
%       figure
%       mypeaks = peaks(20); mylevels = [-8 -6 -4 -2 0 2 4 6 7];
%       [c,h] = contourf(mypeaks,mylevels);
%       colorbartitle = 'peaks';
%       cbd = colorbardiscrete(colorbartitle,mylevels);
%       axpos = get(gca,'position'); set(gca,'position',axpos+[-0.05 0 0 0]);
%       cbdpos = get(cbd,'position'); set(cbd,'position',cbdpos+[-0.05 0 0 0]);
%
%% Example 2
%       figure; ax1 = subplot(2,1,1);
%       mypeaks = peaks(20); mylevels1 = [-8 -6 -4 -2 0 2 4 6 7];
%       [c,h] = contourf(mypeaks,mylevels1);
%       colorbartitle = 'peaks';
%       cbd1 = colorbardiscrete(colorbartitle,mylevels1,'unit','m/s','fmt','%6.2f','peer',ax1);
%       ax1pos = get(ax1,'position'); set(ax1,'position',ax1pos+[-0.07 0 0 0]);
%       cbd1pos = get(cbd1,'position'); set(cbd1,'position',cbd1pos+[-0.07 0 0 0]);
%
%   See also contourf

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
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
% Created: 17 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

fmt = '%6.1f';
dx = 0.03;
dy = 0.03;
hor = 0;
ver = 0;
fontsize = 7;
peeraxes = gca;
unit = '';

%% optional arguments
optvals = varargin;
if 2*round(length(optvals)/2)~=length(optvals),
    error('Invalid option-value pair');
else
    optvals=reshape(optvals,[2 length(optvals)/2]);
end;
OptionUsed=false(1,size(optvals,2));
for i=1:size(optvals,2),
    if ~ischar(optvals{1,i}),
        error('Invalid option'),
    end;
    switch lower(optvals{1,i}),
        case 'dx',
            dx = optvals{2,i};
            OptionUsed(i)=1;
        case 'dy',
            dy = optvals{2,i};
            OptionUsed(i)=1;
        case 'hor',
            hor = optvals{2,i};
            OptionUsed(i)=1;
        case 'ver',
            ver = optvals{2,i};
            OptionUsed(i)=1;
        case 'fontsize',
            fontsize = optvals{2,i};
            OptionUsed(i)=1;
        case 'fmt',
            fmt = optvals{2,i};
            OptionUsed(i)=1;
        case 'peer',
            peeraxes = optvals{2,i};
            OptionUsed(i)=1;
        case 'unit',
            unit = optvals{2,i};
            OptionUsed(i)=1;
    end
end;
optvals(:,OptionUsed)=[];                                                   % delete used options
% optvals = optvals(:);

axes(peeraxes);

cl = clim;
mycolors = colormap;
nrofcolorlevels = length(mycolors);
colorlevels = cl(1):(cl(end)-cl(1))/(nrofcolorlevels-1):cl(end);
mydiscretecolors = [];
for i = 1:length(levels)
    if levels(i)<colorlevels(1)
        mydiscretecolors(i,1) = mycolors(1,1);
        mydiscretecolors(i,2) = mycolors(1,2);
        mydiscretecolors(i,3) = mycolors(1,3);
    else
        if levels(i)>colorlevels(end)
            mydiscretecolors(i,1) = mycolors(end,1);
            mydiscretecolors(i,2) = mycolors(end,2);
            mydiscretecolors(i,3) = mycolors(end,3);
            
        else
            mydiscretecolors(i,1) = interp1(colorlevels,mycolors(:,1),levels(i));
            mydiscretecolors(i,2) = interp1(colorlevels,mycolors(:,2),levels(i));
            mydiscretecolors(i,3) = interp1(colorlevels,mycolors(:,3),levels(i));
        end
        
    end
end

TextAndLineColor = 'k';
nv = length(levels);
nc = size(mydiscretecolors,1);

% save position of countour plot frame

%  determine position of coordinate system of for legend

pos = get(gca,'position');
unt = get(gca,'units');
factor = ( nc*dy + (nc-1)* 0.25 * dy) / pos(4);

% make sure that legend does not become larger than contour plot

if factor>1
    dy = dy/factor ;
    factor = 1  ;
end

%  set legend hor to the right of the contour plot

posnew = [pos(3)+pos(1)+hor,pos(2)+ver,(pos(3)),factor*pos(4)];

%
cbd = axes('units',unt,'Position', posnew,'visible','off');hold on; axis equal;
%
x  = 0;
y  = 0;
%

if (nc == nv)
    for i=1:nc
        
        %        patch color rectangle
        
        xp = [x, x+dx, x+dx, x, x];
        yp = [y, y,    y+dy, y+dy, y];
        patch(xp,yp,1e13*ones(size(xp)),mydiscretecolors(i,:),'EdgeColor',TextAndLineColor);

        %        place texts for v-ranges
        
        if (i==nc)
            label= ['>',num2str(levels(nv),fmt),' ',unit];
        else
            label = [num2str(levels(i),fmt),' - ',num2str(levels(i+1),fmt),' ',unit];
        end
        %
        text (x+1.5*dx,y,100,label, ...
            'color',TextAndLineColor,...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','bottom','FontSize',fontsize,'erasemode','background','visible','on');
        
        y = y + 1.25*dy;
    end
else
    error('Mismatch length values-colors');
end

x_lim = get(gca,'xlim');
lenx = diff(x_lim);
set(cbd,'xlim',[-0.01 lenx],'visible','off');
text(0,y+1*dy,100,colorbartitle,'FontSize',fontsize,'erasemode','background','visible','on');
%
% reset handle of figure to contour plot
%
axes(peeraxes);

return