warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the dry points file name has been specified (Delft3D)
filedry     = get(handles.edit19,'String');
nodry       = 0;
if ~isempty(filedry);
    filedry = [pathin,'\',filedry];
    if exist(filedry,'file')==0;
        errordlg('The specified dry points file does not exist.','Error');
        set(handles.edit27,'String','');
        break;
    end
else
    nodry = 1;
end

% Check if the thin dams file name has been specified (Delft3D)
filethd     = get(handles.edit20,'String');
nothd       = 0;
if ~isempty(filethd);
    filethd = [pathin,'\',filethd];
    if exist(filethd,'file')==0;
        errordlg('The specified thin dams file does not exist.','Error');
        set(handles.edit27,'String','');
        break;
    end
else
    nothd = 1;
end

% Check if 
if nodry == 1 & nothd == 1;
    errordlg('Neither a dry points file nor a thin dams file has not been specified.','Error');
    set(handles.edit27,'String','');
    break;
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
thdfile     = [pathout,'\',thdfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_thd_xyz(filegrd,filedry,filethd,thdfile);