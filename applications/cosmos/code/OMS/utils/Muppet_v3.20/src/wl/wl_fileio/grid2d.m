function Out=grid2d(cmd,varargin),
%GRID2D read files related to grid2d
%
%  Data=grid2d('command',...)
%
%  openBD,openTP,openGM,openGR
%  openBND,openINP:
%
%    Data=grid2d('open...','filename');
%
%
%  writeBND:
%
%    Data=grid2d('write...',Data,'filename');


if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch lower(cmd),
case 'openbd',
  Out=Local_open_bd_file(varargin{:});
case 'opentp',
  Out=Local_open_tp_file(varargin{:});
case 'opengm',
  Out=Local_open_gm_file(varargin{:});
case 'opengr',
  Out=Local_open_gr_file(varargin{:});
case 'openag',
  % Out=Local_open_ag_file(varargin{:});
  uiwait(msgbox('Not implemented','modal'));
  Out=[];
case 'openbnd',
  Out=Local_open_bnd_file(varargin{:});
case 'writebnd',
  Out=Local_write_bnd_file(varargin{:});
case 'openinp',
  Out=Local_open_inp_file(varargin{:});
otherwise,
  uiwait(msgbox('unknown command','modal'));
end;


function Structure=Local_open_bd_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.bd');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','b');
Structure.FileName=filename;

Structure.Boundary=fscanf(fid,'%f',[2 inf]);
Structure.Boundary(Structure.Boundary==9999.9)=NaN;

fclose(fid);
Structure.Check='OK';


function Structure=Local_open_tp_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.tp');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','b');
Structure.FileName=filename;

Line=fgetl(fid);
X=sscanf(Line,'%i',6);
% Structure.NEdgeDBnd=X(1);
% Structure.NIsle=X(2);
Structure.NDBnd=X(3);
Structure.NBlck=X(4);
Structure.NEdge=X(5);
Structure.NVert=X(6);

for dbnd=1:Structure.NDBnd;
  Line=fgetl(fid);
  X=sscanf(Line,'%i',inf);
  % X(1) = dbnd
  Structure.DBnd(dbnd).Edges=X(2+(1:X(2)));
end;

for vert=1:Structure.NVert,
  Line=fgetl(fid);
  X=sscanf(Line,'%f',[1 3]);
  % X(1) = vert
  Structure.Vertex(vert).Point=X(2:3);
end;

for blck=1:Structure.NBlck,
  Line=fgetl(fid);
  X=sscanf(Line,'%i',[1 5]);
  % X(1) = blck
  Structure.Blck(blck).Edges=X(2:5);
end;

for edge=1:Structure.NEdge,
  Line=fgetl(fid);
  X=sscanf(Line,'%i',[1 3]);
  % X(1) = edge
  Structure.Edge(edge).Block=X(2:3);
end;

for edge=1:Structure.NEdge,
  Line=fgetl(fid);
  X=sscanf(Line,'%i',[1 3]);
  % X(1) = edge
  Structure.Edge(edge).Vertex=X(2:3);
end;

for vert=1:Structure.NVert,
  Line=fgetl(fid);
  X=sscanf(Line,'%i',[1 5]);
  % X(1) = vert
  Structure.Vertex(vert).Edge=X(2:5); % in the order up right down left
end;

fclose(fid);
Structure.Check='OK';


function Structure=Local_open_gm_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.gm');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','b');
Structure.FileName=filename;

Line=fgetl(fid);
Structure.NEdge=sscanf(Line,'%i',1);

for edge=1:Structure.NEdge,
  X=fscanf(fid,'%i',2);
  % X(1) = edge
  % X(2) = Number of points (2 or 10)
  X=fscanf(fid,'%f',[2 X(2)]);
  Structure.Edge(edge).Point=X';
  Line=fgetl(fid);
end;

for edge=1:Structure.NEdge,
  Line=fgetl(fid);
  X=sscanf(Line,'%i',[1 2]);
  % X(1) = edge
  % X(2) = ij
  %        where i=1 : Hermite interpolation
  %              j=1 : coordinates free at computation of elliptic grid
  %              j=2 : coordinates free on edge at computation of elliptic grid
  %              j=3 : coordinates fixed at computation of elliptic grid
  % X(2) is not used by Grid2D, so also skipped here
  % Structure.Edge(edge).IntClass=X(2);
