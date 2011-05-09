function refresh(Obj);

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

ErrorMsg='';

% --------
%  Create / update object here
% --------

Info.Legend=handles(ob_ideas(Info.Legend));
Info.Legend=Info.Legend(1);
try,
  Info=UD.Info;
  if ~isempty(UD.CurrentPos) & (Info.Pos(3)==UD.CurrentPos(3)), % just shift
    Shift=Info.Pos(1:2)-UD.CurrentPos(1:2);
    cl=handles(ob_ideas(Obj));
    for i=cl,
      switch get(i,'type'),
      case 'text',
        TmpPos=get(i,'position');
        TmpPos(1:2)=TmpPos(1:2)+Shift(1:2);
        set(i,'position',TmpPos);
      otherwise,
        TmpX=get(i,'xdata');
        TmpY=get(i,'Ydata');
        set(i,'xdata',TmpX+Shift(1),'ydata',TmpY+Shift(2));
      end;
    end;
    UD.Name=UD.Info.Name;
    UD.CurrentPos=Info.Pos;
    set(Handles(1),'userdata',UD);
  else,
    delete(Obj,1);
    Info.Prm=legendparameters(Info.Legend);
    Info.Legend=handles(ob_ideas(Info.Legend));
    Info.Legend=Info.Legend(1);
    Handles=legend(UD.Info.Object,Info);
    if isempty(Handles),
      Handles=line('parent',Info.Legend,'visible','off','xdata',[],'ydata',[]);
    end;
    set(Handles,'tag',tag(Obj));
    UD.Name=UD.Info.Name;
    set(Handles(1),'userdata',UD);
  end;
%try,
catch,
  ErrorMsg={sprintf('Error detected in @%s at line 51:',mfilename),lasterr};
  Handles=handles(ob_ideas(Obj));
  if isempty(Handles),
    Handles=line('parent',Info.Legend,'visible','off','xdata',[],'ydata',[]);
  end;
  set(Handles,'tag',tag(Obj));
  UD.Name=UD.Info.Name;
  set(Handles(1),'userdata',UD);
end;

if ~isempty(ErrorMsg),
  ui_message('error',ErrorMsg);
end;

function Str=OnOff(L),
if L,
  Str='on';
else,
  Str='off';
end;
