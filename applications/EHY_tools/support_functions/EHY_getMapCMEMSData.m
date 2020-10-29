function [times,values] = EHY_getMapCMEMSData(inputFile,start,count,OPT)
    allFiles   = dir([fileparts(inputFile) filesep OPT.varName '*.nc']);
    fileNames  = char({allFiles(:).name}');
    startTimes = datenum(fileNames(:,end-41:end-26),'yyyy-mm-dd_HH-MM');
    
    idF = find(startTimes>=OPT.t0 & startTimes<=OPT.tend);
    if isempty(idF)
        idF = find(startTimes<OPT.t0,1,'last');
    elseif startTimes(idF(1))>OPT.t0
        idF = [idF(1)-1;idF];
    end
    values = NaN([OPT.tend-OPT.t0+1,count(2:end)]);
    idT = 1;
    for iF = idF'
        tic
        tmp    = nc_varget([allFiles(iF).folder filesep allFiles(iF).name],OPT.varName,start-1,[7 count(2:end)]);
        times  = nc_cf_time([allFiles(iF).folder filesep allFiles(iF).name]);
        idKeep = times>=OPT.t0 & times<=OPT.tend;
        values(idT:idT+sum(idKeep)-1,:,:,:) = tmp(idKeep,:,:,:);
        idT = idT+sum(idKeep);
        if OPT.disp
            disp(['Finished reading CMEMS data ' num2str(find(idF==iF),'%03.f') '/' num2str(length(idF),'%03.f') ' (' datestr(min(times(idKeep)),'yyyy-mm-dd') ' till ' datestr(max(times(idKeep)),'yyyy-mm-dd') ') in ' num2str(toc,'%.2f') 's']);
        end
    end
    times  = OPT.t0:1:OPT.tend;
    values = flipud(squeeze(values));
end

