function stackudf(Handle,StackName,Value,Opt),
% STACKUDF Adds a code to a cell stack in a userdata field
%    STACKUDF(H,'StackName',NewCode) adds the new code to the
%    bottom of the stack stored in the field 'StackName' of the
%    structure stored in th UserData property of the graphics
%    object with handle H.
%    STACKUDF(H,'StackName',NewCode,'top') adds the new code to
%    the top of the stack.
%
%    See also SETUDF, GETUDF, ISUDF, RMUDF, WAITFORUDF.

% Copyright (c) 1999, H.R.A. Jagers, WL | delft hydraulics, The Netherlands

UserData=get(Handle,'userdata');
if ~isstruct(UserData),
  if ~isempty(UserData),
    uiwait(msgbox(['Overwriting nonstructure userdata.'],'modal'));
  end;
  UserData=[];
  Stack={Value};
elseif isfield(UserData,StackName),
  Stack=getfield(UserData,StackName);
  if (nargin==4) & strcmp(Opt,'top'),
    Stack={Value,Stack{:}};
  else,
    Stack{length(Stack)+1}=Value;
  end;
else,
  Stack={Value};
end;
UserData=setfield(UserData,StackName,Stack);
set(Handle,'userdata',UserData);
