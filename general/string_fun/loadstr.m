function L = loadstr(fname)
%LOADSTR   load ASCII file in cellstr
%
%   string = LOADSTR(filename)
%
% where each line becomes a cellstr
%
%See also: SAVESTR

fid = fopen(fname);
L   = textscan(fid,'%s','Delimiter',''); % EOL will always be Delimiter
L   = L{1};
fclose(fid);