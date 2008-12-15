function XB = example_selectgrid
%EXAMPLE_SELECTGRID  Example to create XBeach grid
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = example_selectgrid(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   example_selectgrid
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

%% Example to create XBeach grid

%TODO: make XBeach_Write_Inp suitable for 2D grids 

close all
clear
clc

%% read data
fname = 'frfsurvey.htm';

[X Y Z] = readhtmldata(fname);

%%
[X Y Z alfa propertyCell] = XBeach_GridOrientation(X, Y, Z,...
    'xori', max(X),...
    'yori', max(Y),...
    'xend_y0', [min(X) max(Y)],...
    'x_yend', [min(X) min(Y)]);

%% make grid
XB = XBeach_selectgrid(X, Y, Z,...
    CreateEmptyXBeachVar,...
    propertyCell{:},...
    'alfa', alfa,...
    'posdwn', -1);

%% plot grid
figure
pcolor(XB.Input.xInitial, XB.Input.yInitial, XB.Input.zInitial)
axis equal