function [d1,d2]=dpgrad(C,i,type);
%DPGRAD compute depth gradients
%
%   [Comp1,Comp2]=dpgrad(type)
%   where type equals
%      'xe' returns: xi and eta components
%      'xy' returns: x and y components (default)
%      'sn' returns: streamwise (s) and normal (n) components
%
%   The xy components can be combined with the quiver
%   command into a gradient plot.
%
%   [Comp1,Comp2]=dpgrad(C,i,type)
%   uses the i-th field of communication file C
%

if nargin==3, % C i type
  type=lower(type);
elseif nargin==2, % C i   or C type
  if ischar(i),
    type=lower(i);
    i=[];
  else,
    type='xy';
  end;
elseif nargin==1, % C or type
  if isstruct(C), % C
    i=[];
    type='xy';
  else, % type
    type=lower(C);
    C=vs_use('lastread');
    i=[];
  end;
else,
  C=vs_use('lastread');
  type='xy';
end;

switch type,
case {'xe','xy','sn'},
otherwise,
  error('Invalid gradient type specified');
end;                     

switch vs_type(C),
case 'Delft3D-com',
  if isempty(i),
    Info=vs_disp(C,'BOTTIM',[]);
    i=Info.SizeDim;
  end;
  DP=vs_get(C,'BOTTIM',{i},'DP','quiet');
  GUU=vs_get(C,'GRID','GUU','quiet');
  GVV=vs_get(C,'GRID','GVV','quiet');
  GUU(GUU==0)=NaN;
  GVV(GVV==0)=NaN;
  KCS=vs_get(C,'KENMCNST','KCS','quiet');

%  XCOR=vs_get(C,'GRID','XCOR','quiet');
%  YCOR=vs_get(C,'GRID','YCOR','quiet');
%  CODB=vs_get(C,'TEMPOUT','CODB','quiet');
%  XCOR(CODB<0)=NaN;
%  YCOR(CODB<0)=NaN;
%  GUU=repmat(NaN,size(XCOR));
%  GUU(2:end,:)=sqrt(diff(XCOR,1,1).^2+diff(YCOR,1,1).^2);
%  GVV=repmat(NaN,size(XCOR));
%  GVV(:,2:end)=sqrt(diff(XCOR,1,2).^2+diff(YCOR,1,2).^2);
 
end;
 
dDPdeta=repmat(NaN,size(DP));
dDPdeta(2:end,:)=diff(DP,1,1)./GUU(2:end,:);
dDPdxi=repmat(NaN,size(DP));
dDPdxi(:,2:end,:)=diff(DP,1,2)./GVV(:,2:end);
dDPdeta(KCS~=1)=0;
dDPdxi(KCS~=1)=0;

dDPdxi(:,2:end)=(dDPdxi(:,2:end)+dDPdxi(:,1:end-1))/2;
dDPdeta(2:end,:)=(dDPdeta(2:end,:)+dDPdeta(1:end-1,:))/2;

if isequal(type,'xe'),
  d1=dDPdxi;
  d2=dDPdeta;
  return;
end;

alfa=vs_get(C,'GRID','ALFAS','quiet');
alfa0=vs_get(C,'GRID','ALFORI','quiet');
alfa=alfa+alfa0;
alfa=alfa*pi/180;

dDPdx=dDPdxi.*cos(alfa)-dDPdeta.*sin(alfa);
dDPdy=dDPdxi.*sin(alfa)+dDPdeta.*cos(alfa);

if isequal(type,'xy'),
  d1=dDPdx;
  d2=dDPdy;
  return;
end;

[x,y,u,v]=xyveloc;

U2=sqrt(u.^2+v.^2);
U2(U2==0)=NaN;
dDPds=(u.*dDPdx+v.*dDPdy)./U2;
dDPdn=(v.*dDPdx-u.*dDPdy)./U2;

d1=dDPds;
d2=dDPdn;
