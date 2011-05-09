function Handles=xx_tag2handles(Tag);

Obj=xx_tag2obj(Tag);
if ~isempty(Obj),
  Handles=handles(Obj);
else,
  shh=get(0,'showhiddenhandles');
  set(0,'showhiddenhandles','on');
  Handles=findobj('tag',Tag);
  set(0,'showhiddenhandles',shh);
  Handles=xx_allitems(Handles(1));
end;
