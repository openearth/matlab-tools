function L = loadstr(fname)
%LOADSTR   load ASCII file
%
%   string = LOADSTR(filename)
%
%See also: SAVESTR

fid = fopen(fname);
L   = textscan(fid,'%s');
L   = L{1};
fclose(fid);