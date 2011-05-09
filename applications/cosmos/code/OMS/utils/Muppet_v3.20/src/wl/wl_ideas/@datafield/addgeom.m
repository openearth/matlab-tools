function Obj=addgeom(ObjIn,Type,varargin);
% ADDGEOM add geometry information to a datafield
%         DataField2=ADDGEOM(DataField1,Type,...)
%         where the additional arguments depend on the geometry Type,
%         'uniform'
%         'rectilinear'
%         'curvilinear'
%         'unstructured'
%         'gis'

Obj=ObjIn;
xyz=varargin;

b0=length(Obj.Block);
if iscell(xyz{1}), % multiblock
  NBlocks=length(xyz{1});
  for i=2:length(xyz),
    if length(xyz{i})~=NBlocks,
      error('Number of blocks appears to vary.');
    end;
  end;
else,
  NBlocks=1;
end;

if length(Obj.Var)>0,
  Var=cell(1,length(Obj.Var));
  [Var{:}]=deal(NaN);
else,
  Var={};
end;

for newblock=1:NBlocks,
  if iscell(xyz{1}),
    for i=1:length(xyz),
      XYZ{i}=xyz{i}{newblock};
    end;
  else,
    XYZ=xyz;
  end;
  b=b0+newblock;
  switch lower(Type),
  case 'uniform',
    switch length(XYZ),
    case 2, % XYZ = {X Nx}
      Nx=XYZ{2};
      if isequal(size(Nx),[1 1]),
        NxCorrect = Nx==round(Nx) & Nx>0 & isfinite(Nx);
      else,
        NxCorrect = 0;
      end;
      if isequal(size(XYZ{1}),[1 2]),
        XCorrect = XYZ{1}(1)>XYZ{1}(2);
      else,
        XCorrect = 0;
      end;
      if XCorrect & NxCorrect,
        Obj.Block(b).Type='UNIFORM';
        Obj.Block(b).Size=Nx;
        Obj.Block(b).NDim=[1 1];
        Obj.Block(b).XCoord=[XYZ{1}(1) XYZ{1}(2)];
        Obj.Block(b).YCoord=[];
        Obj.Block(b).ZCoord=[];
        Obj.Block(b).Var=Var;
      else,
        error('Invalid uniform grid specification.')
      end;
    case 3, % XYZ = {X, Y, [Nx Ny]}
      Nxy=XYZ{3};
      if isequal(size(Nxy),[1 2]),
        NCorrect = all(Nxy==round(Nxy)) & all(Nxy>0) & all(isfinite(Nxy));
      else,
        NCorrect = 0;
      end;
      if isequal(size(XYZ{1}),[1 2]),
        XCorrect = XYZ{1}(1)>XYZ{1}(2);
      else,
        XCorrect = 0;
      end;
      if isequal(size(XYZ{2}),[1 2]),
        YCorrect = XYZ{2}(1)>XYZ{2}(2);
      else,
        YCorrect = 0;
      end;
      if XCorrect & YCorrect & NCorrect,
        Obj.Block(b).Type='UNIFORM';
        Obj.Block(b).Size=Nxy;
        Obj.Block(b).NDim=[2 2];
        Obj.Block(b).XCoord=[XYZ{1}(1) XYZ{1}(2)];
        Obj.Block(b).YCoord=[XYZ{2}(1) XYZ{2}(2)];
        Obj.Block(b).ZCoord=[];
        Obj.Block(b).Var=Var;
      else,
        error('Invalid uniform grid specification.')
      end;
    case 4, % XYZ = {X, Y, Z, [Nx Ny Nz]}
      Nxyz=XYZ{4};
      if isequal(size(Nxyz),[1 2]),
        if all(Nxyz==round(Nxyz)) & all(Nxyz>0) & all(isfinite(Nxyz)),
          if isequal(size(XYZ{1}),[1 2]),
            XCorrect = XYZ{1}(1)>XYZ{1}(2);
          else,
            XCorrect = 0;
          end;
          if isequal(size(XYZ{2}),[1 2]),
            YCorrect = XYZ{2}(1)>XYZ{2}(2);
          else,
            YCorrect = 0;
          end;
          if isequal(size(XYZ{3}),[1 2]),
            ZCorrect = XYZ{3}(1)>XYZ{3}(2);
          else,
            ZCorrect = 0;
          end;
          Correct = XCorrect & YCorrect & ZCorrect;
        else,
          Correct = 0;
        end;
      else,
        Correct = 0;
      end;
      if Correct,
        Obj.Block(b).Size=Nxyz;
        Obj.Block(b).Type='UNIFORM';
        Obj.Block(b).NDim=[3 3];
        Obj.Block(b).XCoord=[XYZ{1}(1) XYZ{1}(2)];
        Obj.Block(b).YCoord=[XYZ{2}(1) XYZ{2}(2)];
        Obj.Block(b).ZCoord=[XYZ{3}(1) XYZ{3}(2)];
        Obj.Block(b).Var=Var;
      else,
        error('Invalid uniform grid specification.')
      end;
    otherwise,
      error('Incorrect number of arguments.');
    end;
  case 'rectilinear',
    switch length(XYZ),
    case 1, % XYZ = {X}
      szX=size(XYZ{1});
      if (max(szX)==prod(szX)),
        Obj.Block(b).Type='RECTILINEAR';
        Obj.Block(b).Size=max(szX);
        Obj.Block(b).NDim=[1 1];
        Obj.Block(b).XCoord=reshape(XYZ{1},[max(szX) 1]);
        Obj.Block(b).YCoord=[];
        Obj.Block(b).ZCoord=[];
        Obj.Block(b).Var=Var;
      else,
        error('Invalid rectilinear grid specification.')
      end;
    case 2, % XYZ = {X, Y}
      szX=size(XYZ{1});
      szY=size(XYZ{2});
      if (max(szX)==prod(szX)) & (max(szY)==prod(szY)),
        Obj.Block(b).Type='RECTILINEAR';
        Obj.Block(b).Size=[max(szX) max(szY)];
        Obj.Block(b).NDim=[2 2];
        Obj.Block(b).XCoord=reshape(XYZ{1},[max(szX) 1]);
        Obj.Block(b).YCoord=reshape(XYZ{2},[max(szY) 1]);
        Obj.Block(b).ZCoord=[];
        Obj.Block(b).Var=Var;
      else,
        error('Invalid rectilinear grid specification.')
      end;
    case 3, % XYZ = {X, Y, Z}
      szX=size(XYZ{1});
      szY=size(XYZ{2});
      szZ=size(XYZ{3});
      if (max(szX)==prod(szX)) & (max(szY)==prod(szY)) & (max(szZ)==prod(szZ)),
        Obj.Block(b).Type='RECTILINEAR';
        Obj.Block(b).Size=[max(szX) max(szY) max(szZ)];
        Obj.Block(b).NDim=[3 3];
        Obj.Block(b).XCoord=reshape(XYZ{1},[max(szX) 1]);
        Obj.Block(b).YCoord=reshape(XYZ{2},[max(szY) 1]);
        Obj.Block(b).ZCoord=reshape(XYZ{3},[max(szZ) 1]);
        Obj.Block(b).Var=Var;
      else,
        error('Invalid rectilinear grid specification.')
      end;
    otherwise,
      error('Incorrect number of arguments.');
    end;
  case {'curvilinear','structured','irregular'},
    switch length(XYZ),
    case 1, % XYZ = {X}
      szX=size(XYZ{1});
      Obj.Block(b).Type='CURVILINEAR';
      Obj.Block(b).Size=szX(szX>1);
      Obj.Block(b).NDim=[1 1];
      Obj.Block(b).XCoord=reshape(XYZ{1},szX);
      Obj.Block(b).YCoord=[];
      Obj.Block(b).ZCoord=[];
      Obj.Block(b).Var=Var;
    case 2, % XYZ = {X, Y}
      szX=size(XYZ{1});
      szY=size(XYZ{2});
      if isequal(szX,szY) & (length(szX)==2), % CURVILINEAR: LINE, QUAD
        Obj.Block(b).Type='CURVILINEAR';
        Obj.Block(b).Size=szX(szX>1);
        Obj.Block(b).NDim=[2 length(Obj.Block(b).Size)];
        Obj.Block(b).XCoord=reshape(XYZ{1},szX);
        Obj.Block(b).YCoord=reshape(XYZ{2},szX);
        Obj.Block(b).ZCoord=[];
        Obj.Block(b).Var=Var;
      else,
        error('Invalid curvilinear grid specification.')
      end;
    case 3, % XYZ = {X, Y, Z}
      szX=size(XYZ{1});
      szY=size(XYZ{2});
      szZ=size(XYZ{3});
      if isequal(szX,szY,szZ) & (length(szX)<=3), % CURVILINEAR: LINE, QUAD, HEXAHEDRAL
        Obj.Block(b).Type='CURVILINEAR';
        Obj.Block(b).Size=szX(szX>1);
        Obj.Block(b).NDim=[3 length(Obj.Block(b).Size)];
        Obj.Block(b).XCoord=reshape(XYZ{1},szX);
        Obj.Block(b).YCoord=reshape(XYZ{2},szX);
        Obj.Block(b).ZCoord=reshape(XYZ{3},szX);
        Obj.Block(b).Var=Var;
      else,
        error('Invalid curvilinear grid specification.')
      end;
    otherwise,
      error('Incorrect number of arguments.');
    end;
  case 'unstructured',
    switch length(XYZ),
    case 2,
      switch size(XYZ{1},2),
      case 1, % 1D
        Sz=[size(XYZ{1},1) 0 0 0 0 0 0 0 0];
        % POINT LINE (TRIANGLE QUADRILATERAL TETRAHEDRAL PYRAMID PRISM HEXAHEDRAL)
        NCornerNodes=[1 2];
        if ~isequal(size(XYZ{2}),[1 length(NCornerNodes)]),
          error('Invalid cell geometry.');
        end;
        for i=1:length(NCornerNodes),
          if ~isempty(XYZ{2}{i}) & ~isequal(size(XYZ{2}{i},2),NCornerNodes(i)),
            error('Invalid cell geometry.');
          end;
          if (i>length(NCornerNodes)) & size(XYZ{2}{i},1)>0,
            warning('2/3D cells in 1D geometry ignored.');
            XYZ{2}{i}=[];
          else,
            Sz(1+i)=size(XYZ{2}{i},1);
          end;
        end;
        Obj.Block(b).Type='UNSTRUCTURED';
        Obj.Block(b).Size=Sz;
        Obj.Block(b).NDim=[1 0];
        Obj.Block(b).Nodes=XYZ{1};
        Obj.Block(b).Cells=XYZ{2};
        Obj.Block(b).Var=Var;
      case 2, % 2D
        Sz=[size(XYZ{1},1) 0 0 0 0 0 0 0 0];
        % POINT LINE TRIANGLE QUADRILATERAL (TETRAHEDRAL PYRAMID PRISM HEXAHEDRAL)
        NCornerNodes=[1 2 3 4];
        if ~isequal(size(XYZ{2}),[1 length(NCornerNodes)]),
          error('Invalid cell geometry.');
        end;
        for i=1:length(NCornerNodes),
          if ~isempty(XYZ{2}{i}) & ~isequal(size(XYZ{2}{i},2),NCornerNodes(i)),
            error('Invalid cell geometry.');
          end;
          if (i>length(NCornerNodes)) & size(XYZ{2}{i},1)>0,
            warning('3D cells in 2D geometry ignored.');
            XYZ{2}{i}=[];
          else,
            Sz(1+i)=size(XYZ{2}{i},1);
          end;
        end;
        Obj.Block(b).Type='UNSTRUCTURED';
        Obj.Block(b).Size=Sz;
        Obj.Block(b).NDim=[2 0];
        Obj.Block(b).Nodes=XYZ{1};
        Obj.Block(b).Cells=XYZ{2};
        Obj.Block(b).Var=Var;
      case 3, % 3D
        Sz=[size(XYZ{1},1) 0 0 0 0 0 0 0 0];
        % POINT LINE TRIANGLE QUADRILATERAL TETRAHEDRAL PYRAMID PRISM HEXAHEDRAL
        NCornerNodes=[1 2 3 4 4 5 6 8];
        if ~isequal(size(XYZ{2}),[1 length(NCornerNodes)]),
          error('Invalid cell geometry.');
        end;
        for i=1:length(NCornerNodes),
          if ~isempty(XYZ{2}{i}) & ~isequal(size(XYZ{2}{i},2),NCornerNodes(i)),
            error('Invalid cell geometry.');
          end;
          Sz(1+i)=size(XYZ{2}{i},1);
        end;
        Obj.Block(b).Type='UNSTRUCTURED';
        Obj.Block(b).Size=Sz;
        Obj.Block(b).NDim=[3 0];
        Obj.Block(b).Nodes=XYZ{1};
        Obj.Block(b).Cells=XYZ{2};
        Obj.Block(b).Var=Var;
      end;
    end;
  otherwise,
    error('Unknown geometry type.');
  end;
end;