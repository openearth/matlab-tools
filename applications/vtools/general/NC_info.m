%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Write NetCDF file metadata (`ncinfo`) to a text file.

function NC_info(ncFile, varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'outFile','ncinfo.txt');
addOptional(parin,'OutputFormat','table'); %verbose, table

parse(parin,varargin{:});

outFile = char(parin.Results.outFile);
outputFormat = char(parin.Results.OutputFormat);

%% CALC

info = ncinfo(ncFile);

fid = fopen(outFile, 'w');
if fid == -1
    error('Could not open output file.');
end

if strcmpi(outputFormat, 'table')
    writeVariableTable(info, fid);
else
    fprintf(fid, 'NetCDF file metadata\n');
    fprintf(fid, '====================\n\n');
    writeStruct(info, fid, 0);
end

fclose(fid);

end %function

%% 
%% FUNCTIONS
%%

function writeStruct(S, fid, indent)
% Recursive function to print structs

pad = repmat(' ', 1, indent);

fields = fieldnames(S);
for i = 1:numel(fields)
    field = fields{i};
    value = S.(field);

    if isstruct(value)
        fprintf(fid, '%s%s:\n', pad, field);
        if numel(value) > 1
            for j = 1:numel(value)
                fprintf(fid, '%s  (%d)\n', pad, j);
                writeStruct(value(j), fid, indent + 4);
            end
        else
            writeStruct(value, fid, indent + 4);
        end

    elseif iscell(value)
        fprintf(fid, '%s%s:\n', pad, field);
        for j = 1:numel(value)
            fprintf(fid, '%s  {%d} %s\n', pad, j, toString(value{j}));
        end

    else
        fprintf(fid, '%s%s: %s\n', pad, field, toString(value));
    end
end

end %function

%%

function writeVariableTable(info, fid)
% Write a compact variable summary table

if ~isfield(info, 'Variables') || isempty(info.Variables)
    fprintf(fid, 'No variables found in NetCDF file.\n');
    return;
end

vars = info.Variables;
nVars = numel(vars);

names = cell(nVars, 1);
descriptions = cell(nVars, 1);
dimensions = cell(nVars, 1);

for i = 1:nVars
    names{i} = vars(i).Name;
    descriptions{i} = getVariableDescription(vars(i));
    dimensions{i} = getDimensionString(vars(i));
end

nameLengths = cellfun(@numel, names);
descLengths = cellfun(@numel, descriptions);

nameWidth = max([numel('Variable'); nameLengths(:)]);
descWidth = max([numel('Description'); descLengths(:)]);

fprintf(fid, '%-*s  %-*s  %s\n', nameWidth, 'Variable', descWidth, 'Description', 'Dimensions');
fprintf(fid, '%s  %s  %s\n', repmat('-', 1, nameWidth), repmat('-', 1, descWidth), repmat('-', 1, numel('Dimensions')));

for i = 1:nVars
    fprintf(fid, '%-*s  %-*s  %s\n', nameWidth, names{i}, descWidth, descriptions{i}, dimensions{i});
end

end %function

%%

function description = getVariableDescription(variable)
% Resolve a human-readable variable description from common attribute names

description = '';

if isfield(variable, 'Attributes') && ~isempty(variable.Attributes)
    attrNames = {variable.Attributes.Name};
    idx = find(strcmpi(attrNames, 'long_name'), 1);
    if isempty(idx)
        idx = find(strcmpi(attrNames, 'description'), 1);
    end
    if isempty(idx)
        idx = find(strcmpi(attrNames, 'standard_name'), 1);
    end

    if ~isempty(idx)
        description = toString(variable.Attributes(idx).Value);
    end
end

if isempty(description)
    description = '-';
end

end %function

%%

function dims = getDimensionString(variable)
% Convert variable dimensions to a compact string

if isfield(variable, 'Dimensions') && ~isempty(variable.Dimensions)
    nDims = numel(variable.Dimensions);
    dimParts = cell(1, nDims);
    for k = 1:nDims
        dimParts{k} = sprintf('%s(%d)', variable.Dimensions(k).Name, variable.Dimensions(k).Length);
    end
    dims = strjoin(dimParts, ' x ');
elseif isfield(variable, 'Size') && ~isempty(variable.Size)
    dims = sprintf('[%s]', num2str(variable.Size));
else
    dims = '-';
end

end %function

%%

function str = toString(val)
% Convert values to readable strings

if isnumeric(val)
    if isempty(val)
        str = '[]';
    elseif isscalar(val)
        str = num2str(val);
    else
        str = sprintf('[%s]', num2str(size(val)));
    end
elseif ischar(val)
    str = ['''' val ''''];
elseif isstring(val)
    str = char(val);
elseif islogical(val)
    str = mat2str(val);
else
    str = class(val);
end

end %function
