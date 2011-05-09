function L=isempty(Obj),

TObj=struct(Obj);
L=length(TObj);
for i=1:length(TObj),
  L(i)=isempty(TObj(i).Type);
end;
L=logical(L);
