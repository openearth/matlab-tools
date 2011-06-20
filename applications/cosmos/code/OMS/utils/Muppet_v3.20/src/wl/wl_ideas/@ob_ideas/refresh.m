function refresh(Obj),

refresh(Obj.TypeInfo);

%H=handles(Obj);
%if ~isempty(H),
%  MainHandle=H(1);
%  UserData=get(MainHandle,'userdata');
%  LinkObj=UserData.Info.LinkedObjects;
%  for j=1:length(LinkObj),
%    refresh(LinkObj(j));
%  end;
%end;