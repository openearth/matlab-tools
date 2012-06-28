function ITHK_postprocessing(sens)
% function ITHK_postprocessing(sens)
%
% Postprocessing of the Unibest model results from the ITHK.
% The following post-processing is performed:
%      - Setting grid settings used for postprocessing (ITHK_PPsettings)
%      - Add effect SLR to PRN info (ITHK_add_SLR)
%      - Add coastline to KML (ITHK_PRN_to_kml & ITHK_KMLbarplot)
%      - Add measures to KML (ITHK_groyne_to_kml & ITHK_nourishment_to_kml & ITHK_revetment_to_kml)
%      - Map UB results to GE (ITHK_mapUBtoGE)
%      - Compute values for indicators (ITHK_ind_benthos & ITHK_ind_juvenilefish & ITHK_ind_dunetypes etc)
%      - write data to KML file
%
% INPUT:
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

global S

fprintf('ITHK postprocessing\n');

%% BASIC PARAMETERS
    % Grid settings used for postprocessing
    ITHK_PPsettings(sens);

    % Add effect SLR to PRN info
    ITHK_add_SLR(sens);

    % Add impact of coastline on dunes (no feedback from dunes to the coastline!)
    ITHK_postprocessDUNEGROWTH(sens);
    
    % Add coastline to KML
    ITHK_PRN_to_kml(sens);
    
    % Add measures to KML
    ITHK_groyne_to_kml(sens);
    ITHK_nourishment_to_kml(sens);
    ITHK_revetment_to_kml(sens);

    % Map UB results to GE
    ITHK_mapUBtoGE(sens);


%% INDICATORS
    ITHK_ind_ecology_benthos(sens);
    ITHK_ind_foreshore_juvenilefish(sens);
    ITHK_ind_costs_direct(sens);
    ITHK_ind_dunes_duneclasses(sens);
    ITHK_ind_dunes_habitatrichness(sens);
    ITHK_ind_recreation_beachwidth(sens);

%% Add disclaimer
% if isfield(S.settings.postprocessing,'disclaimer') 
%     disclaimer = ITHK_kmldisclaimer;
%     S.PP(sens).output.kml = [S.PP(sens).output.kml disclaimer];
% end

kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, ...
          S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
          S.PP(sens).output.kml_eco_benthos{1}, S.PP(sens).output.kml_eco_benthos{2}, ...
          S.PP(sens).output.kml_foreshore_juvenilefish,S.PP(sens).output.kml_costs_direct1,...
          S.PP(sens).output.kml_costs_direct2,S.PP(sens).output.kml_costs_direct3,...
          S.PP(sens).output.kml_dunes_duneclasses,S.PP(sens).output.kml_dunes_habitatrichness,...
          S.PP(sens).output.kml_recreation_beachwidth];
addtxt = '';
ITHK_io_writeKML(kmltxt,addtxt,sens);

kmltxt = [S.PP(sens).output.kml];
addtxt = '_CL';
ITHK_io_writeKML(kmltxt,addtxt,sens);

kmltxt = [S.PP(sens).output.kml_eco_benthos{1},S.PP(sens).output.kml_eco_benthos{2}];
addtxt = '_benthos';
ITHK_io_writeKML(kmltxt,addtxt,sens);

kmltxt = [S.PP(sens).output.kml_foreshore_juvenilefish];
addtxt = '_foreshore';
ITHK_io_writeKML(kmltxt,addtxt,sens);

kmltxt = [S.PP(sens).output.kml_costs_direct1,S.PP(sens).output.kml_costs_direct2,S.PP(sens).output.kml_costs_direct3];
addtxt = '_costs';
ITHK_io_writeKML(kmltxt,addtxt,sens);

kmltxt = [S.PP(sens).output.kml_dunes_duneclasses,S.PP(sens).output.kml_dunes_habitatrichness];
addtxt = '_dunes';
ITHK_io_writeKML(kmltxt,addtxt,sens);



%    indicatorfields    = {'safety_dykering' ...                      % 
%                          'safety_structures' ...                    % 
%                          'safety_buffer' ...                        % 
%                          'economy_dinkingwater' ...                 % 
%                          'economy_fishery' ...                      % 
%                          'residential_groundwater' ...              % 
%                          'residential_realestate' ...               % 
%                          'recreation_beaches' ...                   % 
%                          'recreation_dunearea' ...                 % 
%                          'ecology_nourishmentimpactlength' ...      % 
%                          'ecology_juvenilefish' ...                 % 
%                          'ecology_benthos' ...                      % 
%                          'ecology_dunetypes' ...                    % 
%                          'ecology_dunedynamics' ...                 % 
%                          'ecology_co2emissions' ...                 % 
%                          'policy_flexibility' ...                   % 
%                          'policy_phaseddevelopment' ...             % 
%                          'policy_publicacceptance' ...              % 
%                          'costs_investment' ...                     % 
%                          'costs_maintenance' ...                    % 
%                          'costs_upgradability'};                    % 
