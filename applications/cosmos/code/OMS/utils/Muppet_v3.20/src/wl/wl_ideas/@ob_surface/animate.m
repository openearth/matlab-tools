function animate(Obj,AnimType,StepI),

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

switch AnimType,
case 'Datastream',
  switch StepI,
  case -inf,
    return; % No initialization necessary
  case inf, % reset
    refresh(Obj);
  otherwise,
    if ~isempty(Info.ShowTime),
      UD.Info.ShowTime=StepI;
    else,
      UD.Info.ShowFrame=StepI;
    end;
    set(MainItem,'userdata',UD); % change Info
    AllItems=refresh(Obj);
    MainItem=AllItems(1);
    UD.Info=Info; % reset Info
    set(MainItem,'userdata',UD);
  end;
end;