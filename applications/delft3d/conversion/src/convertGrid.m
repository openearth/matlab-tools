warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the input is correct
if ~isempty(filedep);
    filedep = [pathin,'\',filedep];
    if exist(filedep,'file')==0;
        errordlg('The specified dep-file does not exist in the specified input directory.','Error');
        break;
    end
end

% Check if the netcdf file name has been specified
filenetcdf  = get(handles.edit8,'String');
if isempty(filenetcdf);
    errordlg('The netcdf file name has not been specified.','Error');
    break;
end
if length(filenetcdf) > 7;
    if strcmp(filenetcdf(end-6:end),'_net.nc') == 0;
        errordlg('The netcdf file name has an improper extension.','Error');
        break;
    end
end

% Check if the bedlevel sample file has been specified
filebedsam  = get(handles.edit30,'String');
if isempty(filebedsam);
    errordlg('The bedlevel sample file name has not been specified.','Error');
    break;
end
if length(filebedsam) > 8;
    if strcmp(filebedsam(end-7:end),'_bed.xyz') == 0;
        errordlg('The bedlevel sample file name has an improper extension.','Error');
        break;
    end
end

% Put the output directory name in the filenames
filenetcdf  = [pathout,'\',filenetcdf];
filebedsam  = [pathout,'\',filebedsam];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_grd2net(filegrd,filedep,filenetcdf,filebedsam);
fclose all;