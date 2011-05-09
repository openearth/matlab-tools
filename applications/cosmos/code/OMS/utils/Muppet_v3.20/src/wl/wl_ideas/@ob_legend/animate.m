function animate(Obj,AnimType,StepI),

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

switch AnimType,
case '<ANIMATION TYPE>',
  switch StepI,
  case -inf,
    % initialization
  case inf, % reset
    refresh(Obj);
  otherwise,
    % change Info
    set(MainItem,'userdata',UD);

    refresh(Obj);

    % reset Info
    UD.Info=Info;
    set(MainItem,'userdata',UD);
  end;
end;