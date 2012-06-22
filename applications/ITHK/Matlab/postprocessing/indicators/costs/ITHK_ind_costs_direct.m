function ITHK_ind_costs_direct(sens)
% function ITHK_ind_costs_direct(sens)
%
% Computes the direct costs due to dredging, transportation and nourishing.
%
% The impact is computed with a formulation which computes a relative decrease
% in foreshore area. For this purpose a standard width of the foreshore is assumed.
% The formulation reads like this:
%
%      Direct costs  = Dreding + Transport + Nourish + Overhead
% 
%
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%

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

fprintf('ITHK postprocessing : Indicator for the direct costs due to dredging, transportation and nourishing\n');

global S

%% LOAD SETTINGS
costs                                    = xml_load('ITHK_settings.xml');
S.PP(sens).GEmapping.costs               = costs;
costs.classdefinition.small              = str2double(costs.classdefinition.small);
costs.classdefinition.medium             = str2double(costs.classdefinition.medium);
costs.classdefinition.large              = str2double(costs.classdefinition.large);
costs.costprices.take_up                 = str2double(costs.costprices.take_up);
costs.costprices.transport               = str2double(costs.costprices.transport);
costs.costprices.nourish_foreshore       = str2double(costs.costprices.nourish_foreshore);
costs.costprices.nourish_rainbow         = str2double(costs.costprices.nourish_rainbow);
costs.costprices.nourish_beach           = str2double(costs.costprices.nourish_beach);
costs.costprices.pipes                   = str2double(costs.costprices.pipes);
costs.distribution.beachtype.release     = str2double(costs.distribution.beachtype.release);
costs.distribution.beachtype.rainbow     = str2double(costs.distribution.beachtype.rainbow);
costs.distribution.beachtype.beach       = str2double(costs.distribution.beachtype.beach);
costs.distribution.foreshoretype.release = str2double(costs.distribution.foreshoretype.release);
costs.distribution.foreshoretype.rainbow = str2double(costs.distribution.foreshoretype.rainbow);
costs.distribution.foreshoretype.beach   = str2double(costs.distribution.foreshoretype.beach);
costs.indirectratio.beachtype            = str2double(costs.indirectratio.beachtype);
costs.indirectratio.foreshoretype        = str2double(costs.indirectratio.foreshoretype);


%% COMPUTE
distance                                 = S.settings.indicators.costs.transportdistance;


for vv=1:length(S.userinput.nourishment)
   VOL        =   S.userinput.nourishment(vv).volume;
   WIDTH      =   S.userinput.nourishment(vv).width;
   volperm    =   VOL/WIDTH;
   lat        =   S.userinput.nourishment(vv).lat;
   lon        =   S.userinput.nourishment(vv).lon;
   idRANGE    =   S.userinput.nourishment(vv).idRANGE;
   idNEAREST  =   S.userinput.nourishment(vv).idNEAREST;

   if volperm < costs.classdefinition.small(2)
       noursizeTYPE=1;       
   elseif volperm < costs.classdefinition.medium(2)
       noursizeTYPE=2;
   else
       noursizeTYPE=3;
   end
   indirectratio(1) = costs.indirectratio.beachtype(noursizeTYPE);
   indirectratio(2) = costs.indirectratio.foreshoretype(noursizeTYPE);

   
   % Compute Costs
   costs_nbeach     = (price.dreding+price.nourish_beach+price.pipes)*PRCTbeach/100
   costs_nrainbow   = (price.dreding+price.nourish_rainbow)*PRCTrainbow/100
   costs_nforeshore = (price.dreding+price.nourish_foreshore)*PRCTrelease/100
   
   
   costs.nourish    = costs_nbeach + costs_nrainbow + costs_nforeshore;
   costs.transport  = distance * costs.costprices.transport(noursizeTYPE)
   costs.direct     = costs.nourish + costs.transport;
   costs.indirect   = directcost*(indirectratio/100.);
   costs.total      = [costs.direct,costs.direct] + costs.indirect;


   %% Make KML with direct cosst for each of the noursihment locations



end

S.PP(sens).UBmapping.costs = ..
S.PP(sens).GEmapping.costs = ..


%% Settings for writing to KMLtext
PLOTscale1   = str2double(S.settings.indicators.foreshore.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
PLOTscale2   = str2double(S.settings.indicators.foreshore.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
PLOToffset   = str2double(S.settings.indicators.foreshore.PLOToffset);     % PLOT setting : plot bar at this distance offshore [m](default initial value can be replaced by setting in ITHK_settings.xml)
colour       = {[0.1 0.1 0.8],[0.2 0.2 0.8]};
fillalpha    = 0.7;
popuptxt     = {'Nursery area for fish','Indirect impact of coastline changes on nursery area for juvenile fish.'};
%% Write to kml
KMLdata      = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                              (S.PP(sens).GEmapping.foreshore.ShoreWidthFact-PLOTscale2), ...
                              PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
S.PP(sens).output.kml_foreshore_juvenilefish = KMLdata;

