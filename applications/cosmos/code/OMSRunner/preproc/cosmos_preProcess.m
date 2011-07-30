function cosmos_preProcess(hm,m)

tmpdir=hm.tempDir;
jobdir=hm.jobDir;

dr=hm.models(m).dir;
inpdir=[dr 'input' filesep];
mdl=hm.models(m).name;

lst=dir(tmpdir);
for i=1:length(lst)
    if isdir([tmpdir lst(i).name])
        [success,message,messageid]=rmdir([tmpdir lst(i).name],'s');
    end
end
    
try
    delete([tmpdir '*']);
end

switch lower(hm.models(m).type)
    case{'delft3dflow','delft3dflowwave'}
        [success,message,messageid] = copyfile([inpdir '*'],tmpdir,'f');
        cosmos_preProcessDelft3D(hm,m)
    case{'ww3'}
        [success,message,messageid] = copyfile([inpdir '*'],tmpdir,'f');
        cosmos_preProcessWW3(hm,m)
    case{'xbeach'}
        [success,message,messageid] = copyfile([inpdir '*'],tmpdir,'f');
        cosmos_preProcessXBeach(hm,m)
    case{'xbeachcluster'}
        cosmos_preProcessXBeachCluster(hm,m);
end

disp(['Moving input to job directory - ' mdl]);

MakeDir(jobdir,mdl);

[success,message,messageid]=movefile([tmpdir '*'],[jobdir mdl],'f');

[success,message,messageid]=rmdir([tmpdir '*']);
