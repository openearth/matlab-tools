function ITHK_ind_foreshore_juvenilefish(sens)
% function ITHK_ind_foreshore_juvenilefish(sens)
%
% Computes the indirect impact of coastline changes on nursery area for juvenile fish
%
% The impact is computed with a formulation which computes a relative decrease
% in foreshore area. For this purpose a standard width of the foreshore is assumed.
% The formulation reads like this:
%
%      Aforeshore  = LENGTHcoast * (WIDTHforeshore,ini - Coastlineposition(time))
% 
%
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP.coast.zminz0
%              .PP.coast.zminz0Rough
%              .PP.coast.x0_refgridRough
%              .PP.coast.y0_refgridRough
%              .PP.GEmapping.fish.ShoreWidthFact
%              .settings.indicators.foreshore.ShoreWidth
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP.UBmapping.fish.ShoreWidthFact
%              .PP.GEmapping.fish.ShoreWidthFact

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

fprintf('ITHK postprocessing : Indicator for indirect impact of coastline changes on nursery area for juvenile fish\n');

global S


%% Set values for shorewidth formulation
zminz0      = S.PP.coast.zminz0;                                           % change of coastline since t0
zminz0Rough = S.PP.coast.zminz0Rough;                                      % change of coastline since t0
ShoreWidth = str2double(S.settings.indicators.foreshore.ShoreWidth);         % Default initial shoreface width can be replaced by setting in ITHK_settings.xml

%% Compute actual shorewidth
S.PP.UBmapping.foreshore.ShoreWidthFact = (ShoreWidth-(zminz0>0))./ShoreWidth;
S.PP.GEmapping.foreshore.ShoreWidthFact = (ShoreWidth-(zminz0Rough>0))./ShoreWidth;  % if zminz0 >0, then the shoreface width decrease, then K and P of the species will descrease in a portion.


%% Settings for writing to KMLtext
PLOTscale1   = str2double(S.settings.indicators.foreshore.PLOTscale1);   % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
PLOTscale2   = str2double(S.settings.indicators.foreshore.PLOTscale2);   % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
PLOToffset   = str2double(S.settings.indicators.foreshore.PLOToffset);   % PLOT setting : plot bar at this distance offshore [m](default initial value can be replaced by setting in ITHK_settings.xml)
colour       = {[0.3 0.2 0.8]};
fillalpha    = 0.7;
popuptxt     = {'Nursery area for fish','Indirect impact of coastline changes on nursery area for juvenile fish.'};

%% Write to kml
KMLdata      = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                              (S.PP(sens).GEmapping.foreshore.ShoreWidthFact-PLOTscale2*ShoreWidth)*PLOTscale1, ...
                              PLOToffset,sens,colour,fillalpha,vectorlength,popuptxt);
S.PP(sens).output.kml_foreshore_juvenilefish = KMLdata;


