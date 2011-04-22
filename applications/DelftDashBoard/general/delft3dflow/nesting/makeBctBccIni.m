function openBoundaries=makeBctBccIni(option,varargin)
% Generates bct, bcc and ini files

flow=[];
opt=[];
openBoundaries=[];
workdir='';
inpdir='';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'xmlfile','nestxml'}
                nestxml=varargin{i+1};
                opt=readNestXML(nestxml);
        end
    end
end

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'inpdir','inputdir'}
                inpdir=[varargin{i+1} filesep];
            case{'runid'}
                runid=varargin{i+1};
            case{'workdir'}
                workdir=varargin{i+1};
            case{'flow'}
                flow=varargin{i+1};
            case{'openboundaries'}
                openBoundaries=varargin{i+1};
            case{'opt'}
                opt=varargin{i+1};
        end
    end
end

if isempty(flow)
    [flow,openBoundaries]=delft3dflow_readInput(inpdir,runid,varargin);
end

switch lower(option)

    case{'bct'}
        
        %% BCT
        
        % Merge data files
        
        % Water levels
        switch opt.waterLevel.BC.source
            case {2,3}
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_waterlevel.mat'];
                errmsg=mergeOceanModelFiles(opt.waterLevel.BC.datafolder,opt.waterLevel.BC.dataname,outfile,'waterlevel',t0,t1);
                opt.waterLevel.BC.file=outfile;
        end
        % Current
        switch opt.current.BC.source
            case {2,3}
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_current_u.mat'];
                errmsg=mergeOceanModelFiles(opt.current.BC.datafolder,opt.current.BC.dataname,outfile,'current_u',t0,t1);
                opt.current.BC.file_u=outfile;
                outfile=[workdir 'TMPOCEAN_current_v.mat'];
                errmsg=mergeOceanModelFiles(opt.current.BC.datafolder,opt.current.BC.dataname,outfile,'current_v',t0,t1);
                opt.current.BC.file_v=outfile;
        end
        
        openBoundaries=generateBctFile(flow,openBoundaries,opt);
        delft3dflow_saveBctFile(flow,openBoundaries,[inpdir flow.bctFile]);
        
    case{'bcc'}
        
        %% BCC
        
        % Merge data files
        
        % Salinity
        switch opt.salinity.BC.source
            case {2,3}
                % File
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_salinity.mat'];
                errmsg=mergeOceanModelFiles(opt.salinity.BC.datafolder,opt.salinity.BC.dataname,outfile,'salinity',t0,t1);
                opt.salinity.BC.file=outfile;
            case {5}
                % Profile
                opt.salinity.BC.profile=load([opt.salinity.BC.datafolder filesep opt.salinity.BC.dataname]);
        end
        % Temperature
        switch opt.temperature.BC.source
            case {2,3}
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_temperature.mat'];
                errmsg=mergeOceanModelFiles(opt.temperature.BC.datafolder,opt.temperature.BC.dataname,outfile,'temperature',t0,t1);
                opt.temperature.BC.file=outfile;
            case {5}
                % Profile
                opt.temperature.BC.profile=load([opt.temperature.BC.datafolder filesep opt.temperature.BC.dataname]);
        end
        openBoundaries=generateBccFile(flow,openBoundaries,opt);
        delft3dflow_saveBccFile(flow,openBoundaries,[inpdir flow.bccFile]);
        
    case{'ini'}
        
        %% INI
        
        % Merge data files
        
        % Water levels
        switch opt.waterLevel.IC.source
            case {2,3}
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_waterlevel.mat'];
                errmsg=mergeOceanModelFiles(opt.waterLevel.IC.datafolder,opt.waterLevel.IC.dataname,outfile,'waterlevel',t0,t1);
                opt.waterLevel.IC.file=outfile;
        end
        % Current
        switch opt.current.IC.source
            case {2,3}
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_current_u.mat'];
                errmsg=mergeOceanModelFiles(opt.current.IC.datafolder,opt.current.IC.dataname,outfile,'current_u',t0,t1);
                opt.current.IC.file_u=outfile;
                outfile=[workdir 'TMPOCEAN_current_v.mat'];
                errmsg=mergeOceanModelFiles(opt.current.IC.datafolder,opt.current.IC.dataname,outfile,'current_v',t0,t1);
                opt.current.IC.file_v=outfile;
        end
        % Salinity
        switch opt.salinity.IC.source
            case {2,3}
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_salinity.mat'];
                errmsg=mergeOceanModelFiles(opt.salinity.IC.datafolder,opt.salinity.IC.dataname,outfile,'salinity',t0,t1);
                opt.salinity.IC.file=outfile;
            case {5}
                % Profile
                opt.salinity.IC.profile=load([opt.salinity.IC.datafolder filesep opt.salinity.IC.dataname]);
        end
        % Temperature
        switch opt.temperature.IC.source
            case {2,3}
                t0=flow.startTime;
                t1=flow.stopTime;
                outfile=[workdir 'TMPOCEAN_temperature.mat'];
                errmsg=mergeOceanModelFiles(opt.temperature.IC.datafolder,opt.temperature.IC.dataname,outfile,'temperature',t0,t1);
                opt.temperature.IC.file=outfile;
            case {5}
                % Profile
                opt.temperature.IC.profile=load([opt.temperature.IC.datafolder filesep opt.temperature.IC.dataname]);
        end
        
        generateIniFile(flow,opt,[inpdir flow.iniFile]);
        
end

if exist([workdir 'TMPOCEAN_waterlevel.mat'],'file')
    delete([workdir 'TMPOCEAN_waterlevel.mat']);
end
if exist([workdir 'TMPOCEAN_current_u.mat'],'file')
    delete([workdir 'TMPOCEAN_current_u.mat']);
end
if exist([workdir 'TMPOCEAN_current_v.mat'],'file')
    delete([workdir 'TMPOCEAN_current_v.mat']);
end
if exist([workdir 'TMPOCEAN_salinity.mat'],'file')
    delete([workdir 'TMPOCEAN_salinity.mat']);
end
if exist([workdir 'TMPOCEAN_temperature.mat'],'file')
    delete([workdir 'TMPOCEAN_temperature.mat']);
end
