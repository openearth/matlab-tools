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

if nargin > 1
    outFile = varargin{1};
else
    outFile = 'ncinfo.txt';
end

info = ncinfo(ncFile);

fid = fopen(outFile, 'w');
if fid == -1
    error('Could not open output file.');
end

fprintf(fid, 'NetCDF file metadata\n');
fprintf(fid, '====================\n\n');

writeStruct(info, fid, 0);

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
