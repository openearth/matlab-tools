function varargout=shape(cmd,varargin),
%SHAPE read data from an ESRI shape file
%
%     FI = SHAPE('open','filename')
%     Open the ESRI shape file and return a File Information Structure to
%     be used in the SHAPE read command described below.
%
%     data = SHAPE('read',FI,objectnumbers,datatype)
%     Read data from the ESRI shape file. The input arguments are to be
%     specified as follows:
%        FI            - File Information Structure as obtained from SHAPE
%                        open file command (explained above).
%        objectnumbers - list of object numbers in shape file to be
%                        retreived; use 0 to load all objects
%        datatype      - currently supported: 'points' or 'lines'

% (c) copyright, H.R.A. Jagers, 2001
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
  if nargout>0,
    varargout=cell(1,nargout);
  end;
  return;
end;

switch lower(cmd),
case {'open'},
  Info=Local_open_shape(varargin{:});
  varargout={Info};
case {'read'},
  Data=Local_read_shape(varargin{:});
  varargout={Data};
otherwise,
  error('Unknown command');
end;


function S=Local_open_shape(filename);
S.Check='NotOK';
S.FileType='ESRI-Shape';

if (nargin==0) | strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.shp','Select shape file');
  if ~ischar(fname),
    return;
  end;
  filename=fullfile(fpath,fname);
end;

[p,n,e]=fileparts(filename);
if ~strcmp(lower(e),'.shp')
  if isempty(e) & exist([filename '.shp'])
    filename=[filename '.shp'];
    e='.shp';
  else
    error('Invalid name of shape file.');
  end
end
if isempty(p)
  p=pwd;
end
if ~isequal(p(end),filesep)
  S.FileBase=[p filesep n];
else
  S.FileBase=[p n];
end
S.ShapeExt=e;

fid=fopen(filename,'r','b');
if ~isequal(fread(fid,[1 6],'int32'),[9994 0 0 0 0 0])
  error('Invalid shape file header.');
end
S.FileSize=fread(fid,1,'int32')*2; % file size stored in words (16 bit)
fseek(fid,0,1);
if S.FileSize~=ftell(fid),
  warning('Invalid file size stored in file.');
end
fclose(fid);
fid=fopen(filename,'r','l');
fseek(fid,28,-1); % skip header

S.Version=fread(fid,1,'int32');
S.ShapeTp=fread(fid,1,'int32');
ShapeTps={'null shape' 'point'  '' 'polyline'  '' 'polygon'  '' '' 'multipoint'  '' ...
          ''           'pointz' '' 'polylinez' '' 'polygonz' '' '' 'multipointz' '' ...
          ''           'pointm' '' 'polylinem' '' 'polygonm' '' '' 'multipointm' '' ...
          ''           'multipatch'};
S.ShapeTpName=ShapeTps{S.ShapeTp+1};
Tmp=fread(fid,[1 8],'float64');
S.XRange=Tmp([1 3]);
S.YRange=Tmp([2 4]);
S.ZRange=Tmp([5 6]);
S.MRange=Tmp([7 8]);
NShapes=0;
TNPrt=0;
TNPnt=0;
Index=0;
if exist([S.FileBase '.shx'])
  Index=1;
  fidx=fopen([S.FileBase '.shx'],'r','b');
  if ~isequal(fread(fidx,[1 6],'int32'),[9994 0 0 0 0 0])
    error('Invalid shape index header.');
  end
  fseek(fidx,100,-1);
  S.Idx=2*fread(fidx,[2 inf],'int32'); % stored in bytes!
  fclose(fidx);
  S.IndexExt='.shx';
end

