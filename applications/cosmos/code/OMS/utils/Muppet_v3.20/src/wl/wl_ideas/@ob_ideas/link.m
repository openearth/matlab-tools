function varargout=link(Obj,varargin),

if nargin==2,
  varargout={general_link(Obj,varargin{1})};
else,
  if nargout>1,
    [varargout{:}]=link(Obj.TypeInfo,varargin{:});
  elseif nargout>0,
    varargout={link(Obj.TypeInfo,varargin{:})};
  else,
    link(Obj.TypeInfo,varargin{:});
  end;
end;


function LinkOK=general_link(ObjFrom,ObjTo),

LinkOK=0;
H=handles(ObjFrom);
if ~isempty(H),
  MainHandle=H(1);
  UserData=get(MainHandle,'userdata');
  LinkObj=UserData.Info.LinkedObjects;
  if isempty(LinkObj),
    LinkObj=ObjTo;
  else,
    LinkObj(end+1)=ObjTo;
  end;
  UserData.Info.LinkedObjects=LinkObj;
  set(MainHandle,'userdata',UserData);
  LinkOK=1;
end;

