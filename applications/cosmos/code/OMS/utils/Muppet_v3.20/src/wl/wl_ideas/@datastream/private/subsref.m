function B = subsref(Obj,S)
%DATASTREAM/SUBSREF

switch S(1).type
case {'()' '{}' }
case '.'
  switch S(1).subs
  case 'OutputProcess',
    B=Obj.OutputProcess;
  case 'OutputConnector',
    B=Obj.OutputConnector;
  case 'NumberOfFields',
    B=Obj.NumberOfFields;
  case 'Process',
    B=Obj.Process;
  case 'Valid',
    B=Obj.Valid;
  end;
end
