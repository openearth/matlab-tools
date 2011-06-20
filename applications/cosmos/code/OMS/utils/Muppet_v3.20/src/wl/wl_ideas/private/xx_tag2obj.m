function Obj=xx_tag2obj(Tag);

shh=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
Handles=findobj('tag',Tag);
set(0,'showhiddenhandles',shh);

UD=get(Handles,'userdata');
if ~iscell(UD),
  UD={UD};
end;
Obj=[];
for i=1:length(UD),
  if isstruct(UD{i}),
    if isfield(UD{i},'Object'),
      Obj=UD{i}.Object;
      return;
    end;
  end;
end;