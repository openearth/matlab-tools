function runTimeInfo=EHY_getRunTimeInfo(mdFile)
% runTimeInfo=EHY_getRunTimeInfo(mdFile)
% mdFile should be a .mdf or .mdu file of a finished simulation
%
% Example: EHY_getRunTimeInfo('D:\Noordzee.mdu')
%
% created by Julien Groenenboom, March 2017
modelType=nesthd_det_filetype(mdFile);
[pathstr,name,ext]=fileparts(mdFile);
switch modelType
    case 'mdu'
        mdu=dflowfm_io_mdu('read',mdFile);
        runTimeInfo.mduInfo=mdu.time;
        
        % DIA - runtime
        if exist([pathstr filesep name '_0000.dia'],'file') % first check if run was done in parallel
            diaFile=[pathstr filesep name '_0000.dia'];
        else %  not in parallel - use out.txt file
            diaFile=[pathstr filesep 'out.txt'];
        end
        fid=fopen(diaFile,'r');
        
        % simulation period
        line=findLineOrQuit(fid,'** INFO   : simulation period     (s)  :');
        line2=strsplit(line);
        runTimeInfo.simPeriod_S=str2double(line2{end});
        
        % average timestep
        line=findLineOrQuit(fid,'** INFO   : average timestep      (s)  :');
        line2=strsplit(line);
        runTimeInfo.aveTimeStep_S=str2double(line2{end});
        
        % time steps
        line=findLineOrQuit(fid,'** INFO   : time steps            (s)  :');
        line2=strsplit(line);
        runTimeInfo.realTime_S=str2double(line2{end});
        
    case 'mdf'
        mdf=delft3d_io_mdf('read',mdFile);
        
        % diag - runtime
        if exist([pathstr filesep 'tri-diag.' name ],'file') % first check if run was done in parallel
            diaFile=[pathstr filesep 'tri-diag.' name ];
        else %  not in parallel
            diaFile=[pathstr filesep 'tri-diag.' name '-001'];
        end
        
        fid=fopen(diaFile,'r');
        line=findLineOrQuit(fid,'|Total                |');
        line2=strsplit(line);
        runTimeInfo.realTime_S=str2double(line2{3});
        
        % simulation period
        dt=mdf.keywords.tstop-mdf.keywords.tstart
        if strcmp(mdf.keywords.tunit,'S')
            runTimeInfo.simPeriod_S=dt;
        elseif strcmp(mdf.keywords.tunit,'M')
            runTimeInfo.simPeriod_S=dt*60;
        elseif strcmp(mdf.keywords.tunit,'H')
            runTimeInfo.simPeriod_S=dt*3600;
        end
end

% runtime
runTimeInfo.simPeriod_M=runTimeInfo.simPeriod_S/60;
runTimeInfo.simPeriod_H=runTimeInfo.simPeriod_S/3600;
runTimeInfo.simPeriod_D=runTimeInfo.simPeriod_H/24;
% simulation period
runTimeInfo.realTime_M=runTimeInfo.realTime_S/60;
runTimeInfo.realTime_H=runTimeInfo.realTime_S/3600;
runTimeInfo.realTime_D=runTimeInfo.realTime_H/24;
% computational time
runTimeInfo.compTime_minPerDay=(runTimeInfo.realTime_S/60)/(runTimeInfo.simPeriod_S/3600/24);
runTimeInfo.compTime_dayPerYear=runTimeInfo.compTime_minPerDay/60/24*365;
end

function line=findLineOrQuit(fid,wantedLine)
line=fgetl(fid);
while isempty(strfind(line,wantedLine)) && ischar(line)
    line=fgetl(fid);
end

if ~ischar(line) && line==-1
    error('Run has probably not finished yet or crashed')
end
end
