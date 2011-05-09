function Out=pcraster(cmd,varargin);
% PCRASTER File operations for PC raster files.
%        FileInfo = pcraster('open',filename);
%           opens a PC raster file.

% (c) copyright, H.R.A. Jagers, 2001
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch cmd,
case 'open',
  Out=Local_open_file(varargin{:});
end;


function Structure=Local_open_file(filename),
Structure.Check='NotOK';
Structure.FileType='PCraster';

if (nargin==0) | strcmp(filename,'?'),
  [fn,fp]=uigetfile('*.map');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','l');
Structure.FileName=filename;
if ~strcmp(char(fread(fid,[1 27],'uchar')),'RUU CROSS SYSTEM MAP FORMAT')
  fclose(fid);
  error('Invalid PC raster header');
end
fread(fid,1,'uchar'); % 0
fread(fid,1,'int32'); % 0
fread(fid,1,'int32'); % 2
fread(fid,1,'int16'); % 0
fread(fid,1,'int16'); % 0 or 1
Structure.InfoTableOffset=fread(fid,1,'int32');
fread(fid,[1 2],'int16'); % 1 1
fread(fid,[1 4],'int32'); % 0 0 0 0
X=fread(fid,[1 2],'int16');
switch X(1)
case 240 % ldd
  Structure.PCRType='ldd';
  Structure.DataType='float32';
  NBytes=4;
case 235 % continuous, real, floating point
  Structure.PCRType='scalar';
  Structure.DataType='float32';
  NBytes=4;
case 226 % classified, integer
  if X(2)==0
    Structure.DataType='int8';
    NBytes=1;
  else
    Structure.DataType='int32';
    NBytes=4;
  end
case 224 % logical, integer
  Structure.PCRType='?';
  Structure.DataType='int8';
  NBytes=4;
otherwise
  fclose(fid)
  error('Unknown data type in PC raster file.');
end
Structure.MinData=fread(fid,1,Structure.DataType);
fread(fid,8-NBytes,'uchar'); % -1 -1 -1 -1
Structure.MaxData=fread(fid,1,Structure.DataType);
Structure.Flags2=fread(fid,8-NBytes,'uchar');% -1 -1 (-1 or 1) -1
if Structure.Flags2(3)==1
    fread(fid,6,'uchar');
end
Structure.Offset=fread(fid,[1 2],'float64'); % xoffset yoffset (upperleft corner)
Structure.Size=fread(fid,[1 2],'int32');
Structure.CellSize=fread(fid,[1 2],'float64'); % xsize ysize

fseek(fid,256,-1);
%Structure.DataOffset=ftell(fid);
Structure.Data=fread(fid,fliplr(Structure.Size),Structure.DataType)';

if Structure.InfoTableOffset~=0
  if Structure.InfoTableOffset~=ftell(fid)
    fclose(fid);
    error('Invalid PC raster info table offset');
  end
  Tp(10)=0;
  for t=1:10,
    Tp(t)=fread(fid,1,'int16'); % 6
    X=fread(fid,1,'int32'); % table
    if Tp(t)~=-1
      Structure.TableOffset(t)=X;
    end
    fread(fid,1,'int32'); % table size ...
  end
  for t=1:length(Structure.TableOffset),
    fseek(fid,Structure.TableOffset(t),-1);
    fread(fid,[1 64],'uchar');
    k=0;
    for i=Structure.MinData:Structure.MaxData,
      k=k+1;
      j=fread(fid,1,'int32');
      if i~=j
        fclose(fid);
        error('Invalid PC raster info table');
      end
      Str=char(fread(fid,[1 60],'uchar'));
      if t==1
        Structure.Table{k,1}=i;
      end
      Structure.Table{k,t+1}=deblank(Str);
    end
  end
end
fclose(fid);
Structure.Check='OK';
