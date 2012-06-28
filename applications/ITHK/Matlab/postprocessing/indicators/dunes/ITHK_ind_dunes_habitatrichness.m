function ITHK_dunes_habitatrichness(sens)

% dunerules_19apr12.m

% -------------------------------------------------------------------
% Alma de Groot
% Ecoshape, WUR
% 19 apr 2012

% Calculates potential for dune formation based on Unibest outcomes.
% Post-processing tool based on UNIBEST outcomes
% used in Interactive Design Tool
% -------------------------------------------------------------------

fprintf('ITHK postprocessing : Indicator for dune habitat richness\n');

%% Housekeeping
global S

if nargin<1
sens=1;
end


if ~isfield(S.PP(sens),'dunes')
    return
end

%% STEP 4: ECOLOGICAL VARIATION
% roughly: number of habitat types expected
% H2110 (embryonic dunes % annuals)
% H2120 (white dunes)
% H1310 (green beach)
% H1330 (green beach)
% H2190 (green beach)
% grey dunes not taken into account

duneclass = S.PP(sens).dunes.duneclass;
richness = duneclass.*0;
richness (duneclass == 1) = 1;  
richness (duneclass == 2) = 1;
richness (duneclass == 3) = 2;
richness (duneclass == 4) = 2;  
richness (duneclass == 5) = 3;
S.PP(sens).dunes.richness = richness;

for jj = 1:length(S.PP(sens).settings.tvec)
    S.PP(sens).dunes.richnessRough(:,jj) = interp1(S.PP(sens).settings.s0,richness(:,jj),S.PP(sens).settings.sgridRough,'nearest');
end
% 1 = low/normal (low is the standard for the current coast)
% 2 = intermediate
% 3 = rich

[KMLdata]=ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough,S.PP(sens).dunes.richnessRough,S.settings.indicators.habitatrichness.icons,str2double(S.settings.indicators.habitatrichness.offset));
S.PP(sens).output.kml_dunes_habitatrichness = KMLdata;