function Obj=isosurface(ObjIn,Label,Isolevel);

if nargin<2,
  error('Insufficient input arguments.');
end;

if ischar(Label),
  Labels={ObjIn.Var(:).Name};
  varnr=strmatch(Label,Labels,'exact');
  if isempty(varnr),
    varnr=strmatch(Label,Labels);
  end;
  if ~isequal(size(varnr),[1 1]),
    error('Variable label not unique.');
  end;
elseif Label>length(ObjIn.Var),
  error('Variable index too large.');
else,
  varnr=Label
end;

switch ObjIn.Var(varnr).Type,
case 'cell',
  error('isosurfaces can only be drawn based on vertex data.');
case 'vertex',
  Obj=vertex_isosurface(ObjIn,varnr,Isolevel);
end;

function Obj=vertex_isosurface(ObjIn,v,Isolevel);

Obj=datafield;
Obj.Var=ObjIn.Var;

for b=1:length(ObjIn.Block),
  switch lower(ObjIn.Block(b).Type),
  case 'uniform',
  case 'rectilinear',
  case 'curvilinear',
    switch ObjIn.Block(b).NDim(2),
    case 1, % 1D
      X=ObjIn.Block(b).Var{v};
      I=find(diff(X<Isolevel)~=0); % from smaller to larger (or equal) or vice versa
      I=transpose(I+(level-X(I))./(X(I+1)-X(I)));
      % ----- or if you want lines for reaches where the value is exactly equal to the
      % ----- isolevel ...
