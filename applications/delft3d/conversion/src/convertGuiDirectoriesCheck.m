% Check if the directories have been set
pathin      = get(handles.edit1,'String');
pathout     = get(handles.edit2,'String');
if isempty(pathin);
    errordlg('The input directory has not been assigned','Error');
    return;
end
if isempty(pathout);
    errordlg('The output directory has not been assigned','Error');
    return;
end
if exist(pathin,'dir')==0;
    errordlg('The input directory does not exist.','Error');
    return;
end
if exist(pathout,'dir')==0;
    errordlg('The output directory does not exist.','Error');
    return;
end

% Check if grid actually exists
filegrd     = get(handles.edit5,'String');
fileenc     = get(handles.edit6,'String');
filedep     = get(handles.edit7,'String');
filegrd     = [pathin,'\',filegrd];
fileenc     = [pathin,'\',fileenc];
filedep     = [pathin,'\',filedep];
if ~isempty(filegrd);
    if exist(filegrd,'file')==0;
        errordlg('The specified grd-file does not exist in the specified input directory.','Error');
        break;
    end
end