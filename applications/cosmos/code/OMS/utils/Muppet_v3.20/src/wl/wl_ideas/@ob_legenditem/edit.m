function AcceptPressed=edit(Obj),
AcceptPressed=0;

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;
AcceptPressed=edit(subtype(UD.Info.Object));