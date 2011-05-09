function delete(Obj,PartOfRefresh)

if nargin==1,
  PartOfRefresh=0;
end;

H=handles(ob_ideas(Obj));
if isempty(H),
  return;
end;
UD=get(H(1),'userdata');
delete(H);
if isstruct(UD) & ~PartOfRefresh,
  refresh(UD.Info.Legend);
end;
