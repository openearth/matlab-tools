function marker_s2p(fig)
%MARKER_S2P Convert marker surfaces to marker patches
%       MARKER_S2P(HFig)
%       Converts the surfaces without lines and patches, but
%       with markers into patches with the same properties.
%       Markers that are not part of at least of one full grid
%       cell are missing if the surface is rendered as painters.

if nargin==0
  fig=gcf;
end

set(fig,'renderer',get(fig,'renderer'))
allp=findall(fig,'type','surface','facecolor','none','linestyle','none');
for p=allp
  Quant={'marker','markerfacecolor','markeredgecolor','linewidth','markersize','cdatamapping','tag','userdata','visible','hittest','parent','edgecolor'};
  Info=get(p,Quant);
  x=get(p,'xdata'); y=get(p,'ydata'); z=get(p,'zdata'); c=get(p,'cdata');
  i=~isnan(c);
  l=patch(x(i),y(i),z(i),c(i),'facecolor','none','linestyle','none',Quant,Info);
  delete(p);
end
