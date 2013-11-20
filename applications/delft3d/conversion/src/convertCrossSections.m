warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the cross-sections file name has been specified (Delft3D)
filecrs     = get(handles.edit16,'String');
if isempty(filecrs);
    errordlg('The cross-sections file name has not been specified.','Error');
    return;
end

% Check if the cross-sections file name has been specified (D-Flow FM)
crsfile     = get(handles.edit31,'String');
if isempty(crsfile);
    errordlg('The cross-sections polyline file name has not been specified.','Error');
    return;
end
if length(crsfile) > 8;
    if strcmp(crsfile(end-7:end),'_crs.pli') == 0;
        errordlg('The ocross-sections polyline file name has an improper extension.','Error');
        return;
    end
end

% Put the output directory name in the filenames
filecrs     = [pathin ,'\',filecrs];
crsfile     = [pathout,'\',crsfile];


%%% ACTUAL CONVERSION OF THE GRID

dflowfm_io_crs('write',filegrd,filecrs,crsfile);