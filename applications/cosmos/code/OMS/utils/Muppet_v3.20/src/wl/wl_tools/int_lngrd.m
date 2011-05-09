function [xo,yo]=int_lngrd(xi,yi,X,Y,diags);
%INT_LNGRD Intersection of line and grid
%    [XCROSS,YCROSS]=INT_LNGRD(XLINE,YLINE,XGRID,YGRID)
%    Computes the points where the line (XLINE,YLINE)
%    crosses coordinate lines of the curvilinear grid
%    (XGRID,YGRID).
%
%    [XCROSS,YCROSS]=INT_LNGRD(XLINE,YLINE,XGRID,YGRID,1)
%    Computes also the points where the line crosses the
%    main diagonals.

% (c) Copyright 2000-2002 H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

if nargin==4
   diags=0;
end

% column lines
X1=X(1:end-1,:);
Y1=Y(1:end-1,:);
dX1=diff(X,1,1);
dY1=diff(Y,1,1);
k = isnan(dX1) | isnan(dY1);
X1=X1(~k);
Y1=Y1(~k);
dX1=dX1(~k);
dY1=dY1(~k);

% row lines
X2=X(:,1:end-1);
Y2=Y(:,1:end-1);
dX2=diff(X,1,2);
dY2=diff(Y,1,2);
k = isnan(dX2) | isnan(dY2);
X2=X2(~k);
Y2=Y2(~k);
dX2=dX2(~k);
dY2=dY2(~k);

if diags
  % diagonal lines
  X3=X(1:end-1,1:end-1);
  Y3=Y(1:end-1,1:end-1);
  dX3=X(2:end,2:end)-X3;
  dY3=Y(2:end,2:end)-Y3;
  k = isnan(dX3) | isnan(dY3);
  X3=X3(~k);
  Y3=Y3(~k);
  dX3=dX3(~k);
  dY3=dY3(~k);
end

%[I,J]=ndgrid(1:size(X,1),1:size(X,2));

N=length(xi);

xo=cell(1,N);
yo=xo;

for i=1:N-1,

  dxi=xi(i)-xi(i+1);
  dyi=yi(i)-yi(i+1);

  Det1=dX1.*dyi-dY1.*dxi;
  Det1(Det1==0)=NaN;
  m1 = (dyi*(xi(i)-X1)-dxi*(yi(i)-Y1)) ./Det1;
  l1 = (-dY1.*(xi(i)-X1)+dX1.*(yi(i)-Y1))./Det1;
  ln1=(l1>=0) & (l1<=1) & (m1>=0) & (m1<=1);

  Det2=dX2.*dyi-dY2.*dxi;
  Det2(Det2==0)=NaN;
  m2 = (dyi*(xi(i)-X2)-dxi*(yi(i)-Y2)) ./Det2;
  l2 = (-dY2.*(xi(i)-X2)+dX2.*(yi(i)-Y2))./Det2;
  ln2=(l2>=0) & (l2<=1) & (m2>=0) & (m2<=1);
  
  if diags
    Det3=dX3.*dyi-dY3.*dxi;
    Det3(Det3==0)=NaN;
    m3 = (dyi*(xi(i)-X3)-dxi*(yi(i)-Y3)) ./Det3;
    l3 = (-dY3.*(xi(i)-X3)+dX3.*(yi(i)-Y3))./Det3;
    ln3=(l3>=0) & (l3<=1) & (m3>=0) & (m3<=1);
    l3ln3=l3(ln3);
    x3=X3(ln3)+m3(ln3).*dX3(ln3);
    y3=Y3(ln3)+m3(ln3).*dY3(ln3);
  else
    l3ln3=[];
    x3=[];
    y3=[];
  end

  l=cat(1,0,l1(ln1),l2(ln2),l3ln3);
  xo{i}=cat(1,xi(i),X1(ln1)+m1(ln1).*dX1(ln1),X2(ln2)+m2(ln2).*dX2(ln2),x3);
  yo{i}=cat(1,yi(i),Y1(ln1)+m1(ln1).*dY1(ln1),Y2(ln2)+m2(ln2).*dY2(ln2),y3);
  
%  m=cat(1,0,m1(~isnan(l1)),m2(~isnan(l2)),m3(~isnan(l3)));
  [l,ind]=unique(l); % includes sort !
  xo{i}=xo{i}(ind);
  yo{i}=yo{i}(ind);
%  m=m(ind);
%  xo{i}=xi(i)-l*dxi; % could also be derived from m1, m2 and m3
%  yo{i}=yi(i)-l*dyi;
end;

xo{end}=xi(end);
yo{end}=yi(end);

xo=cat(1,xo{:});
yo=cat(1,yo{:});
