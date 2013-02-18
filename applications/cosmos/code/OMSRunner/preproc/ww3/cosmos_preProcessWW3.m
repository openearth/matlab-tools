function cosmos_preProcessWW3(hm,m)

model=hm.models(m);
dr=model.dir;
tmpdir=hm.tempDir;

%% Get restart file
trst1=[];
zipfilename=[dr 'restart' filesep model.waveRstFile '.zip'];
if exist(zipfilename,'file')
    trst1=model.tWaveStart;
    [success,message,messageid]=copyfile(zipfilename,tmpdir,'f');
end

%% Get nest file
if model.waveNested
    nr=model.waveNestNr;
    mm=model.waveNestModelNr;
    outputdir=[hm.models(mm).dir 'archive' hm.cycStr filesep 'output' filesep];
    fname=[outputdir 'nest' num2str(nr) '.ww3'];
    if exist(fname,'file')
        [success,message,messageid]=copyfile(fname,[tmpdir 'nest.ww3'],'f');
    end
end

%% Get output locations
[nestrid,nestnames,x,y]=cosmos_getWW3outputPoints(hm,m);

%% Get start and stop times
inpfile=[hm.tempDir 'ww3_shel.inp'];
dtrst=hm.runInterval/24;

trststart=model.restartTime;

trststop=trststart;
toutstart=model.tOutputStart;
dtrst=dtrst*86400;
dt=3600;

%% Write ww3_shel.inp
WriteWW3Shell(inpfile,model.tWaveStart,toutstart,model.tStop,dt,trststart,trststop,dtrst,nestrid,x,y);

%% Get meteo data
ii=strmatch(lower(model.useMeteo),lower(hm.meteoNames),'exact');
dt=hm.meteo(ii).timeStep;
meteoname=model.useMeteo;
meteodir=[hm.scenarioDir 'meteo' filesep meteoname filesep];

[lon,lat]=WriteMeteoFileWW3(meteodir,meteoname,tmpdir,model.xLim,model.yLim,model.tWaveStart,model.tStop,dt,model.useDtAirSea);
writeWW3_prepWind([tmpdir 'ww3_prep.inp'],lon,lat);

%% Pre and post-processing input files

% % ww3_grid
% writeWW3grid([tmpdir 'ww3_grid.inp']);

tstart=model.tWaveStart;
nt=(model.tStop-tstart)*24+1;
dt=3600;

% ww3_outp

% observations points

ip0=model.nrStations;

inest=0;
if ip0>0
    % Table output (wave statistics)
    writeWW3outp([tmpdir 'ww3_outp_' model.name '.inp'],tstart,dt,nt,2,1:ip0);
    % 2D Spectra output
    writeWW3outp([tmpdir 'ww3_outp_' model.name '_sp2.inp'],tstart,dt,nt,1,1:ip0);
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
switch lower(model.runEnv)
    case{'win32'}
        [success,message,messageid]=copyfile([hm.exeDir 'ww3_grid.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.exeDir 'ww3_prep.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.exeDir 'ww3_shel.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.exeDir 'ww3_outp.exe'],tmpdir,'f');
        [success,message,messageid]=copyfile([hm.exeDir 'gx_outf.exe'],tmpdir,'f');
        writeWW3batchWin32([tmpdir 'run.bat'],nestnames,datestr(model.tWaveStart,'yymmddHH'));
    case{'h4'}
        writeWW3batchH4([tmpdir 'run.sh'],nestnames,datestr(model.tWaveStart,'yymmddHH'),trst1,trststart);
end
