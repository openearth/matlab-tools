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
        
        tunit='M';
        
        for var={'date','tstart','tstop'}
            ind1=find(~cellfun(@isempty,strfind(lower(siminp.File),var{1})));
            ind2=regexp(lower(siminp.File{ind1}),var{1})+length(var{1});
            if strcmp(var{1},'date')
                refdate=datenum(strtrim(siminp.File{ind1}(ind2:end)));
            else
                eval([var{1} '=str2double(siminp.File{ind1}(ind2:end));'])
            end
        end
end




