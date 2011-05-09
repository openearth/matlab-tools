function Obj = subsasgn(Obj,S,B);
%DATASTREAM/SUBSASGN

switch S(1).type
case {'()' '{}' }
case '.'
  switch S(1).subs
  case 'OutputProcess',
    Obj.OutputProcess=B;
  case 'OutputConnector',
    Obj.OutputConnector=B;
  case 'NumberOfFields',
    Obj.NumberOfFields=B;
  case 'Process',
    Obj.Process=B;
  case 'Valid',
    Obj.Valid=B;
  end;
end




