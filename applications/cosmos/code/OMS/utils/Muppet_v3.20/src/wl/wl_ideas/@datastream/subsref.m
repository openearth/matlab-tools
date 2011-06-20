function B = subsref(Obj,S)
%DATASTREAM/SUBSREF

switch S(1).type
case {'()' '{}' }
  B=ds_eval(Obj,S(1).subs{1});
  if length(S)>1,
    B=subsref(B,S(2:end));
  end;
case '.'
  switch S(1).subs
  case 'NumberOfFields',
    B=Obj.NumberOfFields;
  otherwise,
    error('Invalid or restricted acces field of datastream object');
  end;
end
