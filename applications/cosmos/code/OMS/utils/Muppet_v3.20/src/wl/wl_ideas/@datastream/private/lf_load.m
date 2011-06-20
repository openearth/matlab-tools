function [EditedEntries,Input]=lf_load(InputIn);

EditedEntries=[];

if nargin==0,
  [filename,pname]=uigetfile('*.lst','select input file ...');
  if ischar(filename),
    filename=[pname filename];
    fid=fopen(filename,'r');
    if fid<0,
      uiwait(msgbox('Could not open output file.','modal'));
      return;
    end;
  end;
  Input.Fid=fid;
elseif isnumeric(InputIn),
  Input.Fid=InputIn;
else,
  Input=InputIn;
end;

i=0;
[Line,Input]=getnel(Input);
while ~isempty(Line),
  NewEntry.FileType=deblank(Line);
  [Line,Input]=getnel(Input);
  NewEntry.FileName=deblank(Line);
  [Succes,FileInfo]=md_filemem('openfile',NewEntry.FileType,NewEntry.FileName);
  if ~Succes,
    return;
  end;
  [Line,Input]=getnel(Input);
  NewEntry.EntryName=deblank(Line);
  NewEntry.EntryParameters=[];
  [Line,Input]=getl(Input);
  f=0;
  while ~isempty(deblank(Line)) & ~isequal(deblank(Line),'}'),
    locis=min(findstr(Line,' = '));
    if isempty(locis),
      uiwait(msgbox({'Invalid parameter definition:',Line},'modal'));
    else,
      fname=deblank(Line(1:locis));
      try,
        fvalue=eval(Line((locis+2):end));
        NewEntry.EntryParameters=setfield(NewEntry.EntryParameters,fname,fvalue);
      catch,
        uiwait(msgbox({'Invalid parameter definition:',Line},'modal'));
      end;
    end;
    [Line,Input]=getnel(Input);
  end;
  switch NewEntry.FileType,
  case 'Delft3D-com',
    [NewEntry,NowError]=ds_comfile(NewEntry,FileInfo.Data);
  case 'Delft3D-botm',
    [NewEntry,NowError]=ds_botmfile(NewEntry,FileInfo.Data);
  case 'Delft3D-trim',
    [NewEntry,NowError]=ds_trimfile(NewEntry,FileInfo.Data);
  case 'Delft3D-tram',
    [NewEntry,NowError]=ds_tramfile(NewEntry,FileInfo.Data);
  otherwise,
    uiwait(msgbox(['Don''t know how to edit entries from a ' FileInfo.FileType,' file.'],'modal'));
    NowError=1;
  end;

  i=i+1;
  if i==1,
    EditedEntries=NewEntry;
  else,
    EditedEntries(i)=NewEntry;
  end;
  if ~isequal(deblank(Line),'}'),
    [Line,Input]=getnel(Input);
  else,
    Line='';
  end;
end;

if nargin==0,
  fclose(fid);
end;



function [Line,Input]=getl(InputIn),
% get the next line from the Input

Input=InputIn;

Line='';
if isempty(Input.Fid),
  if Input.StrNr<=length(Input.CellStr),
    Line=Input.CellStr{Input.StrNr};
    Input.StrNr=Input.StrNr+1;
  end;
else,
  Line=fgetl(Input.Fid);
  if ~ischar(Line), Line=''; end;
end;


function [Line,Input]=getnel(InputIn),
% get the next non-empty line from the Input

Input=InputIn;

Line='';
if isempty(Input.Fid),
  while Input.StrNr<=length(Input.CellStr),
    Line=Input.CellStr{Input.StrNr};
    Input.StrNr=Input.StrNr+1;
    if ~isempty(Line),
      break;
    end;
  end;
else,
  while ~feof(Input.Fid) & isempty(Line),
    Line=fgetl(Input.Fid);
  end;
end;
