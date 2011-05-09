function Out=bagdpt(cmd,varargin),
% BAGDPT read output files BAGGER-BOS-RIZA bagger option
%
%    FILEINFO=BAGDPT('read',FILENAME)
%    Open bagger dpt-file (bagdpt.<case>) and returns a
%    structure containing the data in the file.
%

% (c) copyright, Delft Hydraulics, 2002
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
   error('Missing command.');
end;

switch cmd,
case 'read',
   Out=Local_bagdptread(varargin{:});
otherwise,
   error('Unknown command');
end;


function Structure=Local_bagdptread(filename,quiet),
if nargin<2
   quiet=0;
end
Structure.Check='NotOK';
Structure.FileType='baggerdpt';

if nargin==0 | strcmp(filename,'?'),
   [fname,fpath]=uigetfile('bagdpt.*','Select bagger history file');
   if ~ischar(fname),
      return;
   end;
   filename=[fpath,fname];
end;
Structure.FileName=filename;

fid=fopen(filename,'r');
if fid<0,
   error(['Cannot open ',filename,'.']);
end;

Line=fgetl(fid); %   Time volume in depot gebaggerd volume Volume teruggestort
if ~isequal(lower(Line(1:23)),'   time volume in depot')
   fclose(fid);
   return
end

Line=fgetl(fid); %  [tscale] [m3] [m3] [m3]
Data=fscanf(fid,'%f',[4 inf])';
fclose(fid);

Structure.Time=Data(:,1);
Structure.VolDepot=Data(:,2);
Structure.VolDredge=Data(:,3);
Structure.VolDumped=Data(:,4);
Structure.Check='OK';