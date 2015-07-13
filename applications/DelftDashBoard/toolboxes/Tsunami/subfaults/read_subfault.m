function subfaults = read_subfault(varargin)
%load_subfaults - reads UCSB/NEIC subfault format models into a structure
% Read in subfault format models produced by Chen Ji's group at UCSB,
% downloadable from:
% http://www.geol.ucsb.edu/faculty/ji/big_earthquakes/home.html
%
% Syntax:  function_name(input1)
%
% Inputs:
%    path - path to .cfg file
%
% Outputs:
%    subfaults - A structure containing data for each subfault read from
%    the .cfg file
%
% Example:
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: SeanPaul LaSelle
% USGS
% email: slaselle@usgs.gov
% June 2015; Last revision: 23-June-2015

%------------- BEGIN CODE --------------
%% OPTIONAL INPUTS
% % Get path to file. If not input into function, open a window to select.
if any(strcmpi(varargin,'path'))==1;
    indi=strcmpi(varargin,'path');
    ind=find(indi==1);
    path = varargin{ind+1};
else
    [filename,pathname] = uigetfile('*.cfg','Select a subfault file');
    path = fullfile(pathname, filename);
end

% determine subfault format type
% if not specified, defaults to the USGS/UCSB subfault format
% can specify 'generic' for a custom format
if any(strcmpi(varargin,'filetype'))==1;
    indi=strcmpi(varargin,'filetype');
    ind=find(indi==1);
    filetype = varargin{ind+1};
else
    filetype = 'subfault';
end

% set columns
if any(strcmpi(varargin,'columns'))==1;
    indi=strcmpi(varargin,'columns');
    ind=find(indi==1);
    columns = varargin{ind+1};
else
    % use default format
    columns = {'latitude','longitude','depth','slip','rake','strike','dip',...
        'rupture_time','rise_time','rise_time_ending','mu'};
end

% set units
if any(strcmpi(varargin,'units'))==1;
    indi=strcmpi(varargin,'units');
    ind=find(indi==1);
    units = varargin{ind+1};
else
    % use default values
    units = struct('depth','km',...
        'slip','cm',...
        'mu','dyne/cm2',...
        'length','km',...
        'width','km',...
        'time','s',...
        'coordinate_specification','centroid');
end

%% READ FILE HEADER AND DATA
fid = fopen(path);

if strcmp(filetype, 'subfault') % FOR SUBFAULT FORMAT DATA
    % Read file header, return basic subfault geometry (subfault_dimensions), i.e.
    % number of cells in x and y directions and the length (dx) and width (dy)
    % of each subfault in kilometers.
    % Use regex to find matching strings, may need to make these more generic..
    
    tline = fgetl(fid);
    while ischar(tline)
        dx = regexpi(tline,'Dx=\s*(\d*.\d*)','tokens');
        dy = regexpi(tline,'Dy=\s*(\d*.\d*)','tokens');
        nx = regexpi(tline,'nx\(\w*-\w*\)=\s*(\d*)','tokens');
        ny = regexpi(tline,'ny\(\w*\)=\s*(\d*)','tokens');
        
        if isempty(ny)
            tline = fgetl(fid);
        else
            subfault_dimensions = [str2double(dx{1}{1}); str2double(dy{1}{1});...
                str2double(nx{1}{1}); str2double(ny{1}{1})];
            break
        end
    end
    
    % Now read in the rest of the subfault data (skipping the boundary info)
    %skip to the beginning of the data
    for k=1:8
        tline=fgetl(fid);
    end
    
    fmt = repmat('%f',1,length(columns));
    subfaults_data = textscan(fid,fmt,'delimiter','\t'); % read data
    
elseif strcmp(filetype, 'generic') % FOR GENERIC DATA
    % Skip columns marked with # or %, then read in data.
    tline = fgetl(fid);
    headerlines = 0;
    if strcmp(tline(1), '#') || strcmp(tline(1), '%')
        tline = fgetl(fid);
        headerlines  = headerlines+1;
    end
    frewind(fid);
    fmt = repmat('%f',1,length(columns));
    subfaults_data = textscan(fid,fmt,'delimiter','\t','HeaderLines',headerlines); % read data
else
    disp('Could not recognize input file type.')
end

fclose(fid);
%% WRITE DATA TO SUBFAULTS STRUCTURE

% write data to structure
subfaults = cell2struct(subfaults_data,columns,2);
% add columns for length and width
if isfield(subfaults,'length') == 0
    subfaults.length = ones(length(subfaults.latitude),1)*subfault_dimensions(1);
    subfaults.width = ones(length(subfaults.latitude),1)*subfault_dimensions(2);
end

% convert to standard units (meters and pascals)
% make sure length, width, and depth are in meters
if strcmp(units.length,'km')
    subfaults.length = subfaults.length*1000;
end
if strcmp(units.width,'km')
    subfaults.width = subfaults.width*1000;
end
if strcmp(units.depth,'km')
    subfaults.depth = subfaults.depth*1000;
end

% make sure units of slip are in meters
if strcmp(units.slip,'cm')
    subfaults.slip = subfaults.slip/100; % convert slip from cm to m
end

% make sure mu (rigidity) is in Pascals
if isfield(units,'mu')
    if strcmp(units.mu,'dyne/cm2')
        subfaults.mu = subfaults.mu*0.1;
    end
end

%% CALCULATE SUBFAULT CORNERS/CENTERS

% calculate subfault geometries
subfaults_geo = calculate_subfault_geometry(subfaults, units.coordinate_specification);
subfaults = subfaults_geo;

%------------- END OF CODE --------------
