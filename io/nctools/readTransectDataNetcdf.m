function [transect] = readTransectDataNetcdf(filename, TransectID, SoundingID)
%READTRANSECTDATA   transforms processed data to proper meta data format
%
% input:
%   filename
%   TransectID
%   SoundingID
%
%   See also readGridData, readLineData, readPointData

% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.2, January 2007 (Version 1.0, February 2004)
% By:           <M. van Koningsveld (email: mark.vankoningsveld@wldelft.nl>
% -------------------------------------------------------------
% d = readTransectdata('output.nc', 3000380, 2004);


areaname = cellstr(nc_varget(filename, 'areaname'));
areacode = nc_varget(filename, 'areacode');


% areanameIndex ~cellfun(@isempty, strfind(a,area)) 
% areacodeIndex areacodes == area

% coastwardDistanceIndex = num2str(nc_varget(filename, 'coastward_distance'), '%05d') == id;
% id_index = id((areanameIndex | areacodeIndex)  & coastwardDistanceIndex )



id = nc_varget(filename, 'id');
id_index = find(id == TransectID);
if isempty(id_index)
    error(['transect not found with id: ' num2str(TransectID)]);
end

year = nc_varget(filename, 'year');
year_index = find(year == SoundingID);
if isempty(year_index)
    error(['year not found: ' year_index]);
end


transect.seq = 0;

title = nc_attget(filename, nc_global, 'title');
transect.datatypeinfo = title;

transect.datatype = 1;

transect.datatheme = '';

areanames = cellstr(nc_varget(filename, 'areaname'));
transect.area = areanames(id_index);

areacodes = nc_varget(filename, 'areacode');
transect.areacode = num2str(areacodes(id_index));

coastwardDistance = nc_varget(filename, 'coastward_distance');
transect.transectID = num2str(coastwardDistance(id_index), '%05d');

transect.year = num2str(year(year_index)); %'1965'

%TODO: store and look up
% transect.dateTopo = num2str(transect.dateTopo); % '3008'
% transect.dateBathy = num2str(transect.dateBathy); % '1708'
transect.soundingID = num2str(year(year_index)); % '1965'

seawardDistance = nc_varget(filename, 'seaward_distance');
seawardDistanceZeroIndex = find(seawardDistance == 0);

x = nc_varget(filename,'x');
transect.xRD = x(id_index, seawardDistanceZeroIndex); %in EPSG:28992

y = nc_varget(filename,'y');
transect.yRD = y(id_index, seawardDistanceZeroIndex); %in EPSG:28992

% TODO: store and lookup
transect.GRAD = 0; % 0 - 360

transect.contour = [minmax(x(id_index,:)); minmax(y(id_index,:))]; %[2x2 double]

transect.contourunit = 'm';

transect.contourprojection = 'Amersfoort / RD New';

transect.contourreference = 'origin';

transect.ls_fielddata = 'parentSeq';
%TODO: Check where these are calculated
timestamp = 0; %1.1933e+009;?
%TODO: Check where these are calculated
transect.fielddata = []; %[1x1 struct]
%TODO: Check where these are calculated
transect.MLW = 0; % -0.8000
%TODO: Check where these are calculated
transect.MHW = 0; %0.8000

transect.xi = seawardDistance; %[1264x1 double]
height  = nc_varget(filename, 'height', [year_index-1, id_index-1, 0], [1, 1, length(seawardDistance)]);
transect.zi = height; %[1264x1 double]

%TODO: Check where these are calculated
transect.xe = transect.xi; %[1264x1 double]
transect.ze = transect.zi; %[1264x1 double]



end








