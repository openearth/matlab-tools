function [h1,h2]=polhist(dirs,nbin)
% POLHIST Polar histogram for directional analysis
%         POLHIST(directions,nbin)
%         Default value of nbin=12.
%         Zero direction is east.
%
%         H=POLHIST(...)
%         Returns handle of patch.
%
%         [X,Y]=POLHIST(...)
%         Returns (x,y) coordinates of patch.

% (c) copyright 18-09-2000, H.R.A.Jagers
%                           bert.jagers@wldelft.nl

if nargin==1,
  nbin=12;
end;

if ~isreal(dirs(:)), % in case of complex values convert to angles
  dirs=angle(dirs(:));
end;
dirs=mod(dirs(:),2*pi);
if nbin==1,
  hst=repmat(sum(dirs),1,360);
  binbound=[1:360]*pi/180;
else,
  bincentres=((1:nbin)-.5)*2*pi/nbin;
  hst=hist(dirs,bincentres);
  refine=max(1,ceil(360/nbin));
  hst=repmat(hst,refine+1,1); hst=hst(:);
  binbound=([repmat(0:nbin-1,refine,1)+repmat((0:(refine-1))'/refine,1,nbin); 1:nbin])*2*pi/nbin;
  binbound=binbound(:);
end;

x=cos(binbound).*hst;
y=sin(binbound).*hst;
if nargout==2,
  h1=x;
  h2=y;
  return;
end;

l=polar(binbound,hst*1.03); % reserve some space around the edges
ax=get(l,'parent');
delete(l);
h=patch(x,y,1,'parent',ax);
set(h,'facecolor',[.8 .8 .8])
chax=get(ax,'children');
chpt=findobj(chax,'flat','type','patch');
chot=setdiff(chax,chpt);
set(ax,'children',[chot;chpt]);
if nargout==1,
  h1=h;
end;