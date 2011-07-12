function cosmos_preProcess(hm,m)

tmpdir=hm.TempDir;
jobdir=hm.JobDir;

dr=hm.Models(m).Dir;
inpdir=[dr 'input' filesep];
mdl=hm.Models(m).Name;

lst=dir(tmpdir);
for i=1:length(lst)
    if isdir([tmpdir lst(i).name])
        [success,message,messageid]=rmdir([tmpdir lst(i).name],'s');
    end
end
    
try
    delete([tmpdir '*']);
end

switch lower(hm.Models(m).Type)
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
