function shrinkcolorbar(fig,factor)
%SHRINKCOLORBAR Shrink the colorbar
%
%     SHRINKCOLORBAR(FIG,FACTOR)
%     Shrink the colorbars in indicated figure
%     by the indicated factor. Default: shrink
%     the colorbars in the current figure by
%     a factor of 0.5.

% (c) 2003, WL | Delft Hydraulics
% Author: H.R.A. Jagers
% Date: July 31, 2003.

if nargin<2
  factor=0.5;
end
if nargin<1
  fig=get(0,'currentfigure');
end
CB=findall(fig,'tag','Colorbar');
for i=1:length(CB)
  pp=get(CB(i),'position');
  set(CB(i),'position',[pp(1:2)+pp(3:4)*(1-factor)/2 pp(3:4)*factor])
end
