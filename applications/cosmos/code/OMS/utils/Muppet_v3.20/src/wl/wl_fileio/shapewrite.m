function shapewrite(filename,varargin)
%SHAPEWRITE write simple shape files
%     SHAPEWRITE(filename,XYCell)
%     Write patches to shape file (.shp,.shx,.dbf).
%     XYCell should be a cell array of which each
%     element is a Nix2 array defining the polygon
%     consisting of Ni points (X,Y) co-ordinates.
%     The polygons will be closed automatically if
%     they are open.
%
%     Alternatively use:
%     SHAPEWRITE(filename,XY,Patches)
%     with XY a Nx2 matrix of X and Y co-ordinates
%     and Patches a matrix of point indices: each
%     row of the matrix represents one polygon. All
%     polygons contain the same number of points.
%
%     SHAPEWRITE(...,Values)
%     SHAPEWRITE(...,ValLabels,Values)
%     Write data associated with the polygons to the
%     dBase file. Values should be a NPxM matrix where
%     NP equals the number of polygons and M is the
%     number of values per polygon. The default data
%     labels are 'Val 1', 'Val 2', etc. Use a cell
%     array ValLabels if you want other labels. The
%     label length is restricted to a maximum of 10
%     characters.
%
%     SHAPEWRITE(filename,'polyline', ...)
%     Write polylines instead of polygons.
%     SHAPEWRITE(filename,'polygon', ...)
%     Write polygons (i.e. default setting).
%
%     SHAPEWRITE(filename,'point',XY)
%     Write points instead of polygons. XY should be a
%     NPx2 matrix. The number of rows in the optional
%     Value array should match the number of points.
%
%     See also: SHAPE, DBASE

% (c) 2001, H.R.A.Jagers
%     bert.jagers@wldelft.nl

DataType=5; % polygon
ValLbl={};
IN=varargin;
if ischar(IN{1})
  switch lower(IN{1})
  case 'point'
    DataType=1;
  case {'line','polyline'}
    DataType=3;
  case 'polygon'
    DataType=5;
  otherwise
    error(sprintf('Unknown shape identification: %s',IN{1}))
  end
  IN=IN(2:end);
end
if iscell(IN{1})
  XY=IN{1}(:);
  NShp=length(XY);
  for i=1:NShp
    if size(XY{i},2)~=2, error('Invalid number of columns in XY'); end
  end
  Patch=[];
  switch length(IN)
  case 1
    Val=[];
  case 2
    Val=IN{2};
  case 3
    ValLbl=IN{2};
    if ~iscellstr(ValLbl)
      error('Expected cell string for labels.')
    end
    Val=IN{3};
  otherwise
    error('Invalid number of input arguments.')
  end
else
  XY=IN{1};
  if DataType==1
    NShp=size(XY,1);
    offset=0;
  else
    Patch=IN{2};
    NShp=size(Patch,1);
    NPnt=size(Patch,2);
    offset=1;
    if NPnt<=2, error('Invalid number of columns in Patch, should be at least 3'); end
  end
  %data3d=size(XY,2)==3;
  if size(XY,2)~=2, error('Invalid number of columns in XY'); end
  switch length(IN)
  case 1+offset
    Val=[];
  case 2+offset
    Val=IN{2+offset};
  case 3+offset
    ValLbl=IN{2+offset};
    if ~iscellstr(ValLbl)
      error('Expected cell string for labels.')
    end
    Val=IN{3+offset};
  otherwise
    error('Invalid number of input arguments.')
  end
end
if isempty(Val)
  Val=zeros(NShp,0);
elseif size(Val,1)~=NShp
  error('Invalid length of value vector.');
end
StoreVal=size(Val,2);
if isempty(ValLbl)
  ValLbl(1:StoreVal)={''};
else
  if length(ValLbl)>StoreVal
    error('More value labels than values encountered.');
  else
    if length(ValLbl)<StoreVal
      ValLbl(end+1:StoreVal)={''};
    end
    ValLbl=ValLbl(:)';
    for i=1:length(ValLbl)
      if length(ValLbl{i})>10
        warning(sprintf('Label %i: ''%s'' truncated to ''%s''.',i,ValLbl{i},ValLbl{i}(1:10)));
        ValLbl{i}=ValLbl{i}(1:10);
      end
    end
  end
