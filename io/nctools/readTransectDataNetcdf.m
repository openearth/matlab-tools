function [transect] = readTransectDataNetcdf(filename, varargin)
%READTRANSECTDATA   transforms processed data to proper meta data format
%
% input:
%   filename
%   AreaID
%   transectId
%   SoundingID
%
%   See also readGridData, readLineData, readPointData

% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.2, January 2007 (Version 1.0, February 2004)
% By:           <M. van Koningsveld (email: mark.vankoningsveld@wldelft.nl>
% -------------------------------------------------------------
% d = readTransectdata('output.nc', 3000380, 2004);

if (nargin == 4)
    areaId = cell2mat(varargin(1));
    transectId = cell2mat(varargin(2));
    soundingId = str2num(cell2mat(varargin(3)));
elseif (nargin == 3)
    transectId = varargin(1);
    soundingId = varargin(2);
else 
    error('expecting 3 or 4 arguments')
end



% we need to lookup the index of transect and the year 


%% lookup the header variables
global areaname areacode coastwardDistances;
if isempty(areaname)
    areaname = cellstr(nc_varget(filename, 'areaname'));
end
if isempty(areacode)
    areacode = nc_varget(filename, 'areacode');
end
if isempty(coastwardDistances)
    coastwardDistances = nc_varget(filename, 'coastward_distance');
end


%% first lookup the transect index

if (nargin == 4)
    % we use a double key, areaId + transectId
    % first find the areaIndices
    if isempty(str2num(areaId))
        areaIndex = ~cellfun(@isempty, strfind(areaname, areaId));
    else
        areaIndex = areacode == str2num(areaId);
    end
    % next find the coastward indices
    coastwardIndex = str2num(transectId) == coastwardDistances;
    id_index = find(areaIndex & coastwardIndex);
    if isempty(id_index)
        error(['transect not found with id: ' num2str(transectId)]);
    end    
elseif (nargin == 3)
    % we use the id as stored in the file
    global id
    if isempty(id)
        id = nc_varget(filename, 'id');
    end
    id_index = find(id == transectId);
    if isempty(id_index)
        error(['transect not found with id: ' num2str(transectId)]);
    end
end


global year
if isempty(year)
    year = nc_varget(filename, 'year');
end
year_index = find(year == soundingId);
if isempty(year_index)
    error(['year not found: ' year_index]);
end


transect.seq = 0;
global title
if isempty(title)
    title = nc_attget(filename, nc_global, 'title');
end
transect.datatypeinfo = title;

transect.datatype = 1;

transect.datatheme = '';

transect.area = areaname(id_index);

transect.areacode = num2str(areacode(id_index));

transect.transectID = num2str(coastwardDistances(id_index), '%05d');

transect.year = num2str(year(year_index)); %'1965'

%TODO: store and look up
% transect.dateTopo = num2str(transect.dateTopo); % '3008'
% transect.dateBathy = num2str(transect.dateBathy); % '1708'
transect.soundingID = num2str(year(year_index)); % '1965'


global seawardDistance
if isempty(seawardDistance)
    seawardDistance = nc_varget(filename, 'seaward_distance');
end
seawardDistanceZeroIndex = find(seawardDistance == 0);

global x
if isempty(x)
    x = nc_varget(filename,'x');
end
transect.xRD = x(id_index, seawardDistanceZeroIndex); %in EPSG:28992

global y 
if isempty(y)
    y = nc_varget(filename,'y');
end
transect.yRD = y(id_index, seawardDistanceZeroIndex); %in EPSG:28992

% TODO: store and lookup
transect.GRAD = 0; % 0 - 360

transect.contour = [min(x(id_index,:)),max(x(id_index,:)) ; min(y(id_index,:)), max(y(id_index,:))]; %[2x2 double]

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








