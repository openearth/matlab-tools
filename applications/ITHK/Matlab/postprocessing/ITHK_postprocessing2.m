function ITHK_postprocessing2(sens)

%% Postprocessing Unibest Interactive Tool
global S

%% General PP settings
% Extract MDAdata for original and updated coastline
[S.PP.settings.MDAdata_ORIG_OLD]=ITHK_readMDA('BASIS_ORIG_OLD.MDA');
[S.PP.settings.MDAdata_ORIG]=ITHK_readMDA('BASIS_ORIG.MDA');
[S.PP.settings.MDAdata_NEW]=ITHK_readMDA('BASIS.MDA');

% time settings
S.PP.settings.tvec = S.UB(sens).results.PRNdata.year;
S.PP.settings.t0 = 2005;

% settings
S.PP.settings.dsRough         = str2double(S.settings.plotting.barplot.dsrough); % grid size rough grid
S.PP.settings.dsFine          = str2double(S.settings.plotting.barplot.dsfine);  % grid size fine grid
S.PP.settings.dxFine          = str2double(S.settings.plotting.barplot.widthfine); % distance from suppletion location where fine grid is used
S.PP.settings.sVectorLength   = str2double(S.settings.plotting.barplot.barscalevector);   % scaling factor for vector length

% initial coast line
S.PP.settings.x0              = S.PP.settings.MDAdata_ORIG.Xcoast; 
S.PP.settings.y0              = S.PP.settings.MDAdata_ORIG.Ycoast; 
S.PP.settings.s0              = distXY(S.PP.settings.MDAdata_ORIG.Xcoast,S.PP.settings.MDAdata_ORIG.Ycoast);

% Rough & fine grids
S.PP.settings.sgridRough      = S.PP.settings.s0(1):S.PP.settings.dsRough:S.PP.settings.s0(end);
S.PP.settings.sgridFine       = S.PP.settings.s0(1):S.PP.settings.dsFine:S.PP.settings.s0(end);
S.PP.settings.idplotrough     = ones(length(S.PP.settings.sgridRough),1);
S.PP.settings.widthRough      = max(mean(diff(S.UB(sens).results.PRNdata.xdist)),S.PP.settings.dsRough/2);
S.PP.settings.widthFine       = max(mean(diff(S.UB(sens).results.PRNdata.xdist)),S.PP.settings.dsFine/2);

% Find ids of fine grid corresponding to rough grid
for ii=1:length(S.PP.settings.sgridRough)
    distFR{ii} = abs(S.PP.settings.sgridFine-S.PP.settings.sgridRough(ii));
    S.PP.settings.idFR(ii) = find(distFR{ii} == min(distFR{ii}),1,'first');
end

%% Make KML
S.PP.output.kmlFileName     = [S.settings.outputdir filesep 'output' filesep S.userinput.name filesep S.userinput.name,'.kml'];
KMLmapName      = S.userinput.name;
nam             = S.userinput.name;

%% KML header
fid     = fopen(S.PP.output.kmlFileName,'w');
kml  = [];
S.PP.output.kml  = [kml KML_header('kmlName',nam)];

%% Add effect SLR to PRN info
if S.userinput.indicators.slr == 1
    ITHK_add_SLR(sens);
end

%% Map UB results to GE
ITHK_mapUBtoGE2(sens);

% % Add PRN info
% if S.userinput.indicators.coast == 1
%     ITHK_PRN_to_kml(sens);
% end

%% Add measures
for jj = 1:length(S.userinput.phases)
    if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).groids)
            for kk = 1:S.UB.input(sens).groyne(S.userinput.phase(jj).groids(ii)).Ngroynes
                ITHK_groyne_to_kml2(S.userinput.phase(jj).groids(ii),kk);
            end
        end
    end
    if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).supids)
            ITHK_suppletion_to_kml2(S.userinput.phase(jj).supids(ii));
        end
    end
    if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).revids)
            ITHK_revetment_to_kml2(S.userinput.phase(jj).revids(ii));
        end
    end
end
 
%% Add indicators
if S.userinput.indicators.dunes == 1
    ITHK_dunerules2(sens);                 %dunes
    ITHK_dunes_habitatrichness;
end
% if str2double(S.settings.dunes.on)==1
%     settings.CSTorient = 'BASIS_ORIG.MDA'; 
%     settings.yposinitial = str2double(S.settings.dunes.yposinitial)+S.MDAdata_NEW.Y1i-S.MDAdata_ORIG.Y1i;
%     S.dunes = postprocessDUNEGROWTH(PRNfileName,settings);
% end
%S=ITHK_calculate_costs(S);    %budget
if S.userinput.indicators.eco == 1
   eval(S.settings.indicators.eco.function);%ITHK_ecorules2;
end

%% Add disclaimer
if isfield(S.settings.postprocessing,'disclaimer') 
    disclaimer = ITHK_kmldisclaimer;
    S.PP.output.kml = [S.PP.output.kml disclaimer];
end

%% KML footer
S.PP.output.kml = [S.PP.output.kml KML_footer];
fprintf(fid,S.PP.output.kml);
fclose(fid);
