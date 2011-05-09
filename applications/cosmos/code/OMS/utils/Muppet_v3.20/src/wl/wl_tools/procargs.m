function [Struct,Err]=procargs(VARARGIN,CellFields,CellValues)
%PROCARGS General function for argument processing
%
%     [Struct,Err]=PROCARGS(VARARGIN,CellFields,CellValues)
%     Process the varargin fields from a function. The CellFields
%     and CellValues indicate the names and the default values of
%     the arguments. The CellFields should include fields: Name,
%     HasDefault, and Default.
%     The function returns an error string if an error is detected
%     while processing the arguments (errors in the syntax of the
%     PROCARGS call are handled as normal exceptions). The normal
%     output will be a structure containing a field for every
%     parameter listed in CellValues.

Struct=[];
Err='';

if nargin<2
  error('Not enough input arguments');
end
if ~isstruct(CellFields)
  if ~iscell(CellFields)
    error('Invalid second argument');
  elseif nargin<3
    error('Not enough input arguments');
  elseif ~iscell(CellValues)
    error('Invalid third argument');
  end
  Argument=cell2struct(CellValues,CellFields,2);
else
  Argument=CellFields;
end

Keywords={};
Number=[];
for i=1:length(Argument)
  if iscell(Argument(i).Name)
  elseif ischar(Argument(i).Name)
    Keywords{end+1}=Argument(i).Name;
    Number(end+1)=i;
  end
end

i=1;
while i<=length(VARARGIN)
  if ischar(VARARGIN{i})
    j=ustrcmpi(VARARGIN{i},Keywords);
    if j>0
      if i==length(VARARGIN)
        Err=['Missing value for ',Keywords{j}];
        return
      end
      j=Number(j);
      if Argument(j).HasDefault==2
        Err=[Argument(j).Name ' has been specified twice.'];
        return
      end
      Val=VARARGIN{i+1};  
      if isfield(Argument,'List')
        [Val,Err]=ListCheck(Val,Argument(j));
        if ~isempty(Err), return; end
      end
      Argument(j).Default=Val;
      Argument(j).HasDefault=2; % using 2 here to indicate that this variable has been specified
      VARARGIN(i:i+1)=[];
    else
      i=i+1;
    end
  else
    i=i+1;
  end
end

for i=1:length(VARARGIN)
  if i>length(Argument)
    Err='Too many arguments.';
    return
  elseif Argument(i).HasDefault==2
    Err=[Argument(i).Name ' has been specified twice.'];
    return
  end
  Val=VARARGIN{i};  
  if isfield(Argument,'List')
     [Val,Err]=ListCheck(Val,Argument(i));
     if ~isempty(Err), return; end
  end
  Argument(i).Default=Val;
  Argument(i).HasDefault=2; % using 2 here to indicate that this variable has been specified
end

for i=1:length(Argument)
  if Argument(i).HasDefault==0
    Err=['No value assigned to ',Argument(i).Name];
  end
end

Struct=cell2struct({Argument(:).Default},{Argument(:).Name},2);


function [Val,Err]=ListCheck(ValIn,Argument)
Err='';
Val=ValIn;
        if ~isempty(Argument.List)
          if iscellstr(Argument.List)
            jj=ustrcmpi(Val,Argument.List);
            OK=jj>0;
            if OK, Val=Argument.List{jj}; end
          else
            jj=find(Val,Argument.List);
            OK=~isempty(jj);
            if OK, Val=Argument.List(jj); end
          end
          if ~OK
            if iscellstr(Argument.List)
              List=Argument.List;
              if Argument.HasDefault
                jj=strmatch(Argument.Default,List,'exact');
                List{jj}=['{',List{jj},'}'];
              end
              Ops=sprintf('%s | ',List{:});
              Ops=['[ ',Ops(1:end-2),']'];
            elseif ischar(Argument.List)
              List=Argument.List;
              List=mat2cell(List,1,ones(1,length(List)));
              if Argument.HasDefault
                jj=strmatch(Argument.Default,List,'exact');
                List{jj}=['{',List{jj},'}'];
              end
              Ops=sprintf('%s | ',List{:});
              Ops=['[ ',Ops(1:end-2),']'];
            else
              List=Argument.List;
              List=mat2cell(List,1,ones(1,length(List)));
              for l=1:length(List)
                List{l}=sprintf('%g',List{l});
              end
              if Argument.HasDefault
                jj=find(Argument.List==Argument.Default);
                List{jj}=['{',List{jj},'}'];
              end
              Ops=sprintf('%s | ',List{:});
              Ops=['[ ',Ops(1:end-2),']'];
            end
            Err=['Invalid value for ',Argument.Name,'.',char(10),'Valid options are: ',Ops];
            return
          end
        end
