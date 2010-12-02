function XB = example_selectgrid
%EXAMPLE_SELECTGRID  One line description goes here.
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
%   Copyright (C) 2009 Deltares
%       Dano Roelvink / Ap van Dongeren / C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% Created: 03 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% Example to create XBeach grid

close all
clear
clc

%% read data
fname = 'frfsurvey.htm';

[Xbathy Ybathy Zbathy] = readhtmldata(fname);

%%
[X Y Z alfa propertyCell] = XBeach_GridOrientation(Xbathy, Ybathy, Zbathy,...
    'manual', false,...
    'xori', max(Xbathy),...
    'yori', max(Ybathy),...
    'xend_y0', [min(Xbathy) max(Ybathy)],...
    'x_yend', [min(Xbathy) min(Ybathy)]);

%% make grid
XB = XBeach_selectgrid(X, Y, Z,...
    'manual', false,...
    CreateEmptyXBeachVar,...
    propertyCell{:},...
    'alfa', alfa,...
    'posdwn', -1);

%% plot grid
figure
pcolor(XB.Input.xInitial, XB.Input.yInitial, XB.Input.zInitial)
axis equal