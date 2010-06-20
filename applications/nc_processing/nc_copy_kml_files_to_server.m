function nc_copy_kml_files_to_server(OPT)
if OPT.kml_copy2server 
    disp('copying kml files to server...')
    multiWaitbar('kml_copy',0,'label','removing KML files on the server...');
    
    % delete current kml files on the server
    if ~exist(OPT.kml_server,'dir')
        mkpath(OPT.kml_server)
    end
    dir(OPT.kml_server)
    fns = findAllFiles('pattern_incl', [OPT.datatype '*'], 'basepath', OPT.kml_server, 'recursive', false) ; 
    for ii = 1:length(fns)
        try
            if isdir(fullfile(OPT.kml_server,fns{ii}))
                rmdir(fullfile(OPT.kml_server,fns{ii}),'s')
            else
                delete(fullfile(OPT.kml_server,fns{ii}))
            end
        catch
            warning(lasterr)
        end
    end
    
    %% copy the files
    fns = findAllFiles('pattern_excl',{'.localmachine.'}, 'pattern_incl', [OPT.datatype '*'], 'basepath', OPT.kml_path, 'recursive', false) ; 
    for ii = 1:length(fns)
        multiWaitbar('kml_copy',ii/length(fns),'label','copying kml files to the server');
        try
            copyfile(fullfile(OPT.kml_path,fns{ii}),fullfile(fileparts(fileparts(fileparts((OPT.kml_server)))),fns{ii}))
        catch
            warning(lasterr)
        end
    end
    close(OPT.wb)
    disp('copying kml files to server completed')
else
    disp('copying kml files to server is skipped')
end

if OPT.deleteLocalFiles
    disp('deleting local files...')
    try
        if isdir(OPT.netcdf_path)  rmdir(OPT.netcdf_path,'s');   end
        if isdir(OPT.kml_path   )  rmdir(OPT.kml_path,   's');   end
    catch
        warning(lasterr)
    end
    disp('deleting files completed')
else
    disp('deleting files is skipped')
end