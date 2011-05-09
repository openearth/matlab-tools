function [Output,ErrorMsg]=ds_eval(DataStream,FieldNumber,Inputs),

Output=[];
ErrorMsg='';

if nargin<2,
  error('At least two input arguments expected.');
elseif ~isa(DataStream,'datastream'),
  ErrorMsg='First argument should be a datastream.';
  return;
end;

if nargin>2,
  if length(DataStream.InputCapacity)~=length(Inputs),
    ErrorMsg=['invalid number of arguments for process ', DataStream.Type];
    return;
  end;
end;

switch lower(DataStream.Type),
case 'group',
  if isempty(DataStream.Specs.OutputProcess), % No output process defined
    ErrorMsg='No output process defined.';
    return;
  elseif DataStream.Specs.OutputProcess>length(DataStream.Specs.Process),
    ErrorMsg='Non-existing output process.';
    return;
  end;

  ProcessState=zeros(1,length(DataStream.Specs.Process));
  CP=DataStream.Specs.OutputProcess;
  CPLevel=1;
  while CP>0,
    AllInputs=1;
    i=0;
    NInp=length(DataStream.Specs.Process(CP).Stream.InputCapacity);
    while AllInputs & (i<NInp),
      i=i+1;
      IFP=length(DataStream.Specs.Process(CP).InputFromProcess{i});
      if (DataStream.Specs.Process(CP).Stream.InputCapacity(i)==1) & (IFP~=1),
        ErrorMsg='One input process expected.';
        return;
      elseif (DataStream.Specs.Process(CP).Stream.InputCapacity(i)==0) & (IFP>1),
        ErrorMsg='Zero or one input process expected.';
        return;
      elseif (DataStream.Specs.Process(CP).Stream.InputCapacity(i)==inf) & (IFP==0),
        ErrorMsg='At least one input process expected.';
        return;
      end;
      j=0;
      while AllInputs & (j<IFP),
        j=j+1;
        k=DataStream.Specs.Process(CP).InputFromProcess{i}(j);
        if ~isfield(DataStream.Specs.Process(k),'OutputData'),
          AllInputs=0;
          DataStream.Specs.Process(k).OutputData={};
        elseif isempty(DataStream.Specs.Process(k).OutputData),
          AllInputs=0;
        end;
      end;
    end;
    if ~AllInputs,
      if strcmp(lower(DataStream.Specs.Process(CP).Stream.Type),'fieldrenumber'),
        % Store FieldNumber for other braches to be processed later
        DataStream.Specs.Process(CP).Stream.Specs.TempFieldNumber=FieldNumber;
        FieldNumber=DataStream.Specs.Process(CP).Stream.Specs.Renumber(FieldNumber);
      end;
      % go one ProcessLevel deeper
      ProcessState(CP)=CPLevel;
      CPLevel=CPLevel+1;
      CP=DataStream.Specs.Process(CP).InputFromProcess{i}(j);
    else,
      % evaluate the current process CP
      if isempty(DataStream.Specs.Process(CP).Stream.InputType), % Elementary Process, e.g. load
        [DataStream.Specs.Process(CP).OutputData,ErrorMsg]= ...
            ds_eval(DataStream.Specs.Process(CP).Stream,FieldNumber);
      else, % Other Process, e.g. diff
        if strcmp(lower(DataStream.Specs.Process(CP).Stream.Type),'fieldrenumber'),
          % Undo renumber effect on FieldNumber
          FieldNumber=DataStream.Specs.Process(CP).Stream.Specs.TempFieldNumber;
          k=DataStream.Specs.Process(CP).InputFromProcess{1};
          l=DataStream.Specs.Process(CP).InputFromConnector{1};
          DataStream.Specs.Process(CP).OutputData= ...
              {DataStream.Specs.Process(k).OutputData{l}};
        else,
          % collect input data
          Input={};
          i=0;
          NInp=length(DataStream.Specs.Process(CP).Stream.InputCapacity);
          while i<NInp,
            i=i+1;
            IFP=length(DataStream.Specs.Process(CP).InputFromProcess{i});
            j=0;
            while j<IFP,
              j=j+1;
              k=DataStream.Specs.Process(CP).InputFromProcess{i}(j);
              l=DataStream.Specs.Process(CP).InputFromConnector{i}(j);
              Input{i}{j}= ...
                  DataStream.Specs.Process(k).OutputData{l};
            end;
          end;
          % evaluate process
          % figure; cellplot(Input); title(DataStream.Specs.Process(CP).Stream.Type); drawnow;
          [DataStream.Specs.Process(CP).OutputData,ErrorMsg]=ds_eval(DataStream.Specs.Process(CP).Stream,FieldNumber,Input);
        end;
      end;
      % if the process has just one output connector the output is possibly not returned as a 1x1 cell array
      if ~iscell(DataStream.Specs.Process(CP).OutputData),
        DataStream.Specs.Process(CP).OutputData={DataStream.Specs.Process(CP).OutputData};
      end;
      if ~isempty(ErrorMsg),
        return;
      end;
      if CPLevel>1,
        % go one CPLevel back up
        CPLevel=CPLevel-1;
        CP=find(ProcessState==CPLevel);
        ProcessState(CP)=0;
      else,
        k=DataStream.Specs.OutputProcess; % k==CP
        l=DataStream.Specs.OutputConnector;
        Output= ...
            DataStream.Specs.Process(k).OutputData{l};
        CP=0;
      end;
    end;
  end;

