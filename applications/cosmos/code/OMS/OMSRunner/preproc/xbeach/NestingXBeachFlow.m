function NestingXBeachFlow(hm,m)

tmpdir=hm.TempDir;

curdir=pwd;

mm=hm.Models(m).FlowNestModelNr;

dr=hm.Models(mm).Dir;

outputdir=[dr 'lastrun' filesep 'output' filesep ''];
[success,message,messageid]=copyfile([outputdir 'trih-*'],tmpdir,'f');

cd(tmpdir);

try
        
    nstadm=[hm.Models(m).Dir 'nesting' filesep hm.Models(m).Name '.nst'];

    [status,message,messageid]=copyfile([hm.Models(m).Dir 'nesting' filesep hm.Models(m).Name '.bnd'],tmpdir,'f');
    [status,message,messageid]=copyfile([hm.Models(m).Dir 'nesting' filesep hm.Models(m).Name '.nst'],tmpdir,'f');

    fid=fopen('nesthd2.inp','wt');
%    fprintf(fid,'%s\n',[hm.Models(m).Dir 'nesting' filesep hm.Models(m).Name '.bnd']);
    fprintf(fid,'%s\n',[hm.Models(m).Name '.bnd']);
    fprintf(fid,'%s\n',[hm.Models(m).Name '.nst']);
    fprintf(fid,'%s\n',hm.Models(mm).Runid);
    fprintf(fid,'%s\n','temp.bct');
    fprintf(fid,'%s\n','dummy.bcc');
    fprintf(fid,'%s\n','nest.dia');
    fprintf(fid,'%s\n','0.0');
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
    delete('trih*');

    delete([tmpdir hm.Models(m).Name '.bnd']);
    delete([tmpdir hm.Models(m).Name '.nst']);

catch
    disp('An error occured during nesting');
end

cd(curdir);

%ConvertBct2XBeach([tmpdir hm.Models(m).Name '.bct'],[tmpdir 'tide.txt'],hm.Models(m).MorFac,hm.Models(m).TFlowStart,tmpdir);
ConvertBct2XBeach(tmpdir, [hm.Models(m).Name '.bct'],'tide.txt',hm.Models(m).TFlowStart,32); %FIXME
delete([tmpdir hm.Models(m).Name '.bct']);
