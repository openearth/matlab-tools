function varargout=wlgrid(cmd,varargin),
% WLGRID read/write a grid file
%       [X,Y,ENC]=WLGRID('read',FILENAME) reads the GRID from
%       files that can be used by Delft3D and TRISULA.
%       GRID=WLGRID('read',FILENAME) returns a structure with
%       X, Y, and Enclosure fields.
%
%       OK=WLGRID('write',FILENAME,X,Y,ENC) writes the GRID to
%       files that can be used by Delft3D and TRISULA.

% (c) copyright, Delft Hydraulics, 1997
%       created by H.R.A. Jagers, Delft Hydraulics / University of Twente

if nargin==0,
  if nargout>0,
    varargout=cell(1,nargout);
  end;
  return;
end;

switch lower(cmd),
case {'r','re','rea','read'},
  Grid=Local_read_grid(varargin{:});
  if nargout<=1,
    varargout{1}.X=Grid{1};
    varargout{1}.Y=Grid{2};
    varargout{1}.Enclosure=Grid{3};
    varargout{1}.FileName=Grid{4};
  else,
    varargout=Grid(1:3);
  end;
case {'w','wr','wri','writ','write'},
  Out=Local_write_grid(varargin{:});
  if nargout>0,
    varargout{1}=Out;
  end;
otherwise,
  error('Unknown command');
end;


function Out=Local_read_grid(filename),
Out={[] [] [] ''};

if (nargin==0) | strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.*','Select grid file');
  if ~ischar(fname),
    return;
  end;
  filename=fullfile(fpath,fname);
end;

% detect extension
[path,name,ext]=fileparts(filename);
if isempty(ext), ext='.grd'; end; % default .grd file
filename=fullfile(path,[name ext]);
basename=fullfile(path,name);
Out{4}=filename;

% Grid file
fid=fopen(filename);
if fid<0,
  error(sprintf('Couldn''t open requested file: %s.',filename));
end;
line=fgetl(fid);
while 1,
  line=fgetl(fid);
  if ~isstr(line), break; end;
  if line(1)~='*',
    grdsize=transpose(sscanf(line,'%i'));
    line=fgetl(fid); % read xori,yori,alfori
    if length(grdsize)>2, % the possible third element contains the number of subgrids
      for i=1:(2*grdsize(3)), % read subgrid definitions
        line=fgetl(fid);
      end;
    end;
    grdsize=grdsize(1:2);
    floc=ftell(fid);
    str=fscanf(fid,'%11c',1);
    fseek(fid,floc,-1);
    cc=sscanf(str,'%4s %i',[1 5]);
    skipETA=1;
    if isequal(abs(cc),[abs('ETA=') 1])
      skipETA=0;
    end
    Out{1}=-999*ones(grdsize);
    for c=1:grdsize(2),
      if ~skipETA
        cc=fscanf(fid,'%*4s %i',1); % skip line header ETA= and read c
      else
        cc=fscanf(fid,'%11c',1);
      end
      Out{1}(:,c)=fscanf(fid,'%f',[grdsize(1) 1]);
    end;
    Out{2}=-999*ones(grdsize);
    for c=1:grdsize(2),
      if ~skipETA
        cc=fscanf(fid,'%*4s %i',1); % skip line header ETA= and read c
      else
        cc=fscanf(fid,'%11c',1);
      end
      Out{2}(:,c)=fscanf(fid,'%f',[grdsize(1) 1]);
    end;
    break;
  end;
end;
fclose(fid);
notdef=(Out{1}==0) & (Out{2}==0);
Out{1}(notdef)=NaN;
Out{2}(notdef)=NaN;

% Grid enclosure file
fid=fopen([basename '.enc']);
if fid>0,
  while 1,
    line=fgetl(fid);
    if ~isstr(line), break; end;
    Out{3}=[Out{3}; sscanf(line,'%i',[1 2])];
  end;
  fclose(fid);
else,
  %warning('Grid enclosure not found.');
  [M,N]=size(Out{1});
  Out{3}=[1 1; M+1 1; M+1 N+1; 1 N+1; 1 1];
end;


function OK=Local_write_grid(filename,X,Y,ENC),
% GRDWRITE writes a grid file
%       GRDWRITE(FILENAME,GRID) writes the GRID to files that
%       can be used by Delft3D and TRISULA.

% (c) copyright, Delft Hydraulics, 1997
%       created by H.R.A. Jagers, Delft Hydraulics / University of Twente

OK=0;

if nargin==2,
  if iscell(X),
    Grd=X;
  elseif isstruct(X),
    if isfield(X,'Enclosure'),
      Grd={X.X X.Y X.Enclosure};
    else,
      Grd={X.X X.Y []};
    end;
  end;
elseif nargin==3,
  Grd={X Y []};
elseif nargin==4,
  Grd={X Y ENC};
end;
[i,j]=find(Grd{1}==0); % move any points that have x-coordinate
for l=1:length(i),    % equal to zero.
  Grd{1}(i(l),j(l))=0.001;
end;
[i,j]=find(Grd{2}==0); % move any points that have y-coordinate
for l=1:length(i),    % equal to zero.
  Grd{2}(i(l),j(l))=0.001;
end;
Idx=isnan(Grd{1}.*Grd{2}); % change indicator of grid point exclusion
Grd{1}(Idx)=0;             % from NaN in Matlab to (0,0) in grid file.
Grd{2}(Idx)=0;
if length(Grd)==2,
  Grd{3}=[];
end;

% detect extension
[path,name,ext]=fileparts(filename);
if isempty(ext), ext='.grd'; end; % default .grd file
filename=fullfile(path,[name ext]);
basename=fullfile(path,name);

if ~isempty(Grd{3}),
  fid=fopen([basename '.enc'],'w');
  if fid<0,
    error('* Could not open output file.');
  end;
  for i=1:size(Grd{3},1),
    fprintf(fid,'%5i%5i\n',Grd{3}(i,1),Grd{3}(i,2));
  end;
  fclose(fid);
end;

fid=fopen(filename,'w');
fprintf(fid,'* MATLAB Version %s file created at %s.\n',version,datestr(now));
fprintf(fid,'%8i%8i\n',size(Grd{1},1),size(Grd{1},2));
fprintf(fid,'%8i%8i%8i\n',0,0,0);
for j=1:size(Grd{1},2),
  fprintf(fid,' ETA=%5i',j);
  fprintf(fid,'%12.3f',Grd{1}(1:min(5,size(Grd{1},1)),j));
  fprintf(fid,'\n          %12.3f%12.3f%12.3f%12.3f%12.3f',Grd{1}(6:size(Grd{1},1),j));
  fprintf(fid,'\n');
end;
for j=1:size(Grd{2},2),
  fprintf(fid,' ETA=%5i',j);
  fprintf(fid,'%12.3f',Grd{2}(1:min(5,size(Grd{2},1)),j));
  fprintf(fid,'\n          %12.3f%12.3f%12.3f%12.3f%12.3f',Grd{2}(6:size(Grd{2},1),j));
  fprintf(fid,'\n');
end;
fclose(fid);
OK=1;