end

switch DataType
case 3
  %
  % remove double points
  %
  if iscell(XY)
    for i=1:NShp
      XY{i}(all(abs(diff(XY{i}))<1e-8,2),:)=[]; % remove double values
    end
  end
case 5
  %
  % close polygons and remove double points
  %
  if iscell(XY)
    for i=1:NShp
      if ~isequal(XY{i}(end,:),XY{i}(1,:))
        XY{i}(end+1,:)=XY{i}(1,:);
      end
      XY{i}(all(abs(diff(XY{i}))<1e-8,2),:)=[]; % remove double values
      if ~isequal(XY{i}(end,:),XY{i}(1,:))
        XY{i}(end,:)=XY{i}(1,:);
      end
    end
  else
    if ~isequal(Patch(:,end),Patch(:,1))
      Patch(:,end+1)=Patch(:,1);
    end
  end
  %
  % remove polygons of two or less points
  %
  if iscell(XY)
    for i=NShp:-1:1
      if size(XY{i},1)<=2,
        XY(i)=[];
        Val(i,:)=[]; % remove associated data
      end
    end
    NShp=length(XY);
  end
end
if length(filename)>3
  if strcmp(lower(filename(end-3:end)),'.shp'),
    filename=filename(1:end-4);
  elseif strcmp(lower(filename(end-3:end)),'.shx'),
    filename=filename(1:end-4);
  elseif strcmp(lower(filename(end-3:end)),'.dbf'),
    filename=filename(1:end-4);
  end
end
shapenm=[filename,'.shp'];
shapeidxnm=[filename,'.shx'];
shapedbf=[filename,'.dbf'];
fid=fopen(shapenm,'w','b');
fidx=fopen(shapeidxnm,'w','b');
fidb=fopen(shapedbf,'w','l');
fwrite(fid,[9994 0 0 0 0 0],'int32');
fwrite(fidx,[9994 0 0 0 0 0],'int32');
fwrite(fid,[0 0 0 0],'int8');
fwrite(fidx,[0 0 0 0],'int8');
fclose(fid);
fclose(fidx);

fid=fopen(shapenm,'a','l');
fidx=fopen(shapeidxnm,'a','l');
fwrite(fid,1000,'int32'); %version
fwrite(fidx,1000,'int32'); %version
%ShapeTps={'null shape' 'point'  '' 'polyline'  '' 'polygon'  '' '' 'multipoint'  '' ...
%          ''           'pointz' '' 'polylinez' '' 'polygonz' '' '' 'multipointz' '' ...
%          ''           'pointm' '' 'polylinem' '' 'polygonm' '' '' 'multipointm' '' ...
%          ''           'multipatch'};
fwrite(fid,DataType,'int32');
fwrite(fidx,DataType,'int32');
ranges=zeros(1,8);
if iscell(XY)
  ranges(1)=inf;
  ranges(2)=inf;
  ranges(3)=-inf;
  ranges(4)=-inf;
  for i=1:NShp
    ranges(1)=min(ranges(1),min(XY{i}(:,1)));
    ranges(2)=min(ranges(2),min(XY{i}(:,2)));
    ranges(3)=max(ranges(3),max(XY{i}(:,1)));
    ranges(4)=max(ranges(4),max(XY{i}(:,2)));
  end
else
  ranges(1)=min(XY(:,1));
  ranges(2)=min(XY(:,2));
  ranges(3)=max(XY(:,1));
  ranges(4)=max(XY(:,2));
end
fwrite(fid,ranges,'float64');
fwrite(fidx,ranges,'float64');
fclose(fidx);
fidx=fopen(shapeidxnm,'r+','b'); fseek(fidx,0,1);

