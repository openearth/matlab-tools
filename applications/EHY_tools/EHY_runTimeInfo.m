function runTimeInfo=EHY_runTimeInfo(varargin)
%% runTimeInfo=EHY_runTimeInfo(varargin)
%
% Based on an D-FLOW FM, Delft3D or SIMONA input file (.mdu / .mdf /
% siminp) the simulation period, calculation time and corresponding
% computational time is computed.
%
% Example1: EHY_runTimeInfo
% Example2: runTimeInfo=EHY_runTimeInfo('D:\model.mdu')
%
% created by Julien Groenenboom, March 2017

%%
if nargin>0
    mdFile=varargin{1};
else
    [filename, pathname]=uigetfile('*.*','Open a .mdu / .mdf / siminp file');
    mdFile=[pathname filename];
end
modelType=nesthd_det_filetype(mdFile);
[pathstr,name,ext]=fileparts(mdFile);

switch modelType
    case 'mdu'
        mdu=dflowfm_io_mdu('read',mdFile);
        runTimeInfo.mduInfo=mdu.time;
        
        % startDate
        RefDateNum=datenum(num2str(mdu.time.RefDate),'yyyymmdd');
        if strcmpi(mdu.time.Tunit,'S')
            factor=60*60*24;
        elseif strcmpi(mdu.time.Tunit,'M')
            factor=60*24;
        elseif strcmpi(mdu.time.Tunit,'H')
            factor=24;
        else
            error('Tunit has to be H, M or S')
        end
        startDate=RefDateNum+mdu.time.TStart/factor;
        
        % simPeriod_S
        line=findLineOrQuit(fid,'** INFO   : simulation period     (s)  :');
        line2=strsplit(line);
        simPeriod_S=str2double(line2{end});
        
        try % if simulation has finished
            % dia
            if exist([pathstr filesep name '_0000.dia'],'file') % first check if run was done in parallel
                diaFile=[pathstr filesep name '_0000.dia'];
            else %  not in parallel - use out.txt file
                diaFile=[pathstr filesep 'out.txt'];
            end
            fid=fopen(diaFile,'r');
            
            % average timestep
            line=findLineOrQuit(fid,'** INFO   : average timestep      (s)  :');
            line2=strsplit(line);
            runTimeInfo.aveTimeStep_S=str2double(line2{end});
            
            % realTime_S
            line=findLineOrQuit(fid,'** INFO   : time steps            (s)  :');
            line2=strsplit(line);
            realTime_S=str2double(line2{end});
        end
    case 'mdf'
        mdf=delft3d_io_mdf('read',mdFile);
        
        % startDate
        RefDateNum=datenum(mdf.keywords.itdate,'yyyy-mm-dd');
        if strcmpi(mdf.keywords.tunit,'S')
            factor=60*60*24;
        elseif strcmpi(mdf.keywords.tunit,'M')
            factor=60*24;
        elseif strcmpi(mdf.keywords.tunit,'H')
            factor=24;
        else
            error('Tunit has to be H, M or S')
        end
        startDate=RefDateNum+mdf.keywords.tstart/factor;
        
        % simPeriod_S
        factor=(60*60*24)/factor;
        simPeriod_S=(mdf.keywords.tstop-mdf.keywords.tstart)*factor;
        
        try % if simulation has finished
            % dia
            if exist([pathstr filesep 'tri-diag.' name ],'file') % first check if run was done in parallel
                diaFile=[pathstr filesep 'tri-diag.' name ];
            else %  not in parallel
                diaFile=[pathstr filesep 'tri-diag.' name '-001'];
            end
            fid=fopen(diaFile,'r');
            
            % realTime_S
            line=findLineOrQuit(fid,'|Total                |');
            line2=strsplit(line);
            realTime_S=str2double(line2{3});
        end
    case 'siminp'
        % startDate
        siminp=readsiminp(pathstr,[name ext]);
        ind=strmatch('DATE',siminp.File);
        [~,refDate]=strtok(siminp.File{ind},'''');
        refDate=datestr(datenum(lower(refDate))); % make it matlab style
        ind=strmatch('TSTART',siminp.File);
        [~,TStart]=strtok(siminp.File{ind},' ');
        startDate=datestr(datenum(refDate)+str2num(TStart)/60/24);
        
        % simPeriod_S
        ind=strmatch('TSTOP',siminp.File);
        [~,TStop]=strtok(siminp.File{ind},' ');
        simPeriod_S=(str2num(TStop)-str2num(TStart))*60;
        
        try % if simulation has finished
            % dia
            directory=dir([pathstr filesep 'waqpro-m*']);
            diaFile=[pathstr filesep directory(1).name];
            fid=fopen(diaFile,'r');
            
            % realTime_S
            line=findLineOrQuit(fid,'Simulation started at date:');
            line2=strsplit(line);
            t0=datenum([line2{8} line2{10}],'yyyymmddHHMMSS');
            line=findLineOrQuit(fid,'Simulation ended   at date:');
            line2=strsplit(line);
            tend=datenum([line2{8} line2{10}],'yyyymmddHHMMSS')
            realTime_S=(tend-t0)*24*60*60;
        end
end
fclose all
%% Store all data in struct
% simulation period
runTimeInfo.startDate=datestr(startDate);
runTimeInfo.endDate=datestr(datenum(startDate)+simPeriod_S/3600/24);

runTimeInfo.simPeriod_S=simPeriod_S;
runTimeInfo.simPeriod_M=runTimeInfo.simPeriod_S/60;
runTimeInfo.simPeriod_H=runTimeInfo.simPeriod_S/3600;
runTimeInfo.simPeriod_D=runTimeInfo.simPeriod_H/24;

if exist('realTime_S','var') % if simulation has finished
    % runtime
    runTimeInfo.realTime_S=realTime_S;
    runTimeInfo.realTime_M=runTimeInfo.realTime_S/60;
    runTimeInfo.realTime_H=runTimeInfo.realTime_S/3600;
    runTimeInfo.realTime_D=runTimeInfo.realTime_H/24;
    
    % computational time
    runTimeInfo.compTime_minPerDay=(runTimeInfo.realTime_S/60)/(runTimeInfo.simPeriod_S/3600/24);
    runTimeInfo.compTime_dayPerYear=runTimeInfo.compTime_minPerDay/60/24*365;
else
    runTimeInfo.comment='Simulation has probably not finished yet or crashed'
end
end
%%
function line=findLineOrQuit(fid,wantedLine)
line=fgetl(fid);
while isempty(strfind(line,wantedLine)) && ischar(line)
    line=fgetl(fid);
end

if ~ischar(line) && line==-1
    error('Run has probably not finished yet or crashed')
end
end
