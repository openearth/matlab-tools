function [refdate,tunit,tstart,tstop]=getTimeInfoFromMdFile(mdFile)

modelType=nesthd_det_filetype(mdFile);

switch modelType
    case 'mdu'
        mdu=dflowfm_io_mdu('read',mdFile);
        refdate=datenum(num2str(mdu.time.RefDate),'yyyymmdd');
        tunit=mdu.time.Tunit;
        tstart=mdu.time.TStart;
        tstop=mdu.time.TStop;
    case 'mdf'
        mdf=delft3d_io_mdf('read',mdFile);
        refdate=datenum(mdf.keywords.itdate,'yyyy-mm-dd');
        tunit=mdf.keywords.tunit;
        tstart=mdf.keywords.tstart;
        tstop=mdf.keywords.tstop;
    case 'siminp'
        [pathstr,name,ext]=fileparts(mdFile);
        siminp=readsiminp(pathstr,[name ext]);
        try % if DATE, TSTART and TSTOP are on separate lines
            ind=strmatch('DATE',siminp.File);
            [~,refdate]=strtok(siminp.File{ind},'''');
            refdate=datenum(refdate);
            % lets see if it TSTART,was on same line as DATE
            if ~isempty(findstr('tstart',lower(refdate)))
                error;
            end
            tunit='M';
            ind=strmatch('TSTART',siminp.File);
            [~,tstart]=strtok(siminp.File{ind},' ');
            tstart=str2double(tstart); %deal with .00
            ind=strmatch('TSTOP',siminp.File);
            [~,tstop]=strtok(siminp.File{ind},' ');
            tstop=str2double(tstop); %deal with .00
        catch % if DATE, TSTART and TSTOP are NOT on separate lines
            ind=strmatch('DATE',siminp.File);
            split=strsplit(siminp.File{ind});
            indDate=strmatch('date',lower(split),'exact');
            indStart=strmatch('tstart',lower(split),'exact');
            indStop=strmatch('tstop',lower(split),'exact');
            refdate=datenum(lower(strjoin(split(indDate+1:indStart-1))));
            tunit='M';
            tstart=str2double(split{indStart+1}); %deal with .00
            tstop=str2double(split{indStop+1}); %deal with .00
        end
end



