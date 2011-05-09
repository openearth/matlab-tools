function [OutStream,ErrorMsg]=numfields(InStream,Inputs),
OutStream=InStream;
ErrorMsg='';

switch lower(InStream.Type),
case 'group',
  % first clear all old NumberOfFields fields
  for i=1:length(OutStream.Specs.Process),
    OutStream.Specs.Process(i).Stream.NumberOfFields=[];
  end;

  if isempty(OutStream.Specs.OutputProcess), % No output process defined
    ErrorMsg='No output process defined.';
    return;
  elseif OutStream.Specs.OutputProcess>length(OutStream.Specs.Process),
    ErrorMsg='Non-existing output process.';
    return;
  end;

  ProcessState=zeros(1,length(OutStream.Specs.Process));
  CP=OutStream.Specs.OutputProcess;
  CPLevel=1;
  while CP>0,
    AllInputs=1;
    i=0;
    NInp=length(OutStream.Specs.Process(CP).Stream.InputCapacity);
    while AllInputs & (i<NInp),
      i=i+1;
      IFP=length(OutStream.Specs.Process(CP).InputFromProcess{i});
      if (OutStream.Specs.Process(CP).Stream.InputCapacity(i)==1) & (IFP~=1),
        ErrorMsg='One input process expected.';
        return;
      elseif (OutStream.Specs.Process(CP).Stream.InputCapacity(i)==0) & (IFP>1),
        ErrorMsg='Zero or one input process expected.';
        return;
      elseif (OutStream.Specs.Process(CP).Stream.InputCapacity(i)==inf) & (IFP==0),
        ErrorMsg='At least one input process expected.';
        return;
      end;
      j=0;
      while AllInputs & (j<IFP),
        j=j+1;
        k=OutStream.Specs.Process(CP).InputFromProcess{i}(j);
        if isempty(OutStream.Specs.Process(k).Stream.NumberOfFields),
          AllInputs=0;
        end;
      end;
    end;
    if ~AllInputs,
      % FieldRenumber : no renumbering during testing
      % go one ProcessLevel deeper
      ProcessState(CP)=CPLevel;
      CPLevel=CPLevel+1;
      CP=OutStream.Specs.Process(CP).InputFromProcess{i}(j);
    else,
      % collect input data
      Input={};
      i=0;
      NInp=length(OutStream.Specs.Process(CP).Stream.InputCapacity);
      while i<NInp,
        i=i+1;
        IFP=length(OutStream.Specs.Process(CP).InputFromProcess{i});
        j=0;
        while j<IFP,
          j=j+1;
          k=OutStream.Specs.Process(CP).InputFromProcess{i}(j);
          Input{i}(j)= ...
              OutStream.Specs.Process(k).Stream.NumberOfFields;
        end;
      end;
      [OutStream.Specs.Process(CP).Stream,ErrorMsg]= ...
        numfields(OutStream.Specs.Process(CP).Stream,Input);
      if ~isempty(ErrorMsg),
        return;
      end;
      if CPLevel>1,
        % go one CPLevel back up
        CPLevel=CPLevel-1;
        CP=find(ProcessState==CPLevel);
        ProcessState(CP)=0;
      else,
        k=OutStream.Specs.OutputProcess; % k==CP
        OutStream.NumberOfFields=OutStream.Specs.Process(k).Stream.NumberOfFields;
        CP=0;
      end;
    end;
  end;

case 'constantmatrix',
  OutStream.NumberOfFields=1;

case 'loadfield',
  OutStream.NumberOfFields=sum([OutStream.Specs.LoadField(:).NumberOfFields]);
  if OutStream.NumberOfFields==0,
    ErrorMsg='no fields available from loadfield process.';
    return;
  end;

case {'sum','multiply'},
  OutStream.NumberOfFields=max(Inputs{1});

case {'inverse','scalarmultiply','power'},
  OutStream.NumberOfFields=Inputs{1};

case {'fieldrenumber'},
  OutStream.NumberOfFields=length(OutStream.Specs.Renumber);

otherwise,
  ErrorMsg=['number of fields undefined for' OutStream.Type];
  return;

end;
ErrorMsg='';