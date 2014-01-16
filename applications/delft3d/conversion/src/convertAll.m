%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% FOLLOW THE SEQUENCE

% Check if the session is initialized
mdufile     = get(handles.edit4,'String');
filegrd     = get(handles.edit5,'String');
if isempty(mdufile) & isempty(filegrd);
    errordlg('The sessions has not been initialized. First press ''Initialize''.','Error');
    break;
end

% Remove waitbar if it exists
if exist('wb'); close(wb); end;

% Step  1: Convert the grid
wb = waitbar( 1/15,'Converting the grid ...');
convertGrid;

% Step  2: Generate the pli-files
waitbar( 2/15,wb,'Generating the boundary polylines ...');
convertBoundaryLocations;

% Step  3: Set template of the ext-file
waitbar( 3/15,wb,'Setting the template for the ext file ...');
convertExtForcing;

% Step  4: Check if bct-file is present; if yes, then convert the data
waitbar( 4/15,wb,'Converting the timeseries boundary data ...');
filebct     = get(handles.edit11,'String');
filebct     = deblank2(filebct);
if ~isempty(filebct);
    convertBctData;
end

% Step  5: Check if bca-file is present; if yes, then convert the data
waitbar( 5/15,wb,'Converting the astronomic boundary data ...');
filebca     = get(handles.edit12,'String');
filebca     = deblank2(filebca);
if ~isempty(filebca);
    convertBcaData;
end

% Step  6: Check if bch-file is present; if yes, then convert the data
waitbar( 6/15,wb,'Converting the harmonic boundary data ...');
filebch     = get(handles.edit13,'String');
filebch     = deblank2(filebch);
if ~isempty(filebch);
    convertBchData;
end

% Step  7: Check if bcc-file is present; if yes, then convert the data
waitbar( 7/15,wb,'Converting the salinity boundary data ...');
filebcc     = get(handles.edit14,'String');
filebcc     = deblank2(filebcc);
if ~isempty(filebcc);
    convertBccData;
end

% Step  8: Check if obs-file is present; if yes, then convert the data
waitbar( 8/15,wb,'Converting the observation points ...');
fileobs     = get(handles.edit15,'String');
fileobs     = deblank2(fileobs);
if ~isempty(fileobs);
    convertObservationPoints;
end

% Step  9: Check if crs-file is present; if yes, then convert the data
waitbar( 9/15,wb,'Converting the cross sections ...');
filecrs     = get(handles.edit16,'String');
filecrs     = deblank2(filecrs);
if ~isempty(filecrs);
    convertCrossSections;
end

% Step 10: Check if rgh-file is present; if yes, then convert the data
waitbar(10/15,wb,'Converting the spatial friction data ...');
filergh     = get(handles.edit17,'String');
filergh     = deblank2(filergh);
if ~isempty(filergh);
    convertRoughness;
end

% Step 11: Check if edy-file is present; if yes, then convert the data
waitbar(11/15,wb,'Converting the spatial viscosity data ...');
fileedy     = get(handles.edit18,'String');
fileedy     = deblank2(fileedy);
if ~isempty(fileedy);
    convertViscosity;
end

% Step 12: Check if ini-file is present; if yes, then convert the data
waitbar(12/15,wb,'Converting the initial waterlevels ...');
fileini     = get(handles.edit21,'String');
fileini     = deblank2(fileini);
if ~isempty(fileini);
    convertInitialConditions;
end

% Step 13: Check if dry-file or thd-file is present; if yes, then convert the data
waitbar(13/15,wb,'Converting the dry points and/or thin dams ...');
filedry     = get(handles.edit19,'String');
filedry     = deblank2(filedry);
nodry       = 0;
nothd       = 0;
if isempty(filedry);
    nodry   = 1;
end
filethd     = get(handles.edit20,'String');
filethd     = deblank2(filethd);
if isempty(filethd);
    nothd   = 1;
end
if nodry == 0 | nothd == 0;
    convertThinDams;
end
if nodry == 1 & nothd == 1;
    set(handles.edit27 ,'String','');
end

% Step 14: Finalize ext-file
waitbar(14/15,wb,'Finalizing the ext file ...');
convertExtForcingFin;

% Step 15: Finalize mdu-file
waitbar(15/15,wb,'Finalizing the mdu file ...');
convertMasterFile;
close(wb);

% Finished!
msgbox('Conversion finished!','Message');