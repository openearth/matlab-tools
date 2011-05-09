function Geom=getgeom(Obj);

if length(Obj.Block)==0,
  Geom=[];
  return;
end;

for i=1:length(Obj.Block),
  switch Obj.Block(i).Type,
  case 'UNIFORM',
    Geom(i).X=Obj.Block(i).XCoord;
    Geom(i).Y=Obj.Block(i).YCoord;
    Geom(i).Z=Obj.Block(i).ZCoord;
  case 'RECTILINEAR',
    Geom(i).X=Obj.Block(i).XCoord;
    Geom(i).Y=Obj.Block(i).YCoord;
    Geom(i).Z=Obj.Block(i).ZCoord;
  case 'CURVILINEAR',
    Geom(i).X=Obj.Block(i).XCoord;
    Geom(i).Y=Obj.Block(i).YCoord;
    Geom(i).Z=Obj.Block(i).ZCoord;
  case 'UNSTRUCTURED',
    Geom(i).Nodes=Obj.Block(i).Nodes;
    Geom(i).Cell.Point=Obj.Block(i).Cells{1};
    Geom(i).Cell.Line=Obj.Block(i).Cells{2};
    Geom(i).Cell.Triangle=Obj.Block(i).Cells{3};
    Geom(i).Cell.Quadrilateral=Obj.Block(i).Cells{4};
    Geom(i).Cell.Tetrahedral=Obj.Block(i).Cells{5};
    Geom(i).Cell.Pyramid=Obj.Block(i).Cells{6};
    Geom(i).Cell.Prism=Obj.Block(i).Cells{7};
    Geom(i).Cell.Hexahedral=Obj.Block(i).Cells{8};
  otherwise,
    fprintf(['WARNING: Unable to extract grid from ' Obj.Block(i).Type ' block.\n']);
  end;
end;