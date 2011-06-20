function Obj=setdata(ObjIn,Type,Label,Data);

Obj=ObjIn;
if nargin<4,
  error('Insufficient input arguments.');
end;

if isempty(Obj.Var),
  varnr=length(Obj.Var)+1;
else,
  Labels={Obj.Var(:).Name};
  varnr=strmatch(Label,Labels,'exact'); % replace data that has the same name
  if isempty(varnr),
    varnr=length(Obj.Var)+1;
  end;
end;

if ~iscell(Data),
  BlockData={Data};
else,
  BlockData=Data;
end;
if length(BlockData)~=length(Obj.Block),
  error('Number of data blocks does not match number of geometry blocks');
end;
DataOK=1;
for b=1:length(ObjIn.Block),
  % check Block
  switch lower(Obj.Block(b).Type),
  case {'uniform','rectilinear','curvilinear'},
    switch Type,
    case 'vertex',
      DataOK = DataOK & isequal(Obj.Block(b).Size,size(BlockData{b}));
    case 'cell',
      DataOK = DataOK & isequal(Obj.Block(b).Size-1,size(BlockData{b}));
    otherwise,
      error(['Data type ',Type,' not supported.']);
    end;
  case 'unstructured',
    switch Type,
    case 'vertex',
      DataOK = DataOK & isequal([Obj.Block(b).Size(1) 1],size(BlockData{b}));
    case 'cell',
      DataOK = DataOK & iscell(BlockData{b}) & isequal(size(BlockData{b},[1 8]));
      for i=1:8,
        DataOK = DataOK & isequal([Obj.Block(b).Size(1+i) 1],size(BlockData{b}{i}));
      end;
    otherwise,
      error(['Data type ',Type,' not supported.']);
    end;
  otherwise,
    error(['Data for ',Obj.Block(b).Type,' geometry not yet supported.']);
  end;
end;

if DataOK,
  Obj.Var(varnr).Name=Label;
  Obj.Var(varnr).Type=Type;
  for b=1:length(ObjIn.Block),
    Obj.Block(b).Var{varnr}=BlockData{b};
  end;
else,
  keyboard
  error('Data dimensions does not match geometry');
end;
