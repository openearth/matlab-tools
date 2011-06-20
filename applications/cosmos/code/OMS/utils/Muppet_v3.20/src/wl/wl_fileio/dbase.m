function varargout=dbase(cmd,varargin),
% DBASE read data from a dBase file
%
%     FI=DBASE('open','filename')
%     Open a dBase file.
%
%     Data=DBASE('read',FI,Records,Fields)
%     Read specified records from the opened dBase file.
%     Support 0 for reading all records / fields.

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
  Info=Local_open_dbase(varargin{:});
  varargout={Info};
case {'read'},
  Data=Local_read_dbase(varargin{:});
  varargout={Data};
otherwise,
  error('Unknown command');
end;


function S=Local_open_dbase(filename);
S.Check='NotOK';
S.FileType='dBase';

if (nargin==0) | strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.dbf','Select dBase file');
  if ~ischar(fname),
    return;
  end;
  filename=fullfile(fpath,fname);
end;

S.FileName=filename;
fid=fopen(filename,'r','l');
S.SubTypeNr=fread(fid,1,'uint8');
switch S.SubTypeNr
case 3,
  S.SubType='dBase III+';
case 4,
  S.SubType='dBase IV';
case 5,
  S.SubType='dBase V';
case {6,7,8,9,10},
  S.SubType=sprintf('dBase %i ?',S.SubTypeNr);
case 67,
  S.SubType='with .dbv memo var size';
case 131,
  S.SubType='dBase III+ with memo'; % .dbt
case 139,
  S.SubType='dBase IV with memo'; % .dbt
case 142,
  S.SubType='dBase IV with SQL table';
case 179,
  S.SubType='with .dbv and .dbt memo';
case 245,
  S.SubType='FoxPro with memo'; % .fmp
otherwise
  S.SubType='unknown';
end
Date=fread(fid,[1 3],'uint8');
if (Date(2)>12) | (Date(2)==0) | (Date(3)==0) | (Date(3)>31),
  error('Invalid date in dBase file.');
end
S.LastUpdate=datenum(Date(1)+1900,Date(2),Date(3));
S.NRec=fread(fid,1,'uint32');
S.HeaderBytes=fread(fid,1,'uint16');
S.NFld=(S.HeaderBytes-33)/32;
if S.NFld~=round(S.NFld)
  error('Invalid header size in dBase file.');
end
S.NBytesRec=fread(fid,1,'uint16'); % includes deleted flag
fread(fid,2,'uint8'); % reserved
fread(fid,1,'uint8'); % dBase IV flag
S.Encrypted=fread(fid,1,'uint8');
fread(fid,12,'uint8'); % dBase IV multi-user environment
S.ProdIndex=fread(fid,1,'uint8'); % Production Index Exists (Fp,dB4,dB5)
S.LangID=fread(fid,1,'uint8'); % 1: USA, 2: MultiLing, 3: Win ANSI, 200: Win EE, 0: ignored
fread(fid,2,'uint8'); % reserved
for i=1:S.NFld
  S.Fld(i).Name=deblank(char(fread(fid,[1 11],'uchar')));
  S.Fld(i).Type=char(fread(fid,1,'uchar'));
  fread(fid,[1 4],'uint8'); % memory address, record offset, ignored in latest versions
  S.Fld(i).Width=fread(fid,1,'uint8');
  S.Fld(i).NDec=fread(fid,1,'uint8'); % Type='C' also Width
  fread(fid,2,'uint8'); % reserved
  fread(fid,1,'uint8'); % dBase IV,V work area ID
  fread(fid,2,'uint8'); % multi-user dBase
  fread(fid,1,'uint8'); % set fields
  fread(fid,7,'uint8'); % reserved
  S.Fld(i).ProdIndex=fread(fid,1,'uint8'); % field is part of production index
end
Flag=fread(fid,1,'uint8'); % end of header
if Flag~=13,
  error('Invalid end of dBase header.');
end
Flag=fread(fid,1,'uint8'); % first record
if (Flag~=' ') & (Flag~='*'), % *=deleted
  error('Invalid first record in dBase file.');
end
fclose(fid);
S.Check='OK';


function Dbs=Local_read_dbase(S,Records,Fields);
if ~isequal(Records,0)
  Records=Records(:);
  if any((Records>S.NRec) | (Records<1) | (Records~=round(Records)))
    error('Invalid record number.');
  end
end
if isequal(Fields,0)
  Fields=1:S.NFld;
else
  Fields=Fields(:)';
  if any((Fields>S.NFld) | (Fields<1) | (Fields~=round(Fields)))
    error('Invalid field number.');
  end
end
fid=fopen(S.FileName,'r','l');
Dbs=cell(1,length(Fields));
for j=1:length(Fields)
  i=Fields(j);
  fseek(fid,S.HeaderBytes+1+sum([S.Fld(1:(i-1)).Width]),-1);
  switch S.Fld(i).Type
  case '2' % binary (int16)
    ReadFld=fread(fid,[S.NRec 1],'int16',S.NBytesRec-2);
  case '4' % binary (int32)
    ReadFld=fread(fid,[S.NRec 1],'int32',S.NBytesRec-4);
  case '8' % binary (float64)
    ReadFld=fread(fid,[S.NRec 1],'float64',S.NBytesRec-8);
  case {'B','G','M','P'} % (10 digit block or 10 spaces)
    % B binary: binary data in .dbt
    % G general (FoxPro)
    % M dbt memo index
    % P picture (FoxPro): binary data in .ftp
    Format=sprintf('%%%ic%%*%ic',S.Fld(i).Width,S.NBytesRec-S.Fld(i).Width);
    g=fscanf(fid,Format,[S.NRec 1]);
    g=reshape(g,size(g'))';
    ReadFld=cellstr(g);
  case 'C' % character
    Format=sprintf('%%%ic%%*%ic',S.Fld(i).Width,S.NBytesRec-S.Fld(i).Width);
    g=fscanf(fid,Format,[S.NRec 1]);
    g=reshape(g,size(g'))';
    ReadFld=cellstr(g);
  case 'D' % date: YYYYMMDD, Width=8
    Format=sprintf('%%4i%%2i%%2i%%*%ic',S.NBytesRec-S.Fld(i).Width);
    T=fscanf(fid,Format,[3 S.NRec]);
    ReadFld=datenum(T(1,:),T(2,:),T(3,:));
  case {'F','N'} % F floating point, or N numeric
    Format=sprintf('%%%if%%*%ic',S.Fld(i).Width,S.NBytesRec-S.Fld(i).Width);
    ReadFld=fscanf(fid,Format,[S.NRec 1]);
  case 'L' % logical (T:t,F:f,Y:y,N:n,? or space)
    Format=sprintf('%%%ic%%*%ic',S.Fld(i).Width,S.NBytesRec-S.Fld(i).Width);
    ReadFld=upper(fscanf(fid,Format,[S.NRec 1]));
  otherwise
    error('Invalid dBase field type.');
  end
  if isequal(Records,0)
    Dbs{j}=ReadFld;
  else
    Dbs{j}=ReadFld(Records);
  end
end
fclose(fid);