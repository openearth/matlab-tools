function [Out,Map]=readxwd(filename),
% READXWD read an XWD image file.

% *.xwd

% *.x
% X file format
% Hdim Vdim : int32
% Per point:
%   Alpha R G B : byte

Out=[];
Map=[];

if nargin==0,
  [fn,fp]=uigetfile('*.xwd');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','b');
if fid<=0,
  error('error opening file.');
  return;
end;

X=fread(fid,25,'int32');
Width=X(5);
Height=X(6);
% 107   7   2   8 509 699   0   1
%  32   1  32   8 512   3   0   0
%   0   8 256 256 509 699 769   0
%   0

Str=char(fread(fid,[1 6],'char')); % xwdump

Y=transpose(fread(fid,[12 256],'uint8'));
Map=Y(:,[6 8 10])/255;

B=fread(fid,512,'uint8');
% 0 ... 0 7D 01

Data=uint8(fread(fid,[Width+3 Height],'uint8'));
Out=Data(2:(end-2),:)';

fclose(fid);