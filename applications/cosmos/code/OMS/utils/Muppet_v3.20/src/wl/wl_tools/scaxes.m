function scaxes(varargin)
%SCAXES Set axes to specified scale on paper
%
%  SCAXES(Axes,Scale, ... options ...)
%  Set the specified axes to the specified scale. The
%  scale is specified in data units per cm.
%
%  The optional arguments are:
%     Keep: {Position}, Plotbox, Limits
%           determines whether to keep the position,
%           plot box, or limits equal to that of the
%           current plot.
%     HorizontalAlignment: Left, {Center}, Right
%     VerticalAlignment: Top, {Middle}, Bottom
%           determine the alignment of the new plot
%           relative to the current settings. Same
%           options apply when resizing the plot
%           (limits kept) or changing limits (position
%           or plotbox kept).

%

CellFields={'Name' 'HasDefault' 'Default' 'List' 'CaseSensitive'};
CellValues={'Axes'                0 '' '' 0
            'Scale'               0 '' '' 0
            'Keep'                1 'Position' {'Position' 'Plotbox' 'Limits'} 0
            'HorizontalAlignment' 1 'Center'   {'Left' 'Center' 'Right'} 0
            'VerticalAlignment'   1 'Middle'   {'Top' 'Middle' 'Bottom'} 0};
[X,err]=procargs(varargin,CellFields,CellValues);
if ~isempty(err), error(err); end
ax=X.Axes;
scale=X.Scale;
VerticalAlignment=X.VerticalAlignment;
HorizontalAlignment=X.HorizontalAlignment;
Keep=X.Keep;

V=get(ax,'view');
if ~all(ismember(V,[0 90 180 270]))
  error('Cannot set scale for 3D plot.')
end
XYZ='XYZ';
switch V(1)*1000+V(2)
case {000000,000180,180000,180180}
  x=1;
  y=3;
  xreverse=V(1)==180;
  yreverse=V(2)==180;
case {000090,000270,180090,180270}
  x=1;
  y=2;
  xreverse=V(1)==180;
  yreverse=(V(1)+V(2))==270;
case {090000,090180,270000,270180}
  x=2;
  y=3;
  xreverse=V(1)==270;
  yreverse=V(2)==180;
case {090090,090270,270090,270270}
  x=2;
  y=1;
  xreverse=V(1)==270;
  yreverse=(V(1)+V(2))~=360;
end
X=XYZ(x);
Y=XYZ(y);
    
[current_scale,current_plotbox]=gcsc(ax);
if any(isnan(current_scale))
  error('Cannot set scale for non-linearly scaled plot.')
end
if strcmp(lower(Keep),'position')
  set(ax,'dataaspectratiomode','auto','plotboxaspectratiomode','auto')
  [current_scale,current_plotbox]=gcsc(ax);
end
set(ax,'dataaspectratio',[1 1 1])

set(ax,[X 'limmode'],'manual',[Y 'limmode'],'manual');
pos=get(ax,'position');
xlim=get(ax,[X 'lim']);
ylim=get(ax,[Y 'lim']);
newpos=pos;
newpos(3:4)=pos(3:4).*current_scale([x y])/scale;
%
% ------ process keep option
%
switch lower(Keep),
case 'plotbox'
  reqpos=pos;
case 'position'
  reqpos=pos;
case 'limits'
  reqpos=newpos;
end
%
% ------ horizontal
%
if ~isequal(newpos(3),reqpos(3))
  dxlim=xlim(2)-xlim(1);
  extra_dxlim=dxlim*(reqpos(3)/newpos(3)-1);
  xreverse=xor(xreverse,strcmp(get(ax,[X 'dir']),'reverse'));
  switch lower(HorizontalAlignment),
  case 'left'
    % special case: xlim reverse not yet treated correctly
    xlim(2-xreverse)=xlim(2-xreverse)+(1-2*xreverse)*extra_dxlim;
  case 'center'
    xlim(1)=xlim(1)-0.5*extra_dxlim;
    xlim(2)=xlim(2)+0.5*extra_dxlim;
  case 'right'
    xlim(1+xreverse)=xlim(1+xreverse)-(1-2*xreverse)*extra_dxlim;
  end
  newpos(3)=reqpos(3);
end
switch lower(HorizontalAlignment),
case 'left'
  % nothing to do, default
case 'center'
  newpos(1)=pos(1)+0.5*(pos(3)-newpos(3));
case 'right'
  newpos(1)=pos(1)+pos(3)-newpos(3);
end
%
% ------ vertical
%
if ~isequal(newpos(4),reqpos(4))
  dylim=ylim(2)-ylim(1);
  extra_dylim=dylim*(reqpos(4)/newpos(4)-1);
  yreverse=xor(yreverse,strcmp(get(ax,[Y 'dir']),'reverse'));
  switch lower(VerticalAlignment),
  case 'top'
    ylim(1+yreverse)=ylim(1+yreverse)-(1-2*yreverse)*extra_dylim;
  case 'middle'
    ylim(1)=ylim(1)-0.5*extra_dylim;
    ylim(2)=ylim(2)+0.5*extra_dylim;
  case 'bottom'
    ylim(2-yreverse)=ylim(2-yreverse)+(1-2*yreverse)*extra_dylim;
  end
  newpos(4)=reqpos(4);
end
switch lower(VerticalAlignment),
case 'top'
  newpos(2)=pos(2)+pos(4)-newpos(4);
case 'middle'
  newpos(2)=pos(2)+0.5*(pos(4)-newpos(4));
case 'bottom'
  % nothing to do, default
end
%
% ------ apply changes
%
set(ax,'position',newpos,[X 'lim'],xlim,[Y 'lim'],ylim);