%        level=0.5;
%        Y=find(abs(diff(sign(X-level)))==2); % from smaller to larger or vice versa
%        I=Y+(level-X(Y))./(X(Y+1)-X(Y)); % points crossing
%        N=length(I);
%        
%        U=find(X==level);
%        From=U(logical([1 diff(U)>1]));
%        To=U(logical([diff(U)>1 1]));
%        NPoints=To-From+1;
%        I_Single=From(NPoints==1);
%        N=N+length(I_Single);
%        
%        I_Multi=setdiff(U,I_Single);
%        
%        [I I_Single I_Multi]
%        L=find(diff(I_Multi)==1);
%        {1:N [L;L+1] [] []}
      % continue ...


    case 2, % 2D
      C=transpose(contourc(ObjIn.Block(b).Var{v},Isolevel*[1 1]));
      if ~isempty(C),
        Index=zeros(sum(C(:,1)==Isolevel),1);
        Index(1)=1;
        for i=1:(length(Index)-1),
          Index(i+1)=Index(i)+C(Index(i),2)+1;
        end;
        Cells=zeros(length(C(:,1)),2);
        Cells(:,1)=transpose(1:length(C(:,1)));
        Cells(:,2)=Cells(:,1)+1;
        Cells([Index Index+C(Index,2)],:)=[];
        C(Index,:)=inf;
        [NodeCoords,I,Reorder]=unique(C,'rows');
        NodeCoords(end,:)=[];
        Cells=Reorder(Cells);
        CellCoords=zeros(size(Cells,1),2);
        for i=1:2,
          Temp=NodeCoords(:,i);
          CellCoords(:,i)=mean(Temp(Cells),2);
        end;
        CellCoords=floor(CellCoords);
        Obj.Block(b).Type='unstructured';
        switch ObjIn.Block(b).NDim(1),
        case 2, % 2D physical space
          Obj.Block(b).Nodes=zeros(size(NodeCoords,1),2);
          Obj.Block(b).Nodes(:,1)=interp2(ObjIn.Block(b).XCoord,NodeCoords(:,1),NodeCoords(:,2),'*linear');
          Obj.Block(b).Nodes(:,2)=interp2(ObjIn.Block(b).YCoord,NodeCoords(:,1),NodeCoords(:,2),'*linear');
          Obj.Block(b).NDim=[3 0];
          Obj.Block(b).Size=[4 0 size(Cells,1) 0 0];
          Obj.Block(b).Cells={[] Cells [] []};
          for i=1:length(ObjIn.Block(b).Var),
            if i==v,
              Obj.Block(b).Var{i}=Isolevel;
            elseif isequal(size(ObjIn.Block(b).Var{i}),[1 1]),
              Obj.Block(b).Var{i}=ObjIn.Block(b).Var{i};
            else,
              switch ObjIn.Var(i).Type,
              case 'cell',
                Temp=ObjIn.Block(b).Var{i}((CellCoords(:,2)-1)*Obj.Block(b).Size(1)+CellCoords(:,1));
                Obj.Block(b).Var{i}={[] Temp [] []};
              case 'vertex',
                Temp=interp2(ObjIn.Block(b).Var{i},NodeCoords(:,1),NodeCoords(:,2),'*linear');
                Obj.Block(b).Var{i}=Temp;
              end;
            end;
          end;
        case 3, % 3D physical space
          Obj.Block(b).Nodes=zeros(size(NodeCoords,1),3);
          Obj.Block(b).Nodes(:,1)=interp2(ObjIn.Block(b).XCoord,NodeCoords(:,1),NodeCoords(:,2),'*linear');
          Obj.Block(b).Nodes(:,2)=interp2(ObjIn.Block(b).YCoord,NodeCoords(:,1),NodeCoords(:,2),'*linear');
          Obj.Block(b).Nodes(:,3)=interp2(ObjIn.Block(b).ZCoord,NodeCoords(:,1),NodeCoords(:,2),'*linear');
          Obj.Block(b).NDim=[3 0];
          Obj.Block(b).Size=[8 0 size(Cells,1) 0 0 0 0 0 0];
          Obj.Block(b).Cells={[] Cells [] [] [] [] [] []};
          for i=1:length(ObjIn.Block(b).Var),
            if i==v,
              Obj.Block(b).Var{i}=Isolevel;
            elseif isequal(size(ObjIn.Block(b).Var{i}),[1 1]),
              Obj.Block(b).Var{i}=ObjIn.Block(b).Var{i};
            else,
              switch ObjIn.Var(i).Type,
              case 'cell',
                Temp=ObjIn.Block(b).Var{i}((CellCoords(:,2)-1)*Obj.Block(b).Size(1)+CellCoords(:,1));
                Obj.Block(b).Var{i}={[] Temp [] [] [] [] [] []};
              case 'vertex',
                Temp=interp2(ObjIn.Block(b).Var{i},NodeCoords(:,1),NodeCoords(:,2),'*linear');
                Obj.Block(b).Var{i}=Temp;
              end;
            end;
          end;
        end;
      end;
    case 3, % 3D
      % 3D physical space
      fv=isosurface(ObjIn.Block(b).Var{v},Isolevel);
      Obj.Block(b).Nodes=zeros(size(fv.vertices,1),3);
      Obj.Block(b).Nodes(:,1)=interp3(ObjIn.Block(b).XCoord,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      Obj.Block(b).Nodes(:,2)=interp3(ObjIn.Block(b).YCoord,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      Obj.Block(b).Nodes(:,3)=interp3(ObjIn.Block(b).ZCoord,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      Obj.Block(b).Type='unstructured';
      Obj.Block(b).NDim=[3 0];
      Obj.Block(b).Size=[8 0 0 size(fv.faces,1) 0 0 0 0 0];
      Obj.Block(b).Cells={[] [] fv.faces [] [] [] [] []};
      CellCoords=zeros(size(fv.faces,1),3);
      for i=1:3,
        Temp=fv.vertices(:,i);
        CellCoords(:,i)=mean(Temp(fv.faces),2);
      end;
      CellCoords=floor(CellCoords);
      for i=1:length(ObjIn.Block(b).Var),
        if i==v,
          Obj.Block(b).Var{i}=Isolevel;
        elseif isequal(size(ObjIn.Block(b).Var{i}),[1 1]),
          Obj.Block(b).Var{i}=ObjIn.Block(b).Var{i};
        else,
          switch ObjIn.Var(i).Type,
          case 'cell',
            Temp=ObjIn.Block(b).Var{i}((CellCoords(:,3)-1)*Obj.Block(b).Size(2)*Obj.Block(b).Size(1)+(CellCoords(:,2)-1)*Obj.Block(b).Size(1)+CellCoords(:,1));
            Obj.Block(b).Var{i}={[] [] Temp [] [] [] [] []};
          case 'vertex',
            Temp=interp3(ObjIn.Block(b).Var{i},fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
            Obj.Block(b).Var{i}=Temp;
          end;
        end;
      end;
    end;
  case 'unstructured',
  end;
end;