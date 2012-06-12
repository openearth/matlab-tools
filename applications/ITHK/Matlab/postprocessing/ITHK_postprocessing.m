function ITHK_postprocessing(sens)

global S

%% Postprocessing Unibest Interactive Tool

%% Prepare plotting in GE
ITHK_mapUBtoGE(sens);

%% Make KML
S.PP.output.kmlFileName     = [S.settings.outputdir filesep 'output' filesep S.userinput.name filesep S.userinput.name,'.kml'];
%S.PP.output.kmlFileName     = [S.settings.outputdir S.userinput.name,'.kml'];
KMLmapName      = S.userinput.name;
nam             = S.userinput.name;

% KML header
fid     = fopen(S.PP.output.kmlFileName,'w');
kml  = [];
S.PP.output.kml  = [kml KML_header('kmlName',nam)];

% Add measures
%NGRO =0;
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

% Add effect SLR to PRN info
if S.userinput.indicators.slr == 1
    ITHK_add_SLR(sens);
end

% Add PRN info
if S.userinput.indicators.coast == 1
    ITHK_PRN_to_kml(sens);
end
 
% Add indicators
if S.userinput.indicators.dunes == 1
    ITHK_dunerules(sens);                 %dunes
end
% if str2double(S.settings.dunes.on)==1
%     settings.CSTorient = 'BASIS_ORIG.MDA'; 
%     settings.yposinitial = str2double(S.settings.dunes.yposinitial)+S.MDAdata_NEW.Y1i-S.MDAdata_ORIG.Y1i;
%     S.dunes = postprocessDUNEGROWTH(PRNfileName,settings);
% end
%S=ITHK_calculate_costs(S);    %budget
if S.userinput.indicators.eco == 1
   ITHK_ecorules2;
end

% KML footer
S.PP.output.kml = [S.PP.output.kml KML_footer];
fprintf(fid,S.PP.output.kml);
fclose(fid);
