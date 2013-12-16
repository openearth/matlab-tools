warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the initial conditions file name has been specified (Delft3D)
fileini     = get(handles.edit21,'String');
if ~isempty(fileini);
    fileini = [pathin,'\',fileini];
    if exist(fileini,'file')==0;
        errordlg('The specified initial conditions file does not exist.','Error');
        set(handles.edit28,'String','');
        break;
    end
else
    errordlg('The initial conditions file name has not been specified.','Error');
    set(handles.edit28,'String','');
    break;
end

% Check if the viscosity file name has been specified (D-Flow FM)
inifile     = get(handles.edit28,'String');
if isempty(inifile);
    errordlg('The initial conditions sample file name has not been specified.','Error');
    return;
end
if length(inifile) > 8;
    if strcmp(inifile(end-7:end),'_ini.xyz') == 0;
        errordlg('The initial conditions sample file name has an improper extension.','Error');
        return;
    end
end

% Put the output directory name in the filenames
inifile     = [pathout,'\',inifile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_initial_xyz(filegrd,fileini,inifile);