function cosmos_nestingXBeachClusterFlow(hm,m)

mm=hm.models(m).flowNestModelNr;

dr=hm.models(mm).dir;

outputdir=[dr 'archive' hm.cycStr filesep 'output' filesep];

[status,message,messageid]=copyfile([outputdir 'trih-*'],pwd,'f');

np=hm.models(m).nrProfiles;

zcor=hm.models(mm).zLevel-hm.models(m).zLevel;

for i=1:np
    
    if hm.models(m).profile(i).run
        
        id=hm.models(m).profile(i).name;
        
        tmpdir=hm.tempDir;
        
        try
                    
            fid=fopen('xb.bnd','wt');
            fprintf(fid,'%s\n','sea                  Z T     1     2     1     3  0.0000000e+000');
            fclose(fid);
            
            [status,message,messageid]=copyfile([hm.models(m).dir 'nesting' filesep id filesep hm.models(m).name '.nst'],[pwd filesep 'xb.nst'],'f');
            
            fid=fopen('nesthd2.inp','wt');
            
            fprintf(fid,'%s\n','xb.bnd');
            fprintf(fid,'%s\n','xb.nst');
            fprintf(fid,'%s\n',hm.models(mm).runid);
            fprintf(fid,'%s\n','temp.bct');
            fprintf(fid,'%s\n','dummy.bcc');
            fprintf(fid,'%s\n','nest.dia');
            fprintf(fid,'%s\n',num2str(zcor));
            fclose(fid);
            
            system([hm.exeDir 'nesthd2.exe < nesthd2.inp']);
            fid=fopen('smoothbct.inp','wt');
            fprintf(fid,'%s\n','temp.bct');
            fprintf(fid,'%s\n',[hm.models(m).name '.bct']);
            fprintf(fid,'%s\n','3');
            
            fclose(fid);
            
            system([hm.exeDir 'smoothbct.exe < smoothbct.inp']);
            
            delete('nesthd2.inp');
            delete('nest.dia');
            delete('smoothbct.inp');
            
            delete('temp.bct');
            delete('dummy.bcc');
            
            delete('xb.bnd');
            delete('xb.nst');
            
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of XBeach in Delft3D-FLOW - ' hm.models(m).name ' profile ' hm.models(m).profile(i).name]);
        end
        
        %     cd(curdir);
        
        ConvertBct2XBeach([hm.models(m).name '.bct'],[tmpdir id filesep 'tide.txt'],hm.models(m).tFlowStart);
        delete([hm.models(m).name '.bct']);
    end
end

delete('trih-*');
