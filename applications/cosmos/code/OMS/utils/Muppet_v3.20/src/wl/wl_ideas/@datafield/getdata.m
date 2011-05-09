function Data=getdata(Obj,Label);

if length(Obj.Block)==0,
  Data=[];
  return;
end;

Labels={Obj.Var(:).Name};
fromvarnr=strmatch(Label,Labels,'exact');
if isempty(fromvarnr),
  fromvarnr=strmatch(Label,Labels);
end;
if ~isequal(size(fromvarnr),[1 1]),
  error('Variable label not unique.');
end;

for i=1:length(Obj.Block),
  Data{i}=Obj.Block(i).Var{fromvarnr};
end;