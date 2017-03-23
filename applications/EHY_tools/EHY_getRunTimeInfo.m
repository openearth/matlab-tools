function runTimeInfo=EHY_getRunTimeInfo(mdFile)
% runTimeInfo=EHY_getRunTimeInfo(mdFile)
% mdFile should be a .mdf or .mdu file of a finished simulation
% 
% Example: EHY_getRunTimeInfo('D:\Noordzee.mdu')
% 
% created by Julien Groenenboom, March 2017
modelType=EHY_getModelType(mdFile);
[pathstr,name,ext]=fileparts(mdFile);
switch modelType
    case 'dfm'
        mdu=dflowfm_io_mdu('read',mdFile);
        runTimeInfo.mduInfo=mdu.time;
        
        % DIA - runtime
        if exist([pathstr filesep name '_0000.dia'],'file') % first check if run was done in parallel
            diaFile=[pathstr filesep name '_0000.dia'];
        else %  not in parallel - use out.txt file
            diaFile=[pathstr filesep 'out.txt'];
        end
        fid=fopen(diaFile,'r');
        line=fgetl(fid);
        
        % simulation period
        while isempty(strfind(line,'** INFO   : simulation period     (s)  :')   )
            line=fgetl(fid);
        end
        line2=strsplit(line);
        runTimeInfo.simPeriod_S=str2double(line2{end});
        
        
        % average timestep
        while isempty(strfind(line,'** INFO   : average timestep      (s)  :')   )
            line=fgetl(fid);
        end
        line2=strsplit(line);
        runTimeInfo.aveTimeStep_S=str2double(line2{end});
        
        % time steps
        while isempty(strfind(line,'** INFO   : time steps            (s)  :')   )
            line=fgetl(fid);
        end
        line2=strsplit(line);
        runTimeInfo.realTime_S=str2double(line2{end});

    case 'd3d'
        mdf=delft3d_io_mdf('read',mdFile);
        
        % diag - runtime
          if exist([pathstr filesep 'tri-diag.' name ],'file') % first check if run was done in parallel
            diaFile=[pathstr filesep 'tri-diag.' name ];
        else %  not in parallel - use out.txt file
            error('tri-diag not found')
        end
        fid=fopen(diaFile,'r');
        line=fgetl(fid);
        
        while isempty(strfind(line,'|Total                |')   )
            line=fgetl(fid);
        end
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
runTimeInfo.simPeriod_H=runTimeInfo.simPeriod_S/3600;
runTimeInfo.simPeriod_D=runTimeInfo.simPeriod_H/24;
% simulation period
runTimeInfo.realTime_H=runTimeInfo.realTime_S/3600;
runTimeInfo.realTime_D=runTimeInfo.realTime_H/24;
% computational time
runTimeInfo.compTime_minPerDay=(runTimeInfo.realTime_S/60)/(runTimeInfo.simPeriod_S/3600/24);
runTimeInfo.compTime_dayPerYear=runTimeInfo.compTime_minPerDay/60/24*365;