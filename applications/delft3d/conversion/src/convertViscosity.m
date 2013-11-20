warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the viscosity file name has been specified (Delft3D)
fileedy     = get(handles.edit18,'String');
if isempty(fileedy);
    errordlg('The eddy viscosity file name has not been specified.','Error');
    return;
end

% Check if the viscosity file name has been specified (D-Flow FM)
edyfile     = get(handles.edit25,'String');
if isempty(edyfile);
    errordlg('The eddy viscosity sample file name has not been specified.','Error');
    return;
end
if length(edyfile) > 8;
    if strcmp(edyfile(end-7:end),'_edy.xyz') == 0;
        errordlg('The eddy viscosity sample file name has an improper extension.','Error');
        return;
    end
end

% Put the output directory name in the filenames
fileedy     = [pathin ,'\',fileedy];
edyfile     = [pathout,'\',edyfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_viscosity_xyz(filegrd,fileedy,edyfile);