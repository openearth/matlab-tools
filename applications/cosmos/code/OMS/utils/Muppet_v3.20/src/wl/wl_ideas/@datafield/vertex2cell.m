function [Obj,varnr]=vertex2cell(ObjIn,Label);

Obj=ObjIn;
if nargin<2,
  error('Insufficient input arguments.');
end;

if ischar(Label),
  Labels={Obj.Var(:).Name};
  fromvarnr=strmatch(Label,Labels,'exact');
  if isempty(fromvarnr),
    fromvarnr=strmatch(Label,Labels);
  end;
  if ~isequal(size(fromvarnr),[1 1]),
    error('Variable label not unique.');
  end;
elseif Label>length(Obj.Var),
  error('Variable index too large.');
else,
  fromvarnr=Label
end;

switch Obj.Var(fromvarnr).Type,
case 'cell', % contains cell data - nothing to interpolate!
  varnr=fromvarnr;
  return;
case 'vertex',
otherwise,
  error('Specified variable does not contain vertex data.');
end;

varnr=length(Obj.Var)+1;
Obj.Var(varnr).Name=[Obj.Var(fromvarnr).Name ' in cells'];
Obj.Var(varnr).Type='cell';

for b=1:length(Obj.Block),
  Obj.Block(b).Var{varnr}=Local_interpolate(Obj.Block(b),fromvarnr);
end;


function NewVar=Local_interpolate(Block,fromvarnr);
switch lower(Block.Type),
case {'uniform','rectilinear','curvilinear'},
  if isequal(size(Block.Var{fromvarnr}),[1 1]), % constant value
    NewVar=Block.Var(fromvarnr);
  else,
    switch Block.NDim(2),
    case 1, % 1D
      NewVar=conv2(Block.Var{fromvarnr},ones(2,1)/2,'valid');
    case 2, % 2D
      NewVar=conv2(Block.Var{fromvarnr},ones(2,2)/4,'valid');
    case 3, % 3D
      NewVar=convn(Block.Var{fromvarnr},ones(2,2,2)/8,'valid');
    end;
  end;
case 'unstructured',
  NewVar=cell(1,8);
  for i=1:8,
    NewVar{i}=mean(Block.Var{fromvarnr}(Block.Cells{i}),2);
  end;
end;