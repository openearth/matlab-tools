function cosmos_moveDataXBeachCluster(hm,m)

rundir=[hm.JobDir hm.Models(m).Name filesep];

delete([rundir '*.exe']);
if exist([rundir 'run.bat'],'file')
    delete([rundir 'run.bat']);
end

dr=hm.Models(m).Dir;

lst=dir(rundir);
for i=1:length(lst)
    if isdir([rundir lst(i).name])
        switch lst(i).name
            case{'.','..'}
            otherwise
                
                MakeDir([dr 'lastrun' filesep 'input'],lst(i).name);
                MakeDir([dr 'lastrun' filesep 'output'],lst(i).name);
                inpdir=[dr 'lastrun' filesep 'input' filesep lst(i).name filesep];
                outdir=[dr 'lastrun' filesep 'output' filesep lst(i).name filesep];

                [status,message,messageid]=movefile([rundir lst(i).name filesep hm.Models(m).Runid '*.sp2'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.zip'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.txt'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.dep'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.grd'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*'],outdir,'f');

        end
    end
end