while ~feof(fid)
  [NrSize,k]=readint32b(fid,2);
  if k==0, break; end
  ShapeTp=fread(fid,1,'int32');
  NShapes=NShapes+1;
  if ~Index, S.Idx(NShapes)=ftell(fid)-12; end
  switch ShapeTp
  case 0, % null shape
    % nothing to read
  case 1, % point
    % x,y
    fread(fid,2,'float64');
    TNPnt=TNPnt+1;
  case {3,5} % polyline, polygon
    % box, NPrt, NPnt, {iprt}, {x,y}
    fread(fid,4,'float64');
    NPrt=fread(fid,1,'int32');
    NPnt=fread(fid,1,'int32');
    TNPrt=TNPrt+NPrt;
    TNPnt=TNPnt+NPnt;
    fread(fid,[1 NPrt],'int32');
    fread(fid,[2 NPnt],'float64');
  case 8, % multipoint
    % box, N, {x,y}
    fread(fid,4,'float64');
    NPnt=fread(fid,1,'int32');
    TNPnt=TNPnt+NPnt;
    fread(fid,[2 NPnt],'float64');
  case 11, % pointz
    % x,y,z,m
    fread(fid,4,'float64');
  case {13,15} % polylinez, polygonz
    % box, NPrt, NPnt, {iprt}, {x,y} zrange, {z}, mrange, {m}
    fread(fid,4,'float64');
    NPrt=fread(fid,1,'int32');
    NPnt=fread(fid,1,'int32');
    TNPrt=TNPrt+NPrt;
    TNPnt=TNPnt+NPnt;
    fread(fid,[1 NPrt],'int32');
    fread(fid,[2 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
  case 18, % multipointz
    % box, N, {x,y}, zrange, {z}, mrange, {m}
    fread(fid,4,'float64');
    NPnt=fread(fid,1,'int32');
    TNPnt=TNPnt+NPnt;
    fread(fid,[2 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
  case 21, % pointm
    % x,y,m
    fread(fid,3,'float64');
  case {23,25} % polylinem, polygonm
    % box, NPrt, NPnt, {iprt}, {x,y}, mrange, {m}
    fread(fid,4,'float64');
    NPrt=fread(fid,1,'int32');
    NPnt=fread(fid,1,'int32');
    TNPrt=TNPrt+NPrt;
    TNPnt=TNPnt+NPnt;
    fread(fid,[1 NPrt],'int32');
    fread(fid,[2 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
  case 28, % multipointm
    % box, N, {x,y}
    fread(fid,4,'float64');
    NPnt=fread(fid,1,'int32');
    TNPnt=TNPnt+NPnt;
    fread(fid,[2 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
  case 31, % multipatch
    % box, NPrt, NPnt, {iprt}, {prttyp}, {x,y}, zrange, {z}, mrange, {m}
    PrtTyps={'trianglestrip','trianglefan','outerring','innerring','firstring','ring'}; % 0 -- 5
    fread(fid,4,'float64');
    NPrt=fread(fid,1,'int32');
    NPnt=fread(fid,1,'int32');
    TNPrt=TNPrt+NPrt;
    TNPnt=TNPnt+NPnt;
    fread(fid,[1 NPrt],'int32');
    fread(fid,[1 NPrt],'int32');
    fread(fid,[2 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
    fread(fid,2,'float64');
    fread(fid,[1 NPnt],'float64');
  otherwise % skip unknown
    fread(fid,NrSize(2)-2,'int16');
  end
end
fclose(fid);
S.NShapes=NShapes;
S.NPrt=TNPrt;
S.NPnt=TNPnt;
S.Check='OK';

if ~exist([S.FileBase '.dbf'])
  return;
else
  S.dBase=dbase('open',[S.FileBase '.dbf']);
  if S.dBase.NRec~=S.NShapes
    error('Number of records in dBase file does not match number of shapes.');
  end
end


function Out=Local_read_shape(S,shapes,datatype);
if ~isfield(S,'FileType') | ~strcmp(S.FileType,'ESRI-Shape')
  error('No shape file specified.');
end
if isequal(shapes,0)
  shapes=1:S.NShapes;
elseif min(shapes(:))<1 | max(shapes(:))>S.NShapes | ~isequal(shapes,round(shapes))
  error('Invalid shape number.');
else
  shapes=shapes(:)'; % make sure shapes is a row vector, otherwise Matlab will do just one step in the loop!
end
switch datatype
case 'points',
  fid=fopen([S.FileBase S.ShapeExt],'r','l');
  fseek(fid,S.Idx(1,shapes(1)),-1);
  TNPnt=0;
  Out=zeros(S.NPnt,2);
  for shp=shapes
    fseek(fid,S.Idx(1,shp),-1);
    [NrSize,k]=readint32b(fid,2);
    ShapeTp=fread(fid,1,'int32');
    switch ShapeTp
    case 0, % null shape
      % nothing to read
    case 1, % point
      % x,y
      TNPnt=TNPnt+1;
      Out(TNPnt,1:2)=fread(fid,[1 2],'float64');
    case {3,5} % polyline, polygon
      % box, NPrt, NPnt, {iprt}, {x,y}
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      fread(fid,[1 NPrt],'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      TNPnt=TNPnt+NPnt;
    case 8, % multipoint
      % box, N, {x,y}
      fread(fid,4,'float64');
      NPnt=fread(fid,1,'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      TNPnt=TNPnt+NPnt;
    case 11, % pointz
      % x,y,z,m
      TNPnt=TNPnt+1;
      Out(TNPnt,1:4)=fread(fid,[1 4],'float64');
    case {13,15} % polylinez, polygonz
      % box, NPrt, NPnt, {iprt}, {x,y} zrange, {z}, mrange, {m}
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      fread(fid,[1 NPrt],'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),4)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt;
    case 18, % multipointz
      % box, N, {x,y}, zrange, {z}, mrange, {m}
      fread(fid,4,'float64');
      NPnt=fread(fid,1,'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),4)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt;
    case 21, % pointm
      % x,y,m
      TNPnt=TNPnt+1;
      Out(TNPnt,1:3)=fread(fid,[1 3],'float64');
    case {23,25} % polylinem, polygonm
      % box, NPrt, NPnt, {iprt}, {x,y}, mrange, {m}
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      fread(fid,[1 NPrt],'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt;
    case 28, % multipointm
      % box, N, {x,y}
      fread(fid,4,'float64');
      NPnt=fread(fid,1,'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt;
    case 31, % multipatch
      % box, NPrt, NPnt, {iprt}, {prttyp}, {x,y}, zrange, {z}, mrange, {m}
      PrtTyps={'trianglestrip','trianglefan','outerring','innerring','firstring','ring'}; % 0 -- 5
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      fread(fid,[1 NPrt],'int32');
      fread(fid,[1 NPrt],'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),4)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt;
    otherwise % skip unknown
      fread(fid,NrSize(2)-2,'int16');
    end
  end
case 'lines',
  fid=fopen([S.FileBase S.ShapeExt],'r','l');
  fseek(fid,S.Idx(1,shapes(1)),-1);
  TNPnt=0;
  Out=repmat(NaN,S.NPnt+S.NPrt-1,2);
  for shp=shapes
    fseek(fid,S.Idx(1,shp),-1);
    [NrSize,k]=readint32b(fid,2);
    ShapeTp=fread(fid,1,'int32');
    switch ShapeTp
    case 0, % null shape
      % nothing to read
    case 1, % point
      % x,y
      Out(TNPnt+1,1:2)=fread(fid,[1 2],'float64');
      TNPnt=TNPnt+2;
    case {3,5} % polyline, polygon
      % box, NPrt, NPnt, {iprt}, {x,y}
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      PSz=fread(fid,[1 NPrt],'int32');
      PSz=diff([PSz NPnt]);
      for p=PSz
        Out(TNPnt+(1:p),1:2)=fread(fid,[2 p],'float64')';
        TNPnt=TNPnt+p+1;
      end
    case 8, % multipoint
      % box, N, {x,y}
      fread(fid,4,'float64');
      NPnt=fread(fid,1,'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      TNPnt=TNPnt+NPnt+1;
    case 11, % pointz
      % x,y,z,m
      Out(TNPnt+1,1:4)=fread(fid,[1 4],'float64');
      TNPnt=TNPnt+2;
    case {13,15} % polylinez, polygonz
      % box, NPrt, NPnt, {iprt}, {x,y} zrange, {z}, mrange, {m}
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      PSz=fread(fid,[1 NPrt],'int32');
      PSz=diff([PSz NPnt]);
      TNPnt0=TNPnt;
      for p=PSz
        Out(TNPnt+(1:p),1:2)=fread(fid,[2 p],'float64')';
        TNPnt=TNPnt+p+1;
      end
      fread(fid,2,'float64');
      TNPnt=TNPnt0;
      for p=PSz
        Out(TNPnt+(1:p),3)=fread(fid,[p 1],'float64');
        TNPnt=TNPnt+p+1;
      end
      fread(fid,2,'float64');
      TNPnt=TNPnt0;
      for p=PSz
        Out(TNPnt+(1:p),3)=fread(fid,[p 1],'float64');
        TNPnt=TNPnt+p+1;
      end
    case 18, % multipointz
      % box, N, {x,y}, zrange, {z}, mrange, {m}
      fread(fid,4,'float64');
      NPnt=fread(fid,1,'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),4)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt+1;
    case 21, % pointm
      % x,y,m
      Out(TNPnt+1,1:3)=fread(fid,[1 3],'float64');
      TNPnt=TNPnt+2;
    case {23,25} % polylinem, polygonm
      % box, NPrt, NPnt, {iprt}, {x,y}, mrange, {m}
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      PSz=fread(fid,[1 NPrt],'int32');
      PSz=diff([PSz NPnt]);
      TNPnt0=TNPnt;
      for p=PSz
        Out(TNPnt+(1:p),1:2)=fread(fid,[2 p],'float64')';
        TNPnt=TNPnt+p+1;
      end
      fread(fid,2,'float64');
      TNPnt=TNPnt0;
      for p=PSz
        Out(TNPnt+(1:p),3)=fread(fid,[p 1],'float64');
        TNPnt=TNPnt+p+1;
      end
    case 28, % multipointm
      % box, N, {x,y}
      fread(fid,4,'float64');
      NPnt=fread(fid,1,'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt+1;
    case 31, % multipatch
      % box, NPrt, NPnt, {iprt}, {prttyp}, {x,y}, zrange, {z}, mrange, {m}
      PrtTyps={'trianglestrip','trianglefan','outerring','innerring','firstring','ring'}; % 0 -- 5
      fread(fid,4,'float64');
      NPrt=fread(fid,1,'int32');
      NPnt=fread(fid,1,'int32');
      fread(fid,[1 NPrt],'int32');
      fread(fid,[1 NPrt],'int32');
      Out(TNPnt+(1:NPnt),1:2)=fread(fid,[2 NPnt],'float64')';
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),3)=fread(fid,[NPnt 1],'float64');
      fread(fid,2,'float64');
      Out(TNPnt+(1:NPnt),4)=fread(fid,[NPnt 1],'float64');
      TNPnt=TNPnt+NPnt+1;
    otherwise % skip unknown
      fread(fid,NrSize(2)-2,'int16');
    end
  end
  if TNPnt<size(Out,1)
    Out(TNPnt:end,:)=[];
  end
case 'patches',
otherwise
end


function [X,j]=readint32b(fid,N)
[Tmp,j]=fread(fid,4*N,'uint8');
j=j/4;
X=sscanf(sprintf('%0.2x',Tmp),'%8x',[1 N]);