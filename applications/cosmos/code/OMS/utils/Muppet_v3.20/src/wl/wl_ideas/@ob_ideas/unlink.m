function varargout=unlink(Obj,varargin),

if nargin==2,
  varargout={general_unlink(Obj,varargin{1})};
else,
  if nargout>1,
    [varargout{:}]=unlink(Obj.TypeInfo,varargin{:});
  elseif nargout>0,
    varargout={unlink(Obj.TypeInfo,varargin{:})};
  else,
    unlink(Obj.TypeInfo,varargin{:});
  end;
end;


function LinkOK=general_unlink(ObjFrom,ObjTo),

LinkOK=0;
H=handles(ObjFrom);
if ~isempty(H),
  MainHandle=H(1);
  UserData=get(MainHandle,'userdata');
  LinkObj=UserData.Info.LinkedObjects;
  KeepLink=logical(ones(size(LinkObj)));
  for i=1:length(LinkObj),
    KeepLink=~isequal(LinkObj(i),ObjTo);
  end;
  UserData.Info.LinkedObjects=LinkObj(KeepLink);
  set(MainHandle,'userdata',UserData);
  LinkOK=1;
end;
