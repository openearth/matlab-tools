function cosmos_moveDataWW3(hm,m)

Model=hm.Models(m);

rundir=[hm.JobDir Model.Name filesep];

delete([rundir 'out_grd.ww3']);
% delete([rundir 'out_pnt.ww3']);
% delete([rundir 'partition.ww3']);
% delete([rundir 'ww3_out*.inp']);
% delete([rundir 'gx_outf.inp']);
% delete([rundir 'ww3_grid.inp']);
% delete([rundir 'ww3_prep.inp']);

dr=Model.Dir;

inpdir=[dr 'lastrun' filesep 'input'];
outdir=[dr 'lastrun' filesep 'output'];

[status,message,messageid]=movefile([rundir '*.inp'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.bat'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.sh'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.obs'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.bot'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'wind.ww3'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'restart.ww3'],inpdir,'f');

% dtrst=hm.RunInterval/24;
% 
% trststart=max(Model.TStop-8*dtrst,Model.TWaveStart+dtrst);
% trststart=hm.Cycle+hm.RunInterval/24;
% trststart=hm.Cycle;
% %trststart=Model.TWaveOKay+hm.RunInterval/24;
% 
% nrst=(Model.TStop-trststart)/dtrst+1;
% nrst=1;

% trststart=-1e9;
% trststart=max(trststart,Model.TWaveOkay); % Model must be spun-up
% trststart=max(trststart,hm.Cycle+hm.RunInterval/24); % Start time of next cycle 
% trststart=min(trststart,Model.TLastAnalyzed); % Restart time no later than last analyzed time in meteo fields

% if nrst>0
%     for j=1:nrst
% 
%         t1=trststart+(j-1)*dtrst;

        rsttime=datestr(Model.restartTime,'yyyymmdd.HHMMSS');
        
        MakeDir(dr,'restart');

        % First check if the restart file exists in the run directory
        if exist([rundir 'restart' num2str(1) '.ww3'],'file')
            [status,message,messageid]=movefile([rundir 'restart' num2str(1) '.ww3'],[dr 'restart' filesep 'restart.ww3.' rsttime],'f');
            zip([dr 'restart' filesep 'restart.ww3.' rsttime '.zip'],[dr 'restart' filesep 'restart.ww3.' rsttime]);
            delete([dr 'restart' filesep 'restart.ww3.' rsttime]);
        end
%     end
% end

% Throw away old restart files (3 days or older)
rstfiles=dir([dr 'restart' filesep 'restart.*.zip']);
nrst=length(rstfiles);
if nrst>0
    for j=1:nrst
        rstfil=rstfiles(j).name;
        dt=rstfil(13:end-4);
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if rsttime<Model.restartTime-3
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
