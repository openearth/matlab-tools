warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the observation file name has been specified (Delft3D)
filesta     = get(handles.edit15,'String');
if isempty(filesta);
    errordlg('The observation points file name has not been specified.','Error');
    return;
end

% Check if the observation file name has been specified (D-Flow FM)
obsfile     = get(handles.edit22,'String');
if isempty(obsfile);
    errordlg('The observation points sample file name has not been specified.','Error');
    return;
end
if length(obsfile) > 8;
    if strcmp(obsfile(end-7:end),'_obs.xyn') == 0;
        errordlg('The observation points sample file name has an improper extension.','Error');
        return;
    end
end

% Put the output directory name in the filenames
filesta     = [pathin ,'\',filesta];
obsfile     = [pathout,'\',obsfile];


%%% ACTUAL CONVERSION OF THE GRID

dflowfm_io_obs('write',filegrd,filesta,obsfile);