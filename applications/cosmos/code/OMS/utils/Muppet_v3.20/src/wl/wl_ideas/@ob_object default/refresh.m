function refresh(Obj);

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

ErrorMsg='';

% --------
%  Create / update object here
% --------

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
