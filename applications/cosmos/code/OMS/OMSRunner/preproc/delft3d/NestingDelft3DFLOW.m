function NestingDelft3DFLOW(hm,m)

tmpdir=hm.TempDir;

curdir=pwd;

Model=hm.Models(m);

switch lower(Model.FlowNestType)
    case{'oceanmodel'}

        % Nesting in ocean model
        datafolder=[hm.ScenarioDir 'oceanmodels' filesep Model.oceanModel filesep];
        dataname=Model.oceanModel;
        wlbndfile=[Model.Name '.wl.bnd'];
        wlbcafile=[Model.Name '.wl.bca'];
        curbndfile=[Model.Name '.current.bnd'];
        curbcafile=[Model.Name '.current.bca'];
        wlconst=Model.ZLevel;
        writeNestXML([tmpdir 'nest.xml'],tmpdir,Model.Runid,datafolder,dataname,wlbndfile,wlbcafile,curbndfile,curbcafile,wlconst);
        makeBctBccIni('bct','nestxml',[tmpdir 'nest.xml'],'inpdir',tmpdir,'runid',Model.Runid,'workdir',tmpdir);
        makeBctBccIni('bcc','nestxml',[tmpdir 'nest.xml'],'inpdir',tmpdir,'runid',Model.Runid,'workdir',tmpdir);
        delete([tmpdir 'nest.xml']);
        
    otherwise
        % Regular nesting

        mm=Model.FlowNestModelNr;
        dr=hm.Models(mm).Dir;       
        outputdir=[dr 'lastrun' filesep 'output' filesep];
        usematlabnesthd2=1;

        if usematlabnesthd2

            runid1=Model.Runid;
            runid2=hm.Models(mm).Runid;
            nstadm=[Model.Dir 'nesting' filesep Model.Name '.nst'];
            zcor=hm.Models(mm).ZLevel-Model.ZLevel+Model.ZSeaLevelRise;
            
            hisfile=[outputdir 'trih-' runid2 '.dat'];
            nesthd2('hisfile',hisfile,'inputdir',tmpdir,'runid',runid1,'admfile',nstadm,'zcor',zcor,'save',1,'opt','hydro');

        else

            [success,message,messageid]=copyfile([outputdir 'trih-*'],tmpdir,'f');

            cd(tmpdir);

            try

                nstadm=[Model.Dir 'nesting' filesep Model.Name '.nst'];

                %% Water level correction

                zcor=hm.Models(mm).ZLevel-Model.ZLevel+Model.ZSeaLevelRise;

                fid=fopen('nesthd2.inp','wt');

                fprintf(fid,'%s\n',[Model.Name '.bnd']);
                fprintf(fid,'%s\n',nstadm);
                fprintf(fid,'%s\n',hm.Models(mm).Runid);
                fprintf(fid,'%s\n','temp.bct');
                fprintf(fid,'%s\n','dummy.bcc');
                fprintf(fid,'%s\n','nest.dia');
                fprintf(fid,'%s\n',num2str(zcor));
                fclose(fid);

                system([hm.MainDir 'exe' filesep 'nesthd2.exe < nesthd2.inp']);
                fid=fopen('smoothbct.inp','wt');
                fprintf(fid,'%s\n','temp.bct');
                fprintf(fid,'%s\n',[Model.Name '.bct']);
                fprintf(fid,'%s\n','3');

                fclose(fid);

                system([hm.MainDir 'exe' filesep 'smoothbct.exe < smoothbct.inp']);

                delete('nesthd2.inp');
                delete('smoothbct.inp');

                delete('temp.bct');
                delete('nest.dia');
                delete('dummy.bcc');
                delete('trih*');

            catch
                WriteErrorLogFile(hm,['An error occured during nesting of ' Model.Name]);
            end

            cd(curdir);

        end

end
