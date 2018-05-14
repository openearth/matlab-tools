function [refdate,tunit,tstart,tstop,hisstart,hisstop,mapstart,mapstop]=getTimeInfoFromMdFile(mdFile)
% refdate       : Reference date in MATLAB's datenum
% tunit         : Time unit of tstart and tstop (e.g. 'S' , 'M')
% tstart        : Start time of simulation w.r.t. refdate (in tunit)
% tstop         : Stop time of simulation w.r.t. refdate (in tunit)
% hisstart      : Start time of writing history output (in minutes)
% hisstop       : Stop time of writing history output (in minutes)
% mapstart      : Start time of writing map output (in minutes)
% mapstop       : Stop time of writing map output (in minutes)
% mdFile        : Master definition file (*.mdf, *.mdu, *siminp*)
%
% support function of the EHY_tools, Julien.Groenenboom@deltares.nl

[modelType,mdFile]=EHY_getModelType(mdFile);

switch modelType
    case 'mdu'
        mdu=dflowfm_io_mdu('read',mdFile);
        refdate=datenum(num2str(mdu.time.RefDate),'yyyymmdd');
        tunit=mdu.time.Tunit;
        tstart=mdu.time.TStart;
        tstop=mdu.time.TStop;
        if length(mdu.output.HisInterval)==1 % only interval of his file
            hisstart=tstart;
            hisstop=tstop;
        else % his start stop, all in seconds
            hisstart=mdu.output.HisInterval(2)*timeFactor('S','M');
            hisstop=mdu.output.HisInterval(3)*timeFactor('S','M');
        end
        if length(mdu.output.MapInterval)==1 % only interval of his file
            mapstart=tstart;
            mapstop=tstop;
        else % his start stop, all in seconds
            mapstart=mdu.output.MapInterval(2)*timeFactor('S','M');
            mapstop=mdu.output.MapInterval(3)*timeFactor('S','M');
        end
    case 'mdf'
        mdf=delft3d_io_mdf('read',mdFile);
        refdate=datenum(mdf.keywords.itdate,'yyyy-mm-dd');
        tunit=mdf.keywords.tunit;
        tstart=mdf.keywords.tstart;
        tstop=mdf.keywords.tstop;
        hisstart=mdf.keywords.flhis(1);
        hisstop=mdf.keywords.flhis(3);
        mapstart=mdf.keywords.flmap(1);
        mapstop=mdf.keywords.flmap(3);
    case 'siminp'
        [pathstr,name,ext]=fileparts(mdFile);
        siminp=readsiminp(pathstr,[name ext]);
        
        tunit='M';
        
        for var={'date','tstart','tstop'}
            ind1=find(~cellfun(@isempty,strfind(lower(siminp.File),var{1})));
            ind2=regexp(lower(siminp.File{ind1}),var{1})+length(var{1});
            dmy=regexp(siminp.File{ind1}(ind2:end),'\s+','split');
            if strcmp(var{1},'date')
                refdate=datenum(strtrim(sprintf('%s ',dmy{2:4})));
            else
                eval([var{1} '=str2double(dmy(2));'])
            end
        end
        
        vars={'tfhis'   ,'tlhis'  ,'tfmap'   ,'tlmap';,...
            'hisstart','hisstop','mapstart','mapstop'};
        for iVar=1:length(vars)
            ind1=find(~cellfun(@isempty,strfind(lower(siminp.File),vars{1,iVar})));
            if ~isempty(ind1)
                ind2=regexp(lower(siminp.File{ind1}),vars{1,iVar})+length(vars{1,iVar});
                dmy=regexp(siminp.File{ind1}(ind2:end),'\s+','split');
                eval([vars{2,iVar} '=str2double(dmy(2));'])
            else
                eval([vars{2,iVar} '=t' vars{2,iVar}(4:end) ';'])
            end
        end
end




