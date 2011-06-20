function varargout=thdsurf(val,kfu,kfv,xd,yd)
%THDSURF combines staggered grid data with thin dam info
%     [X,Y,VAL]=THDSURF(val,kfu,kfv,xd,yd)
%     combines the staggered grid data consisting of
%     data in waterlevel points (val) and coordinates
%     of depth points (xd,yd) with the thin dams
%     (kfu,kfv). kfu==0 and kfv==0 represent thin dams.
%
%     VAL=THDSURF(val,kfu,kfv)
%     does not use the coordinates.

% (c) copyright, H.R.A. Jagers, 4/11/2001
%     WL | Delft Hydraulics, The Netherlands

kfu=kfu==0;
kfv=kfv==0;
% from here onwards, it is assumed that kfu and kfv
% are logical matrices with kfu/kfv=1 for a closed
% dam and 0 for an open dam.

M=size(val,1); Mi=M*3-2;
N=size(val,2); Ni=N*3-2;
mh=1:M-1;
mi1=1+3*((1:M)-1);
mih1=1+3*(mh-1);
mih2=mih1+1;
mih3=mih2+1;
nh=1:N-1;
ni1=1+3*((1:N)-1);
nih1=1+3*(nh-1);
nih2=nih1+1;
nih3=nih2+1;

if nargout>1
  X=repmat(NaN,Mi,Ni);
  % Z points
  X(mi1,ni1)=(xd+xd([1 mh],:)+xd(:,[1 nh])+xd([1 mh],[1 nh]))/4;
  % DP points
  X(mih2,nih2)=xd(mh,nh);
  X(mih3,nih2)=xd(mh,nh);
  X(mih3,nih3)=xd(mh,nh);
  X(mih2,nih3)=xd(mh,nh);
  % U points
  X(mih2,nih1+3)=(xd(mh,nh)+xd(mh,nh+1))/2;
  X(mih3,nih1+3)=X(mih2,nih1+3);
  % V points
  X(mih1+3,nih2)=(xd(mh,nh)+xd(mh+1,nh))/2;
  X(mih1+3,nih3)=X(mih1+3,nih2);
  
  Y=repmat(NaN,Mi,Ni);
  % Z points
  Y(mi1,ni1)=(yd+yd([1 mh],:)+yd(:,[1 nh])+yd([1 mh],[1 nh]))/4;
  % DP points
  Y(mih2,nih2)=yd(mh,nh);
  Y(mih3,nih2)=yd(mh,nh);
  Y(mih3,nih3)=yd(mh,nh);
  Y(mih2,nih3)=yd(mh,nh);
  % U points
  Y(mih2,nih1+3)=(yd(mh,nh)+yd(mh,nh+1))/2;
  Y(mih3,nih1+3)=Y(mih2,nih1+3);
  % V points
  Y(mih1+3,nih2)=(yd(mh,nh)+yd(mh+1,nh))/2;
  Y(mih1+3,nih3)=Y(mih1+3,nih2);
end

VAL=repmat(NaN,Mi,Ni);
% Z points
VAL(mi1,ni1)=val;
% U points
VAL(mih2,nih1)=(val(mh,nh)+val(mh+1,nh))/2;
VAL(mih3,nih1)=VAL(mih2,nih1);
I=kfu;
I(:,end)=0; I(end,:)=0;
[mm,nn]=find(I);
P=sub2ind(size(val),mm,nn);
mmi1=1+3*(mm-1);
nni1=1+3*(nn-1);
Pi1=sub2ind(size(VAL),mmi1,nni1);
VAL(Pi1+1)=val(P);
VAL(Pi1+2)=val(P+1);
% V points
VAL(mih1,nih2)=(val(mh,nh)+val(mh,nh+1))/2;
VAL(mih1,nih3)=VAL(mih1,nih2);
I=kfv;
I(:,end)=0; I(end,:)=0;
[mm,nn]=find(I);
P=sub2ind(size(val),mm,nn);
mmi1=1+3*(mm-1);
nni1=1+3*(nn-1);
Pi1=sub2ind(size(VAL),mmi1,nni1);
VAL(Pi1+Mi)=val(P);
VAL(Pi1+2*Mi)=val(P+M);
% DP points
VAL(mih2,nih2)=(val(mh,nh)+val(mh,nh+1)+val(mh+1,nh)+val(mh+1,nh+1))/4;
VAL(mih2,nih3)=VAL(mih2,nih2);
VAL(mih3,nih3)=VAL(mih2,nih2);
VAL(mih3,nih2)=VAL(mih2,nih2);
kfk=kfu(mh,nh)+2*kfv(mh,nh)+4*kfu(mh,nh+1)+8*kfv(mh+1,nh);
% -> kfk=0,1,2,4,8 are normal points
I=kfk==3;
if any(I(:)) % 1,1 + | + 1,2
             %     - o
             % 2,1 +   + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1)=val(P);
  VAL(Pi1+1)=(val(P+1)+val(P+M)+val(P+M+1))/3;
  VAL(Pi1+Mi)=VAL(Pi1+1);
  VAL(Pi1+Mi+1)=VAL(Pi1+1);
