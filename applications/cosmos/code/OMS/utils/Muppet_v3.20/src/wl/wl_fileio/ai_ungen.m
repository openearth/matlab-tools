function varargout=ai_ungen(cmd,varargin),
% AI_UNGEN File operations for ArcInfo (un)generate files
%
%     XY=AI_UNGEN('read',FileName)
%     [X,Y]=AI_UNGEN('read',FileName)
%        Reads the specified file.
%
%     AI_UNGEN('write',FileName,XY)
%     AI_UNGEN('write',FileName,X,Y)
%        Writes the line segments to file. X,Y should either
%        contain NaN separated line segments or X,Y cell arrays
%        containing the line segments.
%     AI_UNGEN(...,'-1')
%        Doesn't write line segments of length 1.

% (c) Copyright Delft Hydraulics, 2001.
%     Created by H.R.A. Jagers, University of Twente / Delft Hydraulics.

if nargout>0,
  varargout=cell(1,nargout);
end;
if nargin==0,
  return;
end;
switch cmd,
case 'read',
  Out=Local_read_file(varargin{:});
  if nargout==1,
    varargout{1}=Out;
  elseif nargout>1,
    varargout{1}=Out(:,1);
    varargout{2}=Out(:,2);
  end;
case 'write',
  Local_write_file(varargin{:});
otherwise,
  uiwait(msgbox('unknown command','modal'));
end;


function Data=Local_read_file(filename);
Data=[];
if nargin==0,
  [fn,fp]=uigetfile('*.gen');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;

fid=fopen(filename,'r');
i=0;
ok=0;
TPrev=[];
Points=0;
while ~feof(fid)
  if isempty(TPrev)
    Line=fgetl(fid);
    id=sscanf(Line,'%f%*[ ,]');
    if length(id)>1
      Points=1;
    end
  end
  if isempty(id),
    END=sscanf(Line,' %[eE]%[nN]%[dD]',3);
    if ~isempty(END) & ~isequal(upper(END),'END')
      fclose(fid);
      error('Missing closing END statement in file.');
    end
    ok=1;
    break
  end
  i=i+1;
  if Points
    T(i).Id=id(1);
    T(i).Coord=id(2:end)';
    TPrev=[];
  else
    T(i).Id=id;
    T(i).Coord=fscanf(fid,'%f%*[ ,]%f\n',[2 inf])';
    if ~isempty(TPrev),
      T(i).Coord=cat(1,TPrev,T(i).Coord);
      TPrev=[];
    end
    END=fscanf(fid,'%[eE]%[nN]%[dD]',3);
    if isempty(END)
      id=T(i).Coord(end-1,1);
      TPrev(1,1)=T(i).Coord(end-1,2);
      TPrev(1,2)=T(i).Coord(end,1);
      T(i).Coord=T(i).Coord(1:end-2,:);
    elseif ~isequal(upper(END),'END')
      fclose(fid);
      error('Unexpected characters.');
    end
  end
  if feof(fid), ok=1; end
end
fclose(fid);
if ~ok
  error('Missing closing END statement in file.');
end

nel=0;
for i=1:length(T)
  nel=nel+size(T(i).Coord,1)+1;
end
nel=nel-1;
Data=repmat(NaN,nel,2);
offset=0;
for i=1:length(T)
  t1=size(T(i).Coord,1);
  Data(offset+(1:t1),:)=T(i).Coord;
  offset=offset+t1+1;
end


function Local_write_file(filename,varargin);

if nargin==1,
  Data=filename;
  [fn,fp]=uiputfile('*.*');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;

j=0;
RemoveLengthOne=0;
XYSep=0;
for i=1:nargin-1
  if ischar(varargin{i}) & strcmp(varargin{i},'-1')
    RemoveLengthOne=1;
  elseif (isnumeric(varargin{i}) | iscell(varargin{i})) & j==0
    Data1=varargin{i};
    j=j+1;
  elseif (isnumeric(varargin{i}) | iscell(varargin{i})) & j==1
    Data2=varargin{i};
    XYSep=1; % x and y supplied separately?
  else
    error(sprintf('Invalid input argument %i',i+2))
  end
end

if ~iscell(Data1) % convert to column vectors
  if XYSep
    Data1=Data1(:);
    Data2=Data2(:);
  else
    if size(Data1,2)~=2 % [x;y] supplied
      Data1=transpose(Data1);
    end
  end
end

if iscell(Data1),
  j=0;
  for i=1:length(Data1),
    if XYSep
      Length=length(Data1{i}(:));
    else
      if size(Data1{i},2)~=2
        Data1{i}=transpose(Data1{i});
      end  
      Length=size(Data1{i},1);
    end
    if ~(isempty(Data1{i}) | (RemoveLengthOne & Length==1)), % remove lines of length 0 (and optionally 1)
      j=j+1;
      T(j).Id = j;
      if XYSep
        T(j).Data = [Data1{i}(:) Data2{i}(:)];
      else
        T(j).Data = Data1{i};
      end
    end;
  end;
elseif ~isstruct(Data1),
  I=[0; find(isnan(Data1(:,1))); size(Data1,1)+1];
  j=0;
  for i=1:(length(I)-1),
    if I(i+1)>(I(i)+1+RemoveLengthOne), % remove lines of length 0  (and optionally 1)
      j=j+1;
      T(j).Id = j;
      if XYSep
        T(j).Data = [Data1((I(i)+1):(I(i+1)-1)) Data2((I(i)+1):(I(i+1)-1))];
      else
        T(j).Data = Data1((I(i)+1):(I(i+1)-1),:);
      end
    end;
  end;
end;

fid=fopen(filename,'w');
for j=1:length(T)
  fprintf(fid,'%d\n',T(j).Id);
  fprintf(fid,'%f, %f\n',transpose(T(j).Data));
  fprintf(fid,'END\n');
end
fprintf(fid,'END\n');
fclose(fid);