case 'constantmatrix',
  Output{1}=ones(DataStream.Specs.Size)*DataStream.Specs.Scalar;

case 'loadfield',
  LF=DataStream.Specs.LoadField;
  Output{1}=[];
  EntryNr=1;
  TotalField=0;
  while (EntryNr<length(LF)) & ((TotalField+LF(EntryNr).NumberOfFields)<FieldNumber),
    TotalField=TotalField+LF(EntryNr).NumberOfFields;
    EntryNr=EntryNr+1;
  end;
  % Limit FieldNumber to available numbers
  FieldNumber=max(1,min(FieldNumber-TotalField,LF(EntryNr).NumberOfFields));
  % get data
  FileData=ideas('opendata',LF(EntryNr).FileType,LF(EntryNr).FileName);
  switch LF(EntryNr).FileType,
  case 'Delft3D-com',
    [Output{1},NowError]=ds_comfile(LF(EntryNr),FileData,FieldNumber);
  case 'Delft3D-botm',
    [Output{1},NowError]=ds_botmfile(LF(EntryNr),FileData,FieldNumber);
  case 'Delft3D-trim',
    [Output{1},NowError]=ds_trimfile(LF(EntryNr),FileData,FieldNumber);
  case 'Delft3D-tram',
    [Output{1},NowError]=ds_tramfile(LF(EntryNr),FileData,FieldNumber);
  otherwise,
    ErrorMsg=['Don''t know how to read from filetype: ',LF(EntryNr).FileType,'.'];
  end;

case 'sum',
  Output{1}=Inputs{1}{1};
  for i=2:length(Inputs{1}),
    Output{1}=Output{1}+Inputs{1}{i};
  end;

case 'multiply',
  Output{1}=Inputs{1}{1};
  for i=2:length(Inputs{1}),
    Output{1}=Output{1}.*Inputs{1}{i};
  end;

case 'inverse',
  INP=Inputs{1}{1};
  INP(INP==0)=NaN;
  Output{1}=1./INP;

case 'transpose',
  INP=Inputs{1}{1};
  Output{1}=transpose(INP);

case 'scalarmultiply',
  Output{1}=DataStream.Specs.Scalar*Inputs{1}{1};

case 'power',
  Output{1}=Inputs{1}{1}.^DataStream.Specs.Scalar;

case 'fieldrenumber',
  % nothing to evaluate

otherwise,
  ErrorMsg=['output undefined for' DataStream.Type];
  return;

end;
ErrorMsg='';