end
I=kfk==5;
if any(I(:)) % 1,1 +   + 1,2
             %     - o -
             % 2,1 +   + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1)=(val(P)+val(P+M))/2;
  VAL(Pi1+Mi)=VAL(Pi1);
  VAL(Pi1+1)=(val(P+1)+val(P+M+1))/2;
  VAL(Pi1+Mi+1)=VAL(Pi1+1);
end
I=kfk==6;
if any(I(:)) % 1,1 + | + 1,2
             %       o -
             % 2,1 +   + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1+Mi)=val(P+M);
  VAL(Pi1)=(val(P)+val(P+1)+val(P+M+1))/3;
  VAL(Pi1+1)=VAL(Pi1);
  VAL(Pi1+Mi+1)=VAL(Pi1);
end
I=kfk==7;
if any(I(:)) % 1,1 + | + 1,2
             %     - o -
             % 2,1 +   + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1)=val(P);
  VAL(Pi1+Mi)=val(P+M);
  VAL(Pi1+1)=(val(P+1)+val(P+M+1))/2;
  VAL(Pi1+Mi+1)=VAL(Pi1+1);
end
I=kfk==9;
if any(I(:)) % 1,1 +   + 1,2
             %     - o 
             % 2,1 + | + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1+1)=val(P+1);
  VAL(Pi1)=(val(P)+val(P+M)+val(P+M+1))/3;
  VAL(Pi1+Mi)=VAL(Pi1);
  VAL(Pi1+Mi+1)=VAL(Pi1);
end
I=kfk==10;
if any(I(:)) % 1,1 + | + 1,2
             %       o 
             % 2,1 + | + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1)=(val(P)+val(P+1))/2;
  VAL(Pi1+1)=VAL(Pi1);
  VAL(Pi1+Mi)=(val(P+M)+val(P+M+1))/2;
  VAL(Pi1+Mi+1)=VAL(Pi1+Mi);
end
I=kfk==11;
if any(I(:)) % 1,1 + | + 1,2
             %     - o 
             % 2,1 + | + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1)=val(P);
  VAL(Pi1+1)=val(P+1);
  VAL(Pi1+Mi)=(val(P+M)+val(P+M+1))/2;
  VAL(Pi1+Mi+1)=VAL(Pi1+Mi);
end
I=kfk==12;
if any(I(:)) % 1,1 +   + 1,2
             %       o -
             % 2,1 + | + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1+Mi+1)=val(P+M+1);
  VAL(Pi1)=(val(P)+val(P+1)+val(P+M))/3;
  VAL(Pi1+1)=VAL(Pi1);
  VAL(Pi1+Mi)=VAL(Pi1);
end
I=kfk==13;
if any(I(:)) % 1,1 +   + 1,2
             %     - o -
             % 2,1 + | + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1+1)=val(P+1);
  VAL(Pi1+Mi+1)=val(P+M+1);
  VAL(Pi1)=(val(P)+val(P+M))/2;
  VAL(Pi1+Mi)=VAL(Pi1);
end
I=kfk==14;
if any(I(:)) % 1,1 + | + 1,2
             %       o -
             % 2,1 + | + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1+Mi)=val(P+M);
  VAL(Pi1+Mi+1)=val(P+M+1);
  VAL(Pi1)=(val(P)+val(P+1))/2;
  VAL(Pi1+1)=VAL(Pi1);
end
I=kfk==15;
if any(I(:)) % 1,1 + | + 1,2
             %     - o -
             % 2,1 + | + 2,2
  [mm,nn]=find(I);
  P=sub2ind(size(val),mm,nn);
  mmi1=2+3*(mm-1);
  nni1=2+3*(nn-1);
  Pi1=sub2ind(size(VAL),mmi1,nni1);
  VAL(Pi1)=val(P);
  VAL(Pi1+1)=val(P+1);
  VAL(Pi1+Mi)=val(P+M);
  VAL(Pi1+Mi+1)=val(P+M+1);
end

if nargout>1
  varargout={X Y VAL};
else
  varargout={VAL};
end