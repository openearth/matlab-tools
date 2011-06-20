function addto(Obj),

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

fig=get(MainItem,'parent');
its=findobj(fig);
itstag=get(its,'tag');
IDEAS_ob=strmatch('IDEAS',itstag); % find all objects with an IDEAS style tag

userdat=get(its(IDEAS_ob),'userdata'); % check their userdata for real IDEAS objects
for i=1:length(userdat),
  if isempty(userdat{i}) | ~isstruct(userdat{i}) | ~isfield(userdat{i},'Object'),
    IDEAS_ob(i)=0;
  end;
end;
userdat(IDEAS_ob==0)=[];
IDEAS_ob(IDEAS_ob==0)=[]; % remove handles that are not valid

% check object type
for i=1:length(userdat),
  if ~isempty(strmatch(type(userdat{i}.Object),{'legend','legenditem'})),
    IDEAS_ob(i)=0;
  end;
end;
userdat(IDEAS_ob==0)=[];
IDEAS_ob(IDEAS_ob==0)=[]; % remove handles that are not valid

if isempty(IDEAS_ob), % no objects left -> no legend item to create
  return;
end;

IDEAS_ob=ob_ideas;
for i=1:length(userdat),
  Name{i}=userdat{i}.Name;
  IDEAS_ob(i)=userdat{i}.Object;
end;

[selname,sellabel,selnr]=ui_typeandname(Name);

if isempty(selname), % cancel pressed?
  return;
end;

legoptions=get(MainItem,'userdata');

yUnit=legoptions.Info.yUnit;
xUnit=legoptions.Info.xUnit;
Pos=legoptions.Info.Pos;

% determine upperleft position for plotting
% and maximum width and height
legitems=setdiff(get(MainItem,'children'), ...
  [AllItems get(MainItem,'xlabel') get(MainItem,'ylabel') ...
  get(MainItem,'zlabel') get(MainItem,'title')]);

NextItPos=[Pos(1)+xUnit Pos(2)+Pos(4)-yUnit Pos(3)-2*xUnit Pos(4)-2*yUnit];
switch legoptions.Info.Border,
case {'text','line and text'},
  NextItPos(2)=NextItPos(2)-3*yUnit;
  NextItPos(4)=Pos(4)-NextItPos(2)-yUnit;
end;

for it=1:length(legoptions.Info.Items),
  Handles=handles(ob_ideas(legoptions.Info.Items(it)));
  if ~isempty(Handles),
    legbox=bbox(subtype(legoptions.Info.Items(it)));
    NextItPos(2)=min(NextItPos(2),legbox(2)-yUnit);
    NextItPos(4)=Pos(4)-NextItPos(2)-yUnit;
  end;
end;

Cmd.Name=sellabel;
Cmd.Legend=Obj;
Cmd.Object=IDEAS_ob(selnr);
Cmd.Pos=NextItPos;

NewObj=ob_legenditem(MainItem,Cmd);

legbox=bbox(subtype(NewObj));
NextItPos(2)=min(NextItPos(2),legbox(2)-yUnit);
NextItPos(4)=Pos(4)-NextItPos(2)-yUnit;

if legoptions.Info.AutoFit,
  Vrt=[Pos(1) NextItPos(2) -1; Pos(1) Pos(2)+Pos(4) -1; Pos(1)+Pos(3) Pos(2)+Pos(4) -1; Pos(1)+Pos(3) NextItPos(2) -1];
  set(AllItems(2),'vertices',Vrt);
end;

if isempty(legoptions.Info.Items),
  legoptions.Info.Items=NewObj;
else,
  legoptions.Info.Items(end+1)=NewObj;
end;
set(MainItem,'userdata',legoptions);
