function Out=mapper(cmd,varargin);
% MAPPER File operations for mapper files
%        InfoData = mapper('open',filename);
%           reads data from a mapper file.
%
%        MapData  = mapper('read',InfoData,'info');
%          reads info from a mapper file.
%
%        MapData  = mapper('read',InfoData,'lines');
%        MapData  = mapper('read',InfoData,'polys');
%        MapData  = mapper('read',InfoData,'names');
%        MapData  = mapper('read',InfoData,'id');
%
%        MapData  = mapper('read',InfoData,'line',Nr);

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch cmd,
case 'open',
  Structure=Local_open_mapper(varargin{:});
  if nargout>0,
    if ~isstruct(Structure),
      Out=[];
    elseif strcmp(Structure.Check,'NotOK'),
      Out=[];
    else,
      Out=Structure;
    end;
  end;
case 'read',
  TempOut=Local_read_mapper(varargin{:});
  if nargout>0,
    Out=TempOut;
  end;
otherwise,
  uiwait(msgbox(['unknown command: ',gui_str(cmd)],'modal'));
end;


function Structure=Local_open_mapper(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.mpl');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','ieee-le');

Structure.Type='mapper';
Structure.File=filename;

Structure.Version=char(fread(fid,[1 6],'uchar'));

switch Structure.Version
case 'MPL3.0',
  Structure.Extent=fread(fid,[1 4],'float32'); % xmin, ymin, xmax, ymax (world coords)
  Structure.Frame=fread(fid,[1 4],'int16'); % xmin, ymin, xmax, ymax (integer coords)
  Structure.NVectors=fread(fid,1,'int16');
  Structure.NLines=fread(fid,1,'int16');
  Structure.NPoints=fread(fid,1,'int16');
  Structure.NPolys=fread(fid,1,'int16');
  Structure.MaxLength=fread(fid,1,'int16');
  Structure.Caption=deblank(char(fread(fid,[1 16],'uchar')));
  Structure.LineStyle=fread(fid,1,'int16');
  Structure.LineColor=fread(fid,[1 3],'uint8');
  X=fread(fid,1,'uint8'); % dummy color (int32 -> 3 uint8)
  Structure.LineWidth=fread(fid,1,'float32');
  Structure.PntStyle=fread(fid,1,'int16');
  Structure.PntSize=fread(fid,1,'float32');
  Structure.FillStyle=fread(fid,1,'int16');
  Structure.FillColor=fread(fid,[1 3],'uint8');
  X=fread(fid,1,'uint8'); % dummy color (int32 -> 3 uint8)
  X=fread(fid,8,'uint8'); % XScale and YScale no longer in use
  Structure.InfoOffset=fread(fid,1,'int32');
  Structure.IDOffset=fread(fid,1,'int32');
  Structure.NmTableOffset=fread(fid,1,'int32');
  Structure.StartOfNames=fread(fid,1,'int32');
  Structure.StartOfCoords=fread(fid,1,'int32');
  if ~isequal(fread(fid,1,'int32'),0), % extra header position no longer in use
    close(fid);
    return;
  end;

  Structure.Check='OK';
otherwise,
  fprintf('Unsupported mapper version: %s\n',Structure.Version);
end;

fclose(fid);


function Out=Local_read_mapper(Structure,field,nr),
Out=[];
switch field,
case 'info',
  fid=fopen(Structure.File,'r','ieee-le');

  % min coordinates X,Y (int16)
  % max coordinates X,Y (int16)
  % 2 (int16)
  % number of points (int16)
  % offset (int32)
  fseek(fid,Structure.InfoOffset,-1);
  Tmp=fread(fid,[8 Structure.NVectors],'int16');
  Out.Rect=transpose(Tmp(1:4,:));
  Out.Type=transpose(mod(Tmp(5,:),16));
  Out.NSec=1+(transpose(Tmp(5,:))-Out.Type)/16;
  Out.NPnt=transpose(Tmp(6,:));
  Tmp(7,Tmp(7,:)<0)=Tmp(7,Tmp(7,:)<0)+65536;
  Tmp(8,Tmp(8,:)<0)=Tmp(8,Tmp(8,:)<0)+65536;
  Out.Offset=transpose(Tmp(7,:)+Tmp(8,:)*65536);
  fclose(fid);
case 'lines',
  Info=Local_read_mapper(Structure,'info');
  Info.Offset=(Info.Offset-Info.Offset(1))/2;

  NPnt=Info.NPnt;
  NSec=Info.NSec;
  TNData=sum(2*NPnt+NSec.*(NSec>1));
  TNSec=sum(NSec);

  % read X,Y coordinates and section lengths (int16)
  fid=fopen(Structure.File,'r','ieee-le');
  fseek(fid,Structure.StartOfCoords,-1);
  Coord=transpose(fread(fid,[1 TNData],'int16'));
  fclose(fid);

  NPnt(cumsum(NSec))=NPnt;
  for i=1:Structure.NVectors,
    if NSec(i)>1,
