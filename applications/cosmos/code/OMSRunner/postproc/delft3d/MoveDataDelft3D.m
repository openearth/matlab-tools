function MoveDataDelft3D(hm,m)

Model=hm.Models(m);

rundir=[hm.JobDir Model.Name filesep];

delete([rundir '*.exe']);

dr=Model.Dir;

delete([dr 'lastrun' filesep 'input' filesep '*']);

[status,message,messageid]=movefile([rundir 'tri-rst.rst'],[dr 'lastrun' filesep 'input'],'f');

rstfiles=dir([rundir 'tri-rst.*']);

nrst=length(rstfiles);

if nrst>0
    for j=1:nrst
        % Only move tri-rst file of restartTime
        rstfil=rstfiles(j).name;
        dt=rstfil(end-14:end);
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if abs(rsttime-Model.restartTime)<0.01
            zip([dr 'restart' filesep 'tri-rst' filesep rstfil '.zip'],[rundir rstfil]);
            break
        end
    end
end
delete([rundir 'tri-rst*']);

% Throw away old restart files (3 days or older)
rstfiles=dir([dr 'restart' filesep 'tri-rst' filesep 'tri-rst.*.zip']);
nrst=length(rstfiles);
if nrst>0
    for j=1:nrst
        rstfil=rstfiles(j).name;
        dt=rstfil(end-18:end-4);
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if rsttime<Model.restartTime-3
            delete([dr 'restart' filesep 'tri-rst' filesep rstfil]);
        end        
    end
end


hot0=[rundir 'hot_1_' datestr(Model.TWaveStart,'yyyymmdd.HHMMSS')];

hot00=[rundir 'hot_1_00000000.000000'];
if exist(hot00,'file')
    movefile(hot00,hot0);
end

if exist(hot0,'file')
    [status,message,messageid]=movefile(hot0,[dr 'lastrun' filesep 'input'],'f');
end

hotfiles=dir([rundir 'hot_1_*']);

nhot=length(hotfiles);

if nhot>0

    for j=1:nhot
        % Only move hot file of restartTime
        hotfil=hotfiles(j).name;
        dt=hotfil(7:end);
        hottime=datenum(dt,'yyyymmdd.HHMMSS');
        tstr=hotfil(16:end);
        if abs(hottime-Model.restartTime)<0.01
%            switch tstr
%                case{'000000','060000','120000','180000'}
                    [status,message,messageid]=copyfile([rundir hotfil],[dr 'restart' filesep 'hot'],'f');
                    zip([dr 'restart' filesep 'hot' filesep hotfil '.zip'],[dr 'restart' filesep 'hot' filesep hotfil]);
                    delete([dr 'restart' filesep 'hot' filesep hotfil]);
%            end
            break;
        end
    end
end
delete([rundir 'hot*']);

% Throw away old hot files (3 days or older)
hotfiles=dir([dr 'restart' filesep 'hot' filesep 'hot*.zip']);
nhot=length(hotfiles);
if nhot>0
    for j=1:nhot
        hotfil=hotfiles(j).name;
        dt=hotfil(7:end-4);
        hottime=datenum(dt,'yyyymmdd.HHMMSS');
        if hottime<Model.restartTime-3
            delete([dr 'restart' filesep 'hot' filesep hotfil]);
        end        
    end
end

inpdir=[dr filesep 'lastrun' filesep 'input'];
outdir=[dr filesep 'lastrun' filesep 'output'];

[status,message,messageid]=movefile([rundir 'tri*'],outdir,'f');
[status,message,messageid]=movefile([rundir 'com-*.*'],outdir,'f');
[status,message,messageid]=movefile([rundir 'wavm-*.d*'],outdir,'f');

% %% PART
% [status,message,messageid]=movefile([rundir 'light_crude.csv'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'couplnef.out'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'his-' Model.Runid '.d*'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'map-' Model.Runid '.d*'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'plo-' Model.Runid '.d*'],outdir,'f');
% [status,message,messageid]=movefile([rundir Model.Runid '.out'],outdir,'f');

% delete([rundir Model.Runid '.his']);
% delete([rundir Model.Runid '.map']);
% delete([rundir Model.Runid '.plo']);

%% SWAN
delete([rundir '*.sp1']);

[status,message,messageid]=movefile([rundir Model.Name '.sp2'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.sp2'],outdir,'f');

delete([rundir 'swn-dia*']);

if exist([rundir 'WNDNOW'],'file')
    delete([rundir 'WNDNOW']);
end

[status,message,messageid]=movefile([rundir '*'],inpdir,'f');
