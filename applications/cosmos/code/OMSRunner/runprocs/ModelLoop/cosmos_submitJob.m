function SubmitJob(hm,m)

Model=hm.Models(m);

switch Model.RunEnv

    case{'win32'}

        % Daemon
        
        f=dir([hm.JobDir filesep 'action.*']);

        nrmax=0;
        if ~isempty(f)
            n=length(f);
            for i=1:n
                nr=str2double(f(i).name(8:end));
                nrmax=max(nr,nrmax);
            end
        end

        nrmax=nrmax+1;

        fname =[hm.JobDir 'action.' num2str(nrmax,'%0.4i')];

        %inpdir=[hm.JobDir Model.Name filesep];
        inpdir=[hm.JobDir Model.Name];

        fid=fopen(fname,'wt');

        cycstr=datestr(hm.Cycle,'yyyymmddHHMMSS');
        % TODO: What does this do?
        % Copy the inpdir (job+model) directory to the current directory
        fprintf(fid,'%s\n',['xcopy /E /I ' inpdir ' ' Model.Name]);
        % remove the job/model directory
        fprintf(fid,'%s\n',['rmdir /Q /S ' inpdir]);
        % add the date to a file
        fprintf(fid,'%s\n',['realdate /f="CCYYMMDD hhmmss" >> ' hm.JobDir 'running.' cycstr '.' Model.Name]);
        % go into the model directory
        fprintf(fid,'%s\n',['cd ' Model.Name]);
        % start the run
        fprintf(fid,'%s\n','call run.bat');
        % ping yourself? Maybe some alternative for sleeping?
        fprintf(fid,'%s\n','ping localhost -n 1 -w 1000 > nul');
        fprintf(fid,'%s\n','cd ..');
        % and ping again but 3 times?
        fprintf(fid,'%s\n','ping localhost -n 3 -w 1000 > nul');
        % copy the model directory back to its original place
        fprintf(fid,'%s\n',['xcopy /E /I ' Model.Name ' ' inpdir]);
        fprintf(fid,'%s\n','ping localhost -n 1 -w 1000 > nul');
        % throw away the directory where the model was run
        fprintf(fid,'%s\n',['rmdir /Q /S ' Model.Name]);
        fprintf(fid,'%s\n','ping localhost -n 1 -w 1000 > nul');
        % echo a "."?
        fprintf(fid,'%s\n',['echo. >>  ' hm.JobDir 'running.' cycstr '.' Model.Name]);
        % add the date again? Finish time?
        fprintf(fid,'%s\n',['realdate /f="CCYYMMDD hhmmss" >> ' hm.JobDir 'running.' cycstr '.' Model.Name]);
        % echo a dot again?
        fprintf(fid,'%s\n',['echo. >>  ' hm.JobDir 'running.' cycstr '.' Model.Name]);
        % move the file which was called running to finished. This is what the
        % runner will check for
        fprintf(fid,'%s\n',['move ' hm.JobDir 'running.' cycstr '.' Model.Name ' ' hm.JobDir 'finished.' cycstr '.' Model.Name]);

        fclose(fid);

    case{'h4'}
        
        % H4 cluster
        
        
        
        fid=fopen('run_h4.sh','wt');
        
        fprintf(fid,'%s\n','#!/bin/sh');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n',['cd ' hm.h4.Path Model.Name]);
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','. /opt/sge/InitSGE');
        fprintf(fid,'%s\n','. /opt/intel/fc/10/bin/ifortvars.sh');
        fprintf(fid,'%s\n','');
        switch lower(Model.Type)
            case{'xbeachcluster'}
                nprfperjob=hm.nrProfilesPerJob;
                njobs=ceil(Model.NrProfiles/nprfperjob);
                for j=1:njobs
                    fprintf(fid,'%s\n',['dos2unix run' num2str(j) '.sh']);
                    fprintf(fid,'%s\n',['qsub -V -N ' Model.Runid '_' num2str(j) ' run' num2str(j) '.sh']);
                end
            otherwise
                fprintf(fid,'%s\n','dos2unix run.sh');
                fprintf(fid,'%s\n',['qsub -V -N ' Model.Name ' run.sh']);
        end
        fprintf(fid,'%s\n','qstat -u $USER ');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','exit');

        fclose(fid);    
        
        system([hm.MainDir 'exe' filesep 'dos2unix run_h4.sh']);
        
        [success,message,messageid]=movefile('run_h4.sh','u:\','f');

%        system([hm.MainDir 'exe' filesep 'plink ormondt@h4 -pw 0rm0ndt dos2unix run.sh']);
        system([hm.MainDir 'exe' filesep 'plink ' hm.h4.Username '@h4 -pw ' hm.h4.Password ' ~/run_h4.sh']);

end
