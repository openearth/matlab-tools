function [OutStream,ErrorMsg]=fillsize(InStream,Inputs),
OutStream=InStream;
ErrorMsg='';

switch InStream.NInputConnectors,
case 0,
  if nargin>1,
    if ~isempty(Inputs),
      ErrorMsg=['too many input arguments for process ', InStream.Type];
      return;
    end;
  end;
case inf,
  if nargin==1,
    ErrorMsg=['not enough input arguments for process ', InStream.Type];
    return;
  end;
otherwise,
  if nargin==1,
    ErrorMsg=['not enough input arguments for process ', InStream.Type];
    return;
  elseif size(Inputs,2)~=InStream.NInputConnectors,
    ErrorMsg=['invalid number of arguments for process ', InStream.Type];
    return;
  end;
end;

switch lower(InStream.Type),
case 'group',
  if isempty(OutStream.Specs.OutputProcess), % No output process defined
    ErrorMsg='no output process defined';
    return;
  end;

  FieldNumber=1;
  ProcessState=zeros(length(OutStream.Specs.Process));
  CP=OutStream.Specs.OutputProcess;
  CPLevel=1;
  ReturnData=[];
  while CP>0,
    NumberOfInputs=size(OutStream.Specs.Process(CP).InputData,2);
    if NumberOfInputs<length(OutStream.Specs.Process(CP).InputFromProcess),
      % FieldRenumber : no renumbering during testing
      % go one ProcessLevel deeper if not in cycle
      ProcessState(CP)=CPLevel;
      CPLevel=CPLevel+1;
      if OutStream.Specs.Process(CP).InputFromProcess(NumberOfInputs+1)==0,
        ErrorMsg=['no input defined for input connector ' num2str(NumberOfInputs+1) ' of process ' OutStream.Specs.Process(CP).Name ];
        return;
      end;
      CP=OutStream.Specs.Process(CP).InputFromProcess(NumberOfInputs+1);
      if ProcessState(CP)~=0,
        ErrorMsg=['process ',CheckedStream.Process(CP).Name,' is used in a cycle.'];
        return;
      end;
    else,
      [OutStream.Specs.Process(CP).Stream,ErrMsg]=fillsize(OutStream.Specs.Process(CP).Stream,OutStream.Specs.Process(CP).InputData);
      if ~isempty(ErrorMsg),
        return;
      end;
      OutStream.Specs.Process(CP).InputData={};
      if CPLevel>1,
        % go one CPLevel back up and store number of fields
        NoF=OutStream.Specs.Process(CP).Stream.NumberOfFields;
        SoF=OutStream.Specs.Process(CP).Stream.FieldSize;
        CPLevel=CPLevel-1;
        CP=find(ProcessState==CPLevel);
        ProcessState(CP)=0;
        CurrentInput=size(OutStream.Specs.Process(CP).InputData,2)+1;
        OutStream.Specs.Process(CP).InputData{1,CurrentInput}=NoF;
        OutStream.Specs.Process(CP).InputData{2,CurrentInput}=SoF;
      else,
        % end of check;
        CP=0;
      end;
    end;
  end;
  
  OutStream.NumberOfFields=OutStream.Specs.Process(OutStream.Specs.OutputProcess).Stream.NumberOfFields;

case 'constantmatrix',
  OutStream.NumberOfFields=1;
  OutStream.FieldSize=OutStream.Specs.Size;

case 'loadfield',
  OutStream.NumberOfFields=sum([OutStream.Specs.LoadField(:).NumberOfFields]);
  if OutStream.NumberOfFields==0,
    ErrorMsg=['no fields available from ' CheckedStream.Process(CP).Name];
    return;
  end;
  OutStream.FieldSize=OutStream.Specs.LoadField(1).FieldSize;

case {'sum','multiply'},
  OutStream.NumberOfFields=max([Inputs{1,:}]);
  OutStream.FieldSize=[1 1];
  for i=1:size(Inputs,2),
    if ~isequal(OutStream.FieldSize,Inputs{2,i}),
      if isequal(OutStream.FieldSize,[1 1]),
        OutStream.FieldSize=Inputs{2,i};
      elseif ~isequal(Inputs{2,i},[1 1]),
        ErrorMsg=['inputs of ' OutStream.Type ' should not vary in size.'];
        return;
      end;
    end;
  end;

case {'inverse','scalarmultiply','power'},
  OutStream.NumberOfFields=Inputs{1,1};
  OutStream.FieldSize=Inputs{2,1};

case {'fieldrenumber'},
  OutStream.NumberOfFields=length(OutStream.Specs.Renumber);
  OutStream.FieldSize=Inputs{2,1};

otherwise,
  ErrorMsg=['number of fields undefined for' OutStream.Type];
  return;

end;
ErrorMsg='';