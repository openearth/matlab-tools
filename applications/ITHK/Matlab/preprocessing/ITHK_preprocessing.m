% function S = preprocessingUnibestIT(lat,lon,mag,time,name,measure,inputDir,outputDir)
function ITHK_preprocessing(sens)

global S

status='ITHK preprocessing';
try
    sendWebStatus(status,S.xml);
catch
end
fprintf('ITHK preprocessing\n');

%% Preprocessing Unibest Interactive Tool

%% Copy input files to output directory
status='ITHK preprocessing : Copy default UNIBEST model files';
try
    sendWebStatus(status,S.xml);
catch
end
fprintf('ITHK preprocessing : Copy default UNIBEST model files\n');
%copyfile(S.settings.inputdir,S.settings.outputdir);
%{
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
%}
%% Prepare input Unibest CL for different measures
status='ITHK preprocessing : Preparing UNIBEST structures amd nourishments';
try
    sendWebStatus(status,S.xml);
catch
end
fprintf('ITHK preprocessing : Preparing UNIBEST structures amd nourishments\n');
% IMPORTANT: first add groynes, since MDA might be updated --> increase in number of coastline points
for jj = 1:length(S.userinput.phases)
    % If GRO-file in phase differs from 'basis', add groyne
    if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis') && ~strcmp([S.settings.outputdir S.userinput.phase(jj-1).GROfile],[S.settings.outputdir S.userinput.phase(jj).GROfile])
        status='Adding groyne(s)';
        try
            sendWebStatus(status,S.xml);
        catch
        end        
        disp('Adding groyne(s)')
        % If groynes have been added in previous phase, use this file as 
        % the basis for adding groynes in current phase
        if jj>1
            if ~strcmp(lower(strtok(S.userinput.phase(jj-1).GROfile,'.')),'basis')
                copyfile([S.settings.outputdir S.userinput.phase(jj-1).GROfile],[S.settings.outputdir S.userinput.phase(jj).GROfile]);
            end
        else
            copyfile([S.settings.rundir 'BASIS.GRO'],[S.settings.outputdir S.userinput.phase(jj).GROfile]);
        end
        NGRO = 0;
        for ii = 1:length(S.userinput.phase(jj).groids)    
            NGRO = NGRO+1;
            ITHK_add_groyne(S.userinput.phase(jj).groids(ii),jj,NGRO,sens);
        end
    end
    % If SOS-file in phase differs from 'basis', add nourishment
    if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
        status='Adding nourishment(s)';
        try
            sendWebStatus(status,S.xml);
        catch
        end        
        disp('Adding nourishment(s)')
        % If continuous nourishment exist, use continuous nourishments as base. 
        % Else use template file to add nourishment
        if exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file') &&  ~strcmp([S.settings.outputdir S.userinput.phase(jj).SOSfile],[S.settings.outputdir '1HOTSPOTSIT_cont.sos'])
           copyfile([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]); 
        elseif ~exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')
            copyfile([S.settings.rundir 'BASIS.SOS'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]);
        end
%         elseif exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')
%         else
%            copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]);
%         end
        for ii = 1:length(S.userinput.phase(jj).supids)
            ITHK_add_nourishment(ii,jj,sens);
        end
    end
    % If REV-file in phase differs from 'basis', add revetment
    if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')&& ~strcmp([S.settings.outputdir S.userinput.phase(jj-1).REVfile],[S.settings.outputdir S.userinput.phase(jj).REVfile])
        status='Adding revetment(s)';
        try
            sendWebStatus(status,S.xml);
        catch
        end        
        disp('Adding revetment(s)')
        % If revetments have been added in previous phase, use this file as 
        % the basis for adding revetments in current phase        
        if jj>1
            if ~strcmp(lower(strtok(S.userinput.phase(jj-1).REVfile,'.')),'basis')
                copyfile([S.settings.outputdir S.userinput.phase(jj-1).REVfile],[S.settings.outputdir S.userinput.phase(jj).REVfile]);
            end
        else
            copyfile([S.settings.rundir 'BASIS.REV'],[S.settings.outputdir S.userinput.phase(jj).REVfile]);
        end
        NREV = 0;
        for ii = 1:length(S.userinput.phase(jj).revids)
            NREV = NREV+1;
            ITHK_add_revetment(S.userinput.phase(jj).revids(ii),jj,NREV,sens);
        end
    end
end

ITHK_prepareCLrun;
