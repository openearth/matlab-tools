warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the dry points file name has been specified (Delft3D)
filedry     = get(handles.edit19,'String');
if isempty(filedry);
    errordlg('The dry points file name has not been specified.','Error');
    return;
end

% Check if the thin dams file name has been specified (Delft3D)
filethd     = get(handles.edit20,'String');
if isempty(filethd);
    errordlg('The thin dams file name has not been specified.','Error');
    return;
end

% Check if the dry points file name has been specified (D-Flow FM)
dryfile     = get(handles.edit26,'String');
if isempty(dryfile);
    errordlg('The dry points file name has not been specified.','Error');
    return;
end
if length(dryfile) > 8;
    if strcmp(dryfile(end-7:end),'_dry.xyz') == 0;
        errordlg('The dry points file name has an improper extension.','Error');
        return;
    end
end

% Check if the thin dams file name has been specified (D-Flow FM)
thdfile     = get(handles.edit27,'String');
if isempty(thdfile);
    errordlg('The thin dams file name has not been specified.','Error');
    return;
end
if length(thdfile) > 8;
    if strcmp(thdfile(end-7:end),'_thd.pli') == 0;
        errordlg('The thin dams file name has an improper extension.','Error');
        return;
    end
end

% Put the output directory name in the filenames
filedry     = [pathin ,'\',filedry];
filethd     = [pathin ,'\',filethd];
dryfile     = [pathout,'\',dryfile];
thdfile     = [pathout,'\',thdfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_thd_xyz(filegrd,filedry,filethd,thdfile);