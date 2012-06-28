function ITHK_ind_drinkwater_dunearea(sens)
% function ITHK_ind_drinkwater_dunearea(sens)
%
% Computes the indicator for the drinking water supply, using dune area as a proxy
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
%              .PP(sens).UBmapping.drinkwater.dunearea
%              .PP(sens).GEmapping.drinkwater.dunearea
%              .PP(sens).output.kml_drinkwater_dunearea

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

fprintf('ITHK postprocessing : Indicator for the drinking water supply, using dune area change as a proxy\n');

global S

%% Determine specific longshore IDs of zone with drinking water fucntion (on the basis of on settings file 'inp_drinkingwater.txt').
sRough                   = S.PP(sens).settings.sgridRough;
dS                       = S.PP(sens).settings.dsRough;
zonedata                 = load('inp_drinkingwater.txt');  % loads a list [Nx2] with center position of the drinkingwater zone (column 1) and the width of the zone (column 2)
ID_drinkingwater         = [];
for ii=1:size(zonedata,1)
    X0zone               = zonedata(ii,1);                                                          % x-position of center of coastal zone
    X1zone               = zonedata(ii,1)-zonedata(ii,2)/2-dS/2;                                    % x-position of southern edge of coastal zone
    X2zone               = zonedata(ii,1)+zonedata(ii,2)/2+dS/2;                                    % x-position of northern edge of coastal zone
    ID_drinkingwater     = [ID_drinkingwater,find(sRough>=X1zone & sRough<=X2zone)];                % find grid points within the zone
    ID_drinkingwater     = [ID_drinkingwater,find(abs(sRough-X0zone)==min(abs(sRough-X0zone)))];    % use at least the grid point nearest to the center of a zone (in case the zone is smaller dan dS)
end
ID_drinkingwater         = unique(ID_drinkingwater);                                                % throw away double id's
ID_notdrinkingwater      = setdiff([1:length(sRough)],ID_drinkingwater);
S.PP(sens).dunes.position.yposREL = S.PP(sens).dunes.position.ypos-repmat(S.PP(sens).dunes.position.ypos(:,1),[1,size(S.PP(sens).dunes.position.ypos,2)]);

%% Set values for beach width in UBmapping (UNIBEST grid) and GEmapping (rough grid)
idUR                                     = S.PP(sens).settings.idUR;           % IDs at UNIBESTgrid of the 'Rough grid', with a second filter for the alongshore coastline IDs of the considered zone
%S.PP(sens).UBmapping.drinkwater.dunearea = S.PP(sens).dunes.position.yposREL;
S.PP(sens).GEmapping.drinkwater.dunearea = S.PP(sens).dunes.position.yposREL(idUR,:);
%S.PP(sens).GEmapping.drinkwater.dunearea = interp1(S.PP(sens).settings.s0,S.PP(sens).dunes.position.beachwidth,S.PP(sens).settings.sgridRough);  
S.PP(sens).GEmapping.drinkwater.dunearea(ID_notdrinkingwater) = 0;

%% Settings for writing to KMLtext
PLOTscale1   = str2double(S.settings.indicators.drinkwater.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
PLOTscale2   = str2double(S.settings.indicators.drinkwater.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
PLOToffset   = str2double(S.settings.indicators.drinkwater.PLOToffset);         % PLOT setting : plot bar at this distance offshore [m] (default initial value can be replaced by setting in ITHK_settings.xml)
colour       = {[0 0.6 0.0],[0.8 0.0 0.0]};
fillalpha    = 0.7;
popuptxt     = {'Drinking water (Dune area)','Dune area as a proxy for drinking water'};

%% Write to kml
KMLdata      = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                              (S.PP(sens).GEmapping.drinkwater.dunearea-PLOTscale2), ...
                              PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
S.PP(sens).output.kml_drinkwater_dunearea = KMLdata;
