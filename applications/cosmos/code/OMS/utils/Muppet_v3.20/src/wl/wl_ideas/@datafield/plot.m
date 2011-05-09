function [Handles]=plot(Obj,Label,Axes);

if nargin<2,
  error('Insufficient input arguments.');
end;

if ischar(Label),
  Labels={Obj.Var(:).Name};
  varnr=strmatch(Label,Labels,'exact');
  if isempty(varnr),
    varnr=strmatch(Label,Labels);
  end;
  if ~isequal(size(varnr),[1 1]),
    error('Variable label not unique.');
  end;
elseif Label>length(Obj.Var),
  error('Variable index too large.');
else,
  varnr=Label
end;

if nargin<3,
  Axes=gca;
end;

Handles=[];
switch Obj.Var(varnr).Type,
case 'cell',
  for b=1:length(Obj.Block),
    Handles=[Handles Local_cell(Obj.Block(b),varnr,Axes)];
  end;
case 'vertex',
  for b=1:length(Obj.Block),
    Handles=[Handles Local_vertex(Obj.Block(b),varnr,Axes)];
  end;
end;


function Handles=Local_cell(Block,varnr,Axes);
Handles=[];
switch lower(Block.Type),
case 'uniform',
case 'rectilinear',
case 'curvilinear',
  switch Block.NDim(2),
  case 1, % line
  case 2, % surface
    switch Block.NDim(1),
    case 2,
      Handles=surface('parent',Axes,'xdata',Block.XCoord, ...
                      'ydata',Block.YCoord,'cdata',Block.Var{varnr}, ...
                      'clipping','off','edgecolor','none','facecolor','flat');
    case 3,
      Handles=surface('parent',Axes,'xdata',Block.XCoord,'ydata', Block.YCoord, ...
                      'zdata',Block.ZCoord,'cdata',Block.Var{varnr}, ...
                      'clipping','off','edgecolor','none','facecolor','flat');
    end;
  case 3, % volume
  end;
case 'unstructured',
  NewVar=cell(1,8);
  for i=1:8,
    NewVar{i}=mean(Block.Var{fromvarnr}(Block.Cells{i}),2);
  end;
end;


function Handles=Local_vertex(Block,varnr,Axes);
Handles=[];
switch lower(Block.Type),
case 'uniform',
case 'rectilinear',
case 'curvilinear',
  switch Block.NDim(2),
  case 1, % line
  case 2, % surface
    switch Block.NDim(1),
    case 2,
      Handles=surface('parent',Axes,'xdata',Block.XCoord, ...
                      'ydata',Block.YCoord,'cdata',Block.Var{varnr}, ...
                      'clipping','off','edgecolor','none','facecolor','interp');
    case 3,
      Handles=surface('parent',Axes,'xdata',Block.XCoord,'ydata', Block.YCoord, ...
                      'zdata',Block.ZCoord,'cdata',Block.Var{varnr}, ...
                      'clipping','off','edgecolor','none','facecolor','interp');
    end;
  case 3, % volume
  end;
case 'unstructured',
  NewVar=cell(1,8);
  for i=1:8,
    NewVar{i}=mean(Block.Var{fromvarnr}(Block.Cells{i}),2);
  end;
end;