warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the roughness file name has been specified (Delft3D)
filergh     = get(handles.edit17,'String');
if isempty(filergh);
    errordlg('The observation points file name has not been specified.','Error');
    return;
end

% Check if the roughness file name has been specified (D-Flow FM)
rghfile     = get(handles.edit24,'String');
if isempty(rghfile);
    errordlg('The roughness sample file name has not been specified.','Error');
    return;
end
if length(rghfile) > 8;
    if strcmp(rghfile(end-7:end),'_rgh.xyz') == 0;
        errordlg('The roughness sample file name has an improper extension.','Error');
        return;
    end
end

% Put the output directory name in the filenames
filergh     = [pathin ,'\',filergh];
rghfile     = [pathout,'\',rghfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_friction_xyz(filegrd,filergh,rghfile);