fwrite(fidb,3,'uint8');
dv=clock;
fwrite(fidb,[dv(1)-1900 dv(2) dv(3)],'uint8');
fwrite(fidb,NShp,'uint32');
NFld=1+StoreVal;
fwrite(fidb,33+32*NFld,'uint16');
fwrite(fidb,1+11+17*StoreVal,'uint16'); % NBytesRec includes deleted flag (= first space): 1 + 11
fwrite(fidb,[0 0],'uint8'); % reserved
fwrite(fidb,0,'uint8'); % dBase IV flag
fwrite(fidb,0,'uint8');
fwrite(fidb,zeros(1,12),'uint8'); % dBase IV multi-user environment
fwrite(fidb,0,'uint8'); % Production Index Exists (Fp,dB4,dB5)
fwrite(fidb,0,'uint8'); % 1: USA, 2: MultiLing, 3: Win ANSI, 200: Win EE, 0: ignored
fwrite(fidb,[0 0],'uint8'); % reserved
for i=1:1+StoreVal
  Str=zeros(1,11);
  if i==1
    Str(1:2)='ID';
  elseif ~isempty(ValLbl{i-1})
    LStr=length(ValLbl{i-1});
    Str(1:LStr)=ValLbl{i-1};
  else
    Str(1:4)='Val ';
    ValNr=sprintf('%i',i-1);
    Str(5:4+length(ValNr))=ValNr;
  end
  fwrite(fidb,Str,'uchar');
  fwrite(fidb,'N','uchar');
  fwrite(fidb,[0 0 0 0],'uint8'); % memory address, record offset, ignored in latest versions
  if i==1
    fwrite(fidb,11,'uint8'); % Width
    fwrite(fidb,0,'uint8'); % Type='C' also Width
  else
    fwrite(fidb,17,'uint8'); % Width
    fwrite(fidb,8,'uint8'); % Type='C' also Width
  end
  fwrite(fidb,[0 0],'uint8'); % reserved
  fwrite(fidb,0,'uint8'); % dBase IV,V work area ID
  fwrite(fidb,[0 0],'uint8'); % multi-user dBase
  fwrite(fidb,0,'uint8'); % set fields
  fwrite(fidb,zeros(1,7),'uint8'); % reserved
  fwrite(fidb,0,'uint8'); % field is part of production index
end
fwrite(fidb,13,'uint8'); % end of header = 13
for i=1:NShp
  strtidx=ftell(fid);
  if DataType==1
    xy=XY(i,:);
    writeint32b(fid,[i 8]); % Nr, Size
    fwrite(fid,DataType,'int32');
    fwrite(fid,xy,'float64');
  else
    if iscell(XY)
      xy=XY{i};
    else
      ind=Patch(i,:);
      xy=XY(ind,:);
    end
    if (DataType==5) & (clockwise(xy(:,1),xy(:,2))<0)
      xy=flipud(xy);
    end
    NPnt=size(xy,1);
    writeint32b(fid,[i 24+8*NPnt]); % Nr, Size
    fwrite(fid,DataType,'int32');
    ranges=zeros(1,4);
    ranges(1)=min(xy(:,1));
    ranges(2)=min(xy(:,2));
    ranges(3)=max(xy(:,1));
    ranges(4)=max(xy(:,2));
    fwrite(fid,ranges,'float64');
    fwrite(fid,[1 NPnt 0],'int32'); % one part, N points, part starting at point 0
    fwrite(fid,xy','float64');
  end
  fwrite(fidx,[strtidx ftell(fid)-strtidx-4]/2,'int32');
end
fprintf(fidb,[' %11i' repmat('%17.8f',1,StoreVal)],[1:NShp;Val']);
fclose(fidb);
flid=ftell(fid);
fclose(fid);
fid=fopen(shapenm,'r+','b');
fseek(fid,24,-1);
fwrite(fid,flid/2,'int32');
fclose(fid);
flidx=ftell(fidx);
fseek(fidx,24,-1);
fwrite(fidx,flidx/2,'int32');
fclose(fidx);

function writeint32b(fid,X)
X=X(:);
N=length(X);
Tmp=sscanf(sprintf('%0.8x',X),'%2x',[4 N]);
fwrite(fid,Tmp,'uint8');