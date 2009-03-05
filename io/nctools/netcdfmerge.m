%NETCDFMERGE
%
%See also:

%% Define library settings

addpath mexnc % native netcdf interface
addpath snctools % convenience matlab toolbox
setpref ('SNCTOOLS', 'USE_JAVA', false); % I couldnt get java to work correctly. 


%% Define path settings
dataType='grid';
dataSet='rijkswaterstaat/jarkus';
rawDataDir='d:\checkouts\mcdata';
outputDir='d:\download';

dataDir = [rawDataDir filesep dataSet ];
gridFileDir = [dataDir filesep 'raw' filesep dataType ];
gridFileArray = dir([gridFileDir]);       % lists all available area data files (15 areas with transect data)

%% Look up all date directories
yearDir = gridFileArray([gridFileArray.isdir]);
tmp = cellfun(@str2num, {yearDir.name},'UniformOutput', false);
year = cell2mat(tmp(~cellfun(@isempty, tmp)));
%% Read all grid files and extract dimension size


results = [];
for i=1:length(year)
    currentyear = year(i);
    filename = [gridFileDir filesep num2str(currentyear) filesep num2str(currentyear) '.nc'];
    [xp, yp, mappingVarinfo] = netcdfraster2xy(filename);
    % Maybe store mappingVarinfo somewhere?
    result.xp = xp;
    result.yp = yp;
    results = [results result];
end

xp = sort(unique([results.xp]));
yp = sort(unique([results.yp]));
nx = length(xp);
ny = length(yp);

%%  Define grid (function of nx, ny)

outputFilename = 'output_grid.nc';
nc_create_empty(outputFilename);

nc_add_dimension(outputFilename, 'x', nx);
nc_add_dimension(outputFilename, 'y', ny);
nc_add_dimension(outputFilename, 'time', 0);


%% Copy geoTransform    
% copy the mapping variable
nc_addvar(outputFilename, mappingVarinfo);


%% Create coordinate variables
variable.Name = 'x';
variable.Nctype = nc_float;
variable.Dimension = {'x'};        
variable.Attribute = struct('Name', 'long_name', 'Value', 'x');
nc_addvar(outputFilename, variable)

variable.Name = 'y';
variable.Nctype = nc_float;
variable.Dimension = {'y'};        
variable.Attribute = struct('Name', 'long_name', 'Value', 'y');
nc_addvar(outputFilename, variable)

variable.Name = 'time';
variable.Nctype = nc_float;
variable.Dimension = {'time'};        
variable.Attribute = struct('Name', 'long_name', 'Value', 'time');
nc_addvar(outputFilename, variable)


nc_varput(outputFilename, 'x', xp)
nc_varput(outputFilename, 'y', yp)        

%% Create height variable
variable.Name = 'height';
variable.Nctype = nc_float;
variable.Dimension = {'time', 'y', 'x'};
variable.Attribute = struct('Name', '_fillValue', 'Value', 0);
nc_addvar(outputFilename, variable);
%% Copy old values for time

for yearIndex=1:length(year)
    currentyear = year(yearIndex);
    filename = [gridFileDir filesep num2str(currentyear) filesep num2str(currentyear) '.nc'];
    
    [xp,yp] = netcdfraster2xy(filename);

    fileinfo = nc_info(filename);
    % Look for all 2 dimensional variables because that's the only ones
    % we're merging right now.. TODO: generalize....
    twoDimensionalIndex = cellfun(@length, {fileinfo.Dataset.Dimension})==2;
    variables = fileinfo.Dataset(twoDimensionalIndex);
    if length(variables) ~= 1
        error('not exactly 1 variable found with 2 dimensions');
    end
    varinfo = variables(1);
    xp_out = nc_varget(outputFilename, 'x');
    yp_out = nc_varget(outputFilename, 'y');
    [c, xpia, xpib] = intersect(xp, xp_out);
    [c, ypia, ypib] = intersect(yp, yp_out);

    h = waitbar(0, ['Merging ', num2str(currentyear), ' into ', outputFilename]);
    % TODO; Maybe do this in blocks to speed it up, but how???
    for j = 1:length(ypia)
        waitbar(j/length(ypia), h);
        % store one x vector
        height = nan(size(xp_out));
        old_height = nc_varget(filename, varinfo.Name, [ypia(j)-1, 0], [1, length(xpia)]);
        height(xpib) = old_height(xpia);
        nc_varput(outputFilename, 'time', currentyear, yearIndex-1, 1)
        nc_varput(outputFilename, 'height', height, [yearIndex-1, ypib(j)-1, 0], [1, 1, length(xpib)]);
        
%         nc_varget(varinfo.Name, ypib(j)
%         height(xpib) = 
    end
    
            
        
    
    
%     for x = 1:length(xp)
%         yp
%     
    
end    