function colorbardiscrete_test()
% COLORBARDISCRETE_TEST  One line description goes here
%  
% This function tests colorbardiscrete.
%
%
%   See also colorbardiscrete

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

Category(TestCategory.Unit);

%% Original code of colorbardiscrete_test.m
clear;
close all;
clc;

%% Example 1
figure
mypeaks = peaks(20);
mylevels = [-8 -6 -4 -2 0 2 4 6 7];
[c,h] = contourf(mypeaks,mylevels);
colorbartitle = 'peaks';
cbd = colorbardiscrete(colorbartitle,mylevels);
axpos = get(gca,'position');
set(gca,'position',axpos+[-0.05 0 0 0]);
cbdpos = get(cbd,'position');
set(cbd,'position',cbdpos+[-0.05 0 0 0]);

%% Example 2
figure;
colormap(hot);
ax1 = subplot(2,1,1);
mypeaks = peaks(20);
mylevels1 = [-8 -6 -4 -2 0 2 4 6 7];
[c,h] = contourf(mypeaks,mylevels1);
colorbartitle = 'peaks';

ax2 = subplot(2,1,2);
mypeaks = peaks(20);
mylevels2 = [-8 -5 0 5 7];
[c,h] = contourf(mypeaks,mylevels2);
colorbartitle = 'peaks';
cbd1 = colorbardiscrete(colorbartitle,mylevels1,'unit','m/s','fmt','%6.2f','peer',ax1);
cbd2 = colorbardiscrete(colorbartitle,mylevels2,'unit','m/s','fmt','%6.2f','peer',ax2,'dx',0.02,'dy',0.02);

ax1pos = get(ax1,'position');
set(ax1,'position',ax1pos+[-0.07 0 0 0]);
ax2pos = get(ax2,'position');
set(ax2,'position',ax2pos+[-0.07 0 0 0]);

cbd1pos = get(cbd1,'position');
set(cbd1,'position',cbd1pos+[-0.07 0 0 0]);
cbd2pos = get(cbd2,'position');
set(cbd2,'position',cbd2pos+[-0.07 0 0 0]);
