function Obj=edge(ObjIn,Order);

if nargin<2,
  error('Insufficient input arguments.');
end;

Obj=datafield;
Obj.Var=ObjIn.Var;

bnew=1;
for b=1:length(ObjIn.Block),
  switch lower(Obj.Block(b).Type),
  case 'uniform',
    switch Order,
    case 0, % corner points
      for v=1:length(Obj.Var),
        switch Obj.Var(v).Type,
        case 'cell',
        case 'vertex',
        end;
      end;
    case 1, % corner edges
    case 2, % corner faces
    end;
  case 'rectilinear',
    switch Order,
    case 0, % corner points
    case 1, % corner edges
    case 2, % corner faces
    end;
  case 'curvilinear',
    switch Order,
    case 0, % corner points
    case 1, % corner edges
    case 2, % corner faces
    end;
  case 'unstructured',
    switch Order,
    case 0, % corner points
    case 1, % corner edges
    case 2, % corner faces
    end;
  end;
end;