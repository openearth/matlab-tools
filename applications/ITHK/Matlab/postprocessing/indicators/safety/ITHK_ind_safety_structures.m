function ITHK_ind_safety_structures(sens)
% function ITHK_ind_safety_structures(sens)
%
% Computes the indicator for safety of structures outside the primary water defenses
%
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).coast.x0_refgridRough
%              .PP(sens).coast.y0_refgridRough
%              .PP(sens).dunes.position.beachwidth
%              .settings.indicators.safety.offset
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).UBmapping.safety.structures
%              .PP(sens).GEmapping.safety.structures
%              .PP(sens).output.kml_safety_structures

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

fprintf('ITHK postprocessing : Indicator for safety of structures outside the primary water defenses, using coastline position as a proxy\n');

global S

%% Determine specific longshore IDs of zone with drinking water fucntion (on the basis of on settings file 'ITHK_ind_safety_structures.txt').
Ythr                     = str2double(S.settings.indicators.safety.structures.Ythr);
sRough                   = S.PP(sens).settings.sgridRough;
dS                       = S.PP(sens).settings.dsRough;
zonedata                 = load('ITHK_ind_safety_structures.txt');  % loads a list [Nx2] with center position of the drinkingwater zone (column 1) and the width of the zone (column 2)
ID_safety                = [];
for ii=1:size(zonedata,1)
    X0zone               = zonedata(ii,1);                                                          % x-position of center of coastal zone
    X1zone               = zonedata(ii,1)-zonedata(ii,2)/2-dS/2;                                    % x-position of southern edge of coastal zone
    X2zone               = zonedata(ii,1)+zonedata(ii,2)/2+dS/2;                                    % x-position of northern edge of coastal zone
    ID_safety            = [ID_safety,find(sRough>=X1zone & sRough<=X2zone)];                % find grid points within the zone
    ID_safety            = [ID_safety,find(abs(sRough-X0zone)==min(abs(sRough-X0zone)))];    % use at least the grid point nearest to the center of a zone (in case the zone is smaller dan dS)
end
ID_safety                = unique(ID_safety);                                                % throw away double id's
ID_notsafety             = setdiff([1:length(sRough)],ID_safety);

%% Set values for beach width in UBmapping (UNIBEST grid) and GEmapping (rough grid)
idUR                     = S.PP(sens).settings.idUR;           % IDs at UNIBESTgrid of the 'Rough grid', with a second filter for the alongshore coastline IDs of the considered zone
structures                 = S.PP(sens).dunes.position.yposREL(idUR,:);
if ~isempty(ID_notsafety); structures(ID_notsafety,:)=0; end
structuresclasses          = structures;
structuresclasses(structures<Ythr)                           = 2;
structuresclasses(structures>=Ythr & structures<2*Ythr)      = 3;
structuresclasses(structures>=2*Ythr)                        = 4;
structuresclasses(ID_notsafety,:)                            = 1;
structures(ID_notsafety,:)                                   = 0;
S.PP(sens).GEmapping.safety.structures   = structures;
S.PP(sens).GEmapping.safety.structures2  = structuresclasses;

%% Settings for writing to KMLtext
PLOTscale1   = str2double(S.settings.indicators.safety.structures.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
PLOTscale2   = str2double(S.settings.indicators.safety.structures.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
PLOToffset   = str2double(S.settings.indicators.safety.structures.PLOToffset);     % PLOT setting : plot bar at this distance offshore [m] (default initial value can be replaced by setting in ITHK_settings.xml)
PLOTicons    = S.settings.indicators.safety.structures.icons;
colour       = {[0 0.6 0.0],[0.8 0.0 0.0]};
fillalpha    = 0.7;
popuptxt     = {'Safety structures','Safety of structures outside the primary water defenses, using coastline position as a proxy'};

%% Write to kml BAR PLOTS / ICONS
[KMLdata1]   = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                              (S.PP(sens).GEmapping.safety.structures-PLOTscale2), ...
                              PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
[KMLdata2]   = ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                             S.PP(sens).GEmapping.safety.structures2,PLOTicons,PLOToffset,sens,popuptxt);
S.PP(sens).output.kml_safety_structures  = KMLdata1;
S.PP(sens).output.kml_safety_structures2 = KMLdata2;
