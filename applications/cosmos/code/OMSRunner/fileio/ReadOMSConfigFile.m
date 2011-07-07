function hm=ReadOMSConfigFile

hm.eMailOnError.send=0;

txt=ReadTextFile('omsconfig.ini');

n=length(txt);

hm.nrProfilesPerJob=50;

for i=1:n
    switch lower(txt{i}),
        case {'maindirectory'}
            hm.MainDir=txt{i+1};
        case {'jobdirectory'}
            hm.JobDir=txt{i+1};
        case {'webdirectory'}
            hm.WebDir=txt{i+1};
        case {'archivedirectory'}
            hm.ArchiveDir=txt{i+1};
        case {'scenario'}
            hm.Scenario=txt{i+1};
        case {'emailonerror'}
            hm.eMailOnError.send=str2double(txt{i+1});
        case {'emailadress'}
            hm.eMailOnError.Adress=txt{i+1};
        case {'h4username'}
            hm.h4.Username=txt{i+1};
        case {'h4password'}
            hm.h4.Password=txt{i+1};
        case {'h4path'}
            hm.h4.Path=txt{i+1};
        case {'nrprofilesperjob'}
            hm.nrProfilesPerJob=str2double(txt{i+1});
    end
end

hm.ScenarioDir=[hm.MainDir 'scenarios' filesep hm.Scenario filesep];
hm.ModelDir=[hm.ScenarioDir filesep 'models' filesep];
hm.ArchiveDir=hm.ModelDir;

hm.TempDir=[hm.MainDir 'temp' filesep];

