function [Output,ErrorMsg]=eval(DataStream,FieldNumber,Inputs),

Output=[];
ErrorMsg='';

switch nargin,
case 2,
  [Output,ErrorMsg]=ds_eval(DataStream,FieldNumber);
case 3,
  [Output,ErrorMsg]=ds_eval(DataStream,FieldNumber,Inputs);
end;

%if nargin<2,
%  error('At least two input arguments expected.');
%elseif ~isa(DataStream,'datastream'),
%  ErrorMsg='First argument should be a datastream.';
%  return;
%end;
%
%switch DataStream.NInputConnectors,
%case 0,
%  if nargin>2,
%    if ~isempty(Inputs),
%      ErrorMsg=['too many input arguments for process ', DataStream.Type];
%      return;
%    end;
%  end;
%case inf,
%  if nargin==2,
%    ErrorMsg=['not enough input arguments for process ', DataStream.Type];
%    return;
%  end;
%otherwise,
%  if nargin==2,
%    ErrorMsg=['not enough input arguments for process ', DataStream.Type];
%    return;
%  elseif size(Inputs,2)~=DataStream.NInputConnectors,
%    ErrorMsg=['invalid number of arguments for process ', DataStream.Type];
%    return;
%  end;
%end;
%
%switch lower(DataStream.Type),
%case 'group',
%  if isempty(DataStream.Specs.OutputProcess), % No output process defined
%    ErrorMsg='no output process defined';
%    return;
%  end;
%
%  ProcessState=zeros(length(DataStream.Specs.Process));
%  CP=DataStream.Specs.OutputProcess;
%  CPLevel=1;
%  ReturnData={};
%  while CP>0,
%    if CP>length(DataStream.Specs.Process),
%      NowError=1;
%      return;
%    else,
%      NumberOfInputs=length(DataStream.Specs.Process(CP).InputData);
%      if NumberOfInputs<length(DataStream.Specs.Process(CP).InputFromProcess),
%        if strcmp(lower(DataStream.Specs.Process(CP).Stream.Type),'fieldrenumber'),
%          % Store FieldNumber for other braches to be processed later
%          DataStream.Specs.Process(CP).Stream.Specs.TempFieldNumber=FieldNumber;
%          FieldNumber=DataStream.Specs.Process(CP).Stream.Specs.Renumber(FieldNumber);
%        end;
%        % go one ProcessLevel deeper
%        ProcessState(CP)=CPLevel;
%        CPLevel=CPLevel+1;
%        CP=DataStream.Specs.Process(CP).InputFromProcess(NumberOfInputs+1);
%      else,
%        % evaluate the current process CP
%        if (DataStream.Specs.Process(CP).Stream.NInputConnectors==0), % Elementary Process, e.g. load
%          [ReturnData,ErrorMsg]=ds_eval(DataStream.Specs.Process(CP).Stream,FieldNumber);
%        else, % Other Process, e.g. diff
%          if strcmp(lower(DataStream.Specs.Process(CP).Stream.Type),'fieldrenumber'),
%            % Undo renumber effect on FieldNumber
%            FieldNumber=DataStream.Specs.Process(CP).Stream.Specs.TempFieldNumber;
%            ReturnData=DataStream.Specs.Process(CP).InputData{1};
%          else,
%            [ReturnData,ErrorMsg]=ds_eval(DataStream.Specs.Process(CP).Stream,FieldNumber,DataStream.Specs.Process(CP).InputData);
%          end;
%          DataStream.Specs.Process(CP).InputData={}; % remove all temporarily stored data
%        end;
%        if ~isempty(ErrorMsg),
%          return;
%        end;
%        if CPLevel>1,
%          % go one CPLevel back up and store ReturnData
%          CPLevel=CPLevel-1;
%          CP=find(ProcessState==CPLevel);
%          ProcessState(CP)=0;
%          CurrentInput=length(DataStream.Specs.Process(CP).InputData)+1;
%          DataStream.Specs.Process(CP).InputData{CurrentInput}=ReturnData{DataStream.Specs.Process(CP).InputFromConnector(CurrentInput)};
%        else,
%          Output=ReturnData{DataStream.Specs.OutputConnector};
%          CP=0;
%        end;
%      end;
%    end;
%  end;
%
%case 'constantmatrix',
%  Output{1}=ones(DataStream.Specs.Size)*DataStream.Specs.Scalar;
%
%case 'loadfield',
%  LF=DataStream.Specs.LoadField;
%  Output{1}=[];
%  EntryNr=1;
%  TotalField=0;
%  while (EntryNr<length(LF)) & ((TotalField+LF(EntryNr).NumberOfFields)<FieldNumber),
%    TotalField=TotalField+LF(EntryNr).NumberOfFields;
%    EntryNr=EntryNr+1;
%  end;
%  % Limit FieldNumber to available numbers
%  FieldNumber=max(1,min(FieldNumber-TotalField,LF(EntryNr).NumberOfFields));
%  % get data
%  FileData=ideas('opendata',LF(EntryNr).FileType,LF(EntryNr).FileName);
%  switch LF(EntryNr).FileType,
%  case 'Delft3D-com',
%    [Output{1},NowError]=ds_comfile(LF(EntryNr),FileData,FieldNumber);
%  case 'Delft3D-botm',
%    [Output{1},NowError]=ds_botmfile(LF(EntryNr),FileData,FieldNumber);
%  case 'Delft3D-trim',
%    [Output{1},NowError]=ds_trimfile(LF(EntryNr),FileData,FieldNumber);
%  case 'Delft3D-tram',
%    [Output{1},NowError]=ds_tramfile(LF(EntryNr),FileData,FieldNumber);
%  otherwise,
%    ErrorMsg=['Don''t know how to read from filetype: ',LF(EntryNr).FileType,'.'];
%  end;
%
%case 'sum',
%  Output{1}=Inputs{1};
%  for i=2:length(Inputs),
%    Output{1}=Output{1}+Inputs{i};
%  end;
%
%case 'multiply',
%  Output{1}=Inputs{1};
%  for i=2:length(Inputs),
%    Output{1}=Output{1}.*Inputs{i};
%  end;
%
%case 'inverse',
%  INP=Inputs{1};
%  INP(INP==0)=NaN;
%  Output{1}=1./INP;
%
%case 'scalarmultiply',
%  Output{1}=DataStream.Specs.Scalar*Inputs{1};
%
%case 'power',
%  Output{1}=Inputs{1}.^DataStream.Specs.Scalar;
%
%case 'fieldrenumber',
%  % nothing to evaluate
%
%otherwise,
%  ErrorMsg=['output undefined for' DataStream.Type];
%  return;
%
%end;
%ErrorMsg='';