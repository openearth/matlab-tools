function [X Y Z alfa propertyVar] = XBeach_GridOrientation(xw, yw, Zbathy, varargin)
%XBEACH_GRIDORIENTATION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = XBeach_GridOrientation(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeach_GridOrientation
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
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

% Created: 12 Dec 2008
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% default properties
OPT = struct(...
    'dx', 2,...
    'dy', 2,...
    'xori', 0,...
    'yori', 0,...
    'xend_y0', [max(max(xw)) 0],...
    'x_yend', [0 max(max(yw))]);
% ,...
%     'xmax', max(max(xw)),...
%     'ymin', 0,...
%     'ymax', max(max(yw)));
% apply custom properties
OPT = setProperty(OPT, varargin{:});

% propertyVar = {...
%     'dx', OPT.dx,...
%     'dy', OPT.dy,...
%     'xori', OPT.xori,...
%     'yori', OPT.yori};
    
%%
%% show data, for selection
% figure(1);
% scatter(xw,yw,5,Zbathy,'filled');
% axis([min(xw)-.5*(max(xw)-min(xw)) ...
%     max(xw)+.5*(max(xw)-min(xw)) ...
%     min(yw)-.5*(max(yw)-min(yw)) ...
%     max(yw)+.5*(max(yw)-min(yw)) ])
% axis equal
% colorbar
% hold on
% 
% % Loop, picking up the points.
% disp('Click grid corner x=0,y=0')
% disp('Then click point x=xn,y=0')
% disp('Finally click to select extent of y')
% [xi yi] = ginput(3);
% plot(xi,yi,'r-o')
% xi = [max(xw) min(xw) min(xw)];
% yi = [max(yw) max(yw) min(yw)];
% xori = xi(1);
% yori = yi(1);
alfa = atan2(OPT.xend_y0(2)-OPT.yori, OPT.xend_y0(1)-OPT.xori);
Xbathy = cos(alfa)*(xw-OPT.xori)+sin(alfa)*(yw-OPT.yori);
Ybathy = -sin(alfa)*(xw-OPT.xori)+cos(alfa)*(yw-OPT.yori);
xn = cos(alfa)*(OPT.xend_y0(1)-OPT.xori)+sin(alfa)*(OPT.xend_y0(2)-OPT.yori);
yn = -sin(alfa)*(OPT.x_yend(1)-OPT.xori)+cos(alfa)*(OPT.x_yend(2)-OPT.yori);
xx = (0:OPT.dx:xn)';
yy = 0:OPT.dy:yn;
X = repmat(xx, 1, length(yy));
Y = repmat(yy, length(xx), 1);
Z = griddata(Xbathy,Ybathy,Zbathy,X,Y);

propertyVar = {...
    'dx', OPT.dx,...
    'dy', OPT.dy,...
    'xori', OPT.xori,...
    'yori', OPT.yori};