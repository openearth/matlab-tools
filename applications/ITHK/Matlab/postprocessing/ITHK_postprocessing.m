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
%     ITHK_ind_ecology_juvenilefish(sens);
%     ITHK_ind_ecology_dunetypes(sens);
%     ITHK_dunerules2(sens);
%     ITHK_dunes_habitatrichness;

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


%% Add disclaimer
if isfield(S.settings.postprocessing,'disclaimer') 
    disclaimer = ITHK_kmldisclaimer;
    S.PP.output.kml = [S.PP.output.kml disclaimer];
end

%% WRITE KML
S.PP(sens).output.kmlFileName  = [S.settings.outputdir S.userinput.name '.kml'];  % KML filename settings
KMLmapName                     = S.userinput.name;
fid                            = fopen(S.PP.output.kmlFileName,'w');
fprintf(fid,[KML_header('kmlName',KMLmapName), ...
            S.PP.output.kml, ...
            S.PP(sens).output.kml_groyne, ...
            S.PP(sens).output.kml_nourishment, ...
            S.PP(sens).output.kml_revetment, ...
            S.PP(sens).output.kml_eco_benthos{1}, ...
            S.PP(sens).output.kml_eco_benthos{2}, ...
            KML_footer]);
fclose(fid);
% KML2
S.PP(sens).output.kmlFileName  = [S.settings.outputdir S.userinput.name '_CL.kml'];  % KML filename settings
KMLmapName               = S.userinput.name;
fid                      = fopen(S.PP.output.kmlFileName,'w');
fprintf(fid,[KML_header('kmlName',KMLmapName), ...
             S.PP.output.kml, ...
             KML_footer]);
fclose(fid);
% KML3
S.PP(sens).output.kmlFileName  = [S.settings.outputdir S.userinput.name '_benthos.kml'];  % KML filename settings
KMLmapName               = S.userinput.name;
fid                      = fopen(S.PP.output.kmlFileName,'w');
fprintf(fid,[KML_header('kmlName',KMLmapName), ...
             S.PP(sens).output.kml_eco_benthos{1}, ...
             S.PP(sens).output.kml_eco_benthos{2}, ...
             KML_footer]);
fclose(fid);

% % Indicator : Dune Types
% if S.userinput.indicators.dunes == 1
%     dunerules(sens);                 %dunes
% end
% 
% % Indicator : Dune Growth
% if S.userinput.indicators.dunesABS == 1
%     settings = S.settings.dunes;
%     S.dunes = postprocessDUNEGROWTH(PRNfileName,settings);
% end
% 
% % Indicator : Direct Impact On Benthic Population
% if S.userinput.indicators.eco == 1
%     ecorules2;
% end
% % Indicator : Costs
% %S=ITHK_calculate_costs(S);    %budget