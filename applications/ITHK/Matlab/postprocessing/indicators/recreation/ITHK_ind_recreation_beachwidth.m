function ITHK_ind_recreation_beachwidth(sens)
% function ITHK_ind_recreation_beachwidth(sens)
%
% Computes the indicator 'recreation beachwidth'.
% The width of the beach is used as a proxy for recreation
%
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).coast.x0_refgridRough
%              .PP(sens).coast.y0_refgridRough
%              .PP(sens).dunes.position.beachwidth
%              .settings.indicators.recreation.offset
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).UBmapping.fish.ShoreWidthFact
%              .PP(sens).GEmapping.fish.ShoreWidthFact

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Indicator for recreation beachwidth\n');

global S

%% Set values for beach width in UBmapping (UNIBEST grid) and GEmapping (rough grid)
idUR = S.PP(sens).settings.idUR;           % IDs at UNIBESTgrid of the 'Rough grid'
S.PP(sens).UBmapping.recreation.beachwidth = S.PP(sens).dunes.position.beachwidth;
S.PP(sens).GEmapping.recreation.beachwidth = S.PP(sens).dunes.position.beachwidth(idUR,:);  
%S.PP(sens).GEmapping.recreation.beachwidth = interp1(S.PP(sens).settings.s0,S.PP(sens).dunes.position.beachwidth,S.PP(sens).settings.sgridRough);  

%% Settings for writing to KMLtext
PLOTscale1   = str2double(S.settings.indicators.recreation.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
PLOTscale2   = str2double(S.settings.indicators.recreation.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
PLOToffset   = str2double(S.settings.indicators.recreation.PLOToffset);         % PLOT setting : plot bar at this distance offshore [m] (default initial value can be replaced by setting in ITHK_settings.xml)
colour       = {[1 1 0],[0.95 0.95 0.4]};
fillalpha    = 0.7;
popuptxt     = {'Beach recreation','Beach width as a proxy for beach recreation'};

%% Write to kml
KMLdata      = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                              (S.PP(sens).GEmapping.recreation.beachwidth-PLOTscale2), ...
                              PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
S.PP(sens).output.kml_recreation_beachwidth = KMLdata;
