function [times,values] = EHY_getMapCMEMSData(inputFile,start,count,OPT)
    allFiles   = dir([fileparts(inputFile) filesep OPT.varName '*.nc']);
    fileNames  = char({allFiles(:).name}');
    startTimes = datenum(fileNames(:,end-41:end-26),'yyyy-mm-dd_HH-MM');
    
    if isempty(OPT.t0) && isempty(OPT.tend)
        idFs = 1:length(allFiles);
        OPT.t0 = startTimes(1);
        OPT.tend = startTimes(end)+6;
    else
        idFs = find(startTimes<OPT.t0,1,'last'):find(startTimes>OPT.tend,1,'first');
    end

    values = NaN([OPT.tend-OPT.t0+1,count(2:end)]);
    idT = 1;
    for iF = 1:length(idFs)
        idF = idFs(iF);
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
    if size(values,1) == 1
        values = squeeze(values);
    end
end

