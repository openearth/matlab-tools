function [Obj,varnr]=cell2vertex(ObjIn,Label);

Obj=ObjIn;
if nargin<2,
  error('Insufficient input arguments.');
end;

Labels={Obj.Var(:).Name};
fromvarnr=strmatch(Label,Labels,'exact');
if isempty(fromvarnr),
  fromvarnr=strmatch(Label,Labels);
end;
if ~isequal(size(fromvarnr),[1 1]),
  error('Variable label not unique.');
end;

switch Obj.Var(fromvarnr).Type,
case 'vertex', % contains vertex data - nothing to interpolate!
  varnr=fromvarnr;
  return;
case 'cell',
otherwise,
  error('Specified variable does not contain cell data.');
end;

varnr=length(Obj.Var)+1;
Obj.Var(varnr).Name=[Obj.Var(fromvarnr).Name ' in vertices'];
Obj.Var(varnr).Type='vertex';

for b=1:length(Obj.Block),
  Obj.Block(b).Var{varnr}=Local_interpolate(Obj.Block(b),fromvarnr);
end;


function NewVar=Local_interpolate(Block,fromvarnr);
switch lower(Block.Type),
case 'uniform',
  if isequal(size(Block.Var{fromvarnr}),[1 1]), % constant value
    NewVar=Block.Var{fromvarnr};
  else,
    switch Block.NDim(2),
    case 1, % 1D
      Var=repmat(NaN,[Block.Size+1 1]);
      Var(2:(end-1))=Block.Var{fromvarnr}(:);
      Valid=~isnan(Var);
      Var(~Valid)=0;
      NewVar=conv2(Var,ones(2,1),'valid');
      Valid=conv2(Valid,ones(2,1),'valid');
      NewVar=NewVar./max(1,Valid);
      NewVar=reshape(NewVar,Block.Size);
    case 2, % 2D
      Var=repmat(NaN,Block.Size+1);
      Var(2:(end-1),2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
      NewVar=conv2(Var,ones(2,2),'valid');
      Valid=conv2(Valid,ones(2,2),'valid');
      NewVar=NewVar./max(1,Valid);
    case 3, % 3D
      Var=repmat(NaN,Block.Size+1);
      Var(2:(end-1),2:(end-1),2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
      NewVar=conv2(Var,ones(2,2,2),'valid');
      Valid=conv2(Valid,ones(2,2,2),'valid');
      NewVar=NewVar./max(1,Valid);
    end;
  end;
case 'rectilinear',
  if isequal(size(Block.Var{fromvarnr}),[1 1]), % constant value
    NewVar=Block.Var{fromvarnr};
  else,
    switch Block.NDim(2),
    case 1, % 1D
      Var=repmat(NaN,[Block.Size+1 1]);
      Var(2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
  
      Dx=[0; diff(Block.XCoord)/2; 0];
  
      Ii=1:(length(Dx)-1);
      NewVar=zeros(length(Dx)-1);
      SumVol=zeros(length(Dx)-1);
      for d1=0:1,
        Vol=Dx(Ii+d1);
        NewVar=NewVar+Var(Ii+d1).*Vol;
        SumVol=SumVol+Valid(Ii+d1).*Vol;
      end;
      NewVar=NewVar./(SumVol+(SumVol==0));
    case 2, % 2D
      Var=repmat(NaN,Block.Size+1);
      Var(2:(end-1),2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
  
      Dx=repmat([0; diff(Block.XCoord)/2; 0],[1 Block.Size(2)+1]);
      Dy=repmat(transpose([0; diff(Block.YCoord)/2; 0]),[Block.Size(1)+1 1]);
  
      Ii=1:(length(Dx)-1);
      Ij=1:(length(Dy)-1);
      NewVar=zeros(length(Dx)-1,length(Dy)-1);
      SumVol=zeros(length(Dx)-1,length(Dy)-1);
      for d1=0:1,
        for d2=0:1,
          Vol=Dx(Ii+d1,Ij+d2).*Dy(Ii+d1,Ij+d2);
          NewVar=NewVar+Var(Ii+d1,Ij+d2).*Vol;
          SumVol=SumVol+Valid(Ii+d1,Ij+d2).*Vol;
        end;
      end;
      NewVar=NewVar./(SumVol+(SumVol==0));
    case 3, % 3D
      Var=repmat(NaN,Block.Size+1);
      Var(2:(end-1),2:(end-1),2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
  
      Dx=repmat([0; diff(Block.XCoord)/2; 0], ...
            [1 Block.Size(2)+1 Block.Size(3)+1]);
      Dy=repmat(transpose([0; diff(Block.YCoord)/2; 0]), ...
            [Block.Size(1)+1 1 Block.Size(3)+1]);
      Dz=repmat(reshape([0; diff(Block.YCoord)/2; 0],[1 1 Block.Size(1)+1]), ...
            [Block.Size(1)+1 Block.Size(2)+1 1]);
  
      Ii=1:(length(Dx)-1);
      Ij=1:(length(Dy)-1);
      Ik=1:(length(Dz)-1);
      NewVar=zeros(length(Dx)-1,length(Dy)-1,length(Dz)-1);
      SumVol=zeros(length(Dx)-1,length(Dy)-1,length(Dz)-1);
      for d1=0:1,
        for d2=0:1,
          for d3=0:1,
            Vol=Dx(Ii+d1,Ij+d2,Ik+d3).*Dy(Ii+d1,Ij+d2,Ik+d3).*Dz(Ii+d1,Ij+d2,Ik+d3);
            NewVar=NewVar+Var(Ii+d1,Ij+d2,Ik+d3).*Vol;
            SumVol=SumVol+Valid(Ii+d1,Ij+d2,Ik+d3).*Vol;
          end;
        end;
      end;
      NewVar=NewVar./(SumVol+(SumVol==0));
    end;
  end;
case 'curvilinear',
  if isequal(size(Block.Var{fromvarnr}),[1 1]), % constant value
    NewVar=Block.Var{fromvarnr};
  else
    switch Block.NDim(2),
    case 1, % 1D
      Var=repmat(NaN,[Block.Size+1 1]);
      Var(2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
      switch Block.NDim(1),
      case 1, % 1D
        dx=diff(Block.XCoord)/2;
        Dx=[0 dx 0];
      case 2, % 2D
        dx=diff(Block.XCoord)/2;
        dy=diff(Block.YCoord)/2;
        Dx=[0 sqrt(dx.^2+dy.^2) 0];
      case 3, % 3D
        dx=diff(Block.XCoord)/2;
        dy=diff(Block.YCoord)/2;
        dz=diff(Block.ZCoord)/2;
        Dx=[0 sqrt(dx.^2+dy.^2+dz.^2) 0];
      end;
      Ii=1:(length(Dx)-1);
      NewVar=Var(Ii).*Dx(Ii);
      SumVol=Valid(Ii).*Dx(Ii);
      NewVar=NewVar+Var(Ii+1).*Dx(Ii+1);
      SumVol=SumVol+Valid(Ii+1).*Dx(Ii+1);
      NewVar=NewVar./(SumVol+(SumVol==0));
    case 2, % 2D
      Var=repmat(NaN,Block.Size+1);
      Var(2:(end-1),2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
  
      NewVar=zeros(Block.Size);
      SumVol=zeros(Block.Size);
      Vol=zeros([Block.Size+1 2 2]);
  
      Ii=1:Block.Size(1);
      Ij=1:Block.Size(2);
  
      Mask=[3 1; -3 -1]/8;
      for d1=0:1,
        if d1==1,
          Mask1=Mask(:,[2 1]);
        else,
          Mask1=Mask;
        end;
        for d2=0:1,
          if d2==1,
            Mask2=Mask(:,[2 1]);
          else,
            Mask2=Mask;
          end;
          % fprintf(1,'step %i ',d2+d1*2+1);
          switch Block.NDim(1),
          case 2, % 2D
            Mask4=Mask1;
            dx1=conv2(Block.XCoord,Mask4,'valid');
            dy1=conv2(Block.YCoord,Mask4,'valid');
            Mask4=permute(Mask2,[2 1]);
            dx2=conv2(Block.XCoord,Mask4,'valid');
            dy2=conv2(Block.YCoord,Mask4,'valid');
            Vol(2:Block.Size(1),2:Block.Size(2),1+d1,1+d2)= ...
              abs(dx2.*dy1-dy2.*dx1);
          case 3, % 3D
            Mask4=Mask1;
            dx1=conv2(Block.XCoord,Mask4,'valid');
            dy1=conv2(Block.YCoord,Mask4,'valid');
            dz1=conv2(Block.ZCoord,Mask4,'valid');
            Mask4=permute(Mask2,[2 1]);
            dx2=conv2(Block.XCoord,Mask4,'valid');
            dy2=conv2(Block.YCoord,Mask4,'valid');
            dz2=conv2(Block.ZCoord,Mask4,'valid');
%            Vol(2:Block.Size(1),2:Block.Size(2),1+d1,1+d2)= ...
%              sqrt((dx2.*dy1-dy2.*dx1).^2);
            Vol(2:Block.Size(1),2:Block.Size(2),1+d1,1+d2)= ...
              sqrt((dz2.*dy1-dy2.*dz1).^2+(dz2.*dx1-dx2.*dz1).^2+(dx2.*dy1-dy2.*dx1).^2);
          end;
          NewVar=NewVar+Var(Ii+1-d1,Ij+1-d2).*Vol(Ii+1-d1,Ij+1-d2,1+d1,1+d2);
          SumVol=SumVol+Valid(Ii+1-d1,Ij+1-d2).*Vol(Ii+1-d1,Ij+1-d2,1+d1,1+d2);
        end;
      end;
      NewVar=NewVar./(SumVol+(SumVol==0));
    case 3, % 3D
      Var=repmat(NaN,Block.Size+1);
      Var(2:(end-1),2:(end-1),2:(end-1))=Block.Var{fromvarnr};
      Valid=~isnan(Var);
      Var(~Valid)=0;
  
      NewVar=zeros(Block.Size);
      SumVol=zeros(Block.Size);
      Vol=zeros([Block.Size+1 2 2 2]);
  
      Ii=1:Block.Size(1);
      Ij=1:Block.Size(2);
      Ik=1:Block.Size(3);
  
      Mask=[9 3; -9 -3]/32; Mask(:,:,2)=[3 1; -3 -1]/32;
      for d1=0:1,
        if d1==1,
          Mask1=Mask(:,:,[2 1]);
        else,
          Mask1=Mask;
        end;
        for d2=0:1,
          if d2==1,
            Mask2=Mask(:,:,[2 1]);
          else,
            Mask2=Mask;
          end;
          for d3=0:1,
            if d3==1,
              Mask3=Mask(:,:,[2 1]);
            else,
              Mask3=Mask;
            end;
            % fprintf(1,'step %i ',d3+d2*2+d1*4+1);
            Mask4=Mask1;
            dx1=convn(Block.XCoord,Mask4,'valid');
            dy1=convn(Block.YCoord,Mask4,'valid');
            dz1=convn(Block.ZCoord,Mask4,'valid');
            Mask4=permute(Mask2,[2 1 3]);
            dx2=convn(Block.XCoord,Mask4,'valid');
            dy2=convn(Block.YCoord,Mask4,'valid');
            dz2=convn(Block.ZCoord,Mask4,'valid');
            Mask4=permute(Mask3,[3 2 1]);
            dx3=convn(Block.XCoord,Mask4,'valid');
            dy3=convn(Block.YCoord,Mask4,'valid');
            dz3=convn(Block.ZCoord,Mask4,'valid');
            Vol(2:Block.Size(1),2:Block.Size(2),2:Block.Size(3),1+d1,1+d2,1+d3)= ...
              abs((dz2.*dy1-dy2.*dz1).*dx3+(dz2.*dx1-dx2.*dz1).*dy3+(dx2.*dy1-dy2.*dx1).*dz3);
            NewVar=NewVar+Var(Ii+1-d1,Ij+1-d2,Ik+1-d3).*Vol(Ii,Ij,Ik,1+d1,1+d2,1+d3);
            SumVol=SumVol+Valid(Ii+1-d1,Ij+1-d2,Ik+1-d3).*Vol(Ii,Ij,Ik,1+d1,1+d2,1+d3);
          end;
        end;
      end;
      NewVar=NewVar./(SumVol+(SumVol==0));
    end;
  end;
case 'unstructured',
  warning('Unstructured meshes not yet supported.');
end;