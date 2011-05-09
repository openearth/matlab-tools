function refresh(Obj);

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

ErrorMsg='';

% --------
%  Create / update object here
% --------

yUnit=Info.yUnit;
xUnit=Info.xUnit;

Pos=Info.Pos;
ymin=Pos(2)+Pos(4)-yUnit;

set(allchild(MainItem),'visible',OnOff(Info.Visible));
switch Info.Border,
case {'line','line and text'},
  set(AllItems(2),'visible','on');
otherwise,
  set(AllItems(2),'visible','off');
end;

if ~isequal(UD.CurrentPos,Info.Pos),
  TPos=[Pos(1)+xUnit Pos(2)+Pos(4)-yUnit 0];
  set(AllItems(3),'position',TPos);
  UD.CurrentPos=Pos;
end;

NextItPos=[Pos(1)+xUnit Pos(2)+Pos(4)-yUnit Pos(3)-2*xUnit Pos(4)-2*yUnit];
switch Info.Border,
case {'text','line and text'},
  set(AllItems(3),'visible','on','string',Info.BorderText);
  NextItPos(2)=NextItPos(2)-3*yUnit;
  NextItPos(4)=Pos(4)-NextItPos(2)-yUnit;
otherwise,
  set(AllItems(3),'visible','off','string','');
end;

Del=logical(zeros(1,length(Info.Items)));
for it=1:length(Info.Items),
  Handles=handles(ob_ideas(Info.Items(it)));
  if ~isempty(Handles),
    UDH=get(Handles(1),'userdata');
    UDH.Info.Pos=NextItPos;
    set(Handles(1),'userdata',UDH);
    refresh(Info.Items(it));
    legbox=bbox(subtype(Info.Items(it)));
    NextItPos(2)=min(NextItPos(2),legbox(2)-yUnit);
    NextItPos(4)=Pos(4)-NextItPos(2)-yUnit;
  else,
    Del(it)=1;
  end;
end;
if any(Del),
  Info.Items(Del)=[];
end;
UD.Info=Info;

if Info.AutoFit,
  Vrt=[Pos(1) NextItPos(2) -1; Pos(1) Pos(2)+Pos(4) -1; Pos(1)+Pos(3) Pos(2)+Pos(4) -1; Pos(1)+Pos(3) NextItPos(2) -1];
  set(AllItems(2),'vertices',Vrt);
end;

if ~isempty(ErrorMsg),
  uiwait(msgbox(ErrorMsg,'modal'));
end;

UD.Name=UD.Info.Name;
set(MainItem,'userdata',UD);


function Str=OnOff(L),
if L,
  Str='on';
else,
  Str='off';
end;
