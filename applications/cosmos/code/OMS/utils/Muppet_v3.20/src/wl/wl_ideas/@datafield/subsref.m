function B = subsref(Obj,S)
%DATAFIELD/SUBSREF

switch S(1).type
case {'()' '{}' }
case '.'
  switch lower(S(1).subs),
  case 'gridtype',
    switch length(Obj.Block),
    case 0,
      B='EMPTY';
    case 1,
      B=Obj.Block.Type;
    otherwise,
      B='MULTIBLOCK';
    end;
  case 'numvar',
    B=length(Obj.Var);
  otherwise,
    error('Invalid or restricted acces field of datafield object');
  end;
end
