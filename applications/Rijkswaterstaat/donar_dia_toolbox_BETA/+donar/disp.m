function disp(File,varargin)
%DISP  displays overview of contents of DONAR (blocks + variables)
%
% File = disp(diafile) displays overview of File Variables
%
% Example:
% 
%  File            = donar.open(diafile)
%  donar.disp(File)
%
%See also: open, read, disp

V = File.Variables;

fmt = '%5s|%4s|%6s|%8s|%8s|%64s | %s';
disp(sprintf(fmt,'File ','WNS ', ' # of ', ' # of ', 'DONAR','CF', 'DONAR'))
disp(sprintf(fmt,'index','code', 'blocks', 'values', 'name','standard_name', 'long_name'))

fmt = '%5s+%4s+%6s+%8s+%8s+%+64s-+-%s';
disp(sprintf(fmt,'-----','----','------','-------','--------','----------------------------------------------------------------','--------->'))

fmt = '%5d|%4s|%6d|%8d|%8s|%64s | %s';

for i=1:length(V)

disp(sprintf(fmt, i, V(i).WNS, length(V), sum(V(i).nval), V(i).hdr.PAR{1}, V(i).standard_name, V(i).long_name))

end

fmt = '%5s+%4s+%6s+%8s+%8s+%64s-+-%s';
disp(sprintf(fmt,'-----','----','------','--------','--------','----------------------------------------------------------------','--------->'))
