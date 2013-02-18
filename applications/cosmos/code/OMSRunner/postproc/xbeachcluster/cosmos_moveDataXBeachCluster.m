function cosmos_moveDataXBeachCluster(hm,m)

rundir=[hm.jobDir hm.models(m).name filesep];

delete([rundir '*.exe']);
if exist([rundir 'run.bat'],'file')
    delete([rundir 'run.bat']);
end

archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];
cycledir=[archivedir hm.cycStr filesep];

lst=dir(rundir);
for i=1:length(lst)
    if isdir([rundir lst(i).name])
        switch lst(i).name
            case{'.','..'}
            otherwise
                
                MakeDir([cycledir 'input'],lst(i).name);
                MakeDir([cycledir 'output'],lst(i).name);
                inpdir=[cycledir 'input' filesep lst(i).name filesep];
                outdir=[cycledir 'output' filesep lst(i).name filesep];

                [status,message,messageid]=movefile([rundir lst(i).name filesep hm.models(m).runid '*.sp2'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.zip'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.txt'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.dep'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.grd'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*'],outdir,'f');

        end
    end
end
