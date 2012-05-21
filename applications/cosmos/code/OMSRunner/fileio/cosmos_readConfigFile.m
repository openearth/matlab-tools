function hm=cosmos_readConfigFile

hm.eMailOnError.send=0;

fname='cosmos.ini';

if ~exist(fname,'file')

    %% Make cosmos.ini
    rundir = uigetdir(pwd, 'Select Run Directory');
    hm.runDir=[rundir filesep];
    
    [filename,pathname,filterindex] = uigetfile([hm.runDir 'scenarios\*.xml'],'Select scenario');
    hm.scenario = filename(1:end-4);

    datadir = uigetdir(pwd, 'Select Data Directory');
    hm.dataDir=[datadir filesep];

    jobdir = uigetdir(pwd, 'Select Job Directory');
    hm.jobDir=[jobdir filesep];
    
    webdir = uigetdir(pwd, 'Select Website Directory');
    hm.webDir=[webdir filesep];

    hm.nrProfilesPerJob=50;
    hm.eMailOnError.send=0;
    hm.eMailOnError.adress='Maarten.vanOrmondt@deltares.nl';
    hm.h4.userName='ormondt';
    hm.h4.password='0rm0ndt';
    hm.h4.path=strrep(['/' hm.jobDir],'\','/');
    hm.h4.path=strrep(hm.h4.path,':','');

    fid=fopen(fname,'wt');
    fprintf(fid,'%s\n',['RunDirectory     ' hm.runDir]);
    fprintf(fid,'%s\n',['DataDirectory    ' hm.dataDir]);
    fprintf(fid,'%s\n',['JobDirectory     ' hm.jobDir]);
    fprintf(fid,'%s\n',['WebDirectory     ' hm.webDir]);
    fprintf(fid,'%s\n',['H4Directory      ' hm.h4.path]);
    fprintf(fid,'%s\n',['H4UserName       ' hm.h4.userName]);
    fprintf(fid,'%s\n',['H4Password       ' hm.h4.password]);
    fprintf(fid,'%s\n',['Scenario         ' hm.scenario]);
    fprintf(fid,'%s\n',['eMailOnError     0']);
    fprintf(fid,'%s\n',['eMailAdress      ' hm.eMailOnError.adress]);
    fprintf(fid,'%s\n',['nrProfilesPerJob ' num2str(hm.nrProfilesPerJob)]);
    fclose(fid);

end

txt=ReadTextFile(fname);

n=length(txt);
hm.nrProfilesPerJob=50;
hm.clusterNode=[];

for i=1:n
    switch lower(txt{i}),
        case {'rundirectory'}
            hm.runDir=txt{i+1};
        case {'datadirectory'}
            hm.dataDir=txt{i+1};
        case {'jobdirectory'}
            hm.jobDir=txt{i+1};
        case {'webdirectory'}
            hm.webDir=txt{i+1};
        case {'archivedirectory'}
            hm.archiveDir=txt{i+1};
        case {'scenario'}
            hm.scenario=txt{i+1};
        case {'emailonerror'}
            hm.eMailOnError.send=str2double(txt{i+1});
        case {'emailadress'}
            hm.eMailOnError.adress=txt{i+1};
        case {'h4username'}
            hm.h4.userName=txt{i+1};
        case {'h4password'}
            hm.h4.password=txt{i+1};
        case {'h4directory'}
            hm.h4.path=txt{i+1};
        case {'nrprofilesperjob'}
            hm.nrProfilesPerJob=str2double(txt{i+1});
        case {'clusternode'}
            hm.clusterNode=txt{i+1};
    end
end

hm.scenarioDir=[hm.runDir 'scenarios' filesep hm.scenario filesep];
hm.jobDir=[hm.jobDir hm.scenario filesep];
hm.h4.path=[hm.h4.path hm.scenario '/'];
hm.modelDir=[hm.scenarioDir 'models' filesep];
hm.archiveDir=hm.modelDir;
hm.tempDir=[hm.runDir 'temp' filesep];
hm.exeDir=[hm.dataDir 'exe' filesep];
MakeDir(hm.tempDir);
