function datenums=EHY_getmodeldata_getDatenumsFromOutputfile(inputFile)

modelType=EHY_getModelType(inputFile);

switch modelType
    case 'dfm'
        infonc      = ncinfo(inputFile);
        
        % - to enhance speed, reconstruct time array from start time, numel and interval
        ncVarInd    = strmatch('time',{infonc.Variables.Name},'exact');
        ncAttrInd    = strmatch('units',{infonc.Variables(ncVarInd).Attributes.Name},'exact');
        nr_times    = infonc.Variables(ncVarInd).Size;
        seconds_int = ncread(inputFile, 'time', 1, 3);
        interval    = seconds_int(3)-seconds_int(2);
        seconds     = [seconds_int(1) seconds_int(2) + interval*[0:nr_times-2] ]';
        days        = seconds / (24*60*60);
        attri       = infonc.Variables(ncVarInd).Attributes(ncAttrInd).Value;
        itdate      = attri(15:end);
        datenums    = datenum(itdate, 'yyyy-mm-dd HH:MM:SS')+days;
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
            trih     = qpfopen(inputFile);
            datenums = qpread(trih,'water level','times');
        end
    case 'simona'
        sds=qpfopen(inputFile);
        datenums = qpread(sds,1,'water level (station)','times');
end