%      [ Info.Offset(i)+(1:NSec(i)) length(Coord)]
      NPnt(sum(NSec(1:(i-1)))+(1:NSec(i)))=Coord(Info.Offset(i)+(1:NSec(i)));
      Coord(Info.Offset(i)+(1:NSec(i)))=NaN;
    end;
  end;
  Coord(isnan(Coord))=[];
  Coord=transpose(reshape(Coord,2,length(Coord)/2));

  xStep=(Structure.Extent(3)-Structure.Extent(1))/(Structure.Frame(3)-Structure.Frame(1));
  yStep=(Structure.Extent(4)-Structure.Extent(2))/(Structure.Frame(4)-Structure.Frame(2));
  
  NaNInd=cumsum(NPnt+1);
  Ind=1:NaNInd(end);
  Ind(NaNInd)=[];
  Out=zeros(size(Coord,2),2);
  Out(NaNInd,1:2)=NaN;

  Out(Ind,1)=(Coord(:,1)-Structure.Frame(1))*xStep+Structure.Extent(1);
  Out(Ind,2)=(Coord(:,2)-Structure.Frame(2))*yStep+Structure.Extent(2);
case 'polys',
  fid=fopen(Structure.File,'r','ieee-le');

  fseek(fid,Structure.InfoOffset+10,-1);
  NPnts=fread(fid,[1 Structure.NVectors],'int16',14);
  TNPnts=sum(NPnts);

  % X,Y coordinates (int16)
  fseek(fid,Structure.StartOfCoords,-1);
  Coord=transpose(fread(fid,[2 TNPnts],'int16'));
  
  fclose(fid);

  xStep=(Structure.Extent(3)-Structure.Extent(1))/(Structure.Frame(3)-Structure.Frame(1));
  yStep=(Structure.Extent(4)-Structure.Extent(2))/(Structure.Frame(4)-Structure.Frame(2));

  Ind=1:(TNPnts+Structure.NVectors);
  NaNInd=cumsum(NPnts+1);
  Ind(NaNInd)=[];
  Out=zeros(TNPnts+Structure.NVectors,2);
  Out(NaNInd,1:2)=NaN;

  Out(Ind,1)=(Coord(:,1)-Structure.Frame(1))*xStep+Structure.Extent(1);
  Out(Ind,2)=(Coord(:,2)-Structure.Frame(2))*yStep+Structure.Extent(2);
case 'line',
  if nr>Structure.NVectors,
    return;
  end;
  fid=fopen(Structure.File,'r','ieee-le');

  fseek(fid,Structure.InfoOffset+16*(nr-1),-1);
  Info=fread(fid,[8 1],'int16');
  if Info(7)<0, Info(7)=Info(7)+65536; end;
  if Info(8)<0, Info(8)=Info(8)+65536; end;
  Offset=Info(7)+Info(8)*65536; % combine lines
  NPnt=Info(6);
  NSec=1+(Info(5)-mod(Info(5),16))/16;

  % read X,Y coordinates and section lengths (int16)
  fseek(fid,Offset,-1);
  Coord=transpose(fread(fid,[1 2*NPnt+NSec*(NSec>1)],'int16'));
  fclose(fid);

  if NSec>1,
    NPnt=Coord(1:NSec);
    Coord=Coord((NSec+1):end);
  end;
  Coord=transpose(reshape(Coord,2,length(Coord)/2));

  xStep=(Structure.Extent(3)-Structure.Extent(1))/(Structure.Frame(3)-Structure.Frame(1));
  yStep=(Structure.Extent(4)-Structure.Extent(2))/(Structure.Frame(4)-Structure.Frame(2));
  
  NaNInd=cumsum(NPnt+1);
  Ind=1:NaNInd(end);
  Ind(NaNInd)=[];
  Out=zeros(size(Coord,2),2);
  Out(NaNInd,1:2)=NaN;

  Out(Ind,1)=(Coord(:,1)-Structure.Frame(1))*xStep+Structure.Extent(1);
  Out(Ind,2)=(Coord(:,2)-Structure.Frame(2))*yStep+Structure.Extent(2);

case 'names',
  fid=fopen(Structure.File,'r','ieee-le');

  % offsets for names (uint32)
  fseek(fid,Structure.NmTableOffset,-1);
  ZZ=fread(fid,[1 Structure.NVectors],'int32');

  % nchars (uint8), name (char)
  Out=cell(1,Structure.NVectors);
  for i=1:Structure.NVectors,
    if ZZ(i)~=0,
      fseek(fid,ZZ(i),-1);
      N=fread(fid,1,'uint8');
      Out{i}=char(fread(fid,[1 N],'uchar'));
    else,
      Out{i}='';
    end;
  end;
  
  fclose(fid);
case 'id',
  fid=fopen(Structure.File,'r','ieee-le');

  % ID (8 * char)
  fseek(fid,Structure.IDOffset,-1);
  Out=char(transpose(fread(fid,[8 Structure.NVectors],'uchar')));
  
  fclose(fid);
end;