warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bnd file name has been specified
filebnd     = get(handles.edit9,'String');
if ~isempty(filebnd);
    filebnd = [pathin,'\',filebnd];
    if exist(filebnd,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified boundary file does not exist.','Error');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The boundary file name has not been specified.','Error');
    break;
end

% Check if the mdu file name has been specified
mdufile     = get(handles.edit4,'String');
if isempty(mdufile);
    if exist('wb'); close(wb); end;
    errordlg('The D-Flow FM master definition file name has not been specified.','Error');
    break;
end
if length(mdufile) > 4;
    if strcmp(mdufile(end-3:end),'.mdu') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The D-Flow FM master definition file name has an improper extension.','Error');
        break;
    end
end

% Put the output directory name in the filenames
mdufile     = [pathout,'\',mdufile];


%%% ACTUAL CONVERSION OF THE BOUNDARY LOCATIONS

plis        = d3d2dflowfm_bnd2pli(filegrd,filebnd,mdufile(1:end-4));



%%% PUT PLI-FILES IN LISTBOX

set(handles.listbox1,'String',plis);