end;

fclose(fid);
Structure.Check='OK';


function Structure=Local_open_gr_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.gr');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','b');
Structure.FileName=filename;

Line=fgetl(fid);
Structure.NEdge=sscanf(Line,'%i',1);

for edge=1:Structure.NEdge,
  X=fscanf(fid,'%i',2);
  % X(1) = edge
  % X(2) = Number of points
  X=fscanf(fid,'%f',[2 X(2)]);
  Structure.Edge(edge).Point=X';
  Line=fgetl(fid);
end;

for edge=1:Structure.NEdge,
  Line=fgetl(fid);
  X=sscanf(Line,'%i',[1 2]);
  % X(1) = edge
  % X(2) = Ni
  %        where i=0 : equidistant distributed grid
  %              i=1 : linear distributed grid
  %              i=4 : exponential distributed grid
  %              i=6 : hyperbolic tangent distributed grid
  %              i=7 : free (manually) distributed grid
  %              N   : number of intervals (should be number of points - 1)
  % I could check validity of N against size(Structure.Edge(edge).Point,1)-1
  Structure.Edge(edge).Distrib=mod(X(2),10);
end;

fclose(fid);
Structure.Check='OK';


function Structure=Local_open_bnd_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.bnd');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','b');
Structure.FileName=filename;

edge=1;
while ~feof(fid),
  X=fscanf(fid,'%i',[1 4]); % NPAIRS, ITYPB, NVBEG, NVEND
  % Structure.Edge(edge).NPnt=X(1);
  Structure.Edge(edge).Fixed=X(2); % 2 = fixed, 1 = not fixed
  Structure.Edge(edge).StartVertex=X(3);
  Structure.Edge(edge).EndVertex=X(4);
  X=fscanf(fid,'%f',[2 X(1)]); % X and Y coordinates of the points
  Structure.Edge(edge).Pnt=X';
  Line=fgetl(fid); % read EOL and possibly EOF
  edge=edge+1;
end;

fclose(fid);
Structure.Check='OK';


function NewStruct=Local_write_bnd_file(Structure,filename),
NewStruct=Structure;
NewStruct.Check='NotOK';

if nargin==1,
  [fn,fp]=uiputfile('*.bnd');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'w','b');
NewStruct.FileName=filename;

for edge=1:length(NewStruct.Edge),
  % write NPAIRS, ITYPB, NVBEG, NVEND
  fprintf(fid,'%4i %3i %3i %3i\n',size(NewStruct.Edge(edge).Pnt,1), ...
       NewStruct.Edge(edge).Fixed,NewStruct.Edge(edge).StartVertex,NewStruct.Edge(edge).EndVertex);
  fprintf(fid,'%8f %8f\n',transpose(NewStruct.Edge(edge).Pnt));
end;

fclose(fid);
NewStruct.Check='OK';


function Structure=Local_open_inp_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.inp');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','b');
Structure.FileName=filename;

Line=fgetl(fid); % read title

X=fscanf(fid,'%i',2); % NEDGES, NPOLY
Structure.NEdge=X(1);
Structure.NPoly=X(2);

for pol=1:Structure.NPoly,
  X=fscanf(fid,'%f', 3);
  Structure.Poly(pol).NEdge=X(1);
  Structure.Poly(pol).dKsi=X(2);
  Structure.Poly(pol).dEta=X(3);
end;

for edge=1:Structure.NEdge,
  X=fscanf(fid,'%f', 5); % index, orientation, 
  Structure.Edge(edge).Orient=X(2); % 1 lower, 2 right, 3 upper, 4 left
  Structure.Edge(edge).NLine=X(3); % number of intersecting grid lines
  Structure.Edge(edge).Fixed=X(4); % 1 may shift, 2 fixed
  Structure.Edge(edge).Distr=X(5); % 0 equidist, N>0 N% increase per interval, N<0 N% decrease per interval
end;

fclose(fid);
Structure.Check='OK';


