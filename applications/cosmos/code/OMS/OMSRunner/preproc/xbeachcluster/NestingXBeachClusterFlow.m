function NestingXBeachClusterFlow(hm,m)

curdir=pwd;

mm=hm.Models(m).FlowNestModelNr;

dr=hm.Models(mm).Dir;

outputdir=[dr 'lastrun' filesep 'output' filesep];

[status,message,messageid]=copyfile([outputdir 'trih-*'],pwd,'f');

np=hm.Models(m).NrProfiles;

zcor=hm.Models(mm).ZLevel-hm.Models(m).ZLevel;

for i=1:np
    
    if hm.Models(m).Profile(i).Run
        
        id=hm.Models(m).Profile(i).Name;
        
        tmpdir=hm.TempDir;
        
        try
                    
            fid=fopen('xb.bnd','wt');
            fprintf(fid,'%s\n','sea                  Z T     1     2     1     3  0.0000000e+000');
            fclose(fid);
            
            [status,message,messageid]=copyfile([hm.Models(m).Dir 'nesting' filesep id filesep hm.Models(m).Name '.nst'],[pwd filesep 'xb.nst'],'f');
            
            fid=fopen('nesthd2.inp','wt');
            
            fprintf(fid,'%s\n','xb.bnd');
            fprintf(fid,'%s\n','xb.nst');
            fprintf(fid,'%s\n',hm.Models(mm).Runid);
            fprintf(fid,'%s\n','temp.bct');
            fprintf(fid,'%s\n','dummy.bcc');
            fprintf(fid,'%s\n','nest.dia');
            fprintf(fid,'%s\n',num2str(zcor));
            fclose(fid);
            
            system([hm.MainDir 'exe' filesep 'nesthd2.exe < nesthd2.inp']);
            fid=fopen('smoothbct.inp','wt');
            fprintf(fid,'%s\n','temp.bct');
            fprintf(fid,'%s\n',[hm.Models(m).Name '.bct']);
            fprintf(fid,'%s\n','3');
            
            fclose(fid);
            
            system([hm.MainDir 'exe' filesep 'smoothbct.exe < smoothbct.inp']);
            
            delete('nesthd2.inp');
            delete('nest.dia');
            delete('smoothbct.inp');
            
            delete('temp.bct');
            delete('dummy.bcc');
            
            delete('xb.bnd');
            delete('xb.nst');
            
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of XBeach in Delft3D-FLOW - ' hm.Models(m).Name ' profile ' hm.Models(m).Profile(i).Name]);
        end
        
        %     cd(curdir);
        
        ConvertBct2XBeach([hm.Models(m).Name '.bct'],[tmpdir id filesep 'tide.txt'],hm.Models(m).TFlowStart);
        delete([hm.Models(m).Name '.bct']);
    end
end

delete('trih-*');
