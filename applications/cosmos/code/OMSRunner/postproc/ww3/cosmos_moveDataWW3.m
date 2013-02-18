function cosmos_moveDataWW3(hm,m)

model=hm.models(m);

rundir=[hm.jobDir model.name filesep];
archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];
cycledir=[archivedir hm.cycStr filesep];

delete([rundir 'out_grd.ww3']);

dr=model.dir;

inpdir=[cycledir 'input'];
outdir=[cycledir 'output'];

[status,message,messageid]=movefile([rundir '*.inp'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.bat'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.sh'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.obs'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.bot'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'wind.ww3'],inpdir,'f');
% Don't copy restart file
% [status,message,messageid]=movefile([rundir 'restart.ww3'],inpdir,'f');

MakeDir(dr,'restart');

% First check if the restart file exists in the run directory
flist=dir([rundir 'restart.*.zip']);
for ii=1:length(flist)
    fname=flist(ii).name;
    [status,message,messageid]=movefile([rundir fname],[dr 'restart'],'f');
end

% Throw away old restart files (10 days or older)
rstfiles=dir([dr 'restart' filesep 'restart.*.zip']);
nrst=length(rstfiles);
if nrst>0
    for j=1:nrst
        rstfil=rstfiles(j).name;
        dt=rstfil(13:end-4);
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if rsttime<model.restartTime-10
            delete([dr 'restart' filesep rstfil]);
        end        
    end
end

delete([rundir 'restart*']);
[status,message,messageid]=copyfile([rundir 'mod_def.ww3'],inpdir,'f');

[status,message,messageid]=movefile([rundir '*.ww3'],outdir,'f');
[status,message,messageid]=movefile([rundir '*.spc'],outdir,'f');
[status,message,messageid]=movefile([rundir '*.ctl'],outdir,'f');
[status,message,messageid]=movefile([rundir '*.grads'],outdir,'f');
[status,message,messageid]=movefile([rundir 'screenfile'],outdir,'f');
