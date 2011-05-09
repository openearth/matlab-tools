function PreProcessWW3(hm,m)

Model=hm.Models(m);
dr=Model.Dir;
tmpdir=hm.TempDir;

%% Get restart file
fname=[dr 'restart' filesep Model.WaveRstFile '.zip'];
if exist(fname,'file')
    unzip(fname,tmpdir);
    [success,message,messageid]=movefile([tmpdir Model.WaveRstFile],[tmpdir 'restart.ww3'],'f');
end

%% Get nest file
if Model.WaveNested
    nr=Model.WaveNestNr;
    mm=Model.WaveNestModelNr;
    outputdir=[hm.Models(mm).Dir 'lastrun' filesep 'output' filesep];
    fname=[outputdir 'nest' num2str(nr) '.ww3'];
    if exist(fname,'file')
        [success,message,messageid]=copyfile(fname,[tmpdir 'nest.ww3'],'f');
    end
end

%% Get output locations
[nestrid,nestnames,x,y]=getWW3points(hm,m);

%% Get start and stop times
inpfile=[hm.TempDir 'ww3_shel.inp'];
dtrst=hm.RunInterval/24;
% trststart=max(Model.TStop-8*dtrst,Model.TWaveStart+dtrst);
% trststart=hm.Cycle+hm.RunInterval/24;
% trststop=hm.Cycle+hm.RunInterval/24;

% meteodir=[hm.ScenarioDir 'meteo' filesep Model.UseMeteo filesep];
% tana=readTLastAnalyzed(meteodir);
% hm.Models(m).TLastAnalyzed=rounddown(tana,hm.RunInterval/24);
% Model.TLastAnalyzed=hm.Models(m).TLastAnalyzed;

%% Determine restart times
% trststart=-1e9;
% trststart=max(trststart,Model.TWaveOkay); % Model must be spun-up
% trststart=max(trststart,hm.Cycle+hm.RunInterval/24); % Start time of next cycle 
% trststart=min(trststart,Model.TLastAnalyzed); % Restart time no later than last analyzed time in meteo fields

trststart=Model.restartTime;

trststop=trststart;
toutstart=Model.TOutputStart;
dtrst=dtrst*86400;
dt=3600;

%% Write ww3_shel.inp
WriteWW3Shell(inpfile,Model.TWaveStart,toutstart,Model.TStop,dt,trststart,trststop,dtrst,nestrid,x,y);

%% Get meteo data
ii=strmatch(lower(Model.UseMeteo),lower(hm.MeteoNames),'exact');
dt=hm.Meteo(ii).TimeStep;
meteoname=Model.UseMeteo;
meteodir=[hm.ScenarioDir 'meteo' filesep meteoname filesep];
exedir=[hm.MainDir 'exe' filesep];
WriteMeteoFileWW3(meteodir,meteoname,exedir,tmpdir,[0 360],[-90 90],Model.TWaveStart,Model.TStop,dt,Model.UseDtAirSea);

%% Pre and post-processing input files

% % ww3_grid
% writeWW3grid([tmpdir 'ww3_grid.inp']);
% % ww3_prep
% writeWW3prep([tmpdir 'ww3_prep.inp']);

tstart=Model.TWaveStart;
nt=(Model.TStop-tstart)*24+1;
dt=3600;

% ww3_outp

% observations points
ip0=Model.NrStations;
inest=0;
if ip0>0
    writeWW3outp([tmpdir 'ww3_outp_' Model.Runid '.inp'],tstart,dt,nt,2,1:ip0);
    inest=inest+1;
end

% 2d spectra
for i=inest+1:length(nestnames)
    np=length(x{i});
    ipoints=ip0+1:ip0+np;
    writeWW3outp([tmpdir 'ww3_outp_' nestnames{i} '.inp'],tstart,dt,nt,1,ipoints);
    ip0=ip0+np;
end

% ww3_outp
writeWW3gxoutf([tmpdir 'gx_outf.inp'],toutstart,dt,nt);

%% Make batch file
switch lower(Model.RunEnv)
    case{'win32'}
        [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'ww3_grid.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'ww3_prep.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'ww3_shel.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'ww3_outp.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'gx_outf.exe'],tmpdir,'f');
        writeWW3batchWin32([tmpdir 'run.bat'],nestnames,datestr(Model.TWaveStart,'yymmddHH'));
    case{'h4'}
        writeWW3batchH4([tmpdir 'run.sh'],nestnames,datestr(Model.TWaveStart,'yymmddHH'));
end
