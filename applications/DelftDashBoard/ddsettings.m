disp('Start DelftDashBoard with ddb or DelftDashBoard');

basePath=fileparts(which('ddsettings.m'));

subDirs={...
    'general'
    'main'
    'models'
    'toolboxes'
    'utils'
    };

totalPath=[];

for ii=1:length(subDirs)
    pp=genpath([basePath filesep subDirs{ii}]);
    pp=strread(strrep(pp,';',char(13)),'%s');
    pp(~cellfun('isempty',regexp(pp,'\.svn')))=[];
    pp(~cellfun('isempty',regexp(pp,'mex\\V')))=[];
    
    pp=[pp repmat({';'},size(pp,1),1)];
    pp=pp';
    totalPath=[totalPath [pp{:}]];
end

addpath(totalPath);

%Add appropriate V* dir
verDir=strrep(version,'.','');
addpath([basePath filesep 'general' filesep 'mex' filesep 'V' verDir(1:2)]);
