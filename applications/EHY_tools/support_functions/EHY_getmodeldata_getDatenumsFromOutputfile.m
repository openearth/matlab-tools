function [datenums,varargout] = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile)

modelType = EHY_getModelType(inputFile);
 
switch modelType
    case 'dfm'
        infonc       = ncinfo(inputFile);
        ncVarInd     = strmatch('time',{infonc.Variables.Name},'exact');
        ncAttrInd    = strmatch('units',{infonc.Variables(ncVarInd).Attributes.Name},'exact');
        nr_times     = infonc.Variables(ncVarInd).Size;
        if nr_times<3
            seconds      = ncread(inputFile, 'time');
        else % - to enhance speed, reconstruct time array from start time, numel and interval
            seconds_int  = ncread(inputFile, 'time', 1, 3);
            interval     = seconds_int(3)-seconds_int(2);
            seconds      = [seconds_int(1) seconds_int(2) + interval*[0:nr_times-2] ]';
            seconds(end) = ncread(inputFile, 'time', nr_times, 1); % overwrite, end time could be different when interval is specified
        end
        days         = seconds / (24*60*60);
        attri        = infonc.Variables(ncVarInd).Attributes(ncAttrInd).Value;
        itdate       = attri(15:end);
        datenums     = datenum(itdate, 'yyyy-mm-dd HH:MM:SS')+days;
        varargout{1} = datenum(itdate,'yyyy-mm-dd  HH:MM:SS');
        
    case 'd3d'
        if ~isempty(strfind(inputFile,'mdf'))
            % mdf file
            mdFile=EHY_getMdFile(inputFile);
            [~,name] = fileparts(inputFile);
            [refdate,tunit,tstart,tstop,hisstart,hisstop,mapstart,mapstop,hisint,mapint]=EHY_getTimeInfoFromMdFile(mdFile,modelType);
            if strcmp(name(1:4),'trih')
                datenums = refdate+(hisstart:hisint:hisstop)/1440;
            elseif strcmp(name(1:4),'trim')
                datenums = refdate+(mapstart:mapint:mapstop)/1440;
            end
        elseif ~isempty(strfind(inputFile,'trih'))
            % history output file from simulation
            trih         = qpfopen(inputFile);
            datenums     = qpread(trih,'water level','times');
            datenums     = datenums([true;diff(datenums)>0]); %JV: delete invalid time steps in unfinished D3D simulation
            itdate       = vs_let(trih,'his-const','ITDATE','quiet');
            varargout{1} = datenum([num2str(itdate(1),'%8.8i') '  ' num2str(itdate(2),'%6.6i')], 'yyyymmdd  HHMMSS');   
        elseif ~isempty(strfind(inputFile,'trim'))
            % history output file from simulation
            trim     = qpfopen(inputFile);
            datenums = qpread(trim,'water level','times');
        end
        
    case 'simona'
        sds=qpfopen(inputFile);
        datenums     = qpread(sds,1,'water level (station)','times');
        varargout{1} = waquaio(sds,'','refdate');
        
    case 'sobek3' 
        D        = read_sobeknc(inputFile);
        refdate  = ncreadatt(inputFile, 'time','units');
        datenums = D.time/1000./1440./60. + datenum(refdate(20:end),'yyyy-mm-dd');
    case 'sobek3_new'
        D        = read_sobeknc(inputFile);
        refdate  = ncreadatt(inputFile, 'time','units');
        datenums = D.time/1440./60. + datenum(refdate(15:end),'yyyy-mm-dd  HH:MM:SS');
        
    case 'implic'
        if exist([inputFile filesep 'implic.mat'],'file')
            load([inputFile filesep 'implic.mat']);
            datenums = tmp.times;
        else
            months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
            fileName = [inputFile filesep 'BDSL.dat'];
            fid      = fopen(fileName,'r');
            line     = fgetl(fid);
            line     = fgetl(fid);
            line     = fgetl(fid);
            i_time   = 0;
            while ~feof(fid)
                i_time             = i_time + 1;
                line               = fgetl(fid);
                i_day              = str2num(line(1:2));
                i_month            = find(~cellfun(@isempty,strfind(months,line(4:6))));
                i_year             = str2num(line( 8:11));
                i_hour             = str2num(line(13:14));
                i_min              = str2num(line(16:17));
                datenums (i_time)  = datenum(i_year,i_month,i_day,i_hour,i_min,0);
            end
            
            fclose(fid);
            
        end
        
    case 'delwaq'
        dw = delwaq('open',inputFile);
        datenums = delwaq('read',dw,dw.SubsName{1},1,0);
end
