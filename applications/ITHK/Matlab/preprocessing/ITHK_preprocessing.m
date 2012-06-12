% function S = preprocessingUnibestIT(lat,lon,mag,time,name,measure,inputDir,outputDir)
function ITHK_preprocessing(sens)

global S

%% Preprocessing Unibest Interactive Tool

%% Copy input files to output directory
copyfile([S.settings.inputdir 'BASIS.MDA'],S.settings.outputdir);
copyfile([S.settings.inputdir 'BASIS_ORIG.MDA'],S.settings.outputdir);
copyfile([S.settings.inputdir 'BASIS_ORIG_OLD.MDA'],S.settings.outputdir);
copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],[S.settings.outputdir 'BASIS.SOS']);
copyfile([S.settings.inputdir 'BRIJN90A.GRO'],[S.settings.outputdir 'BASIS.GRO']);
copyfile([S.settings.inputdir 'HOLLANDCOAST.REV'],[S.settings.outputdir 'BASIS.REV']);
copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],S.settings.outputdir);
copyfile([S.settings.inputdir 'BRIJN90A.GRO'],S.settings.outputdir);
copyfile([S.settings.inputdir 'HOLLANDCOAST.REV'],S.settings.outputdir);
copyfile([S.settings.inputdir 'NULL.BCI'],S.settings.outputdir);
copyfile([S.settings.inputdir 'NULL.BCO'],S.settings.outputdir);
copyfile([S.settings.inputdir 'NULL.OBW'],S.settings.outputdir);
copyfile([S.settings.inputdir 'locations5magrof2.GKL'],S.settings.outputdir);

%% Prepare input Unibest CL for different measures
% IMPORTANT: first add groynes, since MDA might be updated --> increase in number of coastline points
for jj = 1:length(S.userinput.phases)
    % If GRO-file in phase differs from 'basis', add groyne
    if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis') && ~strcmp([S.settings.outputdir S.userinput.phase(jj-1).GROfile],[S.settings.outputdir S.userinput.phase(jj).GROfile])
        disp('Adding groyne(s)')
        % If groynes have been added in previous phase, use this file as 
        % the basis for adding groynes in current phase
        if jj>1
            if ~strcmp(strtok(S.userinput.phase(jj-1).GROfile,'.'),'basis')
                copyfile([S.settings.outputdir S.userinput.phase(jj-1).GROfile],[S.settings.outputdir S.userinput.phase(jj).GROfile]);
            end
        else
            copyfile([S.settings.inputdir 'BRIJN90A.GRO'],[S.settings.outputdir S.userinput.phase(jj).GROfile]);
        end
        NGRO = 0;
        for ii = 1:length(S.userinput.phase(jj).groids)    
            NGRO = NGRO+1;
            %ITHK_add_groyne(S.userinput.phase(jj).groids(ii),jj,NGRO,sens);
            ITHK_add_groyne2(S.userinput.phase(jj).groids(ii),jj,NGRO,sens);
        end
    end
    % If SOS-file in phase differs from 'basis', add suppletion
    if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
        disp('Adding suppletion(s)')
        % If continuous suppletion exist, use continuous suppletions as base. 
        % Else use template file to add suppletion
        if exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file') &&  ~strcmp([S.settings.outputdir S.userinput.phase(jj).SOSfile],[S.settings.outputdir '1HOTSPOTSIT_cont.sos'])
           copyfile([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]); 
        elseif ~exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')
            copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]);
        end
%         elseif exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')
%         else
%            copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]);
%         end
        for ii = 1:length(S.userinput.phase(jj).supids)
            %ITHK_add_suppletion(S.userinput.phase(jj).supids(ii),jj,sens);
            ITHK_add_suppletion2(ii,jj,sens);
        end
    end
    % If REV-file in phase differs from 'basis', add revetment
    if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')&& ~strcmp([S.settings.outputdir S.userinput.phase(jj-1).REVfile],[S.settings.outputdir S.userinput.phase(jj).REVfile])
        disp('Adding revetment(s)')
        % If revetments have been added in previous phase, use this file as 
        % the basis for adding revetments in current phase        
        if jj>1
            if ~strcmp(lower(strtok(S.userinput.phase(jj-1).REVfile,'.')),'basis')
                copyfile([S.settings.outputdir S.userinput.phase(jj-1).REVfile],[S.settings.outputdir S.userinput.phase(jj).REVfile]);
            end
        else
            copyfile([S.settings.inputdir 'HOLLANDCOAST.REV'],[S.settings.outputdir S.userinput.phase(jj).REVfile]);
        end
        NREV = 0;
        for ii = 1:length(S.userinput.phase(jj).revids)
            NREV = NREV+1;
            %ITHK_add_revetment(S.userinput.phase(jj).revids(ii),jj,NREV,sens);
            ITHK_add_revetment2(S.userinput.phase(jj).revids(ii),jj,NREV,sens);
        end
    end
end

ITHK_prepareCLrun;
