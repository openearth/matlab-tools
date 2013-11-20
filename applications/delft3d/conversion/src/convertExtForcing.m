warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the ext file name has been specified (D-Flow FM)
fileext     = get(handles.edit10,'String');
if isempty(fileext);
    errordlg('The external forcings file name has not been specified.','Error');
    return;
end
if length(fileext) > 4;
    if strcmp(fileext(end-3:end),'.ext') == 0;
        errordlg('The external forcings file name has an improper extension.','Error');
        return;
    end
end

% Put the output directory name in the filenames
fileext     = [pathout,'\',fileext];

% Catch the polyline names for the boundary conditions
filepli     = get(handles.listbox1,'String');
npli        = size(filepli,1);


%%% WRITE HEADER OF THE EXT FORCINGS FILE
convertExtForcingHeader;


%%% READ POLYLINE FILES AND CHECK BOUNDARY CONDITIONS TYPE

% Loop over all the boundary pli-files
for i=1:npli;
    fid                     = fopen([pathout,'\',filepli(i,:)],'r');
    tline                   = fgetl(fid);
    tline                   = fgetl(fid);
    tline                   = fgetl(fid);
    tline                   = textscan(tline,'%s%s%s%s%s');
    tlinestr                = cell2mat(tline{3});
    switch tlinestr;
        case 'Z';
            typ  = 'waterlevelbnd';
        case 'C';
            typ  = 'velocitybnd';
        case 'N';
            typ  = 'neumannbnd';
        case 'Q';
            typ  = 'dischargepergridcellbnd';
        case 'T';
            typ  = 'dischargebnd';
        case 'R';
            typ  = 'riemannbnd';
    end
    fprintf(fidext,['QUANTITY='  ,typ         ,'\n']);
    fprintf(fidext,['FILENAME='  ,filepli(i,:),'\n']);
    fprintf(fidext,['FILETYPE=9'              ,'\n']);
    fprintf(fidext,['METHOD  =3'              ,'\n']);
    fprintf(fidext,['OPERAND =O'              ,'\n']);
    fprintf(fidext,[                          ,'\n']);
end
fclose all;