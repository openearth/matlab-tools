function Obj = datastream(arg1,arg2);
% DATASTREAM creates a data stream object
%
%      Six different calls to this function can be expected:
% 
%      1. Obj=DATASTREAM
%         To create an empty group datastream.
%      2. Obj=DATASTREAM('Type')
%         To create a datastream of the specified type.
%      3. Obj=DATASTREAM(fid)
%         To create a group datastream from the specified file.
%      4. Obj=DATASTREAM('Type',fid)
%         To create a datastream of the specified type from the specified file.
%      5. Obj=DATASTREAM(CellStr)
%         To create a group datastream from the specified cell string.
%      6. Obj=DATASTREAM('Type',CellStr)
%         To create a datastream of the specified type from the specified cell string.

switch nargin,
case 0, % case 1: Obj=DATASTREAM,
  Obj=Local_datastream('Group');
case 1,
  if ischar(arg1), % case 2: Obj=DATASTREAM('Type')
    Obj=Local_datastream(arg1);
  elseif iscell(arg1), % case 5: Obj=DATASTREAM(CellStr)
    Input.CellStr=arg1;
    Input.StrNr=1;
    Input.Fid=[];
    Obj=Local_datastream('Group',Input);
  else, % case 3: Obj=DATASTREAM(fid)
    Input.CellStr={};
    Input.StrNr=1;
    Input.Fid=arg1;
    Obj=Local_datastream('Group',Input);
  end;
case 2,
  if iscell(arg2), % case 6: Obj=DATASTREAM('Type',CellStr)
    Input.CellStr=arg2;
    Input.StrNr=1;
    Input.Fid=[];
    Obj=Local_datastream(arg1,Input);
  else, % case 4: Obj=DATASTREAM('Type',fid)
    Input.CellStr={};
    Input.StrNr=1;
    Input.Fid=arg2;
    Obj=Local_datastream(arg1,Input);
  end;
end;

function [Obj,Input]=Local_datastream(Type,InputIn),

GridCell=20;

if nargin>1,
  Input=InputIn;
end;

Obj.Type=Type;
Obj.Specs=[];
Obj.InputCapacity=[];
Obj.InputType={};
Obj.OutputType={};
Obj.NumberOfFields=0;
Obj=class(Obj,'datastream');

