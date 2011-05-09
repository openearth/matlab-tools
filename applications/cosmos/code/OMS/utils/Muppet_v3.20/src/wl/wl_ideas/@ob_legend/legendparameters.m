function Info=legendparameters(Obj),
% @OB_IDEAS/LEGENDPARAMETERS returns the default info structure
% for the creation of a legenditem

H=handles(ob_ideas(Obj));
UD=get(H(1),'userdata');
Info.FontSize=UD.Info.FontSize;
Info.xUnit=UD.Info.xUnit;
Info.yUnit=UD.Info.yUnit;
