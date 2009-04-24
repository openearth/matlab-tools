function [transect] = readTransectDataNetcdf(filename, varargin)
%READTRANSECTDATANETCDF   transforms processed data to proper meta data format
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
% d = readTransectDataNetcdf('output.nc', 3000380, 2004);

if (nargin == 4)
    areaId = varargin{1};
    transectId = varargin{2};
    soundingId = varargin{3};
elseif (nargin == 3)
    transectId = varargin{1};
    soundingId = varargin{2};
else 
    error('expecting 3 or 4 arguments')
end

% make sure that transectId and soundingId are doubles
if ischar(transectId)
    transectId = str2double(transectId);
end
if ischar(soundingId)
    soundingId = str2double(soundingId);
end




% we need to lookup the index of transect and the year 


%% lookup the header variables
global areaname areacode alongshoreCoordinates;
if isempty(areaname)
    % temporary read from local file until website is updated
    areaname = cellstr(nc_varget(filename, 'areaname'));
end
if isempty(areacode)
    areacode = nc_varget(filename, 'areacode');
end
if isempty(alongshoreCoordinates)
    alongshoreCoordinates = nc_varget(filename, 'alongshore');
end
global id
if isempty(id)
    id = nc_varget(filename, 'id');
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
    % next find the alongshore indices
    alongshoreIndex = transectId == alongshoreCoordinates;
    id_index = find(areaIndex & alongshoreIndex);
    if isempty(id_index)
        error(['transect not found with id: ' num2str(transectId)]);
    end    
elseif (nargin == 3)
    % we use the id as stored in the file

    id_index = find(id == transectId);
    if isempty(id_index)
        error(['transect not found with id: ' num2str(transectId)]);
    end
end

%% lookup the year

global year
if isempty(year)
    year = nc_varget(filename, 'year');
end
year_index = find(year == soundingId);
if isempty(year_index)
    error(['year not found: ' year_index]);
end


%% create transect structure
transect.seq = 0;
global title
if isempty(title)
    title = nc_attget(filename, nc_global, 'title');
end
transect.datatypeinfo = title;

transect.datatype = 1;

transect.datatheme = '';

transect.area = areaname{id_index};

transect.areacode = num2str(areacode(id_index));

transect.transectID = num2str(alongshoreCoordinates(id_index), '%05d');

transect.year = num2str(year(year_index)); %'1965'

%TODO: store and look up
% transect.dateTopo = num2str(transect.dateTopo); % '3008'
% transect.dateBathy = num2str(transect.dateBathy); % '1708'
transect.soundingID = num2str(year(year_index)); % '1965'


global crossShoreCoordinate
if isempty(crossShoreCoordinate)
    crossShoreCoordinate = nc_varget(filename, 'cross_shore');
end
crossShoreCoordinateZeroIndex = find(crossShoreCoordinate == 0);

x = nc_varget(filename,'x', [id_index, 0], [1, length(crossShoreCoordinate)]);
transect.xRD = x(crossShoreCoordinateZeroIndex); %in EPSG:28992

y = nc_varget(filename,'y', [id_index, 0], [1, length(crossShoreCoordinate)]);
transect.yRD = y(crossShoreCoordinateZeroIndex); %in EPSG:28992

global angle 
if isempty(angle)
    angle = nc_varget(filename,'angle');
end

transect.GRAD = angle(id_index); %in degrees

transect.contour = [max(x), min(y); min(x) , max(y)]; %[2x2 double]

transect.contourunit = 'm';

transect.contourprojection = 'Amersfoort / RD New';

transect.contourreference = 'origin';

transect.ls_fielddata = 'parentSeq';
%TODO: Check where these are calculated
timestamp = 0; %1.1933e+009;?
%TODO: Check where these are calculated
transect.fielddata = []; %[1x1 struct]

global MHW 
if isempty(MHW)
    MHW = nc_varget(filename,'mean_high_water');
end
transect.MHW = MHW(id_index); 

global MLW
if isempty(MLW)
    MLW = nc_varget(filename,'mean_low_water');
end
transect.MLW = MLW(id_index); 

transect.xi = crossShoreCoordinate; %[1264x1 double]
height  = nc_varget(filename, 'altitude', [year_index-1, id_index-1, 0], [1, 1, length(crossShoreCoordinate)]);
transect.zi = height; %[1264x1 double]

%TODO: Check where these are calculated
transect.xe = transect.xi; %[1264x1 double]
transect.ze = transect.zi; %[1264x1 double]



end








