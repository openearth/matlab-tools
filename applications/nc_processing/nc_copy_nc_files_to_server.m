function nc_copy_nc_files_to_server(OPT)
if OPT.nc_copy2server
    % feedback
    disp('copying nc files to server...')
    OPT.wb = waitbar(0, 'initializing file copying...');
    
    % delete current nc files
    try
        delete([OPT.netcdf_server '*.nc'])
    catch
        warning(lasterr)
    end
    
    if ~exist(OPT.netcdf_server,'dir')
        mkpath(OPT.netcdf_server)
    end
    
    % determine total scope of work
    fns  = dir([OPT.netcdf_path '*.nc']);
    OPT.WBbytesToDo = 0;
    OPT.WBbytesDone = 0;
    for kk = 1:size(fns,1)
        OPT.WBbytesToDo = OPT.WBbytesToDo+fns(kk).bytes;
    end
    
    % copy files
    for kk = 1:length(fns)
        waitbar(OPT.WBbytesDone/OPT.WBbytesToDo,OPT.wb,sprintf('copying %s...',mktex(fns(kk).name)));
        try
            copyfile(fullfile(OPT.netcdf_path,fns(kk).name),fullfile(OPT.netcdf_server,fns(kk).name));
        catch
            warning(lasterr)
        end
        OPT.WBbytesDone = OPT.WBbytesDone + fns(kk).bytes;
    end
    close(OPT.wb)
    disp('copying nc files to server completed')
else
    disp('copying nc files to server is skipped')
end