CellStrIndex=1;
switch lower(Type),
case 'group',
  Obj.OutputType={'?'};
  Obj.Specs.OutputProcess=[];
  Obj.Specs.OutputConnector=[];
  Obj.Specs.Process=[];
  if nargin>1,
    ErrorMsg=[];
    [L,Input]=getnel(Input); % output = ..:..
    LocIs=findstr(L,'=');
    LocCol=findstr(L,':');
    Obj.Specs.OutputProcess=sscanf(L((LocIs+1):(LocCol-1)),'%i');
    Obj.Specs.OutputConnector=sscanf(L((LocCol+1):end),'%i');
    
    [L,Input]=getnel(Input); % ..:..:..
    while ~eoInput(Input) & ~isequal(L,'}') & isempty(ErrorMsg),
      LocCol=findstr(L,':');
      i=sscanf(L(1:(LocCol(1)-1)),'%i');
      OpType=L((LocCol(1)+1):(LocCol(2)-1));
      Obj.Specs.Process(i).Name=deblank(L((LocCol(2)+1):end));
      [L,Input]=getnel(Input); % LowerLeft = .. ..
      LocIs=findstr(L,'=');
      Obj.Specs.Process(i).PlotLocation=GridCell*sscanf(L((LocIs(1)+1):end),'%f',[1 2]);
      [L,Input]=getnel(Input); % .. inputs
      NInput=sscanf(L,'%i');
      Obj.Specs.Process(i).InputFromProcess=cell(1,NInput);
      Obj.Specs.Process(i).InputFromConnector=cell(1,NInput);
      Obj.Specs.Process(i).OutputData={};
      j=0;
      while (j<NInput) & isempty(ErrorMsg),
        j=j+1;
        [L,Input]=getnel(Input); % .. any number of times ..:..
        LocCol=findstr(L,':');
        LVal=strrep(L,':',' ');
        LVal=transpose(sscanf(LVal,'%i'));
        if isequal(j,LVal(1)) & isequal(length(LocCol)*2+1,length(LVal)),
          LVal=LVal(2:end);
          Obj.Specs.Process(i).InputFromProcess{j}=LVal(1:2:end);
          Obj.Specs.Process(i).InputFromConnector{j}=LVal(2:2:end);
        else,
          ErrorMsg=['Error interpreting: ''',L,'''.'];
        end;
      end;
      [L,Input]=getnel(Input); % {
      [Obj.Specs.Process(i).Stream,Input]=Local_datastream(OpType,Input);
      [L,Input]=getnel(Input);
    end;
    [Obj,ErrorMsg]=numfields(Obj);
    if ~isempty(ErrorMsg),
      uiwait(msgbox(ErrorMsg));
    end;
  end;
case 'loadfield',
  Obj.InputCapacity=[];
  Obj.InputType={};
  Obj.OutputType={'nD'};
  Obj.Specs.LoadField=[];
  if nargin>1,
    % construct further from input
    [Obj.Specs.LoadField,Input]=lf_load(Input);
    % } read as closing signal, so don't try to read it again
  end;
case 'constantmatrix',
  Obj.InputCapacity=[];
  Obj.InputType={};
  Obj.OutputType={'2D'};
  Obj.Specs.Scalar=0;
  Obj.Specs.Size=[1 1];
  if nargin>1,
    % construct further from input
    [L,Input]=getnel(Input);
    Obj.Specs.Scalar=sscanf(L,'%f');
    [L,Input]=getnel(Input);
    Obj.Specs.Size=eval(L,'[1 1]');
    [L,Input]=getnel(Input); % }
  end;
case 'sum',
  Obj.InputCapacity=[inf];
  Obj.InputType={'nD'};
  Obj.OutputType={'nD'};
  if nargin>1,
    % construct further from input
    % no parameters
    [L,Input]=getnel(Input); % }
  end;
case 'multiply',
  Obj.InputCapacity=[inf];
  Obj.InputType={'nD'};
  Obj.OutputType={'nD'};
  if nargin>1,
    % construct further from input
    % no parameters
    [L,Input]=getnel(Input); % }
  end;
case 'inverse',
  Obj.InputCapacity=[1];
  Obj.InputType={'nD'};
  Obj.OutputType={'nD'};
  if nargin>1,
    % construct further from input
    % no parameters
    [L,Input]=getnel(Input); % }
  end;
case 'transpose',
  Obj.InputCapacity=[1];
  Obj.InputType={'nD'};
  Obj.OutputType={'nD'};
  if nargin>1,
    % construct further from input
    % no parameters
    [L,Input]=getnel(Input); % }
  end;
case 'scalarmultiply',
  Obj.InputCapacity=[1];
  Obj.InputType={'nD'};
  Obj.OutputType={'nD'};
  Obj.Specs.Scalar=1;
  if nargin>1,
    % construct further from input
    [L,Input]=getnel(Input);
    Obj.Specs.Scalar=sscanf(L,'%f');
    [L,Input]=getnel(Input); % }
  end;
case 'power',
  Obj.InputCapacity=[1];
  Obj.InputType={'nD'};
  Obj.OutputType={'nD'};
  Obj.Specs.Scalar=1;
  if nargin>1,
    % construct further from input
    [L,Input]=getnel(Input);
    Obj.Specs.Scalar=sscanf(L,'%f');
    [L,Input]=getnel(Input); % }
  end;
case 'fieldrenumber',
  Obj.InputCapacity=[inf];
  Obj.InputType={'*'};
  Obj.OutputType={1};
  Obj.Specs.Renumber=[1];
  if nargin>1,
    % construct further from input
    [L,Input]=getnel(Input);
    Obj.Specs.Renumber=sscanf(L,'%f');
    [L,Input]=getnel(Input); % }
  end;
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


function TF=eoInput(Input),
% returns 1 if the end of the Input is reached

if isempty(Input.Fid),
  TF=Input.StrNr>length(Input.CellStr);
else,
  TF=feof(Input.Fid);
end;

